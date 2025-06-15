// MongoDB Index Creation Script
// Run this script once to create all necessary indexes for optimal performance

const { MongoClient } = require('mongodb');
require('dotenv').config();

const createIndexes = async () => {
  const client = new MongoClient(process.env.DB_URI);
  
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB');
    
    const db = client.db();
    
    // Listings Collection Indexes
    console.log('📊 Creating listings indexes...');
    
    // Price, category, and date index for filtered searches
    await db.collection('listings').createIndex({ 
      "price": 1, 
      "category": 1, 
      "createdAt": -1 
    }, { name: "listings_price_category_date" });
    
    // Geospatial index for location-based searches
    await db.collection('listings').createIndex({ 
      "location.coordinates": "2dsphere" 
    }, { name: "listings_geospatial" });
    
    // Text index for full-text search
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
    
    // Status and availability index
    await db.collection('listings').createIndex({
      "status": 1,
      "isAvailable": 1,
      "createdAt": -1
    }, { name: "listings_status_availability" });
    
    // Seller performance index
    await db.collection('listings').createIndex({
      "sellerId": 1,
      "status": 1,
      "createdAt": -1
    }, { name: "listings_seller_performance" });
    
    // Users Collection Indexes
    console.log('👥 Creating users indexes...');
    
    // Unique email index
    await db.collection('users').createIndex({ 
      "email": 1 
    }, { 
      unique: true,
      name: "users_email_unique"
    });
    
    // User activity and performance index
    await db.collection('users').createIndex({
      "lastActive": -1,
      "rating": -1,
      "totalSales": -1
    }, { name: "users_activity_performance" });
    
    // Location-based user search
    await db.collection('users').createIndex({
      "location.coordinates": "2dsphere"
    }, { name: "users_geospatial" });
    
    // Conversations Collection Indexes
    console.log('💬 Creating conversations indexes...');
    
    // Participants and activity index
    await db.collection('conversations').createIndex({
      "participants": 1,
      "lastMessageAt": -1
    }, { name: "conversations_participants_activity" });
    
    // Messages Collection Indexes
    console.log('📨 Creating messages indexes...');
    
    // Conversation and timestamp index
    await db.collection('messages').createIndex({
      "conversationId": 1,
      "createdAt": -1
    }, { name: "messages_conversation_time" });
    
    // Reviews Collection Indexes
    console.log('⭐ Creating reviews indexes...');
    
    // Reviewer and target index
    await db.collection('reviews').createIndex({
      "reviewerId": 1,
      "targetId": 1,
      "targetType": 1
    }, { 
      name: "reviews_reviewer_target",
      unique: true // Prevent duplicate reviews
    });
    
    // Rating and date index
    await db.collection('reviews').createIndex({
      "rating": -1,
      "createdAt": -1
    }, { name: "reviews_rating_date" });
    
    // Analytics Collections Indexes
    console.log('📈 Creating analytics indexes...');
    
    // User events index
    await db.collection('user_events').createIndex({
      "userId": 1,
      "eventType": 1,
      "timestamp": -1
    }, { name: "events_user_type_time" });
    
    // Performance metrics index
    await db.collection('performance_metrics').createIndex({
      "metricType": 1,
      "date": -1
    }, { name: "metrics_type_date" });
    
    console.log('✅ All indexes created successfully!');
    
    // Display created indexes
    console.log('\n📋 Created indexes summary:');
    const collections = ['listings', 'users', 'conversations', 'messages', 'reviews'];
    
    for (const collectionName of collections) {
      const indexes = await db.collection(collectionName).listIndexes().toArray();
      console.log(`\n${collectionName}:`);
      indexes.forEach(index => {
        console.log(`  - ${index.name}: ${JSON.stringify(index.key)}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error creating indexes:', error);
  } finally {
    await client.close();
    console.log('\n🔌 MongoDB connection closed');
  }
};

// Run the script
if (require.main === module) {
  createIndexes().catch(console.error);
}

module.exports = { createIndexes };
