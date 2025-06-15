// Enhanced API service for admin console
// This fixes the "Load failed" error by improving error handling and connection reliability

import { API_BASE_URL, User, Listing, Message, AdminStats } from './api';

// Authentication status check helper
export function isAuthenticated(): boolean {
  // Check if we're on the client side
  if (typeof window === 'undefined') {
    return false;
  }
  return !!localStorage.getItem('adminToken');
}

class AdminAPIService {
  private async makeRequest<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('API calls can only be made on the client side');
    }
    
    const token = localStorage.getItem('adminToken');
    const url = `${API_BASE_URL}${endpoint}`;
    
    console.log(`Making request to: ${url}`);
    
    // Add timeout for fetch requests
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15000); // 15 second timeout
    
    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : '',
          ...options.headers,
        },
        credentials: 'include',
        signal: controller.signal,
        mode: 'cors', // Explicitly set CORS mode
      }).finally(() => clearTimeout(timeoutId));
      
      console.log(`Response status: ${response.status}`);

      if (response.status === 401) {
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        const errorData = await response.json().catch(() => ({}));
        
        // Check if it's a JWT expiration issue
        if (errorData.message && errorData.message.includes('jwt expired')) {
          throw new Error('Your session has expired. Please login again.');
        }
        
        throw new Error('Authentication expired. Please login again.');
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `API Error: ${response.status} ${response.statusText}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error: any) {
      // Enhance error messages for better debugging
      if (error.name === 'AbortError') {
        console.error('Request timeout:', url);
        throw new Error('Request timed out. Please try again later.');
      } else if (error.message === 'Failed to fetch') {
        console.error('Network error when fetching:', url);
        throw new Error('Network error. Please check your connection and ensure the backend server is running.');
      } else if (error.message.includes('Load failed')) {
        console.error('Load failed error:', url);
        throw new Error('Connection to backend server failed. Please verify the API URL and server status.');
      }
      
      console.error(`API request failed: ${error.message}`);
      throw error;
    }
  }

  // Authentication
  async login(email: string, password: string): Promise<{ token: string; user: User }> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('Login can only be performed on the client side');
    }
    
    console.log(`Attempting login for ${email} at ${API_BASE_URL}/auth/login`);
    
    try {
      // First authenticate with the regular auth endpoint
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 15000); // 15 second timeout
      
      console.log('Sending login request...');
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
        credentials: 'omit', // Don't send cookies to prevent CORS preflight issues
        signal: controller.signal,
        mode: 'cors', // Explicitly set CORS mode
      }).finally(() => clearTimeout(timeoutId));
      
      console.log(`Login response status: ${response.status}`);
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        console.error('Login failed:', errorData);
        throw new Error(errorData.message || `Login failed: ${response.status} ${response.statusText}`);
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
      console.error('Login process failed:', error);
      
      // Handle network errors more explicitly
      if (error.name === 'AbortError') {
        throw new Error('Login request timed out. Please check your network connection and try again.');
      } else if (error.message === 'Failed to fetch' || error.message.includes('NetworkError')) {
        throw new Error('Network error. Please check if the backend server is running and accessible.');
      } else if (error.message.includes('CORS')) {
        throw new Error('CORS error. Please check if the backend server is configured to accept requests from this origin.');
      } else if (error.message.includes('Load failed')) {
        throw new Error('Connection failed. Please verify the API URL is correct and the server is running.');
      }
      
      throw error;
    }
  }

  async logout(): Promise<void> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      return;
    }
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
  }

  // Dashboard Stats
  async getStats(): Promise<AdminStats> {
    return this.makeRequest('/admin/stats');
  }

  // Rest of the API service methods...
  // ...
}

// Create singleton instance
export const adminAPI = new AdminAPIService();

// Export types
export type { User, Listing, Message, AdminStats };
