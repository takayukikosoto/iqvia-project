import React, { useState, useEffect } from 'react'
import { useAuth } from './hooks/useAuth'
import { useRole } from './hooks/useRole'
import Auth from './components/Auth'
import Tasks from './pages/Tasks'
import AdminDashboard from './pages/AdminDashboard'
import MyPage from './pages/MyPage'
import Files from './pages/Files'
import TaskDetail from './pages/TaskDetail'
import Calendar from './pages/Calendar'
import CompletedTasks from './pages/CompletedTasks'
import UserManagement from './pages/UserManagement'
import TaskList from './pages/TaskList'

type CurrentPage = 'tasks' | 'task-list' | 'admin' | 'mypage' | 'files' | 'calendar' | 'task-detail' | 'completed' | 'user-management'

export default function App() {
  const { user, loading, signOut } = useAuth()
  const { userRole, hasPermission } = useRole()
  const isAdmin = userRole?.role === 'admin'
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
      case 'user-management':
        return <UserManagement />
      case 'mypage':
        return <MyPage />
      case 'files':
        return <Files />
      case 'calendar':
        return <Calendar />
      case 'completed':
        return <CompletedTasks />
      case 'task-list':
        return <TaskList />
      case 'task-detail':
        return selectedTaskId ? (
          <TaskDetail taskId={selectedTaskId} onBack={handleBackToTasks} />
        ) : (
          <Tasks onTaskSelect={handleTaskSelect} onNavigateToTaskList={() => setCurrentPage('task-list')} />
        )
      case 'tasks':
      default:
        return <Tasks onTaskSelect={handleTaskSelect} onNavigateToTaskList={() => setCurrentPage('task-list')} />
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
                  onClick={() => setCurrentPage('task-list')}
                  className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    currentPage === 'task-list' 
                      ? 'bg-green-100 text-green-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                >
                  タスクリスト
                </button>
                <button
                  onClick={() => setCurrentPage('mypage')}
                  className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    currentPage === 'mypage' 
                      ? 'bg-blue-100 text-blue-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                >
                  マイページ
                </button>
                <button
                  onClick={() => setCurrentPage('files')}
                  className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    currentPage === 'files' 
                      ? 'bg-blue-100 text-blue-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                >
                  ファイル管理
                </button>
                <button
                  onClick={() => setCurrentPage('calendar')}
                  className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    currentPage === 'calendar' 
                      ? 'bg-blue-100 text-blue-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                >
                  カレンダー
                </button>
                <button
                  onClick={() => setCurrentPage('completed')}
                  className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    currentPage === 'completed' 
                      ? 'bg-green-100 text-green-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                >
                  完了済み
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
                {isAdmin && (
                  <button
                    onClick={() => setCurrentPage('user-management')}
                    className={`px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                      currentPage === 'user-management' 
                        ? 'bg-red-100 text-red-700' 
                        : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                    }`}
                  >
                    ユーザー管理
                  </button>
                )}
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
