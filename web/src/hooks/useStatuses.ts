import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface StatusOption {
  id: string
  name: string
  label: string
  color: string
  weight: number
  is_active: boolean
}

export interface StatusHistory {
  id: string
  task_id: string
  user_id: string
  old_status: string | null
  new_status: string
  changed_at: string
  reason: string | null
}

export function useStatuses() {
  const [statusOptions, setStatusOptions] = useState<StatusOption[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Fetch status options from database
  const fetchStatusOptions = async () => {
    setLoading(true)
    setError(null)

    const { data, error: fetchError } = await supabase
      .from('status_options')
      .select('*')
      .eq('is_active', true)
      .order('weight', { ascending: true })

    if (fetchError) {
      setError(fetchError.message)
      console.error('Error fetching status options:', fetchError)
    } else {
      setStatusOptions(data || [])
    }
    
    setLoading(false)
  }

  // Change task status and log history
  const changeStatus = async (taskId: string, newStatus: string, reason?: string) => {
    try {
      // Get current task to know old status
      const { data: currentTask, error: fetchError } = await supabase
        .from('tasks')
        .select('status, status_option_id')
        .eq('id', taskId)
        .single()

      if (fetchError) {
        throw fetchError
      }

      // Get the status_option_id for the new status
      const statusOption = statusOptions.find(opt => opt.name === newStatus)
      if (!statusOption) {
        throw new Error(`Status option not found: ${newStatus}`)
      }

      // Update task status
      const { error: updateError } = await supabase
        .from('tasks')
        .update({ 
          status: newStatus,
          status_option_id: statusOption.id,
          updated_at: new Date().toISOString()
        })
        .eq('id', taskId)

      if (updateError) {
        throw updateError
      }

      // The trigger will automatically log the change to status_change_history
      return { success: true }

    } catch (error: any) {
      console.error('Error changing status:', error)
      return { 
        success: false, 
        error: error.message || 'Failed to change status' 
      }
    }
  }

  // Get status history for a task
  const getStatusHistory = async (taskId: string): Promise<StatusHistory[]> => {
    const { data, error } = await supabase
      .from('status_change_history')
      .select(`
        id,
        task_id,
        user_id,
        old_status,
        new_status,
        changed_at,
        reason
      `)
      .eq('task_id', taskId)
      .order('changed_at', { ascending: false })

    if (error) {
      console.error('Error fetching status history:', error)
      return []
    }

    return data || []
  }

  // Get status option by name
  const getStatusOption = (statusName: string): StatusOption | undefined => {
    return statusOptions.find(option => option.name === statusName)
  }

  // Get status color by name (fallback to hardcoded colors for compatibility)
  const getStatusColor = (statusName: string): string => {
    const option = getStatusOption(statusName)
    if (option) {
      return option.color
    }
    
    // Fallback colors for compatibility
    const fallbackColors: Record<string, string> = {
      todo: '#6c757d',
      review: '#ffc107',
      done: '#28a745',
      resolved: '#17a2b8',
      completed: '#6f42c1'
    }
    
    return fallbackColors[statusName] || '#6c757d'
  }

  // Get status label by name (fallback to hardcoded labels for compatibility)
  const getStatusLabel = (statusName: string): string => {
    const option = getStatusOption(statusName)
    if (option) {
      return option.label
    }
    
    // Fallback labels for compatibility
    const fallbackLabels: Record<string, string> = {
      todo: '未着手',
      review: 'レビュー中',
      done: '作業完了',
      resolved: '対応済み',
      completed: '完了済み'
    }
    
    return fallbackLabels[statusName] || statusName
  }

  // Get board statuses (excluding 'completed' which has separate page)
  const getBoardStatuses = (): StatusOption[] => {
    return statusOptions.filter(status => status.name !== 'completed')
  }

  useEffect(() => {
    fetchStatusOptions()
  }, [])

  return {
    statusOptions,
    loading,
    error,
    fetchStatusOptions,
    changeStatus,
    getStatusHistory,
    getStatusOption,
    getStatusColor,
    getStatusLabel,
    getBoardStatuses
  }
}
