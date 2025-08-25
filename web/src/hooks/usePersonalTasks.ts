import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface PersonalTask {
  id: string
  title: string
  description?: string
  task_type: 'personal' | 'project' | 'team' | 'company'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  status: string
  due_at?: string
  assigned_to?: string
  created_by?: string
  project_id?: string
  estimated_hours?: number
  actual_hours?: number
  created_at: string
  updated_at?: string
  // 関連情報
  assigned_to_name?: string
  project_name?: string
  task_type_label?: string
}

export interface CreatePersonalTaskData {
  title: string
  description?: string
  task_type?: 'personal' | 'project' | 'team' | 'company'
  priority?: 'low' | 'medium' | 'high' | 'urgent'
  due_at?: string
  estimated_hours?: number
  project_id?: string
}

export interface UpdatePersonalTaskData {
  title?: string
  description?: string
  priority?: 'low' | 'medium' | 'high' | 'urgent'
  status?: string
  due_at?: string
  estimated_hours?: number
  actual_hours?: number
}

export function usePersonalTasks() {
  const { user } = useAuth()
  const [tasks, setTasks] = useState<PersonalTask[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchPersonalTasks = async () => {
    if (!user) {
      setTasks([])
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      setError(null)

      // 担当または作成した全てのタスクを取得
      const { data, error: fetchError } = await supabase
        .from('tasks')
        .select(`
          *,
          profiles!tasks_assigned_to_fkey(display_name),
          projects(name)
        `)
        .or(`assigned_to.eq.${user.id},created_by.eq.${user.id}`)
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError

      const formattedTasks = (data || []).map(task => ({
        ...task,
        assigned_to_name: task.profiles?.display_name,
        project_name: task.projects?.name,
        task_type_label: getTaskTypeLabel(task.task_type || 'project')
      }))

      setTasks(formattedTasks)
    } catch (err: any) {
      console.error('Error fetching personal tasks:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // タスク作成
  const createPersonalTask = async (taskData: CreatePersonalTaskData) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const newTask = {
        title: taskData.title,
        description: taskData.description,
        task_type: taskData.task_type || 'personal',
        priority: taskData.priority || 'medium',
        status: 'todo',
        due_at: taskData.due_at,
        estimated_hours: taskData.estimated_hours,
        project_id: taskData.project_id,
        assigned_to: user.id,
        created_by: user.id
      }

      const { data, error } = await supabase
        .from('tasks')
        .insert(newTask)
        .select(`
          *,
          profiles!tasks_assigned_to_fkey(display_name),
          projects(name)
        `)
        .single()

      if (error) throw error

      const formattedTask = {
        ...data,
        assigned_to_name: data.profiles?.display_name,
        project_name: data.projects?.name,
        task_type_label: getTaskTypeLabel(data.task_type || 'project')
      }

      setTasks(prev => [formattedTask, ...prev])
      return { success: true, data: formattedTask }
    } catch (err: any) {
      console.error('Error creating personal task:', err)
      return { success: false, error: err.message }
    }
  }

  // タスク更新
  const updatePersonalTask = async (id: string, updates: UpdatePersonalTaskData) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const updateData = {
        ...updates,
        updated_at: new Date().toISOString()
      }

      const { data, error } = await supabase
        .from('tasks')
        .update(updateData)
        .eq('id', id)
        .or(`assigned_to.eq.${user.id},created_by.eq.${user.id}`)
        .select(`
          *,
          profiles!tasks_assigned_to_fkey(display_name),
          projects(name)
        `)
        .single()

      if (error) throw error

      const formattedTask = {
        ...data,
        assigned_to_name: data.profiles?.display_name,
        project_name: data.projects?.name,
        task_type_label: getTaskTypeLabel(data.task_type || 'project')
      }

      setTasks(prev => prev.map(task => 
        task.id === id ? formattedTask : task
      ))

      return { success: true, data: formattedTask }
    } catch (err: any) {
      console.error('Error updating personal task:', err)
      return { success: false, error: err.message }
    }
  }

  // タスク削除
  const deletePersonalTask = async (id: string) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const { error } = await supabase
        .from('tasks')
        .delete()
        .eq('id', id)
        .or(`assigned_to.eq.${user.id},created_by.eq.${user.id}`)

      if (error) throw error

      setTasks(prev => prev.filter(task => task.id !== id))
      return { success: true }
    } catch (err: any) {
      console.error('Error deleting personal task:', err)
      return { success: false, error: err.message }
    }
  }

  // タスク完了切り替え
  const toggleTaskCompletion = async (id: string) => {
    const task = tasks.find(t => t.id === id)
    if (!task) return { success: false, error: 'Task not found' }

    const newStatus = task.status === 'completed' ? 'todo' : 'completed'
    return updatePersonalTask(id, { status: newStatus })
  }

  // 個人タスクのみ取得
  const getPersonalTasks = () => {
    return tasks.filter(task => task.task_type === 'personal')
  }

  // プロジェクトタスクのみ取得
  const getProjectTasks = () => {
    return tasks.filter(task => task.task_type === 'project')
  }

  // チーム・全社タスク取得
  const getSharedTasks = () => {
    return tasks.filter(task => ['team', 'company'].includes(task.task_type))
  }

  // 今日期日のタスク
  const getTodayTasks = () => {
    const today = new Date().toISOString().split('T')[0]
    return tasks.filter(task => task.due_at?.startsWith(today))
  }

  // 今週期日のタスク
  const getWeekTasks = () => {
    const today = new Date()
    const weekEnd = new Date(today)
    weekEnd.setDate(weekEnd.getDate() + 7)
    
    return tasks.filter(task => {
      if (!task.due_at) return false
      const dueDate = new Date(task.due_at)
      return dueDate >= today && dueDate <= weekEnd
    })
  }

  // 優先度別タスク
  const getTasksByPriority = (priority: 'low' | 'medium' | 'high' | 'urgent') => {
    return tasks.filter(task => task.priority === priority)
  }

  // ステータス別タスク
  const getTasksByStatus = (status: string) => {
    return tasks.filter(task => task.status === status)
  }

  // タスク統計
  const getTaskStats = () => {
    const personal = getPersonalTasks()
    const project = getProjectTasks()
    const shared = getSharedTasks()
    const today = getTodayTasks()
    const week = getWeekTasks()
    
    return {
      total: tasks.length,
      personal: personal.length,
      project: project.length,
      shared: shared.length,
      today: today.length,
      week: week.length,
      completed: tasks.filter(t => t.status === 'completed').length,
      inProgress: tasks.filter(t => t.status === 'in_progress').length,
      urgent: getTasksByPriority('urgent').length,
      high: getTasksByPriority('high').length
    }
  }

  useEffect(() => {
    fetchPersonalTasks()
  }, [user])

  return {
    tasks,
    loading,
    error,
    createPersonalTask,
    updatePersonalTask,
    deletePersonalTask,
    toggleTaskCompletion,
    getPersonalTasks,
    getProjectTasks,
    getSharedTasks,
    getTodayTasks,
    getWeekTasks,
    getTasksByPriority,
    getTasksByStatus,
    getTaskStats,
    refetch: fetchPersonalTasks
  }
}

// ヘルパー関数
function getTaskTypeLabel(taskType: string): string {
  const labels: Record<string, string> = {
    personal: '個人',
    project: 'プロジェクト',
    team: 'チーム',
    company: '全社'
  }
  return labels[taskType] || 'プロジェクト'
}

// 優先度ラベル
export function getPriorityLabel(priority: string): string {
  const labels: Record<string, string> = {
    urgent: '緊急',
    high: '高',
    medium: '中',
    low: '低'
  }
  return labels[priority] || '中'
}

// 優先度色
export function getPriorityColor(priority: string): string {
  const colors: Record<string, string> = {
    urgent: '#dc2626',
    high: '#ea580c',
    medium: '#0891b2',
    low: '#059669'
  }
  return colors[priority] || '#0891b2'
}

// タスクタイプ色
export function getTaskTypeColor(taskType: string): string {
  const colors: Record<string, string> = {
    personal: '#8b5cf6',
    project: '#3b82f6',
    team: '#10b981',
    company: '#f59e0b'
  }
  return colors[taskType] || '#3b82f6'
}
