import React, { useEffect, useState } from 'react'
import { supabase } from '../supabaseClient'
import TaskBoard from '../components/TaskBoard'
import CreateTaskModal from '../components/CreateTaskModal'
import { Task, Project } from '../types'
import { useAuth } from '../hooks/useAuth'

export default function Tasks() {
  const { user } = useAuth()
  const [tasks, setTasks] = useState<Task[]>([])
  const [projects, setProjects] = useState<Project[]>([])
  const [selectedProject, setSelectedProject] = useState<string>('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showCreateModal, setShowCreateModal] = useState(false)

  const loadProjects = async () => {
    const { data, error } = await supabase
      .from('projects')
      .select('id, name, org_id')
    if (error) {
      console.error('Projects load error:', error)
    } else {
      setProjects(data ?? [])
      if (data?.length && !selectedProject) {
        setSelectedProject(data[0].id)
      }
    }
  }

  const loadTasks = async (projectId?: string) => {
    if (!projectId) return
    
    setLoading(true)
    const { data, error } = await supabase
      .from('tasks')
      .select('id, title, description, status, priority, due_at, project_id, created_by, created_at, updated_at')
      .eq('project_id', projectId)
      .order('created_at', { ascending: false })
    
    if (error) {
      setError(error.message)
    } else {
      setTasks(data ?? [])
      setError(null)
    }
    setLoading(false)
  }

  useEffect(() => {
    if (user) {
      console.log('Authenticated user:', user.id, user.email)
      loadProjects()
    }
  }, [user])

  useEffect(() => {
    if (user && selectedProject) {
      loadTasks(selectedProject)
    }
  }, [user, selectedProject])

  useEffect(() => {
    if (!selectedProject) return

    const channel = supabase
      .channel('public:tasks')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'tasks' }, (payload: any) => {
        const task = payload.new as Task | null
        if (task?.project_id === selectedProject || payload.eventType === 'DELETE') {
          loadTasks(selectedProject)
        }
      })
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [selectedProject])

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
    }
  }

  const handleTaskCreate = async (taskData: Partial<Task>) => {
    if (!selectedProject || !user) return
    
    const { error } = await supabase
      .from('tasks')
      .insert([{
        ...taskData,
        project_id: selectedProject,
        created_by: user.id,
        updated_by: user.id
      }])
    
    if (error) {
      console.error('Task create error:', error)
      setError(error.message)
    } else {
      setShowCreateModal(false)
    }
  }

  const handleTaskDelete = async (taskId: string) => {
    if (!confirm('このタスクを削除しますか？')) return
    
    const { error } = await supabase
      .from('tasks')
      .delete()
      .eq('id', taskId)
    
    if (error) {
      console.error('Task delete error:', error)
      setError(error.message)
    }
  }

  return (
    <div>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center', 
        marginBottom: 24 
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <h2>タスク管理</h2>
          {projects.length > 0 && (
            <select
              value={selectedProject}
              onChange={(e) => setSelectedProject(e.target.value)}
              style={{
                padding: '8px 12px',
                border: '1px solid #ccc',
                borderRadius: 4,
                fontSize: 14
              }}
            >
              {projects.map(project => (
                <option key={project.id} value={project.id}>
                  {project.name}
                </option>
              ))}
            </select>
          )}
        </div>
        
        <button
          onClick={() => setShowCreateModal(true)}
          disabled={!selectedProject}
          style={{
            padding: '8px 16px',
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: 4,
            cursor: selectedProject ? 'pointer' : 'not-allowed',
            opacity: selectedProject ? 1 : 0.6
          }}
        >
          新しいタスク
        </button>
      </div>

      {error && (
        <div style={{
          marginBottom: 16,
          padding: 12,
          backgroundColor: '#f8d7da',
          color: '#721c24',
          border: '1px solid #f5c6cb',
          borderRadius: 4
        }}>
          {error}
        </div>
      )}

      {loading ? (
        <p>Loading...</p>
      ) : projects.length === 0 ? (
        <p>プロジェクトがありません。管理者にプロジェクトへの参加を依頼してください。</p>
      ) : (
        <TaskBoard
          tasks={tasks}
          onTaskUpdate={handleTaskUpdate}
          onTaskDelete={handleTaskDelete}
        />
      )}

      {showCreateModal && (
        <CreateTaskModal
          onSubmit={handleTaskCreate}
          onClose={() => setShowCreateModal(false)}
        />
      )}
    </div>
  )
}
