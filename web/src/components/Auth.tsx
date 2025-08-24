import React, { useState } from 'react'
import { supabase } from '../supabaseClient'

type AuthMode = 'login' | 'signup'

interface AuthProps {
  onAuthSuccess: () => void
}

export default function Auth({ onAuthSuccess }: AuthProps) {
  const [mode, setMode] = useState<AuthMode>('login')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null)

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setMessage(null)

    try {
      if (mode === 'signup') {
        const { error } = await supabase.auth.signUp({
          email,
          password,
        })
        
        if (error) throw error
        
        setMessage({ 
          type: 'success', 
          text: 'メール確認リンクをチェックしてください！' 
        })
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        
        if (error) throw error
        onAuthSuccess()
      }
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ 
      maxWidth: 480, 
      margin: '60px auto', 
      padding: 40, 
      border: '1px solid #e0e0e0',
      borderRadius: 12,
      backgroundColor: '#fff',
      boxShadow: '0 4px 6px rgba(0, 0, 0, 0.05)'
    }}>
      <h2 style={{ 
        textAlign: 'center', 
        marginBottom: 32,
        fontSize: '28px',
        fontWeight: 600,
        color: '#333'
      }}>
        {mode === 'login' ? 'ログイン' : 'アカウント作成'}
      </h2>
      
      <form onSubmit={handleAuth} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
        <input
          type="email"
          placeholder="メールアドレス"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          autoComplete="email"
          style={{
            padding: '14px 16px',
            fontSize: '16px',
            border: '2px solid #e0e0e0',
            borderRadius: '8px',
            outline: 'none',
            transition: 'border-color 0.2s ease',
            backgroundColor: '#fafafa'
          }}
        />
        
        <input
          type="password"
          placeholder="パスワード"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          autoComplete="current-password"
          style={{
            padding: '14px 16px',
            fontSize: '16px',
            border: '2px solid #e0e0e0',
            borderRadius: '8px',
            outline: 'none',
            transition: 'border-color 0.2s ease',
            backgroundColor: '#fafafa'
          }}
        />

        <button 
          type="submit" 
          disabled={loading}
          style={{
            padding: '16px 24px',
            fontSize: '16px',
            fontWeight: 600,
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            cursor: loading ? 'not-allowed' : 'pointer',
            opacity: loading ? 0.6 : 1,
            transition: 'background-color 0.2s ease',
            marginTop: '8px'
          }}
        >
          {loading ? '処理中...' : mode === 'login' ? 'ログイン' : 'サインアップ'}
        </button>
      </form>
      
      <button 
        onClick={() => setMode(mode === 'login' ? 'signup' : 'login')}
        style={{
          background: 'none',
          border: 'none',
          color: '#007bff',
          cursor: 'pointer',
          textDecoration: 'underline',
          marginTop: 16,
          width: '100%'
        }}
      >
        {mode === 'login' ? 'アカウントをお持ちでない場合' : 'すでにアカウントをお持ちの場合'}
      </button>

      {message && (
        <div style={{
          marginTop: 16,
          padding: 12,
          borderRadius: 4,
          backgroundColor: message.type === 'success' ? '#d4edda' : '#f8d7da',
          border: `1px solid ${message.type === 'success' ? '#c3e6cb' : '#f5c6cb'}`,
          color: message.type === 'success' ? '#155724' : '#721c24'
        }}>
          {message.text}
        </div>
      )}
    </div>
  )
}
