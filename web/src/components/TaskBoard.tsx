import React from 'react'
import TaskCard from './TaskCard'
import { Task } from '../types'
import { useRecentComments } from '../hooks/useRecentComments'

type TaskStatus = 'todo' | 'review' | 'done' | 'resolved'

interface TaskBoardProps {
  tasks: Task[]
  onTaskUpdate: (taskId: string, updates: Partial<Task>) => void
  onTaskDelete: (taskId: string) => void
  onTaskSelect?: (taskId: string) => void
}

const statusLabels: Record<TaskStatus, string> = {
  todo: '未着手',
  review: 'レビュー中',
  done: '作業完了',
  resolved: '対応済み'
}

const statusColors: Record<TaskStatus, string> = {
  todo: '#f9fafb',
  review: '#f3f4f6', 
  done: '#e5e7eb',
  resolved: '#d1d5db'
}

export default function TaskBoard({ tasks, onTaskUpdate, onTaskDelete, onTaskSelect }: TaskBoardProps) {
  const statuses: (keyof typeof statusLabels)[] = ['todo', 'review', 'done', 'resolved']
  const taskIds = tasks.map(task => task.id)
  const { commentInfo } = useRecentComments(taskIds)
  
  const getTasksByStatus = (status: string) => {
    return tasks.filter(task => task.status === status)
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    e.dataTransfer.dropEffect = 'move'
  }

  const handleDrop = async (e: React.DragEvent, newStatus: TaskStatus) => {
    e.preventDefault()
    const taskId = e.dataTransfer.getData('text/plain')
    const task = tasks.find(t => t.id === taskId)
    
    if (task && task.status !== newStatus) {
      await onTaskUpdate(taskId, { status: newStatus })
    }
  }

  return (
    <div style={{
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
      gap: 16,
      minHeight: '60vh',
      padding: '0 8px'
    }}>
      {statuses.map(status => (
        <div 
          key={status} 
          onDragOver={handleDragOver}
          onDrop={(e) => handleDrop(e, status)}
          style={{
            backgroundColor: statusColors[status],
            borderRadius: 8,
            padding: 12,
            minHeight: 400,
            minWidth: 280,
            maxWidth: '100%',
            transition: 'background-color 0.2s ease'
          }}
          onDragEnter={(e) => {
            e.preventDefault()
            e.currentTarget.style.backgroundColor = status === 'todo' ? '#f3f4f6' :
              status === 'review' ? '#e5e7eb' :
              status === 'done' ? '#d1d5db' : '#9ca3af'
          }}
          onDragLeave={(e) => {
            e.preventDefault()
            e.currentTarget.style.backgroundColor = statusColors[status]
          }}>
          <h3 style={{
            margin: '0 0 12px 0',
            fontSize: 16,
            fontWeight: 600,
            color: '#333',
            textAlign: 'center',
            padding: '8px 0',
            borderBottom: '2px solid rgba(0,0,0,0.1)'
          }}>
            {statusLabels[status]} ({getTasksByStatus(status).length})
          </h3>
          
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            gap: 12
          }}>
            {getTasksByStatus(status).map(task => (
              <TaskCard
                key={task.id}
                task={task}
                onTaskUpdate={onTaskUpdate}
                onTaskDelete={onTaskDelete}
                onTaskSelect={onTaskSelect}
                commentInfo={commentInfo[task.id]}
              />
            ))}
          </div>
        </div>
      ))}
    </div>
  )
}
