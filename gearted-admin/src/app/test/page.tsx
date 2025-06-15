'use client'

import { useState, useEffect } from 'react'
import { adminAPI } from '@/lib/api'

export default function TestPage() {
  type TestResults = Record<string, any> | null;
  
  const [testResults, setTestResults] = useState<TestResults>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [token, setToken] = useState<string | null>(null)
  const [adminEmail] = useState('admin@gearted.com')
  const [adminPassword] = useState('admin123')
  
  // Test direct API login
  const testApiLogin = async () => {
    setLoading(true)
    setError(null)
    
    try {
      console.log(`Testing login for ${adminEmail}...`)
      const response = await adminAPI.login(adminEmail, adminPassword)
      
      setTestResults({
        loginSuccess: true,
        token: response.token,
        user: response.user
      })
      
      setToken(response.token)
      console.log('Login successful:', response)
    } catch (err: unknown) {
      console.error('Login failed:', err)
      const errorMessage = err instanceof Error ? err.message : 'Login failed'
      setError(errorMessage)
      setTestResults({
        loginSuccess: false,
        error: errorMessage
      })
    } finally {
      setLoading(false)
    }
  }
  
  // Test admin API access
  const testAdminAccess = async () => {
    if (!token) {
      setError('No token available. Login first.')
      return
    }
    
    setLoading(true)
    setError(null)
    
    try {
      const stats = await adminAPI.getStats()
      
      setTestResults(prev => ({
        ...prev,
        adminAccessSuccess: true,
        stats
      }))
      
      console.log('Admin access successful:', stats)
    } catch (err: unknown) {
      console.error('Admin access failed:', err)
      const errorMessage = err instanceof Error ? err.message : 'Admin access failed'
      setError(errorMessage)
      setTestResults(prev => {
        if (prev === null) return {
          adminAccessSuccess: false,
          error: errorMessage
        };
        return {
          ...prev,
          adminAccessSuccess: false,
          error: errorMessage
        };
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Admin Console API Test</h1>
      
      <div className="bg-slate-800/40 backdrop-blur-xl border border-slate-700/50 rounded-lg p-6 mb-6">
        <h2 className="text-xl font-semibold mb-4">Test Admin Login</h2>
        <div className="mb-4">
          <p className="text-slate-300">Email: <span className="font-mono bg-slate-700/50 px-2 py-1 rounded">{adminEmail}</span></p>
          <p className="text-slate-300">Password: <span className="font-mono bg-slate-700/50 px-2 py-1 rounded">{"*".repeat(adminPassword.length)}</span></p>
        </div>
        <button 
          onClick={testApiLogin} 
          disabled={loading}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg disabled:opacity-50"
        >
          {loading ? 'Testing...' : 'Test Login'}
        </button>
      </div>
      
      {token && (
        <div className="bg-slate-800/40 backdrop-blur-xl border border-slate-700/50 rounded-lg p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Test Admin API Access</h2>
          <div className="mb-4">
            <p className="text-slate-300">Token: <span className="font-mono bg-slate-700/50 px-2 py-1 rounded text-xs truncate block max-w-full">{token.substring(0, 20)}...</span></p>
          </div>
          <button 
            onClick={testAdminAccess} 
            disabled={loading}
            className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg disabled:opacity-50"
          >
            {loading ? 'Testing...' : 'Test Admin API Access'}
          </button>
        </div>
      )}
      
      {error && (
        <div className="bg-red-500/10 border border-red-500/30 rounded-lg p-4 mb-6">
          <p className="text-red-300">{error}</p>
        </div>
      )}
      
      {testResults && (
        <div className="bg-slate-800/40 backdrop-blur-xl border border-slate-700/50 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">Test Results</h2>
          <pre className="bg-slate-900/50 p-4 rounded-lg overflow-auto max-h-96 text-slate-300 font-mono text-sm">
            {JSON.stringify(testResults, null, 2)}
          </pre>
        </div>
      )}
      
      <div className="mt-8 bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-4">
        <h3 className="font-semibold text-yellow-300 mb-2">Environment Information</h3>
        <p className="text-slate-300 mb-2">API URL: <code className="bg-slate-700/50 px-2 py-1 rounded">{process.env.NEXT_PUBLIC_API_URL || 'Not defined'}</code></p>
        <p className="text-slate-300">Running in: <code className="bg-slate-700/50 px-2 py-1 rounded">{process.env.NODE_ENV}</code></p>
      </div>
    </div>
  )
}
