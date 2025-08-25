import React, { useState } from 'react'
import { useTasks, Task } from '../hooks/useTasks'

const StatusBadge = ({ status }: { status: Task['status'] }) => {
  const getStatusStyle = (status: Task['status']) => {
    switch (status) {
      case 'todo':
        return 'bg-gray-100 text-gray-800'
      case 'review':
        return 'bg-yellow-100 text-yellow-800'
      case 'done':
        return 'bg-green-100 text-green-800'
      case 'resolved':
        return 'bg-blue-100 text-blue-800'
      case 'completed':
        return 'bg-purple-100 text-purple-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusText = (status: Task['status']) => {
    switch (status) {
      case 'todo': return '未着手'
      case 'review': return 'レビュー'
      case 'done': return '完了'
      case 'resolved': return '解決済み'
      case 'completed': return '完了済み'
      default: return status
    }
  }

  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusStyle(status)}`}>
      {getStatusText(status)}
    </span>
  )
}

const PriorityBadge = ({ priority }: { priority: Task['priority'] }) => {
  const getPriorityStyle = (priority: Task['priority']) => {
    switch (priority) {
      case 'urgent':
        return 'bg-red-100 text-red-800 border border-red-200'
      case 'high':
        return 'bg-orange-100 text-orange-800 border border-orange-200'
      case 'medium':
        return 'bg-blue-100 text-blue-800 border border-blue-200'
      case 'low':
        return 'bg-gray-100 text-gray-600 border border-gray-200'
      default:
        return 'bg-gray-100 text-gray-600 border border-gray-200'
    }
  }

  const getPriorityText = (priority: Task['priority']) => {
    switch (priority) {
      case 'urgent': return '緊急'
      case 'high': return '高'
      case 'medium': return '中'
      case 'low': return '低'
      default: return priority
    }
  }

  return (
    <span className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${getPriorityStyle(priority)}`}>
      {getPriorityText(priority)}
    </span>
  )
}

export default function TaskList() {
  const { tasks, loading, error, updateTaskStatus, updateTaskPriority } = useTasks()
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const [filterPriority, setFilterPriority] = useState<string>('all')

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-4 bg-red-50 border border-red-200 rounded-md">
        <p className="text-red-600">エラーが発生しました: {error}</p>
      </div>
    )
  }

  // フィルタリング
  const filteredTasks = tasks.filter((task: Task) => {
    const statusMatch = filterStatus === 'all' || task.status === filterStatus
    const priorityMatch = filterPriority === 'all' || task.priority === filterPriority
    return statusMatch && priorityMatch
  })

  const formatDate = (dateString: string | null) => {
    if (!dateString) return '-'
    return new Date(dateString).toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  const handleStatusChange = async (taskId: string, newStatus: Task['status']) => {
    await updateTaskStatus(taskId, newStatus)
  }

  const handlePriorityChange = async (taskId: string, newPriority: Task['priority']) => {
    await updateTaskPriority(taskId, newPriority)
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-4">タスクリスト</h1>
        
        {/* フィルター */}
        <div className="flex gap-4 mb-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">ステータス</label>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="border border-gray-300 rounded-md px-3 py-2 text-sm"
            >
              <option value="all">すべて</option>
              <option value="todo">未着手</option>
              <option value="review">レビュー</option>
              <option value="done">完了</option>
              <option value="resolved">解決済み</option>
              <option value="completed">完了済み</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">優先度</label>
            <select
              value={filterPriority}
              onChange={(e) => setFilterPriority(e.target.value)}
              className="border border-gray-300 rounded-md px-3 py-2 text-sm"
            >
              <option value="all">すべて</option>
              <option value="urgent">緊急</option>
              <option value="high">高</option>
              <option value="medium">中</option>
              <option value="low">低</option>
            </select>
          </div>
        </div>

        <p className="text-gray-600">
          {filteredTasks.length}件のタスクを表示中（全{tasks.length}件）
        </p>
      </div>

      {/* タスクリスト */}
      <div className="bg-white shadow overflow-hidden sm:rounded-md">
        <ul className="divide-y divide-gray-200">
          {filteredTasks.map((task: Task) => (
            <li key={task.id} className="px-6 py-4 hover:bg-gray-50">
              <div className="flex items-center justify-between">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="text-lg font-medium text-gray-900 truncate">
                      {task.title}
                    </h3>
                    <StatusBadge status={task.status} />
                    <PriorityBadge priority={task.priority} />
                  </div>
                  
                  {task.description && (
                    <p className="text-gray-600 text-sm mb-2 line-clamp-2">
                      {task.description}
                    </p>
                  )}
                  
                  <div className="flex items-center gap-4 text-sm text-gray-500">
                    <span>期日: {formatDate(task.due_at)}</span>
                    <span>作成日: {formatDate(task.created_at)}</span>
                  </div>
                </div>
                
                <div className="flex items-center gap-2 ml-4">
                  {/* ステータス変更 */}
                  <select
                    value={task.status}
                    onChange={(e) => handleStatusChange(task.id, e.target.value as Task['status'])}
                    className="border border-gray-300 rounded-md px-2 py-1 text-xs"
                  >
                    <option value="todo">未着手</option>
                    <option value="review">レビュー</option>
                    <option value="done">完了</option>
                    <option value="resolved">解決済み</option>
                    <option value="completed">完了済み</option>
                  </select>
                  
                  {/* 優先度変更 */}
                  <select
                    value={task.priority}
                    onChange={(e) => handlePriorityChange(task.id, e.target.value as Task['priority'])}
                    className="border border-gray-300 rounded-md px-2 py-1 text-xs"
                  >
                    <option value="urgent">緊急</option>
                    <option value="high">高</option>
                    <option value="medium">中</option>
                    <option value="low">低</option>
                  </select>
                </div>
              </div>
            </li>
          ))}
        </ul>
        
        {filteredTasks.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">該当するタスクがありません</p>
          </div>
        )}
      </div>
    </div>
  )
}
