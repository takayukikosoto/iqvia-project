import React, { useState, useEffect } from 'react'
import TaskBoard from '../components/TaskBoard'
import Chat from '../components/Chat'
import FileUpload from '../components/FileUpload'
import FileList from '../components/FileList'
import MentionNotifications from '../components/MentionNotifications'
import CreateTaskModal from '../components/CreateTaskModal'
import CustomStatusManager from '../components/CustomStatusManager'
import { useFiles } from '../hooks/useFiles'
import { useAuth } from '../hooks/useAuth'
import { supabase } from '../supabaseClient'

interface Task {
  id: string
  title: string
  description?: string
  status: 'todo' | 'review' | 'done' | 'resolved'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  project_id: string
  assigned_to?: string
  created_at: string
  updated_at: string
}

interface Project {
  id: string
  name: string
  org_id: string
  created_at: string
}

interface TasksProps {
  onTaskSelect?: (taskId: string) => void
}

export default function Tasks({ onTaskSelect }: TasksProps) {
  const { user } = useAuth()
  const [tasks, setTasks] = useState<Task[]>([])
  const [projects, setProjects] = useState<Project[]>([])
  const [selectedProject, setSelectedProject] = useState<string>('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [showCustomStatusManager, setShowCustomStatusManager] = useState(false)
  const [activeTab, setActiveTab] = useState<'tasks' | 'files'>('tasks')
  const [showChat, setShowChat] = useState(true)
  
  // File management hook
  const { files, loading: filesLoading, uploadFile, uploadNewVersion, downloadFile, deleteFile, getFileVersions } = useFiles(selectedProject)

  const loadProjects = async () => {
    const { data, error } = await supabase
      .from('projects')
      .select('id, name, created_at')
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
    } else {
      // タスク更新後にページをリロード
      window.location.reload()
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
      // タスク作成後にページをリロード
      window.location.reload()
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
    } else {
      // タスク削除後にページをリロード
      window.location.reload()
    }
  }

  return (
    <div 
      style={{ 
        display: 'flex', 
        gap: showChat ? 24 : 0, 
        height: 'calc(100vh - 140px)',
        transition: 'gap 0.3s ease-in-out'
      }}
    >
      {/* Left Panel - Tasks */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="flex justify-between items-center mb-8">
          <div className="flex items-center space-x-6">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-indigo-50 rounded-lg flex-shrink-0">
                <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" style={{width: '24px', height: '24px'}}>
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
                </svg>
              </div>
              <h2 className="text-2xl font-bold text-gray-900">タスク管理</h2>
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
          <div className="flex space-x-3">
            <button
              onClick={() => setShowChat(!showChat)}
              className={`px-4 py-3 font-semibold rounded-lg shadow-sm hover:shadow-md transition-all duration-200 flex items-center space-x-2 ${
                showChat 
                  ? 'bg-blue-600 hover:bg-blue-700 text-white' 
                  : 'bg-gray-200 hover:bg-gray-300 text-gray-700'
              }`}
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
              <span>{showChat ? 'チャット非表示' : 'チャット表示'}</span>
            </button>
            <button
              onClick={() => setShowCustomStatusManager(true)}
              className="px-4 py-3 bg-gray-600 hover:bg-gray-700 text-white font-semibold rounded-lg shadow-sm hover:shadow-md transition-all duration-200 flex items-center space-x-2"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              <span>ステータス管理</span>
            </button>
            <button
              onClick={() => setShowCreateModal(true)}
              className="px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-semibold rounded-lg shadow-sm hover:shadow-md transition-all duration-200 flex items-center space-x-2"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              <span>新しいタスク</span>
            </button>
          </div>
        </div>

        {error && (
          <div style={{
            padding: 12,
            backgroundColor: '#f8d7da',
            color: '#721c24',
            border: '1px solid #f5c6cb',
            borderRadius: 4,
            marginBottom: 16
          }}>
            {error}
          </div>
        )}

        {/* Tab Navigation */}
        <div className="flex bg-gray-100/70 rounded-xl p-1 mb-6 backdrop-blur-sm">
          <button
            onClick={() => setActiveTab('tasks')}
            className={`flex-1 px-6 py-3 rounded-lg text-sm font-semibold transition-all duration-200 ${
              activeTab === 'tasks'
                ? 'bg-white text-blue-600 shadow-sm ring-1 ring-blue-100'
                : 'text-gray-600 hover:text-gray-800 hover:bg-white/50'
            }`}
          >
            <div className="flex items-center justify-center space-x-2">
              <span className="text-lg">📋</span>
              <span>タスク ({tasks.length})</span>
            </div>
          </button>
          <button
            onClick={() => setActiveTab('files')}
            className={`flex-1 px-6 py-3 rounded-lg text-sm font-semibold transition-all duration-200 ${
              activeTab === 'files'
                ? 'bg-white text-blue-600 shadow-sm ring-1 ring-blue-100'
                : 'text-gray-600 hover:text-gray-800 hover:bg-white/50'
            }`}
          >
            <div className="flex items-center justify-center space-x-2">
              <span className="text-lg">📁</span>
              <span>ファイル ({files.length})</span>
            </div>
          </button>
        </div>

        {loading ? (
          <div>読み込み中...</div>
        ) : activeTab === 'tasks' ? (
          <TaskBoard 
            tasks={tasks}
            onTaskUpdate={handleTaskUpdate}
            onTaskDelete={handleTaskDelete}
            onTaskSelect={onTaskSelect}
          />
        ) : (
          <div className="space-y-4">
            <FileUpload 
              onFileUpload={uploadFile}
              loading={filesLoading}
            />
            <FileList
              files={files}
              loading={filesLoading}
              onDownload={downloadFile}
              onDelete={deleteFile}
              onGetVersions={getFileVersions}
              onUploadNewVersion={uploadNewVersion}
            />
          </div>
        )}
        {/* Mention Notifications */}
        {selectedProject && <MentionNotifications projectId={selectedProject} />}
      </div>
      
      {/* Right Panel - Chat */}
      {showChat && (
        <div 
          style={{ 
            width: 350, 
            minWidth: 350, 
            height: '100%',
            transform: 'translateX(0)',
            transition: 'all 0.3s ease-in-out'
          }}
        >
          <Chat projectId={selectedProject} />
        </div>
      )}
      
      {/* Chat Toggle Button (when hidden) */}
      {!showChat && (
        <div 
          className="fixed right-6 top-1/2 transform -translate-y-1/2 z-10"
          style={{ transition: 'all 0.3s ease-in-out' }}
        >
          <button
            onClick={() => setShowChat(true)}
            className="p-3 bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-lg hover:shadow-xl transition-all duration-200 flex items-center space-x-2"
            title="チャットを表示"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <span className="text-sm font-medium">チャット</span>
          </button>
        </div>
      )}

      {/* Create Task Modal */}
      {showCreateModal && (
        <CreateTaskModal
          onSubmit={handleTaskCreate}
          onClose={() => setShowCreateModal(false)}
        />
      )}
      
      {/* Custom Status Manager Modal */}
      {showCustomStatusManager && (
        <CustomStatusManager
          projectId={selectedProject}
          onClose={() => setShowCustomStatusManager(false)}
        />
      )}
    </div>
  )
}
