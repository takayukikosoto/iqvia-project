import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface UserRole {
  type: 'organization' | 'project'
  id: string
  name: string
  role: string
}

export interface UserRoleInfo {
  organizationRoles: UserRole[]
  projectRoles: UserRole[]
  highestOrgRole: string | null
  isAdmin: boolean
  isOrgManager: boolean
  isProjectManager: boolean
}

export function useUserRoles() {
  const { user } = useAuth()
  const [userRoles, setUserRoles] = useState<UserRoleInfo>({
    organizationRoles: [],
    projectRoles: [],
    highestOrgRole: null,
    isAdmin: false,
    isOrgManager: false,
    isProjectManager: false
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchUserRoles = async () => {
    if (!user) return

    try {
      setLoading(true)

      // ハイブリッド方式: app_metadata.is_adminから高速取得
      const { data: authUser, error: authError } = await supabase.auth.getUser()
      
      if (authError) throw authError

      // app_metadata.is_adminで管理者判定
      const isAdmin = authUser.user?.app_metadata?.is_admin === true
      const baseRole = isAdmin ? 'admin' : 'viewer'

      // シンプルなロール判定（管理者は全権限保有）
      const isProjectManager = isAdmin
      const isOrgManager = isAdmin

      setUserRoles({
        organizationRoles: [],
        projectRoles: [],
        highestOrgRole: baseRole,
        isAdmin,
        isOrgManager,
        isProjectManager
      })
    } catch (err) {
      console.error('Error fetching user roles:', err)
      setError(err instanceof Error ? err.message : 'Failed to fetch user roles')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (user) {
      fetchUserRoles()
    } else {
      setLoading(false)
    }
  }, [user])

  return {
    userRoles,
    loading,
    error,
    refetch: fetchUserRoles
  }
}
