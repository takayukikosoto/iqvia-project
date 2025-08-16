import React, { useState } from 'react'
import { Task, TaskPriority } from '../types'

interface TaskCardProps {
  task: Task
  onStatusChange: (taskId: string, newStatus: Task['status']) => void
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

export default function TaskCard({ task, onStatusChange, onTaskUpdate, onTaskDelete }: TaskCardProps) {
  const [isEditing, setIsEditing] = useState(false)
  const [title, setTitle] = useState(task.title)
  const [description, setDescription] = useState(task.description || '')
  const [priority, setPriority] = useState(task.priority)
  const [dueAt, setDueAt] = useState(task.due_at ? task.due_at.split('T')[0] : '')

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

  return (
    <div style={{
      backgroundColor: 'white',
      borderRadius: 6,
      padding: 12,
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      cursor: 'pointer',
      transition: 'transform 0.1s',
      position: 'relative'
    }}
    onMouseEnter={(e) => {
      e.currentTarget.style.transform = 'translateY(-1px)'
    }}
    onMouseLeave={(e) => {
      e.currentTarget.style.transform = 'translateY(0)'
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
          margin: '0 0 8px 0',
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
      
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: 8
      }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: 8
        }}>
          <span style={{
            backgroundColor: priorityColors[task.priority],
            color: 'white',
            fontSize: 10,
            fontWeight: 'bold',
            padding: '2px 6px',
            borderRadius: 3,
            textTransform: 'uppercase'
          }}>
            {task.priority}
          </span>
          
          <select
            value={task.status}
            onChange={(e) => onStatusChange(task.id, e.target.value as Task['status'])}
            onClick={(e) => e.stopPropagation()}
            style={{
              fontSize: 10,
              padding: '2px 4px',
              border: '1px solid #ccc',
              borderRadius: 3,
              backgroundColor: 'white'
            }}
          >
            {statusOptions.map(option => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>
      </div>
      
      {formatDueDate(task.due_at)}
    </div>
  )
}
