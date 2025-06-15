#!/usr/bin/env node

/**
 * Complete JWT + S3 Integration Test
 * Tests the full authentication and file upload workflow
 */

const { exec } = require('child_process');
const util = require('util');
const execAsync = util.promisify(exec);

async function runCompleteIntegrationTest() {
  console.log('🧪 Complete JWT + S3 Integration Test');
  console.log('====================================\n');
  
  const testResults = {
    login: false,
    adminAccess: false,
    imageUpload: false,
    imageAccessibility: false,
    s3Connection: false
  };
  
  try {
    // Test 1: Login Authentication
    console.log('1️⃣ Testing JWT Authentication...');
    const loginCmd = `curl -s -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d '{"email":"admin@gearted.com","password":"admin123"}'`;
    const { stdout: loginResult } = await execAsync(loginCmd);
    
    if (loginResult.includes('"success":true') && loginResult.includes('"token":')) {
      console.log('✅ JWT Authentication successful');
      testResults.login = true;
      
      // Extract token
      const tokenMatch = loginResult.match(/"token":"([^"]+)"/);
      const token = tokenMatch ? tokenMatch[1] : null;
      
      if (token) {
        // Test 2: Admin Access
        console.log('2️⃣ Testing Admin Access...');
        const adminCmd = `curl -s -X GET http://localhost:3000/api/admin/users -H "Authorization: Bearer ${token}"`;
        const { stdout: adminResult } = await execAsync(adminCmd);
        
        if (adminResult.includes('"users":[') && adminResult.includes('"isAdmin":true')) {
          console.log('✅ Admin access granted');
          testResults.adminAccess = true;
        } else {
          console.log('❌ Admin access failed');
        }
        
        // Test 3: Image Upload
        console.log('3️⃣ Testing Image Upload to S3...');
        
        // Create test image
        const createImageCmd = `echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAGAWA4h4QAAAA==" | base64 -d > /tmp/test-integration.png`;
        await execAsync(createImageCmd);
        
        const uploadCmd = `curl -s -X POST http://localhost:3000/api/upload -H "Authorization: Bearer ${token}" -F "images=@/tmp/test-integration.png;type=image/png"`;
        const { stdout: uploadResult } = await execAsync(uploadCmd);
        
        if (uploadResult.includes('"success":true') && uploadResult.includes('"imageUrls":[')) {
          console.log('✅ Image upload successful');
          testResults.imageUpload = true;
          
          // Extract image URL
          const urlMatch = uploadResult.match(/"imageUrls":\\s*\\[\\s*"([^"]+)"/);
          const imageUrl = urlMatch ? urlMatch[1] : null;
          
          if (imageUrl) {
            console.log('📄 Uploaded image URL:', imageUrl);
            
            // Test 4: Image Accessibility
            console.log('4️⃣ Testing Image Accessibility...');
            const accessCmd = `curl -s -I "${imageUrl}" | head -1`;
            const { stdout: accessResult } = await execAsync(accessCmd);
            
            if (accessResult.includes('200 OK')) {
              console.log('✅ Image is publicly accessible');
              testResults.imageAccessibility = true;
            } else {
              console.log('❌ Image not accessible');
            }
          }
        } else {
          console.log('❌ Image upload failed');
          console.log('Upload result:', uploadResult.substring(0, 200));
        }
        
        // Cleanup
        await execAsync('rm -f /tmp/test-integration.png').catch(() => {});
      }
    } else {
      console.log('❌ JWT Authentication failed');
      console.log('Login result:', loginResult.substring(0, 200));
    }
    
    // Test 5: S3 Direct Connection
    console.log('5️⃣ Testing S3 Direct Connection...');
    const s3TestCmd = `node test-s3-connection.js 2>&1 | grep "S3 Connection Test Complete"`;
    try {
      const { stdout: s3Result } = await execAsync(s3TestCmd);
      if (s3Result.includes('S3 Connection Test Complete')) {
        console.log('✅ S3 direct connection successful');
        testResults.s3Connection = true;
      }
    } catch (error) {
      console.log('❌ S3 direct connection test failed');
    }
    
  } catch (error) {
    console.log('❌ Test execution error:', error.message);
  }
  
  // Summary
  console.log('\\n📊 Test Results Summary:');
  console.log('========================');
  
  const tests = [
    { name: 'JWT Authentication', result: testResults.login },
    { name: 'Admin Access Control', result: testResults.adminAccess },
    { name: 'S3 Image Upload', result: testResults.imageUpload },
    { name: 'Image Accessibility', result: testResults.imageAccessibility },
    { name: 'S3 Direct Connection', result: testResults.s3Connection }
  ];
  
  tests.forEach(test => {
    console.log(`${test.result ? '✅' : '❌'} ${test.name}`);
  });
  
  const passedTests = tests.filter(t => t.result).length;
  const totalTests = tests.length;
  
  console.log(`\\n🎯 Overall Result: ${passedTests}/${totalTests} tests passed`);
  
  if (passedTests === totalTests) {
    console.log('🎉 All systems operational! JWT + S3 integration is fully functional.');
  } else {
    console.log('⚠️  Some tests failed. Please check the individual test results above.');
  }
  
  return testResults;
}

// Run the test
runCompleteIntegrationTest().catch(console.error);
