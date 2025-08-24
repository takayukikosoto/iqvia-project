import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface PersonalTodo {
  id: string
  user_id: string
  title: string
  description?: string
  completed: boolean
  priority: number // 1: Low, 2: Medium, 3: High
  due_date?: string
  week_start?: string
  created_at: string
  completed_at?: string
}

export interface CreateTodoData {
  title: string
  description?: string
  priority?: number
  due_date?: string
}

export interface UpdateTodoData {
  title?: string
  description?: string
  completed?: boolean
  priority?: number
  due_date?: string
  completed_at?: string | null
}

export function usePersonalTodos() {
  const { user } = useAuth()
  const [todos, setTodos] = useState<PersonalTodo[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // 今週の開始日（月曜日）を取得
  const getWeekStart = (date = new Date()) => {
    const startOfWeek = new Date(date)
    const day = startOfWeek.getDay()
    const diff = startOfWeek.getDate() - day + (day === 0 ? -6 : 1) // Monday
    startOfWeek.setDate(diff)
    startOfWeek.setHours(0, 0, 0, 0)
    return startOfWeek.toISOString().split('T')[0]
  }

  const fetchTodos = async () => {
    if (!user) {
      setTodos([])
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('personal_todos')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

      if (fetchError) {
        throw fetchError
      }

      setTodos(data || [])
    } catch (err: any) {
      console.error('Error fetching personal todos:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // 今週のTODOを取得
  const getThisWeekTodos = () => {
    const weekStart = getWeekStart()
    return todos.filter(todo => 
      todo.week_start === weekStart || 
      (todo.due_date && todo.due_date >= weekStart && todo.due_date < getWeekStart(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)))
    )
  }

  // TODOの統計を取得
  const getTodoStats = () => {
    const thisWeekTodos = getThisWeekTodos()
    const completedCount = thisWeekTodos.filter(todo => todo.completed).length
    const totalCount = thisWeekTodos.length
    const highPriorityCount = thisWeekTodos.filter(todo => todo.priority === 3 && !todo.completed).length
    
    return {
      total: totalCount,
      completed: completedCount,
      remaining: totalCount - completedCount,
      highPriority: highPriorityCount,
      completionRate: totalCount > 0 ? Math.round((completedCount / totalCount) * 100) : 0
    }
  }

  // TODO作成
  const createTodo = async (todoData: CreateTodoData) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const newTodo = {
        user_id: user.id,
        title: todoData.title,
        description: todoData.description || null,
        priority: todoData.priority || 2,
        due_date: todoData.due_date || null,
        week_start: getWeekStart(),
        completed: false
      }

      const { data, error } = await supabase
        .from('personal_todos')
        .insert(newTodo)
        .select()
        .single()

      if (error) throw error

      setTodos(prev => [data, ...prev])
      return { success: true, data }
    } catch (err: any) {
      console.error('Error creating todo:', err)
      return { success: false, error: err.message }
    }
  }

  // TODO更新
  const updateTodo = async (id: string, updates: UpdateTodoData) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const updateData = { ...updates }
      
      // 完了状態が変更された場合、completed_atを更新
      if (updates.completed !== undefined) {
        updateData.completed_at = updates.completed ? new Date().toISOString() : null
      }

      const { data, error } = await supabase
        .from('personal_todos')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', user.id)
        .select()
        .single()

      if (error) throw error

      setTodos(prev => prev.map(todo => todo.id === id ? data : todo))
      return { success: true, data }
    } catch (err: any) {
      console.error('Error updating todo:', err)
      return { success: false, error: err.message }
    }
  }

  // TODO削除
  const deleteTodo = async (id: string) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const { error } = await supabase
        .from('personal_todos')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id)

      if (error) throw error

      setTodos(prev => prev.filter(todo => todo.id !== id))
      return { success: true }
    } catch (err: any) {
      console.error('Error deleting todo:', err)
      return { success: false, error: err.message }
    }
  }

  // TODO完了切り替え
  const toggleComplete = async (id: string) => {
    const todo = todos.find(t => t.id === id)
    if (!todo) return { success: false, error: 'Todo not found' }

    return await updateTodo(id, { completed: !todo.completed })
  }

  // 優先度のラベル取得
  const getPriorityLabel = (priority: number) => {
    switch (priority) {
      case 1: return { label: 'Low', color: 'text-green-600 bg-green-100' }
      case 2: return { label: 'Medium', color: 'text-yellow-600 bg-yellow-100' }
      case 3: return { label: 'High', color: 'text-red-600 bg-red-100' }
      default: return { label: 'Medium', color: 'text-yellow-600 bg-yellow-100' }
    }
  }

  // 期日のフォーマット
  const formatDueDate = (dueDate?: string) => {
    if (!dueDate) return null
    
    const date = new Date(dueDate)
    const today = new Date()
    const diffTime = date.getTime() - today.getTime()
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

    if (diffDays < 0) {
      return { label: `${Math.abs(diffDays)}日前`, color: 'text-red-600', isOverdue: true }
    } else if (diffDays === 0) {
      return { label: '今日', color: 'text-orange-600', isToday: true }
    } else if (diffDays === 1) {
      return { label: '明日', color: 'text-yellow-600', isTomorrow: true }
    } else if (diffDays <= 7) {
      return { label: `${diffDays}日後`, color: 'text-blue-600', isThisWeek: true }
    } else {
      return { label: date.toLocaleDateString('ja-JP'), color: 'text-gray-600', isFuture: true }
    }
  }

  useEffect(() => {
    fetchTodos()
  }, [user])

  return {
    todos,
    loading,
    error,
    createTodo,
    updateTodo,
    deleteTodo,
    toggleComplete,
    getThisWeekTodos,
    getTodoStats,
    getPriorityLabel,
    formatDueDate,
    refetch: fetchTodos
  }
}
