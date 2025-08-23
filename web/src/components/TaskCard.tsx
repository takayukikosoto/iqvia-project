import React, { useState, useRef, useEffect } from 'react'
import { usePriority } from '../hooks/usePriority'
import { useFiles } from '../hooks/useFiles'
import { Task, TaskPriority, CustomStatus, User } from '../types'
import { supabase } from '../supabaseClient'
import { useTaskLinks } from '../hooks/useTaskLinks'
import { RecentCommentInfo } from '../hooks/useRecentComments'

interface TaskCardProps {
  task: Task
  onTaskUpdate: (taskId: string, updates: Partial<Task>) => void
  onTaskDelete: (taskId: string) => void
  onTaskSelect?: (taskId: string) => void
  commentInfo?: RecentCommentInfo
}

const priorityColors = {
  low: '#28a745',    // 緑
  medium: '#007bff', // 青
  high: '#ffc107',   // 黄色
  urgent: '#dc3545'  // 赤
}

const priorityLabels: Record<TaskPriority, string> = {
  low: '低',
  medium: '中',
  high: '高',
  urgent: '緊急'
}

const statusOptions: { value: Task['status']; label: string; color: string }[] = [
  { value: 'todo', label: '未着手', color: '#6c757d' },
  { value: 'review', label: 'レビュー中', color: '#ffc107' },
  { value: 'done', label: '作業完了', color: '#28a745' },
  { value: 'resolved', label: '対応済み', color: '#17a2b8' }
]

export default function TaskCard({ task, onTaskUpdate, onTaskDelete, onTaskSelect, commentInfo }: TaskCardProps) {
  const { priorityOptions, changePriority, getPriorityColor, getPriorityLabel, loading, getPriorityHistory } = usePriority()
  const { links, loading: linksLoading, addLink, updateLink, deleteLink } = useTaskLinks(task.id)
  const { files, uploadFile, deleteFile, loading: filesLoading } = useFiles(task.project_id, task.id)
  
  const [isEditing, setIsEditing] = useState(false)
  const [showLinks, setShowLinks] = useState(false)
  const [showFiles, setShowFiles] = useState(false)
  const [showDetails, setShowDetails] = useState(false)
  const [isAddingLink, setIsAddingLink] = useState(false)
  const [title, setTitle] = useState(task.title)
  const [description, setDescription] = useState(task.description || '')
  const [priority, setPriority] = useState(task.priority)
  const [dueAt, setDueAt] = useState(task.due_at ? task.due_at.split('T')[0] : '')
  const [priorityHistory, setPriorityHistory] = useState<any[]>([])
  
  // Link form state
  const [newLinkTitle, setNewLinkTitle] = useState('')
  const [newLinkUrl, setNewLinkUrl] = useState('')
  const [newLinkDescription, setNewLinkDescription] = useState('')
  
  // Load priority history
  useEffect(() => {
    if (task.id) {
      getPriorityHistory(task.id).then(history => {
        setPriorityHistory(history)
      })
    }
  }, [task.id])
  
  const latestPriorityChange = priorityHistory[0]

  const handleSave = () => {
    onTaskUpdate(task.id, {
      title,
      description: description || undefined,
      priority,
      due_at: dueAt ? `${dueAt}T00:00:00+00` : undefined
    })
    setIsEditing(false)
  }

  const handleCancel = () => {
    setTitle(task.title)
    setDescription(task.description || '')
    setPriority(task.priority)
    setDueAt(task.due_at ? task.due_at.split('T')[0] : '')
    setIsEditing(false)
  }

  const formatDueDate = (dateStr?: string) => {
    if (!dateStr) return null
    const date = new Date(dateStr)
    const now = new Date()
    const isOverdue = date < now
    
    return (
      <div style={{
        fontSize: 12,
        color: isOverdue ? '#dc3545' : '#666',
        fontWeight: isOverdue ? 'bold' : 'normal'
      }}>
        締め切り期限: {date.toLocaleDateString('ja-JP')}
        {isOverdue && ' (期限切れ)'}
      </div>
    )
  }

  const handlePriorityChange = async (e: React.MouseEvent, newPriority: string) => {
    e.preventDefault()
    e.stopPropagation()
    
    try {
      console.log('Priority button clicked:', newPriority)
      await changePriority(task.id, newPriority)
      console.log('Priority change result: success')
      
      // Refresh page to reflect changes
      window.location.reload()
    } catch (error) {
      console.error('Priority change result: error', error)
    }
  }

  // Link management functions
  const handleAddLink = async () => {
    if (!newLinkTitle.trim() || !newLinkUrl.trim()) return

    const result = await addLink({
      title: newLinkTitle.trim(),
      url: newLinkUrl.trim(),
      description: newLinkDescription.trim() || undefined
    })

    if (result.success) {
      setNewLinkTitle('')
      setNewLinkUrl('')
      setNewLinkDescription('')
      setIsAddingLink(false)
    }
  }

  const handleDeleteLink = async (linkId: string) => {
    if (confirm('このリンクを削除しますか？')) {
      await deleteLink(linkId)
    }
  }

  if (isEditing) {
    return (
      <div style={{
        backgroundColor: 'white',
        borderRadius: 6,
        padding: 12,
        boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        border: '2px solid #007bff'
      }}>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          style={{
            width: '100%',
            padding: 8,
            border: '1px solid #ccc',
            borderRadius: 4,
            fontSize: 14,
            marginBottom: 8
          }}
          placeholder="タスク名"
        />
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          style={{
            width: '100%',
            padding: 8,
            border: '1px solid #ccc',
            borderRadius: 4,
            fontSize: 12,
            marginBottom: 8,
            resize: 'none'
          }}
          rows={2}
          placeholder="詳細説明"
        />
        <div style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
          <select
            value={priority}
            onChange={(e) => setPriority(e.target.value as Task['priority'])}
            style={{
              padding: '4px 8px',
              border: '1px solid #ccc',
              borderRadius: 4,
              fontSize: 12
            }}
          >
            <option value="low">低</option>
            <option value="medium">中</option>
            <option value="high">高</option>
            <option value="urgent">緊急</option>
          </select>
        </div>
        <input
          type="date"
          value={dueAt}
          onChange={(e) => setDueAt(e.target.value)}
          style={{
            width: '100%',
            padding: '4px 8px',
            border: '1px solid #ccc',
            borderRadius: 4,
            fontSize: 12,
            marginBottom: 8
          }}
        />
        <div style={{ display: 'flex', gap: 8 }}>
          <button
            onClick={handleSave}
            style={{
              padding: '6px 12px',
              backgroundColor: '#007bff',
              color: 'white',
              border: 'none',
              borderRadius: 4,
              fontSize: 12,
              cursor: 'pointer'
            }}
          >
            保存
          </button>
          <button
            onClick={handleCancel}
            style={{
              padding: '6px 12px',
              backgroundColor: '#6c757d',
              color: 'white',
              border: 'none',
              borderRadius: 4,
              fontSize: 12,
              cursor: 'pointer'
            }}
          >
            キャンセル
          </button>
        </div>
      </div>
    )
  }

  // Get background color based on priority
  const getBackgroundColor = () => {
    if (loading || !priorityOptions || priorityOptions.length === 0) {
      // フォールバック色（薄い色）
      switch (task.priority) {
        case 'low': return '#d4edda'      // 薄い緑
        case 'medium': return '#cce5ff'   // 薄い青
        case 'high': return '#fff3cd'     // 薄い黄色
        case 'urgent': return '#f8d7da'   // 薄い赤
        default: return 'white'
      }
    }
    
    // データベースの色を使用（薄くする）
    const priorityOption = priorityOptions.find(option => option.name === task.priority)
    if (priorityOption) {
      // 色を薄くするために透明度を追加
      const color = priorityOption.color
      return color + '20' // 20% opacity
    }
    
    return 'white'
  }

  const getBorderColor = () => {
    if (loading || !priorityOptions || priorityOptions.length === 0) {
      // フォールバック色
      switch (task.priority) {
        case 'low': return '#28a745'    // 緑
        case 'medium': return '#007bff' // 青
        case 'high': return '#ffc107'   // 黄色
        case 'urgent': return '#dc3545' // 赤
        default: return '#e9ecef'
      }
    }
    
    // データベースの色を使用
    const priorityOption = priorityOptions.find(option => option.name === task.priority)
    return priorityOption ? priorityOption.color : '#e9ecef'
  }

  return (
    <div 
      draggable
      onDragStart={(e) => {
        e.dataTransfer.setData('text/plain', task.id)
        e.dataTransfer.effectAllowed = 'move'
        e.currentTarget.style.opacity = '0.5'
      }}
      onDragEnd={(e) => {
        e.currentTarget.style.opacity = '1'
      }}
      style={{
        border: `2px solid ${getBorderColor()}`,
        backgroundColor: getBackgroundColor(),
        borderRadius: 6,
        padding: 8,
        margin: '2px 0',
        transition: 'all 0.2s ease',
        position: 'relative',
        cursor: 'grab'
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.transform = 'translateY(-2px)'
        e.currentTarget.style.boxShadow = '0 4px 8px rgba(0,0,0,0.15)'
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'translateY(0)'
        e.currentTarget.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)'
      }}>
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
        marginBottom: 4
      }}>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <h4 style={{
              margin: 0,
              fontSize: 16,
              fontWeight: 600,
              lineHeight: 1.2
            }}>
              {task.title}
            </h4>
            {commentInfo?.hasRecentComments && (
              <span style={{
                backgroundColor: '#dc3545',
                color: 'white',
                fontSize: 9,
                fontWeight: 'bold',
                padding: '2px 6px',
                borderRadius: 8,
                textTransform: 'uppercase'
              }}>
                New
              </span>
            )}
          </div>
          {task.due_at && (
            <div style={{
              fontSize: 10,
              color: new Date(task.due_at) < new Date() ? '#dc3545' : '#666',
              fontWeight: new Date(task.due_at) < new Date() ? 600 : 400,
              marginTop: 2
            }}>
              📅 {new Date(task.due_at).toLocaleDateString('ja-JP')}
            </div>
          )}
        </div>
        
        <div style={{
          display: 'flex',
          gap: 4,
          marginLeft: 8
        }}>
          <button
            onClick={(e) => {
              e.stopPropagation()
              setShowLinks(!showLinks)
            }}
            style={{
              padding: 2,
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontSize: 12,
              color: links.length > 0 ? '#007bff' : '#666'
            }}
            title={`リンク (${links.length})`}
          >
            🔗 {links.length}
          </button>
          
          <button
            onClick={(e) => {
              e.stopPropagation()
              setShowFiles(!showFiles)
            }}
            style={{
              padding: 2,
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontSize: 12,
              color: files.length > 0 ? '#28a745' : '#666'
            }}
            title={`ファイル (${files.length})`}
          >
            📁 {files.length}
          </button>
          
          <button
            onClick={(e) => {
              e.stopPropagation()
              setIsEditing(true)
            }}
            style={{
              padding: 2,
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontSize: 12,
              color: '#666'
            }}
            title="編集"
          >
            ✏️
          </button>
          
          <button
            onClick={(e) => {
              e.stopPropagation()
              onTaskSelect?.(task.id)
            }}
            style={{
              padding: 2,
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontSize: 12,
              color: '#007bff'
            }}
            title="詳細"
          >
            📋
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation()
              onTaskUpdate(task.id, { status: 'completed' })
              // 完了後に完了済みページへ遷移
              setTimeout(() => {
                window.location.href = '/completed'
              }, 500)
            }}
            style={{
              padding: 2,
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontSize: 12,
              color: '#28a745'
            }}
            title="完了"
          >
            ✅
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation()
              onTaskDelete(task.id)
            }}
            style={{
              padding: 2,
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontSize: 12,
              color: '#dc3545'
            }}
            title="削除"
          >
            🗑️
          </button>
        </div>
      </div>
      
      {/* 詳細情報 - 一括折りたたみ */}
      {(task.description || latestPriorityChange) && (
        <div style={{ marginBottom: 4 }}>
          <button
            onClick={(e) => {
              e.stopPropagation()
              setShowDetails(!showDetails)
            }}
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              fontSize: 9,
              color: '#666',
              display: 'flex',
              alignItems: 'center',
              gap: 2,
              padding: 0
            }}
          >
            <span style={{
              transform: showDetails ? 'rotate(90deg)' : 'rotate(0deg)',
              transition: 'transform 0.2s'
            }}>▶</span>
            詳細情報
          </button>
          {showDetails && (
            <div style={{
              marginTop: 4,
              padding: '8px',
              backgroundColor: '#f8f9fa',
              borderRadius: 4,
              border: '1px solid #e9ecef'
            }}>
              {/* 説明文 */}
              {task.description && (
                <div style={{ marginBottom: 12 }}>
                  <h5 style={{ margin: '0 0 4px 0', fontSize: 11, fontWeight: 600, color: '#333' }}>説明</h5>
                  <p style={{
                    margin: 0,
                    fontSize: 11,
                    color: '#666',
                    lineHeight: 1.3
                  }}>
                    {task.description}
                  </p>
                </div>
              )}
              
              {/* ステータス・優先度設定 */}
              <div style={{ marginBottom: 12 }}>
                <h5 style={{ margin: '0 0 6px 0', fontSize: 11, fontWeight: 600, color: '#333' }}>ステータス・優先度</h5>
                
                <div style={{ marginBottom: 8 }}>
                  <div style={{ fontSize: 10, color: '#666', marginBottom: 4 }}>ステータス</div>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
                    {statusOptions.map((option) => (
                      <button
                        key={option.value}
                        onClick={async (e) => {
                          e.stopPropagation()
                          if (task.status !== option.value) {
                            await onTaskUpdate(task.id, { status: option.value })
                          }
                        }}
                        style={{
                          padding: '4px 8px',
                          backgroundColor: task.status === option.value ? option.color : '#fff',
                          color: task.status === option.value ? '#fff' : '#333',
                          border: `1px solid ${option.color}`,
                          borderRadius: 3,
                          cursor: 'pointer',
                          fontSize: 10,
                          fontWeight: task.status === option.value ? 600 : 400
                        }}
                      >
                        {option.label}
                      </button>
                    ))}
                  </div>
                </div>
                
                <div>
                  <div style={{ fontSize: 10, color: '#666', marginBottom: 4 }}>優先度</div>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
                    {priorityOptions.map((option) => (
                      <button
                        key={option.name}
                        onClick={async (e) => {
                          e.stopPropagation()
                          if (task.priority !== option.name) {
                            await changePriority(task.id, option.name)
                            await onTaskUpdate(task.id, { priority: option.name as TaskPriority })
                          }
                        }}
                        style={{
                          padding: '4px 8px',
                          backgroundColor: task.priority === option.name ? option.color : '#fff',
                          color: task.priority === option.name ? '#fff' : '#333',
                          border: `1px solid ${option.color}`,
                          borderRadius: 3,
                          cursor: 'pointer',
                          fontSize: 10,
                          fontWeight: task.priority === option.name ? 600 : 400
                        }}
                      >
                        {option.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
              
              {/* 優先度変更履歴 */}
              {latestPriorityChange && (
                <div>
                  <h5 style={{ margin: '0 0 4px 0', fontSize: 11, fontWeight: 600, color: '#333' }}>優先度変更履歴</h5>
                  <div style={{ fontSize: 9, color: '#666' }}>
                    <div>変更者: {latestPriorityChange.changed_by_email || 'システム'}</div>
                    <div>{new Date(latestPriorityChange.changed_at).toLocaleString('ja-JP')}</div>
                    {latestPriorityChange.reason && (
                      <div>理由: {latestPriorityChange.reason}</div>
                    )}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      )}

      {/* リンク表示セクション */}
      {showLinks && (
        <div style={{
          marginTop: 8,
          padding: 8,
          backgroundColor: '#f8f9fa',
          borderRadius: 4,
          border: '1px solid #e9ecef'
        }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 8
          }}>
            <div style={{
              fontSize: 11,
              fontWeight: 600,
              color: '#666'
            }}>
              リンク ({links.length})
            </div>
            <button
              onClick={(e) => {
                e.stopPropagation()
                setIsAddingLink(true)
              }}
              style={{
                padding: '2px 6px',
                fontSize: 10,
                backgroundColor: '#007bff',
                color: 'white',
                border: 'none',
                borderRadius: 3,
                cursor: 'pointer'
              }}
            >
              + 追加
            </button>
          </div>

          {/* 新規リンク追加フォーム */}
          {isAddingLink && (
            <div style={{
              marginBottom: 8,
              padding: 8,
              backgroundColor: 'white',
              borderRadius: 4,
              border: '1px solid #ddd'
            }}>
              <input
                type="text"
                placeholder="リンクタイトル"
                value={newLinkTitle}
                onChange={(e) => setNewLinkTitle(e.target.value)}
                style={{
                  width: '100%',
                  padding: 4,
                  fontSize: 11,
                  border: '1px solid #ccc',
                  borderRadius: 3,
                  marginBottom: 4
                }}
              />
              <input
                type="url"
                placeholder="URL"
                value={newLinkUrl}
                onChange={(e) => setNewLinkUrl(e.target.value)}
                style={{
                  width: '100%',
                  padding: 4,
                  fontSize: 11,
                  border: '1px solid #ccc',
                  borderRadius: 3,
                  marginBottom: 4
                }}
              />
              <input
                type="text"
                placeholder="説明（任意）"
                value={newLinkDescription}
                onChange={(e) => setNewLinkDescription(e.target.value)}
                style={{
                  width: '100%',
                  padding: 4,
                  fontSize: 11,
                  border: '1px solid #ccc',
                  borderRadius: 3,
                  marginBottom: 6
                }}
              />
              <div style={{ display: 'flex', gap: 4 }}>
                <button
                  onClick={(e) => {
                    e.stopPropagation()
                    handleAddLink()
                  }}
                  style={{
                    padding: '4px 8px',
                    fontSize: 10,
                    backgroundColor: '#28a745',
                    color: 'white',
                    border: 'none',
                    borderRadius: 3,
                    cursor: 'pointer'
                  }}
                >
                  保存
                </button>
                <button
                  onClick={(e) => {
                    e.stopPropagation()
                    setIsAddingLink(false)
                    setNewLinkTitle('')
                    setNewLinkUrl('')
                    setNewLinkDescription('')
                  }}
                  style={{
                    padding: '4px 8px',
                    fontSize: 10,
                    backgroundColor: '#6c757d',
                    color: 'white',
                    border: 'none',
                    borderRadius: 3,
                    cursor: 'pointer'
                  }}
                >
                  キャンセル
                </button>
              </div>
            </div>
          )}

          {/* 既存リンク一覧 */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            {linksLoading ? (
              <div style={{ fontSize: 10, color: '#666', textAlign: 'center' }}>
                読み込み中...
              </div>
            ) : links.length === 0 ? (
              <div style={{ fontSize: 10, color: '#666', textAlign: 'center' }}>
                リンクがありません
              </div>
            ) : (
              links.map((link) => (
                <div
                  key={link.id}
                  style={{
                    padding: 6,
                    backgroundColor: 'white',
                    borderRadius: 3,
                    border: '1px solid #ddd',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}
                >
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <a
                      href={link.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      onClick={(e) => e.stopPropagation()}
                      style={{
                        fontSize: 11,
                        fontWeight: 600,
                        color: '#007bff',
                        textDecoration: 'none',
                        display: 'block',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap'
                      }}
                      title={link.title}
                    >
                      {link.title}
                    </a>
                    {link.description && (
                      <div style={{
                        fontSize: 9,
                        color: '#666',
                        marginTop: 2,
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap'
                      }}>
                        {link.description}
                      </div>
                    )}
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation()
                      handleDeleteLink(link.id)
                    }}
                    style={{
                      padding: 2,
                      fontSize: 10,
                      backgroundColor: 'transparent',
                      color: '#dc3545',
                      border: 'none',
                      cursor: 'pointer',
                      marginLeft: 4
                    }}
                    title="削除"
                  >
                    ×
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      )}

      {/* ファイル表示セクション */}
      {showFiles && (
        <div style={{
          marginTop: 8,
          padding: 8,
          backgroundColor: '#f8f9fa',
          borderRadius: 4,
          border: '1px solid #e9ecef'
        }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 8
          }}>
            <div style={{
              fontSize: 11,
              fontWeight: 600,
              color: '#666'
            }}>
              ファイル ({files.length})
            </div>
            <label
              style={{
                padding: '2px 6px',
                fontSize: 10,
                backgroundColor: '#28a745',
                color: 'white',
                border: 'none',
                borderRadius: 3,
                cursor: 'pointer'
              }}
            >
              + アップロード
              <input
                type="file"
                multiple
                style={{ display: 'none' }}
                onChange={async (e) => {
                  if (e.target.files) {
                    for (const file of Array.from(e.target.files)) {
                      try {
                        await uploadFile(file)
                      } catch (error) {
                        console.error('ファイルアップロードエラー:', error)
                      }
                    }
                    // ファイル選択をリセット
                    e.target.value = ''
                  }
                }}
              />
            </label>
          </div>

          {/* ファイル一覧 */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            {filesLoading ? (
              <div style={{ fontSize: 10, color: '#666', textAlign: 'center' }}>
                読み込み中...
              </div>
            ) : files.length === 0 ? (
              <div style={{ fontSize: 10, color: '#666', textAlign: 'center' }}>
                ファイルがありません
              </div>
            ) : (
              files.map((file) => (
                <div
                  key={file.id}
                  style={{
                    padding: 6,
                    backgroundColor: 'white',
                    borderRadius: 3,
                    border: '1px solid #ddd',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}
                >
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div
                      style={{
                        fontSize: 11,
                        fontWeight: 600,
                        color: '#007bff',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap'
                      }}
                      title={file.name}
                    >
                      📄 {file.name}
                    </div>
                    <div style={{
                      fontSize: 9,
                      color: '#666',
                      marginTop: 2
                    }}>
                      {new Date(file.created_at).toLocaleDateString('ja-JP')}
                      {file.total_size_bytes && ` • ${Math.round(file.total_size_bytes / 1024)}KB`}
                    </div>
                  </div>
                  <button
                    onClick={async (e) => {
                      e.stopPropagation()
                      if (confirm('このファイルを削除しますか？')) {
                        try {
                          await deleteFile(file.id)
                        } catch (error) {
                          console.error('ファイル削除エラー:', error)
                        }
                      }
                    }}
                    style={{
                      padding: 2,
                      fontSize: 10,
                      backgroundColor: 'transparent',
                      color: '#dc3545',
                      border: 'none',
                      cursor: 'pointer',
                      marginLeft: 4
                    }}
                    title="削除"
                  >
                    🗑️
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      )}

      {/* 期限表示 - コンパクト */}
      {task.due_at && (
        <div style={{
          marginTop: 8,
          textAlign: 'center',
          padding: 6,
          backgroundColor: '#fff3cd',
          borderRadius: 4,
          border: '1px solid #ffeaa7'
        }}>
          {formatDueDate(task.due_at)}
        </div>
      )}
    </div>
  )
}
