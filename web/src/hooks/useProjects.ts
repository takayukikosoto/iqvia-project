import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface Project {
  id: string
  organization_id: string
  name: string
  start_date?: string
  end_date?: string
  status: string
  created_by?: string
  created_at: string
  updated_at?: string
  updated_by?: string
  organization?: {
    id: string
    name: string
  }
}

export interface ProjectMembership {
  id: string
  project_id: string
  user_id: string
  role: 'admin' | 'member' | 'viewer'
  created_at: string
  project?: Project
}

export function useProjects(organizationId?: string) {
  const [projects, setProjects] = useState<Project[]>([])
  const [userMemberships, setUserMemberships] = useState<ProjectMembership[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // プロジェクト一覧を取得
  const fetchProjects = async () => {
    try {
      setLoading(true)
      const { data: { session } } = await supabase.auth.getSession()
      if (!session?.user) throw new Error('User not authenticated')

      // 組織ID指定の場合は組織のプロジェクト、未指定の場合はユーザーが参加する全プロジェクト
      let query = supabase
        .from('projects')
        .select(`
          *,
          organization:organizations(id, name)
        `)
        .order('created_at', { ascending: false })

      if (organizationId) {
        // 指定組織のプロジェクト
        query = query.eq('organization_id', organizationId)
        const { data, error } = await query
        if (error) throw error
        setProjects(data || [])
      } else {
        // ユーザーが参加する全プロジェクト
        const { data: memberships, error: membershipError } = await supabase
          .from('project_memberships')
          .select(`
            *,
            project:projects(
              *,
              organization:organizations(id, name)
            )
          `)
          .eq('user_id', session.user.id)

        if (membershipError) throw membershipError

        setUserMemberships(memberships || [])
        const userProjects = (memberships || [])
          .map(membership => membership.project)
          .filter(Boolean) as Project[]
        setProjects(userProjects)
      }
    } catch (err) {
      console.error('Error fetching projects:', err)
      setError(err instanceof Error ? err.message : 'Failed to fetch projects')
    } finally {
      setLoading(false)
    }
  }

  // 新しいプロジェクトを作成
  const createProject = async (
    name: string,
    orgId: string,
    description?: string
  ): Promise<string | null> => {
    try {
      const { data: { session } } = await supabase.auth.getSession()
      if (!session?.user) throw new Error('User not authenticated')

      // 1. プロジェクトを作成（descriptionは現在のスキーマにないため除外）
      const { data: projectData, error: projectError } = await supabase
        .from('projects')
        .insert({
          organization_id: orgId,
          name,
          status: 'active',
          created_by: session.user.id
        })
        .select()
        .single()

      if (projectError) throw projectError

      // 2. 作成者を管理者として追加
      const { error: membershipError } = await supabase
        .from('project_memberships')
        .insert({
          project_id: projectData.id,
          user_id: session.user.id,
          role: 'admin' // マイグレーションでadminに変更済み
        })

      if (membershipError) throw membershipError

      // 3. リストを再取得
      await fetchProjects()
      
      return projectData.id
    } catch (err) {
      console.error('Error creating project:', err)
      setError(err instanceof Error ? err.message : 'Failed to create project')
      return null
    }
  }

  // プロジェクトを更新
  const updateProject = async (id: string, updates: Partial<Project>): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('projects')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', id)

      if (error) throw error

      await fetchProjects()
      return true
    } catch (err) {
      console.error('Error updating project:', err)
      setError(err instanceof Error ? err.message : 'Failed to update project')
      return false
    }
  }

  // プロジェクトメンバーを追加
  const addProjectMember = async (
    projectId: string,
    userId: string,
    role: 'admin' | 'member' | 'viewer' = 'member'
  ): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('project_memberships')
        .insert({
          project_id: projectId,
          user_id: userId,
          role
        })

      if (error) throw error
      return true
    } catch (err) {
      console.error('Error adding project member:', err)
      setError(err instanceof Error ? err.message : 'Failed to add project member')
      return false
    }
  }

  // プロジェクトメンバーを削除
  const removeProjectMember = async (projectId: string, userId: string): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('project_memberships')
        .delete()
        .eq('project_id', projectId)
        .eq('user_id', userId)

      if (error) throw error
      return true
    } catch (err) {
      console.error('Error removing project member:', err)
      setError(err instanceof Error ? err.message : 'Failed to remove project member')
      return false
    }
  }

  // ユーザーがプロジェクトの管理者かチェック
  const isProjectAdmin = (projectId: string): boolean => {
    return userMemberships.some(
      membership => membership.project_id === projectId && membership.role === 'admin'
    )
  }

  // プロジェクトを削除
  const deleteProject = async (id: string): Promise<boolean> => {
    try {
      const { error } = await supabase
        .from('projects')
        .delete()
        .eq('id', id)

      if (error) throw error

      await fetchProjects()
      return true
    } catch (err) {
      console.error('Error deleting project:', err)
      setError(err instanceof Error ? err.message : 'Failed to delete project')
      return false
    }
  }

  useEffect(() => {
    fetchProjects()
  }, [organizationId])

  return {
    projects,
    userMemberships,
    loading,
    error,
    createProject,
    updateProject,
    deleteProject,
    addProjectMember,
    removeProjectMember,
    isProjectAdmin,
    refetch: fetchProjects
  }
}
