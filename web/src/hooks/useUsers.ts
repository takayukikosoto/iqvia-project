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
  is_admin?: boolean
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

      console.log('Fetching users with hybrid admin system...')
      
      // プロファイル情報を取得（roleカラムは削除済み）
      const { data: profiles, error: profileError } = await supabase
        .from('profiles')
        .select('user_id, display_name, company, created_at, updated_at')
        .order('created_at', { ascending: false })

      console.log('Profiles query result:', { profiles, profileError })

      if (profileError) throw profileError

      // 管理者情報をRPC経由で取得
      const { data: admins, error: adminsError } = await supabase
        .rpc('get_current_admins')

      if (adminsError) {
        console.warn('Could not fetch admin data:', adminsError)
      }

      const adminUserIds = new Set(admins?.map((a: any) => a.user_id) || [])

      // ユーザー情報にロール情報を追加
      const usersWithEmails = (profiles || []).map((profile) => ({
        ...profile,
        role: adminUserIds.has(profile.user_id) ? 'admin' : 'viewer',
        is_admin: adminUserIds.has(profile.user_id),
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
      if (newRole === 'admin') {
        // 管理者権限付与
        const { error } = await supabase.rpc('grant_admin_privileges', {
          target_user_id: userId
        })
        if (error) throw error
      } else {
        // 管理者権限剥奪
        const { error } = await supabase.rpc('revoke_admin_privileges', {
          target_user_id: userId
        })
        if (error) throw error
      }

      // ローカル状態を更新
      setUsers(prev => 
        prev.map(user => 
          user.user_id === userId 
            ? { ...user, role: newRole, is_admin: newRole === 'admin', updated_at: new Date().toISOString() }
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
