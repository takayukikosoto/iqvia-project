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

      // profilesテーブルからロールを取得
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role')
        .eq('user_id', user.id)
        .single()

      if (profileError && profileError.code !== 'PGRST116') {
        throw profileError
      }

      const baseRole = profile?.role || 'viewer'

      // シンプルなロール判定
      const isAdmin = baseRole === 'admin'
      const isProjectManager = baseRole === 'project_manager'
      const isOrgManager = baseRole === 'org_manager'

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
