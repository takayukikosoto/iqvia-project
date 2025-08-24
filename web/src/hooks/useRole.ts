import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface UserRole {
  role: string
  roleLevel: number
  displayName: string
}

export interface UserWithRole {
  user_id: string
  email: string
  role_name: string
  created_at: string
  last_sign_in_at: string | null
}

// Simple role mapping (matches hybrid system)
const ROLE_MAPPING = {
  admin: { level: 8, displayName: '管理者' },
  organizer: { level: 7, displayName: '主催者' },
  sponsor: { level: 6, displayName: 'スポンサー' },
  agency: { level: 5, displayName: '代理店' },
  production: { level: 4, displayName: '制作会社' },
  secretariat: { level: 3, displayName: '事務局' },
  staff: { level: 2, displayName: 'スタッフ' },
  viewer: { level: 1, displayName: '閲覧者' }
}

export function useRole() {
  const { user } = useAuth()
  const [userRole, setUserRole] = useState<UserRole | null>(null)
  const [allUsers, setAllUsers] = useState<UserWithRole[]>([])
  const [loading, setLoading] = useState(true)
  const [usersLoading, setUsersLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Get current user role from JWT app_metadata
  const fetchUserRole = async () => {
    try {
      setLoading(true)
      setError(null)
      
      if (!user) {
        setUserRole(null)
        setLoading(false)
        return
      }

      // Get role from JWT app_metadata (hybrid system)
      const role = user.app_metadata?.role || 'viewer'
      const roleInfo = ROLE_MAPPING[role as keyof typeof ROLE_MAPPING] || ROLE_MAPPING.viewer
      
      setUserRole({
        role: role,
        roleLevel: roleInfo.level,
        displayName: roleInfo.displayName
      })
    } catch (err: any) {
      setError(err.message)
      setUserRole({
        role: 'viewer',
        roleLevel: 1,
        displayName: '閲覧者'
      })
    } finally {
      setLoading(false)
    }
  }

  // Check if user has specific permission based on role
  const hasPermission = (permission: string): boolean => {
    if (!userRole) return false
    
    const role = userRole.role
    
    // Simple permission mapping based on role
    switch (permission) {
      case 'users_manage':
        return role === 'admin'
      case 'organizations_create':
      case 'organizations_update':
      case 'organizations_delete':
        return ['admin', 'organizer'].includes(role)
      case 'projects_create':
      case 'projects_update':
        return ['admin', 'organizer', 'agency', 'production'].includes(role)
      case 'tasks_create':
      case 'tasks_update':
        return ['admin', 'organizer', 'agency', 'production', 'secretariat', 'staff'].includes(role)
      case 'events_create':
      case 'events_update':
        return ['admin', 'organizer', 'secretariat'].includes(role)
      default:
        return false
    }
  }

  // Fetch all users with roles (for admin)
  const fetchAllUsers = async () => {
    try {
      setUsersLoading(true)
      
      // Get users - Note: direct auth.users access may need RLS policy updates
      const { data: users, error: usersError } = await supabase
        .from('profiles')
        .select('user_id, display_name, company, created_at, updated_at')
      
      if (usersError) throw usersError
      
      // Map to expected format - in real implementation would join with roles
      const usersWithRoles = users.map(user => ({
        user_id: user.user_id,
        email: user.display_name || 'Unknown',
        role_name: 'viewer', // Default for now
        created_at: user.created_at,
        last_sign_in_at: null
      }))
      
      setAllUsers(usersWithRoles)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setUsersLoading(false)
    }
  }

  // Update user role (admin only)
  const updateUserRole = async (userId: string, newRole: string) => {
    try {
      if (!hasPermission('users_manage')) {
        throw new Error('Permission denied')
      }
      
      // Use roles.assign_role function from hybrid system
      const { error } = await supabase.rpc('assign_role', {
        target_user_id: userId,
        new_role: newRole
      })
      
      if (error) throw error
      
      // Refresh users list
      await fetchAllUsers()
    } catch (err: any) {
      setError(err.message)
      throw err
    }
  }

  useEffect(() => {
    fetchUserRole()
  }, [user])

  return {
    userRole,
    loading,
    error,
    hasPermission,
    allUsers,
    usersLoading,
    fetchAllUsers,
    updateUserRole,
    refreshRole: fetchUserRole
  }
}
