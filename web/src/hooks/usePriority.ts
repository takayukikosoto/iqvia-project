import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface PriorityOption {
  id: string
  name: string
  label: string
  color: string
  weight: number
  is_active: boolean
}

export interface PriorityHistory {
  id: string
  task_id: string
  user_id: string
  old_priority: string | null
  new_priority: string
  changed_at: string
  reason: string | null
}

export function usePriority() {
  const [priorityOptions, setPriorityOptions] = useState<PriorityOption[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Fetch priority options from database
  const fetchPriorityOptions = async () => {
    setLoading(true)
    setError(null)

    const { data, error: fetchError } = await supabase
      .from('priority_options')
      .select('*')
      .eq('is_active', true)
      .order('weight', { ascending: true })

    if (fetchError) {
      setError(fetchError.message)
      console.error('Error fetching priority options:', fetchError)
    } else {
      setPriorityOptions(data || [])
    }
    
    setLoading(false)
  }

  // Change task priority and log history
  const changePriority = async (taskId: string, newPriority: string, reason?: string) => {
    try {
      // Get current task to know old priority
      const { data: currentTask, error: fetchError } = await supabase
        .from('tasks')
        .select('priority')
        .eq('id', taskId)
        .single()

      if (fetchError) {
        throw fetchError
      }

      // Update task priority
      const { error: updateError } = await supabase
        .from('tasks')
        .update({ 
          priority: newPriority,
          updated_at: new Date().toISOString()
        })
        .eq('id', taskId)

      if (updateError) {
        throw updateError
      }

      // The trigger will automatically log the change to priority_change_history
      return { success: true }

    } catch (error: any) {
      console.error('Error changing priority:', error)
      return { 
        success: false, 
        error: error.message || 'Failed to change priority' 
      }
    }
  }

  // Get priority history for a task
  const getPriorityHistory = async (taskId: string): Promise<PriorityHistory[]> => {
    const { data, error } = await supabase
      .from('priority_change_history')
      .select(`
        id,
        task_id,
        user_id,
        old_priority,
        new_priority,
        changed_at,
        reason
      `)
      .eq('task_id', taskId)
      .order('changed_at', { ascending: false })

    if (error) {
      console.error('Error fetching priority history:', error)
      return []
    }

    return data || []
  }

  // Get priority option by name
  const getPriorityOption = (priorityName: string): PriorityOption | undefined => {
    return priorityOptions.find(option => option.name === priorityName)
  }

  // Get priority color by name (fallback to hardcoded colors for compatibility)
  const getPriorityColor = (priorityName: string): string => {
    const option = getPriorityOption(priorityName)
    if (option) {
      return option.color
    }
    
    // Fallback colors for compatibility
    const fallbackColors: Record<string, string> = {
      low: '#28a745',    // 緑
      medium: '#007bff', // 青
      high: '#ffc107',   // 黄色
      urgent: '#dc3545'  // 赤
    }
    
    return fallbackColors[priorityName] || '#6c757d'
  }

  // Get priority label by name (fallback to hardcoded labels for compatibility)
  const getPriorityLabel = (priorityName: string): string => {
    const option = getPriorityOption(priorityName)
    if (option) {
      return option.label
    }
    
    // Fallback labels for compatibility
    const fallbackLabels: Record<string, string> = {
      low: '低',
      medium: '中',
      high: '高', 
      urgent: '緊急'
    }
    
    return fallbackLabels[priorityName] || priorityName
  }

  useEffect(() => {
    fetchPriorityOptions()
  }, [])

  return {
    priorityOptions,
    loading,
    error,
    fetchPriorityOptions,
    changePriority,
    getPriorityHistory,
    getPriorityOption,
    getPriorityColor,
    getPriorityLabel
  }
}
