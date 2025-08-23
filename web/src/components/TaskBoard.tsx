import React from 'react'
import { Task, TaskStatus } from '../types'
import TaskCard from './TaskCard'
import { useStatuses } from '../hooks/useStatuses'
import { useRecentComments, RecentCommentInfo } from '../hooks/useRecentComments'

interface TaskBoardProps {
  tasks: Task[]
  onTaskUpdate: (taskId: string, updates: Partial<Task>) => void
  onTaskDelete: (taskId: string) => void
  onTaskSelect?: (taskId: string) => void
}

export default function TaskBoard({ tasks, onTaskUpdate, onTaskDelete, onTaskSelect }: TaskBoardProps) {
  const { getBoardStatuses, getStatusLabel, getStatusColor } = useStatuses()
  const boardStatuses = getBoardStatuses()
  const taskIds = tasks.map(task => task.id)
  const { commentInfo } = useRecentComments(taskIds)

  const getTasksByStatus = (statusName: string) => {
    return tasks.filter(task => task.status === statusName)
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
    <div style={{ display: 'flex', gap: 16, height: '100%', padding: 16 }}>
      {boardStatuses.map(status => (
        <div
          key={status.name}
          onDragOver={handleDragOver}
          onDrop={(e) => handleDrop(e, status.name as TaskStatus)}
          style={{
            flex: 1,
            backgroundColor: '#f9fafb',
            borderRadius: 8,
            padding: 12,
            minHeight: 400
          }}
          onDragEnter={(e) => {
            e.preventDefault()
            e.currentTarget.style.backgroundColor = status.name === 'todo' ? '#f3f4f6' :
              status.name === 'review' ? '#e5e7eb' :
              status.name === 'done' ? '#d1d5db' : '#9ca3af'
          }}
          onDragLeave={(e) => {
            e.preventDefault()
            e.currentTarget.style.backgroundColor = '#f9fafb'
          }}
        >
          <h3 style={{
            margin: '0 0 12px 0',
            fontSize: 16,
            fontWeight: 600,
            color: '#333',
            textAlign: 'center',
            padding: '8px 0',
            borderBottom: '2px solid rgba(0,0,0,0.1)'
          }}>
            {status.label} ({getTasksByStatus(status.name).length})
          </h3>
          
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            gap: 12
          }}>
            {getTasksByStatus(status.name).map(task => (
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
