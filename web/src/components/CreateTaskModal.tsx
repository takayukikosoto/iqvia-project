import React, { useState } from 'react'
import { Task } from '../types'

interface CreateTaskModalProps {
  onSubmit: (task: Partial<Task>) => void
  onClose: () => void
}

export default function CreateTaskModal({ onSubmit, onClose }: CreateTaskModalProps) {
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [priority, setPriority] = useState<Task['priority']>('medium')
  const [dueAt, setDueAt] = useState('')
  const [status, setStatus] = useState<Task['status']>('todo')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!title.trim()) return
    
    onSubmit({
      title: title.trim(),
      description: description.trim() || undefined,
      priority,
      status,
      due_at: dueAt ? `${dueAt}T00:00:00+00` : undefined
    })
    
    // Reset form
    setTitle('')
    setDescription('')
    setPriority('medium')
    setDueAt('')
    setStatus('todo')
  }

  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(0, 0, 0, 0.5)',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      zIndex: 1000
    }}>
      <div style={{
        backgroundColor: 'white',
        borderRadius: 8,
        padding: 24,
        width: '100%',
        maxWidth: 500,
        maxHeight: '80vh',
        overflow: 'auto',
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
          <h2 style={{ fontSize: 20, fontWeight: 'bold', margin: 0 }}>新しいタスクを作成</h2>
          <button
            onClick={onClose}
            style={{
              background: 'none',
              border: 'none',
              fontSize: 18,
              cursor: 'pointer',
              color: '#666'
            }}
          >
            ✕
          </button>
        </div>
        
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <div>
            <label style={{ display: 'block', marginBottom: 4, fontSize: 14, fontWeight: 500 }}>
              タスク名 *
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              style={{
                width: '100%',
                padding: 10,
                border: '1px solid #ccc',
                borderRadius: 4,
                fontSize: 14
              }}
              placeholder="タスク名を入力"
            />
          </div>
          
          <div>
            <label style={{ display: 'block', marginBottom: 4, fontSize: 14, fontWeight: 500 }}>
              説明
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              style={{
                width: '100%',
                padding: 10,
                border: '1px solid #ccc',
                borderRadius: 4,
                fontSize: 14,
                minHeight: 80,
                resize: 'vertical'
              }}
              placeholder="タスクの詳細を入力"
            />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            <div>
              <label style={{ display: 'block', marginBottom: 4, fontSize: 14, fontWeight: 500 }}>優先度</label>
              <select
                value={priority}
                onChange={(e) => setPriority(e.target.value as Task['priority'])}
                style={{
                  width: '100%',
                  padding: 10,
                  border: '1px solid #ccc',
                  borderRadius: 4,
                  fontSize: 14
                }}
              >
                <option value="low">低</option>
                <option value="medium">中</option>
                <option value="high">高</option>
                <option value="urgent">緊急</option>
              </select>
            </div>

            <div>
              <label style={{ display: 'block', marginBottom: 4, fontSize: 14, fontWeight: 500 }}>ステータス</label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value as Task['status'])}
                style={{
                  width: '100%',
                  padding: 10,
                  border: '1px solid #ccc',
                  borderRadius: 4,
                  fontSize: 14
                }}
              >
                <option value="todo">未着手</option>
                <option value="doing">進行中</option>
                <option value="review">レビュー中</option>
                <option value="done">完了</option>
                <option value="blocked">停止中</option>
              </select>
            </div>
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: 4, fontSize: 14, fontWeight: 500 }}>期限</label>
            <input
              type="date"
              value={dueAt}
              onChange={(e) => setDueAt(e.target.value)}
              style={{
                width: '100%',
                padding: 10,
                border: '1px solid #ccc',
                borderRadius: 4,
                fontSize: 14
              }}
            />
          </div>

          <div style={{ display: 'flex', gap: 12, justifyContent: 'flex-end', marginTop: 8 }}>
            <button
              type="button"
              onClick={onClose}
              style={{
                padding: '10px 16px',
                backgroundColor: '#6c757d',
                color: 'white',
                border: 'none',
                borderRadius: 4,
                cursor: 'pointer',
                fontSize: 14
              }}
            >
              キャンセル
            </button>
            <button
              type="submit"
              style={{
                padding: '10px 16px',
                backgroundColor: '#007bff',
                color: 'white',
                border: 'none',
                borderRadius: 4,
                cursor: 'pointer',
                fontSize: 14
              }}
            >
              作成
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
