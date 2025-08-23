import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface RoleDefinition {
  id: string
  role_name: string
  role_level: number
  display_name: string
  description: string
  is_active: boolean
}

export interface PermissionDefinition {
  id: string
  permission_name: string
  resource: string
  action: string
  description: string
  is_active: boolean
}

export interface UserRole {
  role: string
  roleLevel: number
  displayName: string
  permissions: string[]
}

export function useRole() {
  const [userRole, setUserRole] = useState<UserRole | null>(null)
  const [allRoles, setAllRoles] = useState<RoleDefinition[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Fetch user's current role and permissions
  const fetchUserRole = async () => {
    try {
      setLoading(true)
      setError(null)

      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        setUserRole(null)
        return
      }

      // Get user role from auth.users
      const { data: userData, error: userError } = await supabase
        .from('auth.users')
        .select(`
          role,
          role_definitions!inner (
            role_level,
            display_name
          )
        `)
        .eq('id', user.id)
        .single()

      if (userError) throw userError

      // Get user permissions
      const { data: permissions, error: permError } = await supabase
        .from('role_permissions')
        .select('permission_name')
        .eq('role_name', userData.role)
        .eq('is_granted', true)

      if (permError) throw permError

      setUserRole({
        role: userData.role,
        roleLevel: userData.role_definitions.role_level,
        displayName: userData.role_definitions.display_name,
        permissions: permissions.map(p => p.permission_name)
      })

    } catch (err: any) {
      setError(err.message)
      console.error('Error fetching user role:', err)
    } finally {
      setLoading(false)
    }
  }

  // Fetch all available roles
  const fetchAllRoles = async () => {
    try {
      const { data, error } = await supabase
        .from('role_definitions')
        .select('*')
        .eq('is_active', true)
        .order('role_level', { ascending: false })

      if (error) throw error
      setAllRoles(data || [])
    } catch (err: any) {
      console.error('Error fetching roles:', err)
    }
  }

  // Check if user has specific permission
  const hasPermission = (permission: string): boolean => {
    return userRole?.permissions.includes(permission) || false
  }

  // Check if user has resource-action permission
  const canPerform = (resource: string, action: string): boolean => {
    const permissionName = `${resource}_${action}`
    return hasPermission(permissionName)
  }

  // Check if user role level is at least the specified level
  const hasRoleLevel = (minLevel: number): boolean => {
    return (userRole?.roleLevel || 0) >= minLevel
  }

  // Get role display name by role name
  const getRoleDisplayName = (roleName: string): string => {
    const role = allRoles.find(r => r.role_name === roleName)
    return role?.display_name || roleName
  }

  // Role level constants for easy reference
  const ROLE_LEVELS = {
    ADMIN: 8,
    ORGANIZER: 7,
    SPONSOR: 6,
    AGENCY: 5,
    PRODUCTION: 4,
    SECRETARIAT: 3,
    STAFF: 2,
    VIEWER: 1
  } as const

  // Role name constants
  const ROLES = {
    ADMIN: 'admin',
    ORGANIZER: 'organizer', 
    SPONSOR: 'sponsor',
    AGENCY: 'agency',
    PRODUCTION: 'production',
    SECRETARIAT: 'secretariat',
    STAFF: 'staff',
    VIEWER: 'viewer'
  } as const

  // Convenience methods for common role checks
  const isAdmin = () => userRole?.role === ROLES.ADMIN
  const isOrganizer = () => userRole?.role === ROLES.ORGANIZER
  const isSponsor = () => userRole?.role === ROLES.SPONSOR
  const isAgency = () => userRole?.role === ROLES.AGENCY
  const isProduction = () => userRole?.role === ROLES.PRODUCTION
  const isSecretariat = () => userRole?.role === ROLES.SECRETARIAT
  const isStaff = () => userRole?.role === ROLES.STAFF
  const isViewer = () => userRole?.role === ROLES.VIEWER

  // Check if user can manage organizations
  const canManageOrganizations = () => hasRoleLevel(ROLE_LEVELS.ADMIN)
  
  // Check if user can manage projects
  const canManageProjects = () => hasRoleLevel(ROLE_LEVELS.ORGANIZER)
  
  // Check if user can create content
  const canCreateContent = () => hasPermission('content_create')
  
  // Check if user can manage budget
  const canManageBudget = () => hasPermission('budget_manage')

  useEffect(() => {
    fetchUserRole()
    fetchAllRoles()

    // Subscribe to auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
          fetchUserRole()
        } else if (event === 'SIGNED_OUT') {
          setUserRole(null)
        }
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  return {
    userRole,
    allRoles,
    loading,
    error,
    hasPermission,
    canPerform,
    hasRoleLevel,
    getRoleDisplayName,
    ROLE_LEVELS,
    ROLES,
    isAdmin,
    isOrganizer,
    isSponsor,
    isAgency,
    isProduction,
    isSecretariat,
    isStaff,
    isViewer,
    canManageOrganizations,
    canManageProjects,
    canCreateContent,
    canManageBudget,
    fetchUserRole,
    fetchAllRoles
  }
}
