import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface Organization {
  id: string
  name: string
  domain?: string
  settings?: Record<string, any>
  created_at: string
  updated_at?: string
}

export interface OrganizationMembership {
  id: string
  organization_id: string
  user_id: string
  role: 'admin' | 'member'
  created_at: string
  organization?: Organization
}

export function useOrganizations() {
  const [organizations, setOrganizations] = useState<Organization[]>([])
  const [userMemberships, setUserMemberships] = useState<OrganizationMembership[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // ユーザーが参加している組織一覧を取得
  const fetchUserOrganizations = async () => {
    try {
      setLoading(true)
      const { data: user } = await supabase.auth.getUser()
      if (!user.user) throw new Error('User not authenticated')

      // ユーザーのメンバーシップと組織情報を同時取得
      const { data, error } = await supabase
        .from('organization_memberships')
        .select(`
          *,
          organization:organizations(*)
        `)
        .eq('user_id', user.user.id)

      if (error) throw error

      setUserMemberships(data || [])
      const orgs = (data || []).map(membership => membership.organization).filter(Boolean) as Organization[]
      setOrganizations(orgs)
    } catch (err) {
      console.error('Error fetching organizations:', err)
      setError(err instanceof Error ? err.message : 'Failed to fetch organizations')
    } finally {
      setLoading(false)
    }
  }

  // 新しい組織を作成
  const createOrganization = async (name: string, domain?: string): Promise<string | null> => {
    try {
      const { data: user } = await supabase.auth.getUser()
      if (!user.user) throw new Error('User not authenticated')

      // 1. 組織を作成
      const { data: orgData, error: orgError } = await supabase
        .from('organizations')
        .insert({
          name,
          domain,
          settings: {}
        })
        .select()
        .single()

      if (orgError) throw orgError

      // 2. 作成者を管理者として追加
      const { error: membershipError } = await supabase
        .from('organization_memberships')
        .insert({
          organization_id: orgData.id,
          user_id: user.user.id,
          role: 'admin'
        })

      if (membershipError) throw membershipError

      // 3. リストを再取得
      await fetchUserOrganizations()
      
      return orgData.id
    } catch (err) {
      console.error('Error creating organization:', err)
      setError(err instanceof Error ? err.message : 'Failed to create organization')
      return null
    }
  }

  // 組織を更新
  const updateOrganization = async (id: string, updates: Partial<Organization>): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('organizations')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', id)

      if (error) throw error

      await fetchUserOrganizations()
      return true
    } catch (err) {
      console.error('Error updating organization:', err)
      setError(err instanceof Error ? err.message : 'Failed to update organization')
      return false
    }
  }

  // 組織を削除
  const deleteOrganization = async (id: string): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('organizations')
        .delete()
        .eq('id', id)

      if (error) throw error

      await fetchUserOrganizations()
      return true
    } catch (err) {
      console.error('Error deleting organization:', err)
      setError(err instanceof Error ? err.message : 'Failed to delete organization')
      return false
    }
  }

  // ユーザーが組織の管理者かチェック
  const isOrgAdmin = (orgId: string): boolean => {
    return userMemberships.some(
      membership => membership.organization_id === orgId && membership.role === 'admin'
    )
  }

  useEffect(() => {
    fetchUserOrganizations()
  }, [])

  return {
    organizations,
    userMemberships,
    loading,
    error,
    createOrganization,
    updateOrganization,
    deleteOrganization,
    isOrgAdmin,
    refetch: fetchUserOrganizations
  }
}
