// MongoDB Index Update Script
// Handles existing indexes gracefully by dropping and recreating them

const { MongoClient } = require('mongodb');
require('dotenv').config();

const updateIndexes = async () => {
  const client = new MongoClient(process.env.DB_URI);
  
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB');
    
    const db = client.db();
    
    // Function to safely drop and recreate index
    const recreateIndex = async (collection, indexSpec, options) => {
      try {
        // Try to drop existing index if it exists
        const existingIndexes = await db.collection(collection).listIndexes().toArray();
        const conflictingIndex = existingIndexes.find(idx => 
          JSON.stringify(idx.key) === JSON.stringify(indexSpec) || 
          (idx.name && idx.name === options.name)
        );
        
        if (conflictingIndex && conflictingIndex.name !== '_id_') {
          console.log(`Dropping existing index: ${conflictingIndex.name}`);
          await db.collection(collection).dropIndex(conflictingIndex.name);
        }
        
        // Create new index
        await db.collection(collection).createIndex(indexSpec, options);
        console.log(`✅ Created index: ${options.name}`);
      } catch (error) {
        if (error.code === 27 || error.codeName === 'IndexNotFound') {
          // Index doesn't exist, create it
          await db.collection(collection).createIndex(indexSpec, options);
          console.log(`✅ Created new index: ${options.name}`);
        } else {
          console.warn(`⚠️ Warning for index ${options.name}: ${error.message}`);
        }
      }
    };
    
    // Listings Collection Indexes
    console.log('\n📊 Updating listings indexes...');
    
    await recreateIndex('listings', { 
      "price": 1, 
      "category": 1, 
      "createdAt": -1 
    }, { name: "listings_price_category_date" });
    
    await recreateIndex('listings', { 
      "location.coordinates": "2dsphere" 
    }, { name: "listings_geospatial" });
    
    // Special handling for text index
    try {
      // Drop any existing text indexes
      const textIndexes = await db.collection('listings').listIndexes().toArray();
      for (const idx of textIndexes) {
        if (idx.key && (idx.key._fts === 'text' || Object.values(idx.key).includes('text'))) {
          console.log(`Dropping existing text index: ${idx.name}`);
          await db.collection('listings').dropIndex(idx.name);
        }
      }
      
      // Create new text index
      await db.collection('listings').createIndex({
        "title": "text",
        "description": "text",
        "tags": "text"
      }, { 
        name: "listings_text_search",
        weights: {
          "title": 10,
          "tags": 5,
          "description": 1
        }
      });
      console.log('✅ Created text search index');
    } catch (error) {
      console.warn(`⚠️ Warning for text index: ${error.message}`);
    }
    
    await recreateIndex('listings', {
      "status": 1,
      "isAvailable": 1,
      "createdAt": -1
    }, { name: "listings_status_availability" });
    
    await recreateIndex('listings', {
      "sellerId": 1,
      "status": 1,
      "createdAt": -1
    }, { name: "listings_seller_performance" });
    
    // Users Collection Indexes
    console.log('\n👥 Updating users indexes...');
    
    await recreateIndex('users', { 
      "email": 1 
    }, { 
      unique: true,
      name: "users_email_unique"
    });
    
    await recreateIndex('users', {
      "lastActive": -1,
      "rating": -1,
      "totalSales": -1
    }, { name: "users_activity_performance" });
    
    await recreateIndex('users', {
      "location.coordinates": "2dsphere"
    }, { name: "users_geospatial" });
    
    // Conversations Collection Indexes
    console.log('\n💬 Updating conversations indexes...');
    
    await recreateIndex('conversations', {
      "participants": 1,
      "lastMessageAt": -1
    }, { name: "conversations_participants_activity" });
    
    // Messages Collection Indexes
    console.log('\n📨 Updating messages indexes...');
    
    await recreateIndex('messages', {
      "conversationId": 1,
      "createdAt": -1
    }, { name: "messages_conversation_time" });
    
    // Reviews Collection Indexes
    console.log('\n⭐ Updating reviews indexes...');
    
    await recreateIndex('reviews', {
      "reviewerId": 1,
      "targetId": 1,
      "targetType": 1
    }, { 
      name: "reviews_reviewer_target",
      unique: true
    });
    
    await recreateIndex('reviews', {
      "rating": -1,
      "createdAt": -1
    }, { name: "reviews_rating_date" });
    
    // Analytics Collections Indexes
    console.log('\n📈 Updating analytics indexes...');
    
    await recreateIndex('user_events', {
      "userId": 1,
      "eventType": 1,
      "timestamp": -1
    }, { name: "events_user_type_time" });
    
    await recreateIndex('performance_metrics', {
      "metricType": 1,
      "date": -1
    }, { name: "metrics_type_date" });
    
    console.log('\n✅ All indexes updated successfully!');
    
    // Display final index summary
    console.log('\n📋 Final indexes summary:');
    const collections = ['listings', 'users', 'conversations', 'messages', 'reviews'];
    
    for (const collectionName of collections) {
      try {
        const indexes = await db.collection(collectionName).listIndexes().toArray();
        console.log(`\n${collectionName}:`);
        indexes.forEach(index => {
          console.log(`  - ${index.name}: ${JSON.stringify(index.key)}`);
        });
      } catch (error) {
        console.log(`\n${collectionName}: Collection not found (will be created when needed)`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error updating indexes:', error);
  } finally {
    await client.close();
    console.log('\n🔌 MongoDB connection closed');
  }
};

// Run the script
if (require.main === module) {
  updateIndexes().catch(console.error);
}

module.exports = { updateIndexes };
