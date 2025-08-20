import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface UserProfile {
  user_id: string
  display_name: string
  company: string
  role: string
  created_at: string
  updated_at: string
  email?: string
}

export function useUsers() {
  const { user } = useAuth()
  const [users, setUsers] = useState<UserProfile[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchUsers = async () => {
    if (!user) {
      console.log('No authenticated user, skipping user fetch')
      return
    }

    try {
      setLoading(true)
      setError(null)

      console.log('Fetching users from profiles table...')
      
      // プロファイル情報を取得（メール情報は現在のユーザーのものを使用）
      const { data: profiles, error: profileError } = await supabase
        .from('profiles')
        .select('user_id, display_name, company, role, created_at, updated_at')
        .order('created_at', { ascending: false })

      console.log('Profiles query result:', { profiles, profileError })

      if (profileError) throw profileError

      // 現在のユーザーのメールアドレスを各プロファイルに設定
      // 注意: 本来は各ユーザーのメールを取得すべきですが、権限の問題でサーバーサイドAPIが必要
      const usersWithEmails = (profiles || []).map((profile) => ({
        ...profile,
        email: profile.user_id === user.id ? user.email || 'メール不明' : `user-${profile.user_id.slice(0, 8)}@example.com`
      }))

      console.log('Users with emails:', usersWithEmails)
      setUsers(usersWithEmails)
    } catch (err: any) {
      console.error('Error fetching users:', err)
      setError(err.message || 'ユーザー取得に失敗しました')
    } finally {
      setLoading(false)
    }
  }

  const updateUserRole = async (userId: string, newRole: string) => {
    try {
      const { error } = await supabase
        .from('profiles')
        .update({ role: newRole, updated_at: new Date().toISOString() })
        .eq('user_id', userId)

      if (error) throw error

      // ローカル状態を更新
      setUsers(prev => 
        prev.map(user => 
          user.user_id === userId 
            ? { ...user, role: newRole, updated_at: new Date().toISOString() }
            : user
        )
      )

      return { success: true }
    } catch (err: any) {
      console.error('Error updating user role:', err)
      return { success: false, error: err.message }
    }
  }

  useEffect(() => {
    fetchUsers()
  }, [user])

  return {
    users,
    loading,
    error,
    refetch: fetchUsers,
    updateUserRole
  }
}
