import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { TaskLink } from '../types'

export const useTaskLinks = (taskId: string) => {
  const [links, setLinks] = useState<TaskLink[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Load task links
  const loadLinks = async () => {
    if (!taskId) return
    
    setLoading(true)
    setError(null)
    
    try {
      const { data, error } = await supabase
        .from('task_links')
        .select('*')
        .eq('task_id', taskId)
        .order('created_at', { ascending: true })
      
      if (error) throw error
      setLinks(data || [])
    } catch (err: any) {
      console.error('Load links error:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // Add new link
  const addLink = async (linkData: {
    title: string
    url: string
    description?: string
    link_type?: 'url' | 'file' | 'storage'
  }) => {
    try {
      const { data: user } = await supabase.auth.getUser()
      
      const { data, error } = await supabase
        .from('task_links')
        .insert([{
          task_id: taskId,
          title: linkData.title,
          url: linkData.url,
          description: linkData.description,
          link_type: linkData.link_type || 'url',
          created_by: user.user?.id
        }])
        .select()
        .single()
      
      if (error) throw error
      
      // Add to local state
      setLinks(prev => [...prev, data])
      return { success: true, data }
    } catch (err: any) {
      console.error('Add link error:', err)
      setError(err.message)
      return { success: false, error: err.message }
    }
  }

  // Update link
  const updateLink = async (linkId: string, updates: Partial<TaskLink>) => {
    try {
      const { data: user } = await supabase.auth.getUser()
      
      const { data, error } = await supabase
        .from('task_links')
        .update({
          ...updates,
          updated_by: user.user?.id,
          updated_at: new Date().toISOString()
        })
        .eq('id', linkId)
        .select()
        .single()
      
      if (error) throw error
      
      // Update local state
      setLinks(prev => prev.map(link => 
        link.id === linkId ? { ...link, ...data } : link
      ))
      return { success: true, data }
    } catch (err: any) {
      console.error('Update link error:', err)
      setError(err.message)
      return { success: false, error: err.message }
    }
  }

  // Delete link
  const deleteLink = async (linkId: string) => {
    try {
      const { error } = await supabase
        .from('task_links')
        .delete()
        .eq('id', linkId)
      
      if (error) throw error
      
      // Remove from local state
      setLinks(prev => prev.filter(link => link.id !== linkId))
      return { success: true }
    } catch (err: any) {
      console.error('Delete link error:', err)
      setError(err.message)
      return { success: false, error: err.message }
    }
  }

  // Load links on mount and when taskId changes
  useEffect(() => {
    loadLinks()
  }, [taskId])

  return {
    links,
    loading,
    error,
    addLink,
    updateLink,
    deleteLink,
    refreshLinks: loadLinks
  }
}
