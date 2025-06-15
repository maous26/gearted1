#!/usr/bin/env node

/**
 * Simple MongoDB Atlas Configuration Helper
 */

const fs = require('fs');
const path = require('path');

console.log('🔧 MongoDB Atlas Connection Helper');
console.log('==================================\n');

console.log('Please provide your MongoDB Atlas connection string.');
console.log('You can find this in your MongoDB Atlas dashboard:\n');
console.log('1. Go to your Atlas dashboard');
console.log('2. Click "Connect" on your cluster');
console.log('3. Choose "Connect your application"');
console.log('4. Copy the connection string\n');

console.log('Example format:');
console.log('mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/gearted?retryWrites=true&w=majority\n');

// Check if .env file exists
const envPath = path.join(__dirname, '.env');
if (!fs.existsSync(envPath)) {
  console.log('❌ .env file not found!');
  console.log('Please make sure you have a .env file in your project root.');
  process.exit(1);
}

console.log('📝 To configure your Atlas connection:');
console.log('1. Open your .env file');
console.log('2. Find the line that starts with DB_URI=');
console.log('3. Replace it with your Atlas connection string');
console.log('4. Make sure to replace <username>, <password>, and <cluster-url> with your actual values\n');

console.log('Current .env configuration:');
const envContent = fs.readFileSync(envPath, 'utf8');
const dbUriLine = envContent.split('\n').find(line => line.startsWith('DB_URI='));

if (dbUriLine) {
  // Mask password for security
  const maskedUri = dbUriLine.replace(/(:)([^:@]+)(@)/, '$1***$3');
  console.log('Current DB_URI:', maskedUri);
} else {
  console.log('❌ DB_URI not found in .env file');
}

console.log('\n🧪 After updating your .env file, test the connection with:');
console.log('node test-atlas-connection.js\n');

console.log('💡 Tips:');
console.log('- Make sure your IP is whitelisted in Atlas');
console.log('- Verify your database user has proper permissions');
console.log('- URL-encode special characters in your password');
console.log('- Use the database name "gearted" in your connection string\n');

console.log('🆘 Need help? Check ATLAS_SETUP_GUIDE.md for detailed instructions.');
