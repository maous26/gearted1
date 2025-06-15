// API service to connect with Gearted backend
export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api'

export interface User {
  id: string
  name: string
  email: string
  status: 'active' | 'suspended' | 'pending'
  role: 'user' | 'admin'
  createdAt: string
  lastLogin: string
  profilePicture?: string
}

export interface Listing {
  id: string
  title: string
  description: string
  price: number
  category: string
  subcategory: string
  condition: string
  images: string[]
  seller: {
    id: string
    name: string
    email: string
  }
  status: 'active' | 'pending' | 'suspended' | 'sold'
  createdAt: string
  location: string
  views: number
}

export interface Message {
  id: string
  senderId: string
  receiverId: string
  listingId?: string
  content: string
  createdAt: string
  read: boolean
  reported: boolean
}

export interface AdminStats {
  totalUsers: number
  activeUsers: number
  totalListings: number
  activeListings: number
  totalMessages: number
  reportedContent: number
  newUsersThisMonth: number
  salesThisMonth: number
}

class AdminAPIService {
  private async makeRequest<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('API calls can only be made on the client side')
    }
    
    const token = localStorage.getItem('adminToken')
    
    try {
      console.log(`Making request to: ${API_BASE_URL}${endpoint}`);
      
      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : '',
          ...options.headers,
        },
        credentials: 'include',
      })
      
      console.log(`Response status: ${response.status}`);

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
        throw new Error(errorData.message || `API Error: ${response.status} ${response.statusText}`)
      }
      
      const data = await response.json();
      return data;
    } catch (error: unknown) {
      console.error(`API request failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
      throw error;
    }
  }

  // Authentication
  async login(email: string, password: string): Promise<{ token: string; user: User }> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      throw new Error('Login can only be performed on the client side')
    }
    
    console.log(`Attempting login for ${email} at ${API_BASE_URL}/auth/login`);
    
    try {
      // First authenticate with the regular auth endpoint
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout
      
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
      }
      
      throw error;
    }
  }

  async logout(): Promise<void> {
    // Check if we're on the client side
    if (typeof window === 'undefined') {
      return
    }
    localStorage.removeItem('adminToken')
  }

  // Dashboard Stats
  async getStats(): Promise<AdminStats> {
    return this.makeRequest('/admin/stats')
  }

  // User Management
  async getUsers(page = 1, limit = 20, search = ''): Promise<{ users: User[]; total: number }> {
    const params = new URLSearchParams({
      page: page.toString(),
      limit: limit.toString(),
      search,
    })
    return this.makeRequest(`/admin/users?${params}`)
  }

  async getUserById(id: string): Promise<User> {
    return this.makeRequest(`/admin/users/${id}`)
  }

  async updateUser(id: string, updates: Partial<User>): Promise<User> {
    return this.makeRequest(`/admin/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    })
  }

  async suspendUser(id: string, reason: string): Promise<void> {
    return this.makeRequest(`/admin/users/${id}/suspend`, {
      method: 'POST',
      body: JSON.stringify({ reason }),
    })
  }

  async deleteUser(id: string): Promise<void> {
    return this.makeRequest(`/admin/users/${id}`, {
      method: 'DELETE',
    })
  }

  // Listing Management
  async getListings(page = 1, limit = 20, search = '', status = ''): Promise<{ listings: Listing[]; total: number }> {
    const params = new URLSearchParams({
      page: page.toString(),
      limit: limit.toString(),
      search,
      status,
    })
    return this.makeRequest(`/admin/listings?${params}`)
  }

  async getListingById(id: string): Promise<Listing> {
    return this.makeRequest(`/admin/listings/${id}`)
  }

  async updateListing(id: string, updates: Partial<Listing>): Promise<Listing> {
    return this.makeRequest(`/admin/listings/${id}`, {
      method: 'PUT',
      body: JSON.stringify(updates),
    })
  }

  async approveListing(id: string): Promise<void> {
    return this.makeRequest(`/admin/listings/${id}/approve`, {
      method: 'POST',
    })
  }

  async suspendListing(id: string, reason: string): Promise<void> {
    return this.makeRequest(`/admin/listings/${id}/suspend`, {
      method: 'POST',
      body: JSON.stringify({ reason }),
    })
  }

  async deleteListing(id: string): Promise<void> {
    return this.makeRequest(`/admin/listings/${id}`, {
      method: 'DELETE',
    })
  }

  // Message Management
  async getMessages(page = 1, limit = 20, reportedOnly = false): Promise<{ messages: Message[]; total: number }> {
    const params = new URLSearchParams({
      page: page.toString(),
      limit: limit.toString(),
      reportedOnly: reportedOnly.toString(),
    })
    return this.makeRequest(`/admin/messages?${params}`)
  }

  async getMessageById(id: string): Promise<Message> {
    return this.makeRequest(`/admin/messages/${id}`)
  }

  async deleteMessage(id: string): Promise<void> {
    return this.makeRequest(`/admin/messages/${id}`, {
      method: 'DELETE',
    })
  }

  // Reports and Moderation
  async getReports(page = 1, limit = 20): Promise<{ reports: any[]; total: number }> {
    const params = new URLSearchParams({
      page: page.toString(),
      limit: limit.toString(),
    })
    return this.makeRequest(`/admin/reports?${params}`)
  }

  async resolveReport(id: string, action: 'approve' | 'remove' | 'warn'): Promise<void> {
    return this.makeRequest(`/admin/reports/${id}/resolve`, {
      method: 'POST',
      body: JSON.stringify({ action }),
    })
  }

  // System Settings
  async getSettings(): Promise<any> {
    return this.makeRequest('/admin/settings')
  }

  async updateSettings(settings: any): Promise<any> {
    return this.makeRequest('/admin/settings', {
      method: 'PUT',
      body: JSON.stringify(settings),
    })
  }

  // Analytics
  async getAnalytics(period: 'day' | 'week' | 'month' | 'year' = 'month'): Promise<any> {
    return this.makeRequest(`/admin/analytics?period=${period}`)
  }
}

export const adminAPI = new AdminAPIService()

// Authentication utilities
export const isAuthenticated = () => {
  // Check if we're on the client side
  if (typeof window === 'undefined') {
    return false // Return false during SSR
  }
  return !!localStorage.getItem('adminToken')
}

export const getCurrentUser = () => {
  // Check if we're on the client side
  if (typeof window === 'undefined') {
    return null // Return null during SSR
  }
  const userStr = localStorage.getItem('adminUser')
  return userStr ? JSON.parse(userStr) : null
}

export const logout = () => {
  // Check if we're on the client side
  if (typeof window === 'undefined') {
    return
  }
  localStorage.removeItem('adminToken')
  localStorage.removeItem('adminUser')
}

// React hooks for data fetching
export function useAdminStats() {
  // This would typically use React Query or SWR
  // For now, returning mock data
  return {
    data: {
      totalUsers: 1247,
      activeUsers: 892,
      totalListings: 3892,
      activeListings: 3241,
      totalMessages: 15678,
      reportedContent: 23,
      newUsersThisMonth: 156,
      salesThisMonth: 89,
    },
    isLoading: false,
    error: null,
  }
}

export function useUsers(page = 1, search = '') {
  // Mock data for now
  return {
    data: {
      users: [
        { id: '1', name: 'John Doe', email: 'john@example.com', status: 'active' as const, role: 'user' as const, createdAt: '2024-01-15', lastLogin: '2024-06-05' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', status: 'active' as const, role: 'user' as const, createdAt: '2024-02-20', lastLogin: '2024-06-04' },
        { id: '3', name: 'Bob Wilson', email: 'bob@example.com', status: 'suspended' as const, role: 'user' as const, createdAt: '2024-03-10', lastLogin: '2024-05-20' },
      ].filter(user => 
        user.name.toLowerCase().includes(search.toLowerCase()) ||
        user.email.toLowerCase().includes(search.toLowerCase())
      ),
      total: 3,
    },
    isLoading: false,
    error: null,
  }
}

export function useListings(page = 1, search = '', status = '') {
  // Mock data for now
  return {
    data: {
      listings: [
        { 
          id: '1', 
          title: 'M4A1 Daniel Defense', 
          price: 250, 
          category: 'Répliques',
          subcategory: 'Fusils d\'assaut',
          condition: 'Comme neuf',
          description: 'Réplique M4A1 Daniel Defense en excellent état',
          images: [],
          seller: { id: '1', name: 'John Doe', email: 'john@example.com' }, 
          status: 'active' as const,
          createdAt: '2024-06-01',
          location: 'Paris',
          views: 45
        },
        { 
          id: '2', 
          title: 'Gearbox V2 complète', 
          price: 80, 
          category: 'Gearbox',
          subcategory: 'Version 2',
          condition: 'Bon état',
          description: 'Gearbox V2 complète révisée',
          images: [],
          seller: { id: '2', name: 'Jane Smith', email: 'jane@example.com' }, 
          status: 'pending' as const,
          createdAt: '2024-06-02',
          location: 'Lyon',
          views: 23
        },
      ].filter(listing => 
        listing.title.toLowerCase().includes(search.toLowerCase()) &&
        (status === '' || listing.status === status)
      ),
      total: 2,
    },
    isLoading: false,
    error: null,
  }
}
