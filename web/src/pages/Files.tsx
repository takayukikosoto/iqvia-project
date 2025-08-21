import React, { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import FileUpload from '../components/FileUpload'
import FileList from '../components/FileList'

type Task = {
  id: string
  title: string
  status: string
  storage_folder?: string
  file_count?: number
}

export default function Files() {
  const [tasks, setTasks] = useState<Task[]>([])
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  // タスクベースのファイル管理用state
  const [files, setFiles] = useState<any[]>([])
  const [filesLoading, setFilesLoading] = useState(false)

  useEffect(() => {
    fetchTasksWithFileCount()
  }, [])

  const fetchTasksWithFileCount = async () => {
    try {
      setLoading(true)
      
      // タスク一覧とファイル数を取得
      const { data: tasksData, error: tasksError } = await supabase
        .from('tasks')
        .select(`
          id,
          title,
          status,
          storage_folder,
          created_at
        `)
        .order('created_at', { ascending: false })

      if (tasksError) throw tasksError

      // 各タスクのファイル数を取得
      const tasksWithFileCount = await Promise.all(
        (tasksData || []).map(async (task: any) => {
          if (!task.storage_folder) {
            return { ...task, file_count: 0 }
          }

          // storage_folderベースでファイル数を取得
          const { data, error } = await supabase
            .storage
            .from('task-files')
            .list(task.storage_folder || `task_${task.id}`, {
              limit: 1000,
              offset: 0
            })
          
          const fileCount = data ? data.length : 0

          return {
            ...task,
            file_count: error ? 0 : fileCount
          }
        })
      )

      setTasks(tasksWithFileCount)
    } catch (error) {
      console.error('Error fetching tasks:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleTaskSelect = (taskId: string) => {
    setSelectedTaskId(taskId)
    loadTaskFiles(taskId)
  }

  // タスクのファイルを読み込み
  const loadTaskFiles = async (taskId: string) => {
    setFilesLoading(true)
    try {
      const task = tasks.find(t => t.id === taskId)
      if (!task?.storage_folder) {
        setFiles([])
        return
      }

      const { data, error } = await supabase
        .storage
        .from('task-files')
        .list(task.storage_folder, {
          limit: 1000,
          offset: 0
        })

      if (error) throw error
      
      // ファイル情報を整形
      const fileList = (data || []).map(file => ({
        id: file.name,
        name: file.name,
        storage_path: `${task.storage_folder}/${file.name}`,
        created_at: file.created_at || new Date().toISOString(),
        total_size_bytes: file.metadata?.size || 0,
        total_versions: 1
      }))
      
      setFiles(fileList)
    } catch (error) {
      console.error('Error loading task files:', error)
      setFiles([])
    } finally {
      setFilesLoading(false)
    }
  }

  // ファイル操作関数
  const uploadFile = async (file: File, description?: string) => {
    if (!selectedTaskId) return null
    
    const task = tasks.find(t => t.id === selectedTaskId)
    if (!task) return null
    
    const storageFolder = task.storage_folder || `task_${task.id}`
    const filePath = `${storageFolder}/${file.name}`
    
    try {
      const { error } = await supabase.storage
        .from('task-files')
        .upload(filePath, file)
        
      if (error) throw error
      
      // ファイル一覧を更新
      await loadTaskFiles(selectedTaskId)
      return filePath
    } catch (error) {
      console.error('Upload error:', error)
      return null
    }
  }
  
  const deleteFile = async (fileId: string, storagePath?: string) => {
    if (!storagePath) return
    
    try {
      const { error } = await supabase.storage
        .from('task-files')
        .remove([storagePath])
        
      if (error) throw error
      
      if (selectedTaskId) {
        await loadTaskFiles(selectedTaskId)
      }
    } catch (error) {
      console.error('Delete error:', error)
    }
  }
  
  const getFileVersions = async (fileId: string) => {
    // バージョン管理は簡略化
    return []
  }
  
  const uploadNewVersion = async (fileId: string, file: File, changeNotes?: string) => {
    // 新バージョンアップロードは簡略化
    return false
  }

  const handleBackToTasks = () => {
    setSelectedTaskId(null)
  }

  const handleDownload = async (storagePath: string, fileName: string) => {
    try {
      const { data, error } = await supabase.storage
        .from('task-files')
        .download(storagePath)

      if (error) throw error

      const url = URL.createObjectURL(data)
      const a = document.createElement('a')
      a.href = url
      a.download = fileName
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Download error:', error)
      alert('ファイルのダウンロードに失敗しました。')
    }
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  // タスク別ファイル表示
  if (selectedTaskId) {
    const selectedTask = tasks.find(t => t.id === selectedTaskId)
    
    return (
      <div className="p-6">
        <div className="mb-6">
          <button
            onClick={handleBackToTasks}
            className="flex items-center text-blue-600 hover:text-blue-800 mb-4"
          >
            <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            ファイル一覧に戻る
          </button>
          
          <div className="bg-white rounded-lg shadow-sm border p-6">
            <div className="flex items-center gap-4 mb-4">
              <div className="p-3 bg-blue-50 rounded-lg">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">{selectedTask?.title}</h1>
                <p className="text-gray-600">タスク別ファイル管理</p>
              </div>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
              <div className="lg:col-span-3">
                <FileList
                  files={files}
                  onDownload={handleDownload}
                  onDelete={deleteFile}
                  onGetVersions={getFileVersions}
                  onUploadNewVersion={uploadNewVersion}
                  loading={filesLoading}
                />
              </div>
              
              <div className="lg:col-span-1">
                <div className="sticky top-6">
                  <FileUpload
                    onFileUpload={async (file: File, description?: string) => {
                      const result = await uploadFile(file, description)
                      if (result) {
                        fetchTasksWithFileCount()
                      }
                      return result
                    }}
                    loading={filesLoading}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // タスク一覧表示
  return (
    <div className="p-6">
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-6">
          <div className="p-3 bg-emerald-50 rounded-lg">
            <svg className="w-6 h-6 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 5a2 2 0 012-2h4a2 2 0 012 2v1H8V5z" />
            </svg>
          </div>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">ファイル管理</h1>
            <p className="text-gray-600">タスクごとのファイルを管理できます</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {tasks.map((task) => (
          <div
            key={task.id}
            onClick={() => handleTaskSelect(task.id)}
            className="bg-white rounded-lg shadow-sm border hover:shadow-md transition-shadow duration-200 cursor-pointer p-6"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-blue-50 rounded-lg">
                  <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                  </svg>
                </div>
                <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                  task.status === 'completed' 
                    ? 'bg-green-100 text-green-800'
                    : task.status === 'in_progress'
                    ? 'bg-blue-100 text-blue-800'
                    : 'bg-gray-100 text-gray-800'
                }`}>
                  {task.status === 'completed' ? '完了' : 
                   task.status === 'in_progress' ? '進行中' : '未着手'}
                </span>
              </div>
              
              <div className="flex items-center gap-1 text-sm text-gray-500">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <span>{task.file_count || 0}</span>
              </div>
            </div>
            
            <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2">{task.title}</h3>
            
            <div className="flex items-center justify-between text-sm text-gray-500">
              <span>ファイルを管理</span>
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </div>
        ))}
      </div>

      {tasks.length === 0 && (
        <div className="text-center py-12">
          <div className="p-4 bg-gray-50 rounded-lg inline-block">
            <svg className="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <p className="text-gray-500">タスクが見つかりません</p>
          </div>
        </div>
      )}
    </div>
  )
}
