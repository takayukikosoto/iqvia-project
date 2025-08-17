import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { CustomStatus } from '../types'

export function useCustomStatuses(projectId: string | null) {
  const [customStatuses, setCustomStatuses] = useState<CustomStatus[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchCustomStatuses = async () => {
    if (!projectId) {
      setCustomStatuses([])
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('custom_statuses')
        .select('*')
        .eq('project_id', projectId)
        .eq('is_active', true)
        .order('order_index')

      if (error) throw error
      setCustomStatuses(data || [])
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const createCustomStatus = async (status: Omit<CustomStatus, 'id' | 'created_at' | 'updated_at' | 'created_by' | 'updated_by'>): Promise<boolean> => {
    try {
      const { data, error } = await supabase
        .from('custom_statuses')
        .insert({
          project_id: status.project_id,
          name: status.name,
          label: status.label,
          color: status.color,
          order_index: status.order_index,
          is_active: status.is_active
        })
        .select()

      if (error) throw error
      
      if (data && data[0]) {
        setCustomStatuses(prev => [...prev, data[0]].sort((a, b) => a.order_index - b.order_index))
      }
      return true
    } catch (err: any) {
      setError(err.message)
      return false
    }
  }

  const updateCustomStatus = async (id: string, updates: Partial<CustomStatus>): Promise<boolean> => {
    try {
      const { data, error } = await supabase
        .from('custom_statuses')
        .update(updates)
        .eq('id', id)
        .select()

      if (error) throw error
      
      if (data && data[0]) {
        setCustomStatuses(prev => 
          prev.map(status => 
            status.id === id ? { ...status, ...data[0] } : status
          ).sort((a, b) => a.order_index - b.order_index)
        )
      }
      return true
    } catch (err: any) {
      setError(err.message)
      return false
    }
  }

  const deleteCustomStatus = async (id: string): Promise<boolean> => {
    try {
      // ソフトデリート（is_active = false に設定）
      const { error } = await supabase
        .from('custom_statuses')
        .update({ is_active: false })
        .eq('id', id)

      if (error) throw error
      
      setCustomStatuses(prev => prev.filter(status => status.id !== id))
      return true
    } catch (err: any) {
      setError(err.message)
      return false
    }
  }

  const reorderCustomStatuses = async (reorderedStatuses: CustomStatus[]): Promise<boolean> => {
    try {
      const updates = reorderedStatuses.map((status, index) => ({
        id: status.id,
        order_index: index
      }))

      for (const update of updates) {
        const { error } = await supabase
          .from('custom_statuses')
          .update({ order_index: update.order_index })
          .eq('id', update.id)

        if (error) throw error
      }

      setCustomStatuses(reorderedStatuses)
      return true
    } catch (err: any) {
      setError(err.message)
      return false
    }
  }

  useEffect(() => {
    fetchCustomStatuses()
  }, [projectId])

  // リアルタイム更新の設定
  useEffect(() => {
    if (!projectId) return

    const channel = supabase
      .channel('custom_statuses_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'custom_statuses',
          filter: `project_id=eq.${projectId}`
        },
        () => {
          fetchCustomStatuses()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [projectId])

  return {
    customStatuses,
    loading,
    error,
    createCustomStatus,
    updateCustomStatus,
    deleteCustomStatus,
    reorderCustomStatuses,
    refetch: fetchCustomStatuses
  }
}
