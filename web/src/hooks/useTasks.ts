import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface Task {
  id: string
  title: string
  description?: string
  status: 'todo' | 'review' | 'done' | 'resolved' | 'completed'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  project_id: string
  assigned_to?: string
  created_at: string
  updated_at: string
  due_at?: string
  project?: {
    id: string
    name: string
  }
}

export interface Project {
  id: string
  name: string
  organization_id: string
  created_at: string
}

export function useTasks() {
  const [tasks, setTasks] = useState<Task[]>([])
  const [projects, setProjects] = useState<Project[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // タスクを取得
  const fetchTasks = async () => {
    try {
      setLoading(true)
      setError(null)

      // タスクとプロジェクト情報を一緒に取得
      const { data: tasksData, error: tasksError } = await supabase
        .from('tasks')
        .select(`
          *,
          project:projects (
            id,
            name
          )
        `)
        .order('created_at', { ascending: false })

      if (tasksError) {
        console.error('Tasks fetch error:', tasksError)
        setError(tasksError.message)
        return
      }

      setTasks(tasksData || [])
    } catch (err) {
      console.error('Unexpected error:', err)
      setError('予期しないエラーが発生しました')
    } finally {
      setLoading(false)
    }
  }

  // プロジェクトを取得
  const fetchProjects = async () => {
    try {
      const { data: projectsData, error: projectsError } = await supabase
        .from('projects')
        .select('*')
        .order('name', { ascending: true })

      if (projectsError) {
        console.error('Projects fetch error:', projectsError)
        return
      }

      setProjects(projectsData || [])
    } catch (err) {
      console.error('Projects fetch error:', err)
    }
  }

  // タスクのステータス更新
  const updateTaskStatus = async (taskId: string, status: Task['status']) => {
    try {
      const { error: updateError } = await supabase
        .from('tasks')
        .update({ 
          status,
          updated_at: new Date().toISOString()
        })
        .eq('id', taskId)

      if (updateError) {
        console.error('Status update error:', updateError)
        setError(updateError.message)
        return false
      }

      // ローカル状態を更新
      setTasks(prevTasks => 
        prevTasks.map(task => 
          task.id === taskId 
            ? { ...task, status, updated_at: new Date().toISOString() }
            : task
        )
      )

      return true
    } catch (err) {
      console.error('Unexpected status update error:', err)
      setError('ステータス更新中にエラーが発生しました')
      return false
    }
  }

  // タスクの優先度更新
  const updateTaskPriority = async (taskId: string, priority: Task['priority']) => {
    try {
      const { error: updateError } = await supabase
        .from('tasks')
        .update({ 
          priority,
          updated_at: new Date().toISOString()
        })
        .eq('id', taskId)

      if (updateError) {
        console.error('Priority update error:', updateError)
        setError(updateError.message)
        return false
      }

      // ローカル状態を更新
      setTasks(prevTasks => 
        prevTasks.map(task => 
          task.id === taskId 
            ? { ...task, priority, updated_at: new Date().toISOString() }
            : task
        )
      )

      return true
    } catch (err) {
      console.error('Unexpected priority update error:', err)
      setError('優先度更新中にエラーが発生しました')
      return false
    }
  }

  // タスク作成
  const createTask = async (taskData: {
    title: string
    description?: string
    status?: Task['status']
    priority?: Task['priority']
    project_id: string
    assigned_to?: string
    due_at?: string
  }) => {
    try {
      const { data: newTask, error: createError } = await supabase
        .from('tasks')
        .insert([{
          ...taskData,
          status: taskData.status || 'todo',
          priority: taskData.priority || 'medium'
        }])
        .select(`
          *,
          project:projects (
            id,
            name
          )
        `)
        .single()

      if (createError) {
        console.error('Task creation error:', createError)
        setError(createError.message)
        return null
      }

      // ローカル状態を更新
      setTasks(prevTasks => [newTask, ...prevTasks])
      return newTask
    } catch (err) {
      console.error('Unexpected task creation error:', err)
      setError('タスク作成中にエラーが発生しました')
      return null
    }
  }

  // 初期化時にデータを取得
  useEffect(() => {
    fetchTasks()
    fetchProjects()
  }, [])

  return {
    tasks,
    projects,
    loading,
    error,
    updateTaskStatus,
    updateTaskPriority,
    createTask,
    refetch: fetchTasks
  }
}
