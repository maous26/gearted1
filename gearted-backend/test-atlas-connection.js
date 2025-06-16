#!/usr/bin/env node

/**
 * Script de test de connexion MongoDB Atlas
 */

const { MongoClient } = require('mongodb');
require('dotenv').config();

async function testAtlasConnection() {
  console.log('🔧 Test de connexion MongoDB Atlas');
  console.log('==================================\n');

  const uri = process.env.DB_URI;
  
  if (!uri) {
    console.log('❌ DB_URI non définie dans les variables d\'environnement');
    console.log('Vérifiez votre fichier .env ou vos variables d\'environnement sur Render');
    return;
  }

  // Masquer le mot de passe pour la sécurité
  const maskedUri = uri.replace(/(:)([^:@]+)(@)/, '$1***$3');
  console.log('🔗 URI de connexion:', maskedUri);
  
  const client = new MongoClient(uri);
  
  try {
    console.log('⏳ Tentative de connexion...');
    
    // Connexion avec timeout
    await client.connect();
    console.log('✅ Connexion établie avec succès !');
    
    // Test d'une opération simple
    const db = client.db();
    const collections = await db.listCollections().toArray();
    console.log(`📊 Base de données: ${db.databaseName}`);
    console.log(`📚 Nombre de collections: ${collections.length}`);
    
    if (collections.length > 0) {
      console.log('📋 Collections disponibles:');
      collections.forEach(collection => {
        console.log(`   - ${collection.name}`);
      });
    }
    
  } catch (error) {
    console.log('❌ Erreur de connexion:');
    console.log(`   ${error.message}`);
    
    if (error.message.includes('IP address')) {
      console.log('\n💡 Solutions possibles:');
      console.log('1. Allez sur https://cloud.mongodb.com');
      console.log('2. Naviguez vers "Network Access"');
      console.log('3. Cliquez sur "Add IP Address"');
      console.log('4. Sélectionnez "Allow Access from Anywhere" (0.0.0.0/0)');
      console.log('5. Ou ajoutez les IP spécifiques de Render');
    }
    
    if (error.message.includes('authentication')) {
      console.log('\n💡 Vérifiez:');
      console.log('1. Le nom d\'utilisateur et mot de passe dans votre URI');
      console.log('2. Que l\'utilisateur a les permissions nécessaires');
    }
    
  } finally {
    await client.close();
    console.log('\n🔚 Test terminé');
  }
}

testAtlasConnection().catch(console.error);
