import React, { useState, useEffect } from 'react'
import { Task, TaskPriority, TaskLink } from '../types'
import { usePriority } from '../hooks/usePriority'
import { useTaskLinks } from '../hooks/useTaskLinks'

interface TaskCardProps {
  task: Task
  onTaskUpdate: (taskId: string, updates: Partial<Task>) => void
  onTaskDelete: (taskId: string) => void
}

const priorityColors = {
  low: '#28a745',
  medium: '#ffc107',
  high: '#fd7e14',
  urgent: '#dc3545'
}

const priorityLabels: Record<TaskPriority, string> = {
  low: '低',
  medium: '中',
  high: '高',
  urgent: '緊急'
}

const statusOptions: { value: Task['status']; label: string }[] = [
  { value: 'todo', label: '未着手' },
  { value: 'review', label: 'レビュー中' },
  { value: 'done', label: '完了' },
  { value: 'resolved', label: '対応済み' }
]

export default function TaskCard({ task, onTaskUpdate, onTaskDelete }: TaskCardProps) {
  const { priorityOptions, changePriority, getPriorityColor, getPriorityLabel, loading, getPriorityHistory } = usePriority()
  const { links, loading: linksLoading, addLink, updateLink, deleteLink } = useTaskLinks(task.id)
  
  const [isEditing, setIsEditing] = useState(false)
  const [showLinks, setShowLinks] = useState(false)
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
        Due: {date.toLocaleDateString('ja-JP')}
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
      // フォールバック色
      switch (task.priority) {
        case 'low': return '#e8f5e8'
        case 'medium': return '#fff8e1'
        case 'high': return '#fff3e0'
        case 'urgent': return '#ffebee'
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
        case 'low': return '#28a745'
        case 'medium': return '#ffc107'
        case 'high': return '#fd7e14'
        case 'urgent': return '#dc3545'
        default: return '#e9ecef'
      }
    }
    
    // データベースの色を使用
    const priorityOption = priorityOptions.find(option => option.name === task.priority)
    return priorityOption ? priorityOption.color : '#e9ecef'
  }

  return (
    <div style={{
      backgroundColor: getBackgroundColor(),
      borderRadius: 6,
      padding: 12,
      boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
      cursor: 'pointer',
      transition: 'all 0.2s ease',
      position: 'relative',
      border: `2px solid ${getBorderColor()}`
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
        marginBottom: 8
      }}>
        <h4 style={{
          margin: 0,
          fontSize: 14,
          fontWeight: 600,
          lineHeight: 1.3,
          flex: 1
        }}>
          {task.title}
        </h4>
        
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
            🔗
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
      
      {task.description && (
        <p style={{
          margin: '0 0 12px 0',
          fontSize: 12,
          color: '#666',
          lineHeight: 1.4
        }}>
          {task.description.length > 100 
            ? `${task.description.substring(0, 100)}...` 
            : task.description
          }
        </p>
      )}
      
      {/* ステータス・優先度 - コンパクト2列表示 */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr',
        gap: 8,
        marginBottom: 12
      }}>
        {/* ステータス */}
        <div style={{
          padding: 8,
          backgroundColor: '#f8f9fa',
          borderRadius: 6,
          border: '1px solid #e9ecef'
        }}>
          <div style={{
            fontSize: 10,
            fontWeight: 600,
            color: '#666',
            marginBottom: 4,
            textAlign: 'center'
          }}>ステータス</div>
          <select
            value={task.status}
            onChange={(e) => {
              e.stopPropagation()
              onTaskUpdate(task.id, { status: e.target.value as Task['status'] })
            }}
            style={{
              fontSize: 11,
              fontWeight: 600,
              border: '1px solid #ccc',
              borderRadius: 4,
              padding: '4px 6px',
              width: '100%',
              backgroundColor: 'white'
            }}
          >
            {statusOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>

        {/* 優先度 - コンパクト */}
        <div style={{
          padding: 8,
          backgroundColor: '#f8f9fa',
          borderRadius: 6,
          border: '1px solid #e9ecef'
        }}>
          <div style={{
            fontSize: 10,
            fontWeight: 600,
            color: '#666',
            marginBottom: 4,
            textAlign: 'center'
          }}>優先度</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2 }}>
            {(loading || !priorityOptions || priorityOptions.length === 0) ? (
              // フォールバック用のボタン
              <>
                <button
                  onClick={(e) => handlePriorityChange(e, 'low')}
                  style={{
                    padding: '4px 2px',
                    fontSize: 9,
                    borderRadius: 3,
                    border: 'none',
                    fontWeight: 600,
                    cursor: 'pointer',
                    backgroundColor: task.priority === 'low' ? '#28a745' : '#e9ecef',
                    color: task.priority === 'low' ? 'white' : '#666'
                  }}
                >
                  低
                </button>
                <button
                  onClick={(e) => handlePriorityChange(e, 'medium')}
                  style={{
                    padding: '4px 2px',
                    fontSize: 9,
                    borderRadius: 3,
                    border: 'none',
                    fontWeight: 600,
                    cursor: 'pointer',
                    backgroundColor: task.priority === 'medium' ? '#ffc107' : '#e9ecef',
                    color: task.priority === 'medium' ? 'white' : '#666'
                  }}
                >
                  中
                </button>
                <button
                  onClick={(e) => handlePriorityChange(e, 'high')}
                  style={{
                    padding: '4px 2px',
                    fontSize: 9,
                    borderRadius: 3,
                    border: 'none',
                    fontWeight: 600,
                    cursor: 'pointer',
                    backgroundColor: task.priority === 'high' ? '#fd7e14' : '#e9ecef',
                    color: task.priority === 'high' ? 'white' : '#666'
                  }}
                >
                  高
                </button>
                <button
                  onClick={(e) => handlePriorityChange(e, 'urgent')}
                  style={{
                    padding: '4px 2px',
                    fontSize: 9,
                    borderRadius: 3,
                    border: 'none',
                    fontWeight: 600,
                    cursor: 'pointer',
                    backgroundColor: task.priority === 'urgent' ? '#dc3545' : '#e9ecef',
                    color: task.priority === 'urgent' ? 'white' : '#666'
                  }}
                >
                  緊急
                </button>
              </>
            ) : (
              // データベースから取得したボタン
              priorityOptions.slice(0, 4).map((option) => (
                <button
                  key={option.name}
                  onClick={(e) => handlePriorityChange(e, option.name)}
                  style={{
                    padding: '4px 2px',
                    fontSize: 9,
                    borderRadius: 3,
                    border: 'none',
                    fontWeight: 600,
                    cursor: 'pointer',
                    backgroundColor: task.priority === option.name ? option.color : '#e9ecef',
                    color: task.priority === option.name ? 'white' : '#666'
                  }}
                >
                  {option.label}
                </button>
              ))
            )}
          </div>
        </div>
      </div>

      {/* 最新の優先度変更情報 - 必要時のみ表示 */}
      {latestPriorityChange && (
        <div style={{
          marginBottom: 8,
          fontSize: 9,
          color: '#666',
          backgroundColor: '#f8f9fa',
          padding: 6,
          borderRadius: 3,
          border: '1px solid #e9ecef'
        }}>
          <div style={{ fontWeight: 600, marginBottom: 2 }}>優先度変更履歴</div>
          <div>変更者: {latestPriorityChange.changed_by_email || 'システム'}</div>
          <div>{new Date(latestPriorityChange.changed_at).toLocaleString('ja-JP')}</div>
          {latestPriorityChange.reason && (
            <div>理由: {latestPriorityChange.reason}</div>
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
