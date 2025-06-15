'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { adminAPI, isAuthenticated } from '@/lib/enhanced-api'
import { Shield, Eye, EyeOff, Info } from 'lucide-react'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')
  const [debugInfo, setDebugInfo] = useState<Record<string, any> | null>(null)
  const [showDebugInfo, setShowDebugInfo] = useState(false)
  const router = useRouter()

  useEffect(() => {
    // Check if already logged in
    if (isAuthenticated()) {
      router.push('/')
    }
    
    // Check environment
    setDebugInfo({
      apiUrl: process.env.NEXT_PUBLIC_API_URL || 'Not defined',
      environment: process.env.NODE_ENV,
      buildTime: new Date().toISOString()
    })
  }, [router])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError('')

    try {
      console.log(`Attempting login for ${email}...`)
      console.log(`API URL: ${process.env.NEXT_PUBLIC_API_URL}`)
      
      const response = await adminAPI.login(email, password)
      console.log('Login successful, token received')
      localStorage.setItem('adminToken', response.token)
      router.push('/')
    } catch (err: any) {
      console.error('Login error:', err)
      setError(err?.message || 'Email ou mot de passe incorrect')
      
      // Update debug info with error details
      setDebugInfo(prevInfo => {
        if (prevInfo === null) {
          return {
            error: err?.message,
            errorType: err?.constructor?.name,
            timestamp: new Date().toISOString()
          };
        }
        return {
          ...prevInfo,
          error: err?.message,
          errorType: err?.constructor?.name,
          timestamp: new Date().toISOString()
        };
      })
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800 flex items-center justify-center p-4 relative overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-gradient-to-r from-purple-500/20 to-pink-500/20 rounded-full blur-3xl animate-pulse" style={{animationDelay: '2s'}}></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-gradient-to-r from-blue-500/10 to-purple-500/10 rounded-full blur-3xl animate-pulse" style={{animationDelay: '4s'}}></div>
      </div>

      <div className="max-w-md w-full relative z-10">
        <div className="bg-slate-800/40 backdrop-blur-xl border border-slate-700/50 rounded-2xl shadow-2xl shadow-black/20 p-8">
          {/* Header */}
          <div className="text-center mb-8">
            <div className="mx-auto w-20 h-20 bg-gradient-to-r from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mb-6 shadow-2xl shadow-blue-500/25 relative">
              <Shield className="w-10 h-10 text-white" />
              <div className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-2xl blur-xl"></div>
            </div>
            <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent mb-2">
              Gearted Admin
            </h1>
            <p className="text-slate-400 text-lg font-medium">Console d'administration</p>
            <div className="w-24 h-1 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full mx-auto mt-4"></div>
          </div>

          {/* Error Message */}
          {error && (
            <div className="mb-6 p-4 bg-red-500/10 border border-red-500/30 rounded-xl backdrop-blur-sm">
              <p className="text-red-300 text-sm font-medium">{error}</p>
            </div>
          )}

          {/* Login Form */}
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="email" className="block text-sm font-semibold text-slate-300 mb-3">
                Adresse email
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-4 bg-slate-700/50 border border-slate-600/50 rounded-xl text-white placeholder-slate-400 focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 focus:bg-slate-700/70 transition-all duration-300 backdrop-blur-sm"
                placeholder="admin@gearted.com"
                required
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-semibold text-slate-300 mb-3">
                Mot de passe
              </label>
              <div className="relative">
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-4 py-4 pr-12 bg-slate-700/50 border border-slate-600/50 rounded-xl text-white placeholder-slate-400 focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 focus:bg-slate-700/70 transition-all duration-300 backdrop-blur-sm"
                  placeholder="••••••••"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-white transition-colors duration-200"
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white py-4 px-6 rounded-xl hover:from-blue-600 hover:to-purple-700 focus:ring-2 focus:ring-blue-500/50 focus:ring-offset-2 focus:ring-offset-slate-800 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed font-semibold text-lg shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 relative overflow-hidden group"
            >
              <div className="absolute inset-0 bg-gradient-to-r from-blue-600/20 to-purple-600/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <span className="relative z-10">
                {isLoading ? (
                  <div className="flex items-center justify-center space-x-2">
                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                    <span>Connexion...</span>
                  </div>
                ) : (
                  'Se connecter'
                )}
              </span>
            </button>
          </form>

          {/* Debug Info */}
          <div className="mt-6">
            <button 
              onClick={() => setShowDebugInfo(!showDebugInfo)}
              className="flex items-center text-xs text-slate-400 hover:text-slate-300"
            >
              <Info className="w-3 h-3 mr-1" />
              {showDebugInfo ? 'Hide' : 'Show'} Debug Info
            </button>
            
            {showDebugInfo && debugInfo && (
              <div className="mt-2 p-3 bg-slate-800/60 border border-slate-700/50 rounded-lg">
                <pre className="text-xs text-slate-400 overflow-auto max-h-32">
                  {JSON.stringify(debugInfo, null, 2)}
                </pre>
              </div>
            )}
          </div>

          {/* Demo Credentials */}
          <div className="mt-8 p-6 bg-slate-700/30 border border-slate-600/30 rounded-xl backdrop-blur-sm">
            <div className="text-sm font-semibold text-slate-300 mb-3 flex items-center">
              <div className="w-2 h-2 bg-gradient-to-r from-emerald-400 to-emerald-500 rounded-full mr-2"></div>
              Identifiants de démonstration
            </div>
            <div className="space-y-2">
              <div className="text-sm text-slate-400">
                Email: <span className="bg-slate-600/50 text-blue-300 px-2 py-1 rounded-md font-mono">admin@gearted.com</span>
              </div>
              <div className="text-sm text-slate-400">
                Mot de passe: <span className="bg-slate-600/50 text-blue-300 px-2 py-1 rounded-md font-mono">admin123</span>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="mt-8 text-center">
            <div className="flex items-center justify-center space-x-2 text-slate-500">
              <div className="w-1 h-1 bg-slate-500 rounded-full"></div>
              <p className="text-xs font-medium">Console d'administration Gearted v1.0</p>
              <div className="w-1 h-1 bg-slate-500 rounded-full"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
