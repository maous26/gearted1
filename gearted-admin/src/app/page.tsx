'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { adminAPI, isAuthenticated, logout as apiLogout } from '../lib/api'
import { 
  Users, 
  Package, 
  MessageSquare, 
  BarChart3, 
  Settings,
  Search,
  Bell,
  LogOut,
  Eye,
  Edit,
  Trash2,
  Plus,
  Filter
} from 'lucide-react'

// Custom hooks for data fetching
function useAdminStats() {
  const [stats, setStats] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await adminAPI.getStats()
        setStats(data)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch stats')
      } finally {
        setLoading(false)
      }
    }

    // Only fetch if we're on the client side and authenticated
    if (typeof window !== 'undefined' && isAuthenticated()) {
      fetchStats()
    } else {
      setLoading(false)
    }
  }, [])

  return { stats, loading, error }
}

function useUsers() {
  const [users, setUsers] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const data = await adminAPI.getUsers(1, 10)
        setUsers(data.users || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch users')
      } finally {
        setLoading(false)
      }
    }

    // Only fetch if we're on the client side and authenticated
    if (typeof window !== 'undefined' && isAuthenticated()) {
      fetchUsers()
    } else {
      setLoading(false)
    }
  }, [])

  return { users, loading, error }
}

function useListings() {
  const [listings, setListings] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchListings = async () => {
      try {
        const data = await adminAPI.getListings(1, 10)
        setListings(data.listings || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch listings')
      } finally {
        setLoading(false)
      }
    }

    // Only fetch if we're on the client side and authenticated
    if (typeof window !== 'undefined' && isAuthenticated()) {
      fetchListings()
    } else {
      setLoading(false)
    }
  }, [])

  return { listings, loading, error }
}

export default function Home() {
  const [isClient, setIsClient] = useState(false)
  const [authenticated, setAuthenticated] = useState(false)
  const router = useRouter()

  useEffect(() => {
    // Set client-side flag
    setIsClient(true)
    
    // Check authentication on client side only
    const checkAuth = () => {
      const isAuth = isAuthenticated()
      setAuthenticated(isAuth)
      
      if (!isAuth) {
        router.push('/login')
      }
    }
    
    checkAuth()
  }, [router])

  // Show loading during SSR or initial client load
  if (!isClient || !authenticated) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800 flex items-center justify-center">
        <div className="text-center">
          <div className="relative mb-6">
            <div className="animate-spin rounded-full h-16 w-16 border-4 border-blue-500/30 border-t-blue-500 mx-auto"></div>
            <div className="absolute inset-0 rounded-full bg-blue-500/10 animate-pulse"></div>
          </div>
          <h1 className="text-2xl font-bold text-white mb-4">Gearted Admin Console</h1>
          <p className="text-slate-400">
            {!isClient ? 'Chargement...' : 'Vérification de l\'authentification...'}
          </p>
        </div>
      </div>
    )
  }

  // If authenticated, show the dashboard
  return <AdminDashboard />
}

function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('dashboard')
  const [searchTerm, setSearchTerm] = useState('')
  const router = useRouter()

  const handleLogout = () => {
    apiLogout()
    router.push('/login')
  }

  // Fetch real data using custom hooks
  const { stats, loading: loadingStats, error: errorStats } = useAdminStats()
  const { users, loading: loadingUsers, error: errorUsers } = useUsers()
  const { listings, loading: loadingListings, error: errorListings } = useListings()

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800 relative overflow-hidden">
      {/* Enhanced Floating Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-gradient-to-r from-blue-500/10 to-purple-500/10 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-gradient-to-r from-purple-500/10 to-pink-500/10 rounded-full blur-3xl animate-pulse" style={{animationDelay: '2s'}}></div>
        <div className="absolute top-1/3 left-1/4 w-32 h-32 bg-gradient-to-r from-emerald-500/5 to-teal-500/5 rounded-full blur-2xl animate-pulse" style={{animationDelay: '1s'}}></div>
        <div className="absolute bottom-1/3 right-1/4 w-24 h-24 bg-gradient-to-r from-orange-500/5 to-red-500/5 rounded-full blur-2xl animate-pulse" style={{animationDelay: '3s'}}></div>
      </div>

      {/* Sidebar */}
      <div className="fixed inset-y-0 left-0 w-72 bg-gradient-to-b from-slate-800/95 to-slate-900/95 backdrop-blur-xl border-r border-slate-700/50 shadow-2xl z-50">
        <div className="flex items-center justify-center h-20 border-b border-slate-700/50 relative">
          <div className="absolute inset-0 bg-gradient-to-r from-blue-500/5 to-purple-500/5 animate-pulse"></div>
          <div className="flex items-center space-x-3 relative z-10">
            <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-xl flex items-center justify-center shadow-lg relative group">
              <span className="text-white font-bold text-lg">G</span>
              <div className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-xl blur-xl group-hover:blur-2xl transition-all duration-300"></div>
            </div>
            <div>
              <h1 className="text-xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                Gearted Admin
              </h1>
              <p className="text-xs text-slate-400">Console d'administration</p>
            </div>
          </div>
        </div>
        
        <nav className="mt-8">
          <div className="px-6 space-y-3">
            <button
              onClick={() => setActiveTab('dashboard')}
              className={`w-full flex items-center px-4 py-3 text-left rounded-xl transition-all duration-300 group ${
                activeTab === 'dashboard' 
                  ? 'bg-gradient-to-r from-blue-500/20 to-purple-500/20 text-blue-300 border border-blue-500/30 shadow-lg shadow-blue-500/25' 
                  : 'text-slate-300 hover:bg-slate-700/50 hover:text-white hover:translate-x-1'
              }`}
            >
              <BarChart3 className={`w-5 h-5 mr-3 transition-colors ${activeTab === 'dashboard' ? 'text-blue-400' : 'text-slate-400 group-hover:text-blue-400'}`} />
              <span className="font-medium">Tableau de bord</span>
              {activeTab === 'dashboard' && (
                <div className="ml-auto w-2 h-2 bg-blue-400 rounded-full shadow-lg shadow-blue-400/50"></div>
              )}
            </button>
            
            <button
              onClick={() => setActiveTab('users')}
              className={`w-full flex items-center px-4 py-3 text-left rounded-xl transition-all duration-300 group ${
                activeTab === 'users' 
                  ? 'bg-gradient-to-r from-emerald-500/20 to-teal-500/20 text-emerald-300 border border-emerald-500/30 shadow-lg shadow-emerald-500/25' 
                  : 'text-slate-300 hover:bg-slate-700/50 hover:text-white hover:translate-x-1'
              }`}
            >
              <Users className={`w-5 h-5 mr-3 transition-colors ${activeTab === 'users' ? 'text-emerald-400' : 'text-slate-400 group-hover:text-emerald-400'}`} />
              <span className="font-medium">Utilisateurs</span>
              {activeTab === 'users' && (
                <div className="ml-auto w-2 h-2 bg-emerald-400 rounded-full shadow-lg shadow-emerald-400/50"></div>
              )}
            </button>
            
            <button
              onClick={() => setActiveTab('listings')}
              className={`w-full flex items-center px-4 py-3 text-left rounded-xl transition-all duration-300 group ${
                activeTab === 'listings' 
                  ? 'bg-gradient-to-r from-orange-500/20 to-red-500/20 text-orange-300 border border-orange-500/30 shadow-lg shadow-orange-500/25' 
                  : 'text-slate-300 hover:bg-slate-700/50 hover:text-white hover:translate-x-1'
              }`}
            >
              <Package className={`w-5 h-5 mr-3 transition-colors ${activeTab === 'listings' ? 'text-orange-400' : 'text-slate-400 group-hover:text-orange-400'}`} />
              <span className="font-medium">Annonces</span>
              {activeTab === 'listings' && (
                <div className="ml-auto w-2 h-2 bg-orange-400 rounded-full shadow-lg shadow-orange-400/50"></div>
              )}
            </button>
            
            <button
              onClick={() => setActiveTab('messages')}
              className={`w-full flex items-center px-4 py-3 text-left rounded-xl transition-all duration-300 group ${
                activeTab === 'messages' 
                  ? 'bg-gradient-to-r from-purple-500/20 to-pink-500/20 text-purple-300 border border-purple-500/30 shadow-lg shadow-purple-500/25' 
                  : 'text-slate-300 hover:bg-slate-700/50 hover:text-white hover:translate-x-1'
              }`}
            >
              <MessageSquare className={`w-5 h-5 mr-3 transition-colors ${activeTab === 'messages' ? 'text-purple-400' : 'text-slate-400 group-hover:text-purple-400'}`} />
              <span className="font-medium">Messages</span>
              {activeTab === 'messages' && (
                <div className="ml-auto w-2 h-2 bg-purple-400 rounded-full shadow-lg shadow-purple-400/50"></div>
              )}
            </button>
            
            <button
              onClick={() => setActiveTab('settings')}
              className={`w-full flex items-center px-4 py-3 text-left rounded-xl transition-all duration-300 group ${
                activeTab === 'settings' 
                  ? 'bg-gradient-to-r from-slate-500/20 to-gray-500/20 text-slate-300 border border-slate-500/30 shadow-lg shadow-slate-500/25' 
                  : 'text-slate-300 hover:bg-slate-700/50 hover:text-white hover:translate-x-1'
              }`}
            >
              <Settings className={`w-5 h-5 mr-3 transition-colors ${activeTab === 'settings' ? 'text-slate-400' : 'text-slate-400 group-hover:text-slate-300'}`} />
              <span className="font-medium">Paramètres</span>
              {activeTab === 'settings' && (
                <div className="ml-auto w-2 h-2 bg-slate-400 rounded-full shadow-lg shadow-slate-400/50"></div>
              )}
            </button>
          </div>
          
          {/* User Profile Section */}
          <div className="absolute bottom-6 left-6 right-6">
            <div className="bg-slate-800/50 backdrop-blur-sm rounded-xl p-4 border border-slate-700/50">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
                  <span className="text-white font-semibold text-sm">AD</span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-white font-medium text-sm truncate">Admin</p>
                  <p className="text-slate-400 text-xs truncate">admin@gearted.com</p>
                </div>
                <button
                  onClick={handleLogout}
                  className="p-2 hover:bg-slate-700/50 rounded-lg transition-colors group"
                  title="Se déconnecter"
                >
                  <LogOut className="w-4 h-4 text-slate-400 group-hover:text-red-400 transition-colors" />
                </button>
              </div>
            </div>
          </div>
        </nav>
      </div>

      {/* Main Content */}
      <div className="ml-72">
        {/* Header */}
        <header className="bg-slate-800/50 backdrop-blur-xl border-b border-slate-700/50 shadow-lg">
          <div className="flex items-center justify-between px-8 py-5">
            <div className="flex items-center space-x-4">
              <div className="relative">
                <Search className="w-5 h-5 absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-400" />
                <input
                  type="text"
                  placeholder="Rechercher..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-12 pr-4 py-3 bg-slate-700/50 border border-slate-600/50 rounded-xl text-white placeholder-slate-400 focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 focus:bg-slate-700/70 transition-all duration-200 backdrop-blur-sm"
                />
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              <button className="relative p-3 text-slate-400 hover:text-white hover:bg-slate-700/50 rounded-xl transition-all duration-200">
                <Bell className="w-5 h-5" />
                <span className="absolute top-2 right-2 w-2 h-2 bg-gradient-to-r from-red-500 to-pink-500 rounded-full shadow-lg shadow-red-500/50"></span>
              </button>
              <button 
                onClick={handleLogout}
                className="flex items-center space-x-2 text-slate-400 hover:text-white hover:bg-slate-700/50 px-4 py-2 rounded-xl transition-all duration-200"
              >
                <LogOut className="w-5 h-5" />
                <span className="font-medium">Déconnexion</span>
              </button>
            </div>
          </div>
        </header>

        {/* Content */}
        <main className="p-8 bg-slate-900/20 min-h-screen relative">
          <div className="max-w-7xl mx-auto">
            {activeTab === 'dashboard' && (
              <div className="animate-fadeIn">
                <DashboardContent 
                  stats={stats} 
                  loading={loadingStats} 
                  error={errorStats} 
                />
              </div>
            )}
            {activeTab === 'users' && (
              <div className="animate-fadeIn">
                <UsersContent 
                  users={users} 
                  searchTerm={searchTerm}
                  loading={loadingUsers}
                  error={errorUsers}
                />
              </div>
            )}
            {activeTab === 'listings' && (
              <div className="animate-fadeIn">
                <ListingsContent 
                  listings={listings} 
                  searchTerm={searchTerm}
                  loading={loadingListings}
                  error={errorListings}
                />
              </div>
            )}
            {activeTab === 'messages' && (
              <div className="animate-fadeIn">
                <MessagesContent />
              </div>
            )}
            {activeTab === 'settings' && (
              <div className="animate-fadeIn">
                <SettingsContent />
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  )
}

function DashboardContent({ stats, loading, error }: { 
  stats: any, 
  loading: boolean, 
  error: string | null 
}) {
  if (loading) {
    return (
      <div>
        <h2 className="text-3xl font-bold text-white mb-8">Tableau de bord</h2>
        <div className="flex items-center justify-center py-16">
          <div className="relative">
            <div className="animate-spin rounded-full h-16 w-16 border-4 border-blue-500/30 border-t-blue-500"></div>
            <div className="absolute inset-0 rounded-full bg-blue-500/10 animate-pulse"></div>
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div>
        <h2 className="text-3xl font-bold text-white mb-8">Tableau de bord</h2>
        <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-6 backdrop-blur-sm">
          <p className="text-red-300">Erreur lors du chargement des statistiques: {error}</p>
        </div>
      </div>
    )
  }

  if (!stats) {
    return (
      <div>
        <h2 className="text-3xl font-bold text-white mb-8">Tableau de bord</h2>
        <div className="bg-slate-700/30 border border-slate-600/50 rounded-xl p-6 backdrop-blur-sm">
          <p className="text-slate-300">Aucune donnée disponible</p>
        </div>
      </div>
    )
  }
  return (
    <div>
      <h2 className="text-3xl font-bold text-white mb-8">Tableau de bord</h2>
      
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="bg-gradient-to-br from-blue-500/10 to-blue-600/10 backdrop-blur-sm border border-blue-500/20 p-6 rounded-xl shadow-lg hover:shadow-blue-500/25 transition-all duration-500 group cursor-pointer transform hover:scale-105 hover:-translate-y-1">
          <div className="flex items-center">
            <div className="p-3 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl shadow-lg shadow-blue-500/25 group-hover:shadow-blue-500/40 transition-all duration-500 group-hover:rotate-6">
              <Users className="w-6 h-6 text-white" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-slate-400 group-hover:text-slate-300 transition-colors duration-300">Utilisateurs totaux</p>
              <p className="text-2xl font-bold text-white group-hover:text-blue-300 transition-colors duration-300">{(stats.totalUsers || 0).toLocaleString()}</p>
            </div>
          </div>
          <div className="mt-4 flex items-center text-xs text-slate-400">
            <div className="w-2 h-2 bg-blue-500 rounded-full mr-2 animate-pulse"></div>
            En temps réel
          </div>
        </div>
        
        <div className="bg-gradient-to-br from-emerald-500/10 to-emerald-600/10 backdrop-blur-sm border border-emerald-500/20 p-6 rounded-xl shadow-lg hover:shadow-emerald-500/25 transition-all duration-500 group cursor-pointer transform hover:scale-105 hover:-translate-y-1">
          <div className="flex items-center">
            <div className="p-3 bg-gradient-to-r from-emerald-500 to-emerald-600 rounded-xl shadow-lg shadow-emerald-500/25 group-hover:shadow-emerald-500/40 transition-all duration-500 group-hover:rotate-6">
              <Package className="w-6 h-6 text-white" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-slate-400 group-hover:text-slate-300 transition-colors duration-300">Annonces totales</p>
              <p className="text-2xl font-bold text-white group-hover:text-emerald-300 transition-colors duration-300">{(stats.totalListings || 0).toLocaleString()}</p>
            </div>
          </div>
          <div className="mt-4 flex items-center text-xs text-slate-400">
            <div className="w-2 h-2 bg-emerald-500 rounded-full mr-2 animate-pulse"></div>
            Données en direct
          </div>
        </div>
        
        <div className="bg-gradient-to-br from-amber-500/10 to-amber-600/10 backdrop-blur-sm border border-amber-500/20 p-6 rounded-xl shadow-lg hover:shadow-amber-500/25 transition-all duration-500 group cursor-pointer transform hover:scale-105 hover:-translate-y-1">
          <div className="flex items-center">
            <div className="p-3 bg-gradient-to-r from-amber-500 to-amber-600 rounded-xl shadow-lg shadow-amber-500/25 group-hover:shadow-amber-500/40 transition-all duration-500 group-hover:rotate-6">
              <MessageSquare className="w-6 h-6 text-white" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-slate-400 group-hover:text-slate-300 transition-colors duration-300">Messages totaux</p>
              <p className="text-2xl font-bold text-white group-hover:text-amber-300 transition-colors duration-300">{(stats.totalMessages || 0).toLocaleString()}</p>
            </div>
          </div>
          <div className="mt-4 flex items-center text-xs text-slate-400">
            <div className="w-2 h-2 bg-amber-500 rounded-full mr-2 animate-pulse"></div>
            Mise à jour continue
          </div>
        </div>
        
        <div className="bg-gradient-to-br from-purple-500/10 to-purple-600/10 backdrop-blur-sm border border-purple-500/20 p-6 rounded-xl shadow-lg hover:shadow-purple-500/25 transition-all duration-500 group cursor-pointer transform hover:scale-105 hover:-translate-y-1">
          <div className="flex items-center">
            <div className="p-3 bg-gradient-to-r from-purple-500 to-purple-600 rounded-xl shadow-lg shadow-purple-500/25 group-hover:shadow-purple-500/40 transition-all duration-500 group-hover:rotate-6">
              <Users className="w-6 h-6 text-white" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-slate-400 group-hover:text-slate-300 transition-colors duration-300">Utilisateurs actifs</p>
              <p className="text-2xl font-bold text-white group-hover:text-purple-300 transition-colors duration-300">{(stats.activeUsers || 0).toLocaleString()}</p>
            </div>
          </div>
          <div className="mt-4 flex items-center text-xs text-slate-400">
            <div className="w-2 h-2 bg-purple-500 rounded-full mr-2 animate-pulse"></div>
            Activité en cours
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl">
        <div className="p-6 border-b border-slate-700/50">
          <h3 className="text-xl font-semibold text-white">Activité récente</h3>
        </div>
        <div className="p-6">
          <div className="space-y-4">
            <div className="flex items-center space-x-4 p-3 bg-slate-700/30 rounded-lg hover:bg-slate-700/50 transition-colors">
              <div className="w-3 h-3 bg-gradient-to-r from-emerald-400 to-emerald-500 rounded-full shadow-lg shadow-emerald-500/50"></div>
              <span className="text-sm text-slate-300 flex-1">Nouvel utilisateur inscrit: john@example.com</span>
              <span className="text-xs text-slate-400 bg-slate-600/50 px-2 py-1 rounded-md">Il y a 5 minutes</span>
            </div>
            <div className="flex items-center space-x-4 p-3 bg-slate-700/30 rounded-lg hover:bg-slate-700/50 transition-colors">
              <div className="w-3 h-3 bg-gradient-to-r from-blue-400 to-blue-500 rounded-full shadow-lg shadow-blue-500/50"></div>
              <span className="text-sm text-slate-300 flex-1">Nouvelle annonce publiée: M4A1 Daniel Defense</span>
              <span className="text-xs text-slate-400 bg-slate-600/50 px-2 py-1 rounded-md">Il y a 15 minutes</span>
            </div>
            <div className="flex items-center space-x-4 p-3 bg-slate-700/30 rounded-lg hover:bg-slate-700/50 transition-colors">
              <div className="w-3 h-3 bg-gradient-to-r from-amber-400 to-amber-500 rounded-full shadow-lg shadow-amber-500/50"></div>
              <span className="text-sm text-slate-300 flex-1">Message signalé par un utilisateur</span>
              <span className="text-xs text-slate-400 bg-slate-600/50 px-2 py-1 rounded-md">Il y a 1 heure</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function UsersContent({ users, searchTerm, loading, error }: { 
  users: any[], 
  searchTerm: string,
  loading: boolean,
  error: string | null
}) {
  if (loading) {
    return (
      <div>
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-3xl font-bold text-white">Gestion des utilisateurs</h2>
          <button className="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-6 py-3 rounded-xl hover:from-blue-600 hover:to-blue-700 flex items-center space-x-2 shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 transition-all duration-300">
            <Plus className="w-5 h-5" />
            <span className="font-medium">Nouvel utilisateur</span>
          </button>
        </div>
        <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl p-12">
          <div className="flex items-center justify-center">
            <div className="relative">
              <div className="animate-spin rounded-full h-12 w-12 border-4 border-blue-500/30 border-t-blue-500"></div>
              <div className="absolute inset-0 rounded-full bg-blue-500/10 animate-pulse"></div>
            </div>
            <span className="ml-4 text-slate-300 font-medium">Chargement des utilisateurs...</span>
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div>
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-3xl font-bold text-white">Gestion des utilisateurs</h2>
          <button className="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-6 py-3 rounded-xl hover:from-blue-600 hover:to-blue-700 flex items-center space-x-2 shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 transition-all duration-300">
            <Plus className="w-5 h-5" />
            <span className="font-medium">Nouvel utilisateur</span>
          </button>
        </div>
        <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-6 backdrop-blur-sm">
          <p className="text-red-300">Erreur lors du chargement des utilisateurs: {error}</p>
        </div>
      </div>
    )
  }

  const filteredUsers = users.filter(user => 
    (user.name || user.username || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (user.email || '').toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-3xl font-bold text-white">Gestion des utilisateurs</h2>
        <button className="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-6 py-3 rounded-xl hover:from-blue-600 hover:to-blue-700 flex items-center space-x-2 shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 transition-all duration-300">
          <Plus className="w-5 h-5" />
          <span className="font-medium">Nouvel utilisateur</span>
        </button>
      </div>

      <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl overflow-hidden">
        <table className="min-w-full divide-y divide-slate-700/50">
          <thead className="bg-slate-700/30">
            <tr>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Utilisateur
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Statut
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Date d'inscription
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-700/50">
            {filteredUsers.map((user) => (
              <tr key={user._id || user.id} className="hover:bg-slate-700/20 transition-colors">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div>
                    <div className="text-sm font-medium text-white">{user.username || user.name || 'N/A'}</div>
                    <div className="text-sm text-slate-400">{user.email || 'N/A'}</div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`inline-flex px-3 py-1 text-xs font-semibold rounded-full ${
                    user.isActive !== false 
                      ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' 
                      : 'bg-red-500/20 text-red-300 border border-red-500/30'
                  }`}>
                    {user.isActive !== false ? 'Actif' : 'Suspendu'}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-400">
                  {user.createdAt ? new Date(user.createdAt).toLocaleDateString('fr-FR') : user.joined || 'N/A'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex space-x-2">
                    <button className="p-2 text-blue-400 hover:text-blue-300 hover:bg-blue-500/20 rounded-lg transition-all duration-200">
                      <Eye className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-emerald-400 hover:text-emerald-300 hover:bg-emerald-500/20 rounded-lg transition-all duration-200">
                      <Edit className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-red-400 hover:text-red-300 hover:bg-red-500/20 rounded-lg transition-all duration-200">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

function ListingsContent({ listings, searchTerm, loading, error }: { 
  listings: any[], 
  searchTerm: string,
  loading: boolean,
  error: string | null
}) {
  if (loading) {
    return (
      <div>
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-3xl font-bold text-white">Gestion des annonces</h2>
          <div className="flex space-x-3">
            <button className="border border-slate-600/50 text-slate-300 px-6 py-3 rounded-xl hover:bg-slate-700/50 hover:text-white flex items-center space-x-2 backdrop-blur-sm transition-all duration-300">
              <Filter className="w-5 h-5" />
              <span className="font-medium">Filtrer</span>
            </button>
          </div>
        </div>
        <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl p-12">
          <div className="flex items-center justify-center">
            <div className="relative">
              <div className="animate-spin rounded-full h-12 w-12 border-4 border-orange-500/30 border-t-orange-500"></div>
              <div className="absolute inset-0 rounded-full bg-orange-500/10 animate-pulse"></div>
            </div>
            <span className="ml-4 text-slate-300 font-medium">Chargement des annonces...</span>
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div>
        <div className="flex items-center justify-between mb-8">
          <h2 className="text-3xl font-bold text-white">Gestion des annonces</h2>
          <div className="flex space-x-3">
            <button className="border border-slate-600/50 text-slate-300 px-6 py-3 rounded-xl hover:bg-slate-700/50 hover:text-white flex items-center space-x-2 backdrop-blur-sm transition-all duration-300">
              <Filter className="w-5 h-5" />
              <span className="font-medium">Filtrer</span>
            </button>
          </div>
        </div>
        <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-6 backdrop-blur-sm">
          <p className="text-red-300">Erreur lors du chargement des annonces: {error}</p>
        </div>
      </div>
    )
  }

  const filteredListings = listings.filter(listing => 
    (listing.title || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (listing.seller?.username || listing.seller?.name || listing.seller || '').toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-3xl font-bold text-white">Gestion des annonces</h2>
        <div className="flex space-x-3">
          <button className="border border-slate-600/50 text-slate-300 px-6 py-3 rounded-xl hover:bg-slate-700/50 hover:text-white flex items-center space-x-2 backdrop-blur-sm transition-all duration-300">
            <Filter className="w-5 h-5" />
            <span className="font-medium">Filtrer</span>
          </button>
        </div>
      </div>

      <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl overflow-hidden">
        <table className="min-w-full divide-y divide-slate-700/50">
          <thead className="bg-slate-700/30">
            <tr>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Annonce
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Prix
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Vendeur
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Statut
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-700/50">
            {filteredListings.map((listing) => (
              <tr key={listing._id || listing.id} className="hover:bg-slate-700/20 transition-colors">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div>
                    <div className="text-sm font-medium text-white">{listing.title || 'N/A'}</div>
                    <div className="text-sm text-slate-400">{listing.category?.name || listing.category || 'N/A'}</div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-semibold text-white">
                  {listing.price ? `${listing.price}€` : 'N/A'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-400">
                  {listing.seller?.username || listing.seller?.name || listing.seller || 'N/A'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`inline-flex px-3 py-1 text-xs font-semibold rounded-full ${
                    listing.status === 'active' 
                      ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' 
                      : listing.status === 'pending'
                      ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                      : 'bg-slate-500/20 text-slate-300 border border-slate-500/30'
                  }`}>
                    {listing.status === 'active' ? 'Actif' : 
                     listing.status === 'pending' ? 'En attente' : 
                     listing.status || 'Inconnu'}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex space-x-2">
                    <button className="p-2 text-blue-400 hover:text-blue-300 hover:bg-blue-500/20 rounded-lg transition-all duration-200">
                      <Eye className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-emerald-400 hover:text-emerald-300 hover:bg-emerald-500/20 rounded-lg transition-all duration-200">
                      <Edit className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-red-400 hover:text-red-300 hover:bg-red-500/20 rounded-lg transition-all duration-200">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

function MessagesContent() {
  return (
    <div>
      <h2 className="text-3xl font-bold text-white mb-8">Modération des messages</h2>
      <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl p-8">
        <div className="text-center">
          <MessageSquare className="w-16 h-16 text-purple-400 mx-auto mb-4" />
          <p className="text-slate-300 text-lg font-medium">Fonctionnalité en développement</p>
          <p className="text-slate-400 mt-2">La modération des messages sera bientôt disponible...</p>
        </div>
      </div>
    </div>
  )
}

function SettingsContent() {
  return (
    <div>
      <h2 className="text-3xl font-bold text-white mb-8">Paramètres de l'application</h2>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Configuration générale</h3>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">Nom de l'application</label>
              <input 
                type="text" 
                defaultValue="Gearted" 
                className="w-full px-4 py-3 bg-slate-700/50 border border-slate-600/50 rounded-xl text-white placeholder-slate-400 focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 transition-all duration-200"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">Email administrateur</label>
              <input 
                type="email" 
                defaultValue="admin@gearted.com" 
                className="w-full px-4 py-3 bg-slate-700/50 border border-slate-600/50 rounded-xl text-white placeholder-slate-400 focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 transition-all duration-200"
              />
            </div>
          </div>
        </div>
        
        <div className="bg-slate-800/30 backdrop-blur-sm border border-slate-700/50 rounded-xl shadow-xl p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Préférences système</h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-slate-300">Notifications email</span>
              <button className="relative inline-flex h-6 w-11 items-center rounded-full bg-blue-600 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                <span className="inline-block h-4 w-4 transform rounded-full bg-white transition-transform translate-x-6"></span>
              </button>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-slate-300">Mode maintenance</span>
              <button className="relative inline-flex h-6 w-11 items-center rounded-full bg-slate-600 transition-colors focus:outline-none focus:ring-2 focus:ring-slate-500 focus:ring-offset-2">
                <span className="inline-block h-4 w-4 transform rounded-full bg-white transition-transform translate-x-1"></span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
