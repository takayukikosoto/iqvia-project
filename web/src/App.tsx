import React from 'react'
import { useAuth } from './hooks/useAuth'
import Auth from './components/Auth'
import Tasks from './pages/Tasks'

export default function App() {
  const { user, loading, signOut } = useAuth()

  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        fontFamily: 'system-ui, sans-serif'
      }}>
        Loading...
      </div>
    )
  }

  if (!user) {
    return <Auth onAuthSuccess={() => {}} />
  }

  return (
    <div style={{ padding: 16, fontFamily: 'system-ui, sans-serif' }}>
      <header style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: 24,
        borderBottom: '1px solid #ddd',
        paddingBottom: 16
      }}>
        <h1>IQVIA × JTB タスク管理</h1>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <span style={{ color: '#666' }}>
            {user.email}
          </span>
          <button
            onClick={signOut}
            style={{
              padding: '6px 12px',
              backgroundColor: '#dc3545',
              color: 'white',
              border: 'none',
              borderRadius: 4,
              cursor: 'pointer'
            }}
          >
            ログアウト
          </button>
        </div>
      </header>
      <Tasks />
    </div>
  )
}
