// Simple test script that checks the admin console API service
// This script verifies the API service is working correctly in the browser environment

// First, let's check if admin console is properly configured
console.log('🔍 ADMIN CONSOLE FRONTEND VERIFICATION SCRIPT');

// Get configuration from environment variables
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

console.log('API Base URL:', API_BASE_URL);

// Test connection to backend
const testBackendConnection = async () => {
  try {
    console.log('Testing connection to backend...');
    const response = await fetch(`${API_BASE_URL}/health`);
    if (response.ok) {
      console.log('✅ Backend connection successful');
    } else {
      console.error('❌ Backend connection failed:', response.status, response.statusText);
    }
  } catch (error) {
    console.error('❌ Backend connection error:', error.message);
  }
};

// Test login flow
const testLoginFlow = async (email, password) => {
  try {
    console.log(`Testing login with ${email}...`);
    
    const loginResponse = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    
    if (loginResponse.ok) {
      const data = await loginResponse.json();
      console.log('✅ Login successful, token received');
      
      if (data.token) {
        // Test admin access
        console.log('Testing admin access with token...');
        const statsResponse = await fetch(`${API_BASE_URL}/admin/stats`, {
          headers: { 'Authorization': `Bearer ${data.token}` }
        });
        
        if (statsResponse.ok) {
          const statsData = await statsResponse.json();
          console.log('✅ Admin access successful');
          console.log('Stats:', statsData);
        } else {
          console.error('❌ Admin access failed:', statsResponse.status, statsResponse.statusText);
        }
      }
    } else {
      console.error('❌ Login failed:', loginResponse.status, loginResponse.statusText);
    }
  } catch (error) {
    console.error('❌ Login flow error:', error.message);
  }
};

// Only run in browser environment
if (typeof window !== 'undefined') {
  testBackendConnection();
  testLoginFlow('admin@gearted.com', 'admin123');
}

// Export functions for module usage
module.exports = { testBackendConnection, testLoginFlow };
