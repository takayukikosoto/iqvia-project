import React from 'react'
import TaskCard from './TaskCard'
import { Task } from '../types'

type TaskStatus = 'todo' | 'doing' | 'review' | 'done' | 'blocked'

interface TaskBoardProps {
  tasks: Task[]
  onTaskUpdate: (taskId: string, updates: Partial<Task>) => void
  onTaskDelete: (taskId: string) => void
}

const statusLabels: Record<TaskStatus, string> = {
  todo: '未着手',
  doing: '進行中',
  review: 'レビュー中',
  done: '完了',
  blocked: '停止中'
}

const statusColors: Record<TaskStatus, string> = {
  todo: 'bg-gray-200',
  doing: 'bg-yellow-200',
  review: 'bg-blue-200',
  done: 'bg-green-200',
  blocked: 'bg-red-200'
}

export default function TaskBoard({ tasks, onTaskUpdate, onTaskDelete }: TaskBoardProps) {
  const statuses: (keyof typeof statusLabels)[] = ['todo', 'doing', 'review', 'done', 'blocked']
  
  const getTasksByStatus = (status: string) => {
    return tasks.filter(task => task.status === status)
  }

  const handleStatusChange = (taskId: string, newStatus: Task['status']) => {
    onTaskUpdate(taskId, { status: newStatus })
  }

  return (
    <div style={{
      display: 'grid',
      gridTemplateColumns: 'repeat(5, 1fr)',
      gap: 16,
      minHeight: '60vh'
    }}>
      {statuses.map(status => (
        <div key={status} style={{
          backgroundColor: statusColors[status],
          borderRadius: 8,
          padding: 16,
          minHeight: 400
        }}>
          <h3 style={{
            margin: '0 0 16px 0',
            fontSize: 16,
            fontWeight: 600,
            color: '#333'
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
                onStatusChange={handleStatusChange}
                onTaskUpdate={onTaskUpdate}
                onTaskDelete={onTaskDelete}
              />
            ))}
          </div>
        </div>
      ))}
    </div>
  )
}
