// Script to fix the admin console API configuration
const fs = require('fs');
const path = require('path');

// Path to API file
const apiFilePath = path.join(__dirname, 'src', 'lib', 'api.ts');

// Read file
console.log(`Reading API file: ${apiFilePath}`);
const apiContent = fs.readFileSync(apiFilePath, 'utf8');

// Fix the login method to add better error handling
const originalLoginMethod = `  // Authentication
  async login(email: string, password: string): Promise<{ token: string; user: User }> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('Login can only be performed on the client side')
    }
    
    // First authenticate with the regular auth endpoint
    const response = await fetch(\`\${API_BASE_URL}/auth/login\`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password }),
    })

    if (!response.ok) {
      throw new Error('Invalid credentials')
    }

    const data = await response.json()
    
    // Store the token and check admin access
    if (data.token) {
      localStorage.setItem('adminToken', data.token)
      
      // Verify admin access by calling admin stats
      try {
        await this.makeRequest('/admin/stats')
        localStorage.setItem('adminUser', JSON.stringify(data.user))
        return { token: data.token, user: data.user }
      } catch (error) {
        localStorage.removeItem('adminToken')
        throw new Error('Access denied. Admin privileges required.')
      }
    }
    
    throw new Error('Authentication failed')
  }`;

const fixedLoginMethod = `  // Authentication
  async login(email: string, password: string): Promise<{ token: string; user: User }> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('Login can only be performed on the client side')
    }
    
    console.log(\`Attempting login for \${email} at \${API_BASE_URL}/auth/login\`);
    
    try {
      // First authenticate with the regular auth endpoint
      const response = await fetch(\`\${API_BASE_URL}/auth/login\`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
        credentials: 'omit', // Don't send cookies to prevent CORS preflight issues
      })
      
      console.log(\`Login response status: \${response.status}\`);
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        console.error('Login failed:', errorData);
        throw new Error(errorData.message || 'Invalid credentials');
      }

      const data = await response.json();
      console.log('Login successful, received token');
      
      // Store the token and check admin access
      if (data.token) {
        localStorage.setItem('adminToken', data.token);
        
        // Verify admin access by calling admin stats
        try {
          console.log('Verifying admin access...');
          await this.makeRequest('/admin/stats');
          console.log('Admin access verified successfully');
          localStorage.setItem('adminUser', JSON.stringify(data.user));
          return { token: data.token, user: data.user };
        } catch (error: any) {
          console.error('Admin access verification failed:', error.message);
          localStorage.removeItem('adminToken');
          throw new Error('Access denied. Admin privileges required.');
        }
      }
      
      throw new Error('Authentication failed: No token received');
    } catch (error: any) {
      console.error('Login process failed:', error.message);
      throw error;
    }
  }`;

// Replace the login method
const updatedApiContent = apiContent.replace(originalLoginMethod, fixedLoginMethod);

if (apiContent === updatedApiContent) {
  console.error('Failed to find and replace the login method');
  process.exit(1);
}

// Write the updated content back to the file
fs.writeFileSync(apiFilePath, updatedApiContent);
console.log('Successfully updated the API file with improved error handling');

// Fix the makeRequest method to add better error handling
const originalMakeRequestMethod = `  private async makeRequest<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('API calls can only be made on the client side')
    }
    
    const token = localStorage.getItem('adminToken')
    
    const response = await fetch(\`\${API_BASE_URL}\${endpoint}\`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? \`Bearer \${token}\` : '',
        ...options.headers,
      },
      credentials: 'include',
    })

    if (response.status === 401) {
      localStorage.removeItem('adminToken')
      localStorage.removeItem('adminUser')
      const errorData = await response.json().catch(() => ({}))
      
      // Check if it's a JWT expiration issue
      if (errorData.message && errorData.message.includes('jwt expired')) {
        throw new Error('Your session has expired. Please login again.')
      }
      
      throw new Error('Authentication expired. Please login again.')
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.message || \`API Error: \${response.status} \${response.statusText}\`)
    }

    return response.json()`;

const fixedMakeRequestMethod = `  private async makeRequest<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('API calls can only be made on the client side')
    }
    
    const token = localStorage.getItem('adminToken')
    console.log(\`Making API request to \${API_BASE_URL}\${endpoint}\`);
    
    try {
      const response = await fetch(\`\${API_BASE_URL}\${endpoint}\`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? \`Bearer \${token}\` : '',
          ...options.headers,
        },
        credentials: 'omit', // Changed from 'include' to avoid CORS preflight issues
      })
      
      console.log(\`API response status: \${response.status}\`);

      if (response.status === 401) {
        localStorage.removeItem('adminToken')
        localStorage.removeItem('adminUser')
        const errorData = await response.json().catch(() => ({}))
        console.error('Authentication error:', errorData);
        
        // Check if it's a JWT expiration issue
        if (errorData.message && errorData.message.includes('jwt expired')) {
          throw new Error('Your session has expired. Please login again.')
        }
        
        throw new Error('Authentication expired. Please login again.')
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}))
        console.error('API error:', errorData);
        throw new Error(errorData.message || \`API Error: \${response.status} \${response.statusText}\`)
      }

      const data = await response.json();
      return data;
    } catch (error: any) {
      console.error(\`API request to \${endpoint} failed:\`, error.message);
      throw error;
    }`;

// Replace the makeRequest method
const finalApiContent = updatedApiContent.replace(originalMakeRequestMethod, fixedMakeRequestMethod);

if (updatedApiContent === finalApiContent) {
  console.error('Failed to find and replace the makeRequest method');
  process.exit(1);
}

// Write the final updated content back to the file
fs.writeFileSync(apiFilePath, finalApiContent);
console.log('Successfully updated both login and makeRequest methods with improved error handling');
