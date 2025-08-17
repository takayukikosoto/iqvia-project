import React, { useState } from 'react'
import { useAuth } from './hooks/useAuth'
import Auth from './components/Auth'
import Tasks from './pages/Tasks'
import AdminDashboard from './pages/AdminDashboard'
import TaskDetail from './pages/TaskDetail'

type CurrentPage = 'tasks' | 'admin' | 'task-detail'

export default function App() {
  const { user, loading, signOut } = useAuth()
  const [currentPage, setCurrentPage] = useState<CurrentPage>('tasks')
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null)

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!user) {
    return <Auth onAuthSuccess={() => {}} />
  }

  const handleTaskSelect = (taskId: string) => {
    setSelectedTaskId(taskId)
    setCurrentPage('task-detail')
  }

  const handleBackToTasks = () => {
    setSelectedTaskId(null)
    setCurrentPage('tasks')
  }

  const renderCurrentPage = () => {
    switch (currentPage) {
      case 'admin':
        return <AdminDashboard />
      case 'task-detail':
        return selectedTaskId ? (
          <TaskDetail taskId={selectedTaskId} onBack={handleBackToTasks} />
        ) : (
          <Tasks onTaskSelect={handleTaskSelect} />
        )
      case 'tasks':
      default:
        return <Tasks onTaskSelect={handleTaskSelect} />
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-8">
              <h1 className="text-2xl font-bold text-gray-900">IQVIA × JTB</h1>
              <nav className="flex space-x-6">
                <button
                  onClick={() => setCurrentPage('tasks')}
                  className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    currentPage === 'tasks' 
                      ? 'bg-blue-100 text-blue-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                >
                  タスク管理
                </button>
                <button
                  onClick={() => setCurrentPage('admin')}
                  className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    currentPage === 'admin' 
                      ? 'bg-blue-100 text-blue-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                >
                  管理者ダッシュボード
                </button>
              </nav>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-600">{user.email}</span>
              <button
                onClick={signOut}
                className="px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700 transition-colors"
              >
                ログアウト
              </button>
            </div>
          </div>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto">
        {renderCurrentPage()}
      </main>
    </div>
  )
}
