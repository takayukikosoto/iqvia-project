import React, { useState, useEffect } from 'react'
import TaskCard from '../components/TaskCard'
import { useAuth } from '../hooks/useAuth'
import { supabase } from '../supabaseClient'

interface Task {
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
  created_by?: string
}

interface Project {
  id: string
  name: string
  organization_id: string
  created_at: string
}

export default function CompletedTasks() {
  const { user } = useAuth()
  const [tasks, setTasks] = useState<Task[]>([])
  const [projects, setProjects] = useState<Project[]>([])
  const [selectedProject, setSelectedProject] = useState<string>('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadProjects = async () => {
    const { data, error } = await supabase
      .from('projects')
      .select('id, name, organization_id, created_at')
    if (error) {
      console.error('Projects load error:', error)
    } else {
      setProjects(data ?? [])
      if (data?.length && !selectedProject) {
        setSelectedProject(data[0].id)
      }
    }
  }

  const loadCompletedTasks = async (projectId?: string) => {
    if (!projectId) return
    
    setLoading(true)
    const { data, error } = await supabase
      .from('tasks')
      .select('id, title, description, status, priority, due_at, project_id, created_by, created_at, updated_at')
      .eq('project_id', projectId)
      .eq('status', 'completed') // 完了したタスクのみ取得
      .order('updated_at', { ascending: false }) // 更新日時順（新しい順）
    
    if (error) {
      setError(error.message)
    } else {
      setTasks(data ?? [])
      setError(null)
    }
    setLoading(false)
  }

  useEffect(() => {
    if (user?.id) {
      loadProjects()
    }
  }, [user?.id])

  useEffect(() => {
    if (user?.id && selectedProject) {
      loadCompletedTasks(selectedProject)
    }
  }, [user?.id, selectedProject])

  const handleTaskUpdate = async (taskId: string, updates: Partial<Task>) => {
    if (!user) return
    
    const { error } = await supabase
      .from('tasks')
      .update({
        ...updates,
        updated_by: user.id
      })
      .eq('id', taskId)
    
    if (error) {
      console.error('Task update error:', error)
      setError(error.message)
    } else {
      // タスクリストを再読み込み
      loadCompletedTasks(selectedProject)
    }
  }

  const handleTaskDelete = async (taskId: string) => {
    if (!confirm('このタスクを完全に削除しますか？')) return
    
    const { error } = await supabase
      .from('tasks')
      .delete()
      .eq('id', taskId)
    
    if (error) {
      console.error('Task delete error:', error)
      setError(error.message)
    } else {
      // タスクリストを再読み込み
      loadCompletedTasks(selectedProject)
    }
  }

  const handleRestoreTask = async (taskId: string) => {
    await handleTaskUpdate(taskId, { status: 'todo' })
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-8">
        <div className="flex items-center space-x-6">
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-green-50 rounded-lg flex-shrink-0">
              <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h2 className="text-2xl font-bold text-gray-900">完了したタスク</h2>
          </div>
          {projects.length > 0 && (
            <select
              value={selectedProject}
              onChange={(e) => setSelectedProject(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg text-sm font-medium bg-white hover:border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-colors"
            >
              {projects.map(project => (
                <option key={project.id} value={project.id}>
                  {project.name}
                </option>
              ))}
            </select>
          )}
        </div>
      </div>

      {error && (
        <div className="p-3 mb-4 bg-red-100 border border-red-300 text-red-700 rounded">
          {error}
        </div>
      )}

      {loading ? (
        <div className="text-center py-8">
          <div className="text-gray-500">読み込み中...</div>
        </div>
      ) : tasks.length === 0 ? (
        <div className="text-center py-12">
          <div className="text-gray-500 mb-4">完了したタスクはまだありません</div>
          <div className="text-sm text-gray-400">
            タスク管理画面でタスクを完了すると、ここに表示されます
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {tasks.map(task => (
            <div key={task.id} className="relative">
              <TaskCard
                task={task}
                onTaskUpdate={handleTaskUpdate}
                onTaskDelete={handleTaskDelete}
              />
              {/* 復元ボタンをオーバーレイ */}
              <button
                onClick={() => handleRestoreTask(task.id)}
                className="absolute top-2 right-2 bg-blue-500 hover:bg-blue-600 text-white text-xs px-2 py-1 rounded shadow-sm transition-colors"
                title="未着手に戻す"
              >
                復元
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
