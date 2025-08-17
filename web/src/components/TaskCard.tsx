import React, { useState, useEffect } from 'react'
import { Task, TaskPriority } from '../types'
import { usePriority } from '../hooks/usePriority'

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
  { value: 'doing', label: '進行中' },
  { value: 'review', label: 'レビュー中' },
  { value: 'done', label: '完了' },
  { value: 'blocked', label: '停止中' }
]

export default function TaskCard({ task, onTaskUpdate, onTaskDelete }: TaskCardProps) {
  const { priorityOptions, changePriority, getPriorityColor, getPriorityLabel, loading, getPriorityHistory } = usePriority()
  
  const [isEditing, setIsEditing] = useState(false)
  const [title, setTitle] = useState(task.title)
  const [description, setDescription] = useState(task.description || '')
  const [priority, setPriority] = useState(task.priority)
  const [dueAt, setDueAt] = useState(task.due_at ? task.due_at.split('T')[0] : '')
  const [priorityHistory, setPriorityHistory] = useState<any[]>([])
  
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
      
      {/* ステータス表示 - 大きく独立 */}
      <div style={{
        marginBottom: 12,
        padding: 12,
        backgroundColor: '#f8f9fa',
        borderRadius: 6,
        border: '1px solid #e9ecef'
      }}>
        <div style={{
          fontSize: 11,
          fontWeight: 600,
          color: '#666',
          marginBottom: 4
        }}>ステータス</div>
        <select
          value={task.status}
          onChange={(e) => {
            e.stopPropagation()
            onTaskUpdate(task.id, { status: e.target.value as Task['status'] })
          }}
          style={{
            fontSize: 14,
            fontWeight: 600,
            border: '1px solid #ccc',
            borderRadius: 4,
            padding: '6px 8px',
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

      {/* 優先度ボタン - 横並び */}
      <div style={{ marginBottom: 12 }}>
        <div style={{
          fontSize: 11,
          fontWeight: 600,
          color: '#666',
          marginBottom: 6
        }}>優先度</div>
        <div style={{ display: 'flex', gap: 4 }}>
          {(loading || !priorityOptions || priorityOptions.length === 0) ? (
            // フォールバック用のボタン
            <>
              <button
                onClick={(e) => handlePriorityChange(e, 'low')}
                style={{
                  flex: 1,
                  padding: '6px 8px',
                  fontSize: 11,
                  borderRadius: 4,
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
                  flex: 1,
                  padding: '6px 8px',
                  fontSize: 11,
                  borderRadius: 4,
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
                  flex: 1,
                  padding: '6px 8px',
                  fontSize: 11,
                  borderRadius: 4,
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
                  flex: 1,
                  padding: '6px 8px',
                  fontSize: 11,
                  borderRadius: 4,
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
            priorityOptions.map((option) => (
              <button
                key={option.name}
                onClick={(e) => handlePriorityChange(e, option.name)}
                style={{
                  flex: 1,
                  padding: '6px 8px',
                  fontSize: 11,
                  borderRadius: 4,
                  border: 'none',
                  fontWeight: 600,
                  cursor: 'pointer',
                  transition: 'all 0.2s',
                  backgroundColor: task.priority === option.name ? option.color : '#e9ecef',
                  color: task.priority === option.name ? 'white' : '#666'
                }}
              >
                {option.label}
              </button>
            ))
          )}
        </div>
        
        {/* 最新の優先度変更情報 */}
        {latestPriorityChange && (
          <div style={{
            marginTop: 6,
            fontSize: 10,
            color: '#666',
            backgroundColor: '#f8f9fa',
            padding: 6,
            borderRadius: 3
          }}>
            <div>最終変更: {latestPriorityChange.changed_by_email || 'システム'}</div>
            <div>{new Date(latestPriorityChange.changed_at).toLocaleString('ja-JP')}</div>
            {latestPriorityChange.reason && (
              <div>理由: {latestPriorityChange.reason}</div>
            )}
          </div>
        )}
      </div>

      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: 8
      }}>
        <div></div>
        {formatDueDate(task.due_at)}
      </div>
    </div>
  )
}
