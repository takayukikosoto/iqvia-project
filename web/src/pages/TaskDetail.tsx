import React, { useState, useEffect } from 'react'
import { Task } from '../types'
import { usePriority } from '../hooks/usePriority'
import { useTaskLinks } from '../hooks/useTaskLinks'
import { useFiles } from '../hooks/useFiles'
import FileUpload from '../components/FileUpload'
import FileList from '../components/FileList'
import { supabase } from '../supabaseClient'

interface TaskDetailProps {
  taskId: string
  onBack: () => void
}

export default function TaskDetail({ taskId, onBack }: TaskDetailProps) {
  const { priorityOptions, changePriority, getPriorityColor, getPriorityLabel, loading: priorityLoading } = usePriority()
  const { links, loading: linksLoading, addLink, updateLink, deleteLink } = useTaskLinks(taskId)
  
  const [task, setTask] = useState<Task | null>(null)
  const { files, loading: filesLoading, uploadFile, downloadFile, deleteFile } = useFiles(task?.project_id || '', taskId)
  const [loading, setLoading] = useState(true)
  const [isEditing, setIsEditing] = useState(false)
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [priority, setPriority] = useState<Task['priority']>('low')
  const [dueAt, setDueAt] = useState('')
  const [showFiles, setShowFiles] = useState(false)
  
  // Link form state
  const [isAddingLink, setIsAddingLink] = useState(false)
  const [newLinkTitle, setNewLinkTitle] = useState('')
  const [newLinkUrl, setNewLinkUrl] = useState('')
  const [newLinkDescription, setNewLinkDescription] = useState('')

  // Load task data
  const loadTask = async () => {
    setLoading(true)
    const { data, error } = await supabase
      .from('tasks')
      .select('*')
      .eq('id', taskId)
      .single()

    if (error) {
      console.error('Error loading task:', error)
    } else if (data) {
      setTask(data)
      setTitle(data.title)
      setDescription(data.description || '')
      setPriority(data.priority)
      setDueAt(data.due_at ? data.due_at.split('T')[0] : '')
    }
    setLoading(false)
  }

  useEffect(() => {
    loadTask()
  }, [taskId])

  // Update task function
  const updateTask = async (taskId: string, updates: Partial<Task>) => {
    const { error } = await supabase
      .from('tasks')
      .update(updates)
      .eq('id', taskId)

    if (error) {
      console.error('Error updating task:', error)
    } else {
      // Reload task data
      await loadTask()
    }
  }

  const handleSave = async () => {
    if (!task) return
    
    await updateTask(task.id, {
      title,
      description: description || undefined,
      priority,
      due_at: dueAt ? `${dueAt}T00:00:00+00` : undefined
    })
    setIsEditing(false)
  }

  const handleCancel = () => {
    if (!task) return
    setTitle(task.title)
    setDescription(task.description || '')
    setPriority(task.priority)
    setDueAt(task.due_at ? task.due_at.split('T')[0] : '')
    setIsEditing(false)
  }

  const handlePriorityChange = async (newPriority: string) => {
    if (!task) return
    await changePriority(task.id, newPriority)
    setPriority(newPriority as Task['priority'])
  }

  const handleStatusChange = async (newStatus: Task['status']) => {
    if (!task) return
    await updateTask(task.id, { status: newStatus })
  }

  const handleAddLink = async () => {
    if (!newLinkTitle || !newLinkUrl) return
    
    await addLink({
      title: newLinkTitle,
      url: newLinkUrl,
      description: newLinkDescription || undefined
    })
    
    setNewLinkTitle('')
    setNewLinkUrl('')
    setNewLinkDescription('')
    setIsAddingLink(false)
  }

  const formatDueDate = (dateStr?: string) => {
    if (!dateStr) return null
    const date = new Date(dateStr)
    const now = new Date()
    const isOverdue = date < now
    
    return (
      <div style={{
        fontSize: 14,
        color: isOverdue ? '#dc3545' : '#666',
        fontWeight: isOverdue ? 'bold' : 'normal'
      }}>
        締め切り期限: {date.toLocaleDateString('ja-JP')}
        {isOverdue && ' (期限切れ)'}
      </div>
    )
  }

  if (loading || !task) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  const priorityColor = getPriorityColor(task.priority)
  const statusOptions = [
    { value: 'todo' as const, label: '未着手' },
    { value: 'review' as const, label: 'レビュー中' },
    { value: 'done' as const, label: '完了' },
    { value: 'resolved' as const, label: '対応済み' }
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-4">
              <button
                onClick={onBack}
                className="flex items-center text-gray-600 hover:text-gray-900"
              >
                <span className="mr-2">←</span>
                タスク一覧に戻る
              </button>
              <div className="text-sm text-gray-500">|</div>
              <h1 className="text-xl font-bold text-gray-900">タスク詳細</h1>
            </div>
            
            <div className="flex items-center space-x-4">
              <button
                onClick={() => setShowFiles(!showFiles)}
                className={`px-4 py-2 text-sm font-medium rounded-md transition-colors flex items-center gap-2 ${
                  showFiles 
                    ? 'bg-blue-100 text-blue-700' 
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                }`}
              >
                <span>📁</span>
                <span>{showFiles ? 'ファイル非表示' : 'ファイル表示'}</span>
                {files.length > 0 && (
                  <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full">
                    {files.length}
                  </span>
                )}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Task Details - Left Column */}
          <div className="lg:col-span-2 space-y-6">
            {/* Task Card */}
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              {/* Priority Bar */}
              <div 
                className="h-1 rounded-t-lg mb-4"
                style={{ backgroundColor: priorityColor }}
              />

              {/* Title Section */}
              <div className="mb-6">
                {isEditing ? (
                  <input
                    type="text"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="w-full text-2xl font-bold border border-gray-300 rounded-md px-3 py-2"
                  />
                ) : (
                  <h2 className="text-2xl font-bold text-gray-900 mb-2">{task.title}</h2>
                )}

                <div className="flex items-center justify-between mt-4">
                  <div className="flex items-center space-x-4">
                    {/* Status */}
                    <select
                      value={task.status}
                      onChange={(e) => handleStatusChange(e.target.value as Task['status'])}
                      className="px-3 py-1 text-sm border border-gray-300 rounded-md"
                    >
                      {statusOptions.map(option => (
                        <option key={option.value} value={option.value}>
                          {option.label}
                        </option>
                      ))}
                    </select>

                    {/* Priority */}
                    <div className="flex items-center space-x-2">
                      <span className="text-sm text-gray-600">優先度:</span>
                      <select
                        value={task.priority}
                        onChange={(e) => handlePriorityChange(e.target.value)}
                        className="px-3 py-1 text-sm border border-gray-300 rounded-md"
                        style={{ backgroundColor: priorityColor + '20' }}
                      >
                        {priorityOptions.map(option => (
                          <option key={option.name} value={option.name}>
                            {option.label}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>

                  <div className="flex items-center space-x-2">
                    {!isEditing && (
                      <button
                        onClick={() => setIsEditing(true)}
                        className="px-4 py-2 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700"
                      >
                        編集
                      </button>
                    )}
                  </div>
                </div>
              </div>

              {/* Description */}
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">説明</h3>
                {isEditing ? (
                  <textarea
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows={6}
                    className="w-full border border-gray-300 rounded-md px-3 py-2"
                    placeholder="タスクの詳細説明を入力してください..."
                  />
                ) : (
                  <div className="text-gray-700 whitespace-pre-wrap">
                    {task.description || '説明なし'}
                  </div>
                )}
              </div>

              {/* Due Date */}
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">期限</h3>
                {isEditing ? (
                  <input
                    type="date"
                    value={dueAt}
                    onChange={(e) => setDueAt(e.target.value)}
                    className="border border-gray-300 rounded-md px-3 py-2"
                  />
                ) : (
                  <div>
                    {formatDueDate(task.due_at) || <span className="text-gray-500">期限なし</span>}
                  </div>
                )}
              </div>

              {/* Edit Actions */}
              {isEditing && (
                <div className="flex justify-end space-x-2 pt-4 border-t">
                  <button
                    onClick={handleCancel}
                    className="px-4 py-2 text-sm text-gray-600 hover:text-gray-900"
                  >
                    キャンセル
                  </button>
                  <button
                    onClick={handleSave}
                    className="px-4 py-2 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700"
                  >
                    保存
                  </button>
                </div>
              )}
            </div>

            {/* Links Section */}
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold text-gray-900">関連リンク</h3>
                <button
                  onClick={() => setIsAddingLink(!isAddingLink)}
                  className="px-4 py-2 text-sm bg-green-600 text-white rounded-md hover:bg-green-700"
                >
                  {isAddingLink ? 'キャンセル' : '+ リンク追加'}
                </button>
              </div>

              {isAddingLink && (
                <div className="mb-4 p-4 border border-gray-200 rounded-md bg-gray-50">
                  <div className="space-y-3">
                    <input
                      type="text"
                      placeholder="リンクタイトル"
                      value={newLinkTitle}
                      onChange={(e) => setNewLinkTitle(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md"
                    />
                    <input
                      type="url"
                      placeholder="URL"
                      value={newLinkUrl}
                      onChange={(e) => setNewLinkUrl(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md"
                    />
                    <textarea
                      placeholder="説明（任意）"
                      value={newLinkDescription}
                      onChange={(e) => setNewLinkDescription(e.target.value)}
                      rows={2}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md"
                    />
                    <div className="flex justify-end space-x-2">
                      <button
                        onClick={() => setIsAddingLink(false)}
                        className="px-3 py-2 text-sm text-gray-600 hover:text-gray-900"
                      >
                        キャンセル
                      </button>
                      <button
                        onClick={handleAddLink}
                        className="px-3 py-2 text-sm bg-green-600 text-white rounded-md hover:bg-green-700"
                      >
                        追加
                      </button>
                    </div>
                  </div>
                </div>
              )}

              <div className="space-y-3">
                {links.length > 0 ? (
                  links.map(link => (
                    <div key={link.id} className="border border-gray-200 rounded-md p-4">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <h4 className="font-semibold text-blue-600 hover:text-blue-800">
                            <a href={link.url} target="_blank" rel="noopener noreferrer">
                              {link.title}
                            </a>
                          </h4>
                          {link.description && (
                            <p className="text-gray-600 text-sm mt-1">{link.description}</p>
                          )}
                          <p className="text-gray-400 text-xs mt-2">{link.url}</p>
                        </div>
                        <button
                          onClick={() => deleteLink(link.id)}
                          className="text-red-600 hover:text-red-800 text-sm"
                        >
                          削除
                        </button>
                      </div>
                    </div>
                  ))
                ) : (
                  <p className="text-gray-500 text-center py-4">関連リンクがありません</p>
                )}
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="space-y-6">
            {/* Files */}
            {showFiles && (
              <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-lg font-semibold text-gray-900">
                    ファイル ({files.length})
                  </h3>
                </div>
                
                {/* File Upload */}
                <div className="mb-6">
                  <FileUpload 
                    onFileUpload={uploadFile}
                    loading={filesLoading}
                  />
                </div>
                
                {/* File List */}
                <FileList 
                  files={files}
                  loading={filesLoading}
                  onDownload={downloadFile}
                  onDelete={deleteFile}
                  onGetVersions={async () => []}
                  onUploadNewVersion={async () => false}
                />
              </div>
            )}

          </div>
        </div>
      </div>
    </div>
  )
}
