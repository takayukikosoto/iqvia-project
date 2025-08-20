import React, { useState } from 'react'
import { supabase } from '../supabaseClient'
import { quickTestLogin, createAdminUser, createUserWithRole } from '../utils/testSetup'

type AuthMode = 'login' | 'signup' | 'role-signup'

interface AuthProps {
  onAuthSuccess: () => void
}

export default function Auth({ onAuthSuccess }: AuthProps) {
  const [mode, setMode] = useState<AuthMode>('login')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [displayName, setDisplayName] = useState('')
  const [company, setCompany] = useState('')
  const [selectedRole, setSelectedRole] = useState<string>('admin')
  const [adminPassword, setAdminPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null)

  const roles = [
    { value: 'admin', label: '管理者', description: '全権限' },
    { value: 'org_manager', label: '組織マネージャー', description: '組織管理権限' },
    { value: 'project_manager', label: 'プロジェクトマネージャー', description: 'プロジェクト管理権限' },
    { value: 'contributor', label: '貢献者', description: '編集権限' },
    { value: 'viewer', label: '閲覧者', description: '閲覧のみ' }
  ]

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setMessage(null)

    try {
      if (mode === 'role-signup') {
        // 管理者パスワードの確認
        if (adminPassword !== 'admin123') {
          throw new Error('管理者パスワードが正しくありません')
        }
        
        const result = await createUserWithRole(email, password, selectedRole)
        if (result.success) {
          setMessage({ 
            type: 'success', 
            text: `${roles.find(r => r.value === selectedRole)?.label}アカウントを作成しました` 
          })
          onAuthSuccess()
        } else {
          throw new Error(result.error || 'ユーザー作成に失敗しました')
        }
      } else if (mode === 'signup') {
        const { data, error } = await supabase.auth.signUp({
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
        {mode === 'login' ? 'ログイン' : mode === 'role-signup' ? 'ロール指定アカウント作成' : 'アカウント作成'}
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
        
        {mode === 'role-signup' && (
          <>
            <div style={{ marginBottom: 12 }}>
              <label style={{ display: 'block', marginBottom: 8, fontWeight: 'bold' }}>
                ロール選択
              </label>
              <select
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value)}
                style={{ 
                  width: '100%', 
                  padding: 12, 
                  border: '1px solid #ccc', 
                  borderRadius: 4,
                  backgroundColor: 'white'
                }}
              >
                {roles.map(role => (
                  <option key={role.value} value={role.value}>
                    {role.label} - {role.description}
                  </option>
                ))}
              </select>
            </div>
            
            <input
              type="password"
              placeholder="管理者パスワード (admin123)"
              value={adminPassword}
              onChange={(e) => setAdminPassword(e.target.value)}
              required
              style={{ padding: 12, border: '1px solid #ccc', borderRadius: 4 }}
            />
          </>
        )}

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
          {loading ? '処理中...' : 
           mode === 'login' ? 'ログイン' : 
           mode === 'role-signup' ? 'ロール指定で作成' : 'アカウント作成'}
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
      
      <div style={{ textAlign: 'center', marginTop: 16, display: 'flex', gap: 8, justifyContent: 'center', flexWrap: 'wrap' }}>
        <button
          type="button"
          onClick={() => setMode('login')}
          style={{
            background: mode === 'login' ? '#007bff' : 'none',
            border: '1px solid #007bff',
            color: mode === 'login' ? 'white' : '#007bff',
            padding: '4px 8px',
            borderRadius: 4,
            cursor: 'pointer',
            fontSize: '12px'
          }}
        >
          ログイン
        </button>
        <button
          type="button"
          onClick={() => setMode('signup')}
          style={{
            background: mode === 'signup' ? '#007bff' : 'none',
            border: '1px solid #007bff',
            color: mode === 'signup' ? 'white' : '#007bff',
            padding: '4px 8px',
            borderRadius: 4,
            cursor: 'pointer',
            fontSize: '12px'
          }}
        >
          通常登録
        </button>
        <button
          type="button"
          onClick={() => setMode('role-signup')}
          style={{
            background: mode === 'role-signup' ? '#28a745' : 'none',
            border: '1px solid #28a745',
            color: mode === 'role-signup' ? 'white' : '#28a745',
            padding: '4px 8px',
            borderRadius: 4,
            cursor: 'pointer',
            fontSize: '12px'
          }}
        >
          ロール指定登録
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
