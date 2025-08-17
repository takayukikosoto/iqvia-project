import React, { useState } from 'react'
import { supabase } from '../supabaseClient'
import { quickTestLogin, createAdminUser } from '../utils/testSetup'

type AuthMode = 'login' | 'signup'

interface AuthProps {
  onAuthSuccess: () => void
}

export default function Auth({ onAuthSuccess }: AuthProps) {
  const [mode, setMode] = useState<AuthMode>('login')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [displayName, setDisplayName] = useState('')
  const [company, setCompany] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null)

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setMessage(null)

    try {
      if (mode === 'signup') {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
        })
        
        if (error) throw error
        
        if (data.user) {
          // Create profile after successful signup
          const { error: profileError } = await supabase
            .from('profiles')
            .insert([{
              user_id: data.user.id,
              display_name: displayName || email.split('@')[0],
              company: company || 'Unknown'
            }])
          
          if (profileError) {
            console.error('Profile creation error:', profileError)
          } else {
            // Auto-add to sample organization and project for testing
            try {
              const { error: orgError } = await supabase
                .from('organization_memberships')
                .insert([{
                  org_id: '11111111-1111-1111-1111-111111111111',
                  user_id: data.user.id,
                  role: 'contributor'
                }])
              
              if (orgError) {
                console.error('Org membership error:', orgError)
              }
              
              const { error: projectError } = await supabase
                .from('project_memberships')
                .insert([{
                  project_id: '22222222-2222-2222-2222-222222222222',
                  user_id: data.user.id,
                  role: 'contributor'
                }])
              
              if (projectError) {
                console.error('Project membership error:', projectError)
              }
            } catch (autoJoinError) {
              console.error('Auto-join error:', autoJoinError)
            }
          }
        }

        setMessage({ 
          type: 'success', 
          text: 'Check your email for the confirmation link!' 
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

  const handleMagicLink = async () => {
    setLoading(true)
    try {
      const { error } = await supabase.auth.signInWithOtp({ email })
      if (error) throw error
      setMessage({ type: 'success', text: 'Check your email for the login link!' })
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ 
      maxWidth: 400, 
      margin: '50px auto', 
      padding: 24, 
      border: '1px solid #ddd',
      borderRadius: 8,
      backgroundColor: '#fff'
    }}>
      <h2 style={{ textAlign: 'center', marginBottom: 24 }}>
        {mode === 'login' ? 'ログイン' : 'アカウント作成'}
      </h2>
      
      <form onSubmit={handleAuth} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
        <input
          type="email"
          placeholder="メールアドレス"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          style={{ padding: 12, border: '1px solid #ccc', borderRadius: 4 }}
        />
        
        <input
          type="password"
          placeholder="パスワード"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          style={{ padding: 12, border: '1px solid #ccc', borderRadius: 4 }}
        />
        
        {mode === 'signup' && (
          <>
            <input
              type="text"
              placeholder="表示名"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              style={{ padding: 12, border: '1px solid #ccc', borderRadius: 4 }}
            />
            <input
              type="text"
              placeholder="会社名"
              value={company}
              onChange={(e) => setCompany(e.target.value)}
              style={{ padding: 12, border: '1px solid #ccc', borderRadius: 4 }}
            />
          </>
        )}
        
        <button
          type="submit"
          disabled={loading}
          style={{
            padding: 12,
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: 4,
            cursor: loading ? 'not-allowed' : 'pointer',
            opacity: loading ? 0.7 : 1
          }}
        >
          {loading ? '処理中...' : mode === 'login' ? 'ログイン' : 'アカウント作成'}
        </button>
      </form>
      
      <div style={{ margin: '16px 0', textAlign: 'center', display: 'flex', gap: 8, justifyContent: 'center' }}>
        <button
          onClick={handleMagicLink}
          disabled={loading || !email}
          style={{
            padding: '8px 16px',
            backgroundColor: 'transparent',
            color: '#007bff',
            border: '1px solid #007bff',
            borderRadius: 4,
            cursor: loading || !email ? 'not-allowed' : 'pointer'
          }}
        >
          マジックリンクでログイン
        </button>
        
        <button
          onClick={async () => {
            setLoading(true)
            try {
              const result = await quickTestLogin()
              if (result.success) {
                onAuthSuccess()
              } else {
                setMessage({ type: 'error', text: result.error || 'テストログインに失敗' })
              }
            } catch (error: any) {
              setMessage({ type: 'error', text: error.message })
            } finally {
              setLoading(false)
            }
          }}
          disabled={loading}
          style={{
            padding: '8px 16px',
            backgroundColor: '#28a745',
            color: 'white',
            border: 'none',
            borderRadius: 4,
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          テストログイン
        </button>
        
        <button
          onClick={async () => {
            setLoading(true)
            try {
              const result = await createAdminUser()
              if (result.success) {
                setMessage({ type: 'success', text: 'admin@test.comアカウントを作成しました' })
              } else {
                setMessage({ type: 'error', text: result.error || 'Adminユーザー作成に失敗' })
              }
            } catch (error: any) {
              setMessage({ type: 'error', text: error.message })
            } finally {
              setLoading(false)
            }
          }}
          disabled={loading}
          style={{
            padding: '8px 16px',
            backgroundColor: '#dc3545',
            color: 'white',
            border: 'none',
            borderRadius: 4,
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          Adminユーザー作成
        </button>
      </div>
      
      <div style={{ textAlign: 'center', marginTop: 16 }}>
        <button
          type="button"
          onClick={() => setMode(mode === 'login' ? 'signup' : 'login')}
          style={{
            background: 'none',
            border: 'none',
            color: '#007bff',
            textDecoration: 'underline',
            cursor: 'pointer'
          }}
        >
          {mode === 'login' ? 'アカウント作成はこちら' : 'ログインはこちら'}
        </button>
      </div>
      
      {message && (
        <div style={{
          marginTop: 16,
          padding: 12,
          borderRadius: 4,
          backgroundColor: message.type === 'error' ? '#f8d7da' : '#d4edda',
          color: message.type === 'error' ? '#721c24' : '#155724',
          border: `1px solid ${message.type === 'error' ? '#f5c6cb' : '#c3e6cb'}`
        }}>
          {message.text}
        </div>
      )}
    </div>
  )
}
