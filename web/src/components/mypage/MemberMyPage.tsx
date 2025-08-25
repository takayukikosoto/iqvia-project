import React, { useState } from 'react'
import { useAuth } from '../../hooks/useAuth'
import { useUserRoles } from '../../hooks/useUserRoles'
import { useProjects } from '../../hooks/useProjects'
import { useProfile } from '../../hooks/useProfile'
import { useUserActivity } from '../../hooks/useUserActivity'
import { usePersonalTodos } from '../../hooks/usePersonalTodos'
import { usePersonalTasks, getPriorityColor, getTaskTypeColor } from '../../hooks/usePersonalTasks'
import { useAttendance, formatHours } from '../../hooks/useAttendance'

export default function MemberMyPage() {
  const { user } = useAuth()
  const { userRoles } = useUserRoles()
  const { projects, loading: projectLoading } = useProjects()
  const { profile, loading: profileLoading, updateProfile } = useProfile()
  const { activities, getWeeklyStats, loading: activityLoading } = useUserActivity()
  const { 
    todos, 
    createTodo, 
    toggleComplete, 
    deleteTodo, 
    getWeekProgress,
    getTodoStats,
    loading: todoLoading 
  } = usePersonalTodos()
  const { 
    tasks, 
    createPersonalTask, 
    toggleTaskCompletion, 
    getPersonalTasks, 
    getProjectTasks, 
    getTodayTasks, 
    getTaskStats,
    loading: tasksLoading 
  } = usePersonalTasks()
  const { 
    getAttendanceStats, 
    getCurrentWorkStatus, 
    getTodayRealTimeHours,
    clockIn, 
    clockOut,
    loading: attendanceLoading 
  } = useAttendance()
  const [activeTab, setActiveTab] = useState<'overview' | 'projects' | 'activity' | 'profile'>('overview')
  const [isEditingProfile, setIsEditingProfile] = useState(false)
  const [displayName, setDisplayName] = useState('')
  const [company, setCompany] = useState('')
  const [newTodo, setNewTodo] = useState('')
  const [newTodoPriority, setNewTodoPriority] = useState<'low' | 'medium' | 'high'>('medium')
  const [newPersonalTask, setNewPersonalTask] = useState('')
  const [newTaskPriority, setNewTaskPriority] = useState<'low' | 'medium' | 'high' | 'urgent'>('medium')
  const [showTaskForm, setShowTaskForm] = useState(false)

  const weekProgress = getWeekProgress()
  const weeklyStats = getWeeklyStats()
  const taskStats = getTaskStats()
  const attendanceStats = getAttendanceStats()
  const workStatus = getCurrentWorkStatus()
  const personalTasks = getPersonalTasks()
  const todayTasks = getTodayTasks()
  const isLoading = activityLoading || todoLoading || tasksLoading || attendanceLoading

  const renderOverview = () => {
    
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">メンバー権限</h3>
          <p className="text-gray-600 mb-4">プロジェクトへの参加・貢献権限</p>
          <div className="flex items-center text-green-600">
            <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
            </svg>
            {userRoles.highestOrgRole || 'Member'}
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">参加プロジェクト</h3>
          <p className="text-3xl font-bold text-blue-600">{projects.length}</p>
          <p className="text-gray-600">プロジェクト</p>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">今週のTODO</h3>
          <p className="text-3xl font-bold text-yellow-600">{weekProgress.remaining}</p>
          <p className="text-gray-600">残り {weekProgress.total > 0 && `/ ${weekProgress.total}`}</p>
          {!isLoading && weekProgress.total > 0 && (
            <div className="mb-4">
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-medium text-gray-700">今週のTODO進捗</span>
                <span className="text-sm text-gray-500">{weekProgress.percentage}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className="bg-green-600 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${weekProgress.percentage}%` }}
                ></div>
              </div>
            </div>
          )}
        </div>

        <div className="bg-white p-6 rounded-lg shadow md:col-span-2 lg:col-span-3">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">今週の活動</h3>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div className="bg-blue-50 p-4 rounded-lg">
              <h3 className="text-sm font-semibold text-blue-900 mb-1">今週の完了タスク</h3>
              <p className="text-2xl font-bold text-blue-600">{weeklyStats.tasksCompleted}</p>
              <p className="text-xs text-blue-700">件</p>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <h3 className="text-sm font-semibold text-green-900 mb-1">今日の勤務時間</h3>
              <p className="text-2xl font-bold text-green-600">{formatHours(attendanceStats.todayHours)}</p>
              <p className="text-xs text-green-700">{workStatus.isWorking ? '勤務中' : '未出勤'}</p>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <h3 className="text-sm font-semibold text-purple-900 mb-1">個人タスク</h3>
              <p className="text-2xl font-bold text-purple-600">{taskStats.personal}</p>
              <p className="text-xs text-purple-700">件</p>
            </div>
            <div className="bg-orange-50 p-4 rounded-lg">
              <h3 className="text-sm font-semibold text-orange-900 mb-1">緊急タスク</h3>
              <p className="text-2xl font-bold text-orange-600">{taskStats.urgent}</p>
              <p className="text-xs text-orange-700">件</p>
            </div>
          </div>

          {/* 勤怠クイックアクション */}
          <div className="bg-white p-6 rounded-lg shadow-sm border mb-6">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-lg font-semibold mb-2">勤怠管理</h3>
                <p className="text-sm text-gray-600">
                  {workStatus.isWorking ? `勤務中 (${formatHours(getTodayRealTimeHours())})` : '未出勤'}
                </p>
              </div>
              <button
                onClick={handleClockAction}
                className={`px-6 py-2 rounded-lg font-medium ${
                  workStatus.canClockIn 
                    ? 'bg-green-600 text-white hover:bg-green-700' 
                    : 'bg-red-600 text-white hover:bg-red-700'
                }`}
              >
                {workStatus.canClockIn ? '出勤' : '退勤'}
              </button>
            </div>
          </div>
        </div>
      </div>
    )
  }

  const handleCreateTodo = async () => {
    if (!newTodo.trim()) return
    
    const result = await createTodo({
      title: newTodo.trim()
    })
    
    if (result.success) {
      setNewTodo('')
      setNewTodoPriority('medium')
    }
  }

  const handleCreatePersonalTask = async () => {
    if (!newPersonalTask.trim()) return
    
    const result = await createPersonalTask({
      title: newPersonalTask.trim(),
      task_type: 'personal',
      priority: newTaskPriority
    })
    
    if (result.success) {
      setNewPersonalTask('')
      setNewTaskPriority('medium')
      setShowTaskForm(false)
    }
  }

  const handleClockAction = async () => {
    if (workStatus.canClockIn) {
      await clockIn({ name: 'オフィス' })
    } else if (workStatus.canClockOut) {
      await clockOut({ name: 'オフィス' })
    }
  }

  const renderActivity = () => {
    const formatTimeAgo = (dateString: string) => {
      const date = new Date(dateString)
      const now = new Date()
      const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60))
      
      if (diffInMinutes < 60) {
        return `${diffInMinutes}分前`
      } else if (diffInMinutes < 1440) {
        return `${Math.floor(diffInMinutes / 60)}時間前`
      } else {
        return `${Math.floor(diffInMinutes / 1440)}日前`
      }
    }

    // 今週のTODO取得
    const thisWeekTodos = todos

    return (
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* 今週のTODO */}
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">今週のTODO</h3>
            <div className="text-sm text-gray-600">
              進捗: {weekProgress.completed}/{weekProgress.total} ({weekProgress.percentage}%)
            </div>
          </div>
          
          <div className="mb-4">
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-blue-600 h-2 rounded-full transition-all duration-300" 
                style={{ width: `${weekProgress.percentage}%` }}
              ></div>
            </div>
          </div>

          <div className="space-y-3 mb-4 max-h-48 overflow-y-auto">
            {todos.map(todo => (
              <div key={todo.id} className="flex items-center space-x-3 p-2 hover:bg-gray-50 rounded">
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => toggleComplete(todo.id)}
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                />
                <span className={`flex-1 text-sm ${
                  todo.completed ? 'line-through text-gray-500' : 'text-gray-900'
                }`}>
                  {todo.title}
                </span>
                <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                  todo.priority === 3 ? 'bg-red-100 text-red-800' :
                  todo.priority === 2 ? 'bg-yellow-100 text-yellow-800' :
                  'bg-green-100 text-green-800'
                }`}>
                  {todo.priority === 3 ? '高' : todo.priority === 2 ? '中' : '低'}
                </span>
                <button
                  onClick={() => deleteTodo(todo.id)}
                  className="text-red-600 hover:text-red-800 p-1"
                >
                  ×
                </button>
              </div>
            ))}
          </div>

          <div className="flex space-x-2">
            <input
              type="text"
              value={newTodo}
              onChange={(e) => setNewTodo(e.target.value)}
              placeholder="新しいTODOを追加..."
              className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
              onKeyDown={(e) => e.key === 'Enter' && handleCreateTodo()}
            />
            <select
              value={newTodoPriority}
              onChange={(e) => setNewTodoPriority(e.target.value as 'low' | 'medium' | 'high')}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
            >
              <option value="low">低</option>
              <option value="medium">中</option>
              <option value="high">高</option>
            </select>
            <button
              onClick={handleCreateTodo}
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 text-sm"
            >
              追加
            </button>
          </div>
        </div>

        {/* 個人タスク */}
        <div className="bg-white p-6 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">個人タスク</h3>
            <button
              onClick={() => setShowTaskForm(!showTaskForm)}
              className="px-3 py-1 bg-purple-600 text-white rounded-md hover:bg-purple-700 text-sm"
            >
              + 新規
            </button>
          </div>

          {showTaskForm && (
            <div className="mb-4 p-3 bg-gray-50 rounded-lg">
              <div className="flex space-x-2 mb-2">
                <input
                  type="text"
                  value={newPersonalTask}
                  onChange={(e) => setNewPersonalTask(e.target.value)}
                  placeholder="個人タスクのタイトル..."
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 text-sm"
                  onKeyDown={(e) => e.key === 'Enter' && handleCreatePersonalTask()}
                />
                <select
                  value={newTaskPriority}
                  onChange={(e) => setNewTaskPriority(e.target.value as 'low' | 'medium' | 'high' | 'urgent')}
                  className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 text-sm"
                >
                  <option value="low">低</option>
                  <option value="medium">中</option>
                  <option value="high">高</option>
                  <option value="urgent">緊急</option>
                </select>
              </div>
              <div className="flex space-x-2">
                <button
                  onClick={handleCreatePersonalTask}
                  className="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 text-sm"
                >
                  作成
                </button>
                <button
                  onClick={() => setShowTaskForm(false)}
                  className="px-4 py-2 bg-gray-500 text-white rounded-md hover:bg-gray-600 text-sm"
                >
                  キャンセル
                </button>
              </div>
            </div>
          )}

          <div className="space-y-3 max-h-60 overflow-y-auto">
            {personalTasks.map(task => (
              <div key={task.id} className="flex items-center space-x-3 p-3 hover:bg-gray-50 rounded-lg border">
                <input
                  type="checkbox"
                  checked={task.status === 'completed'}
                  onChange={() => toggleTaskCompletion(task.id)}
                  className="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded"
                />
                <div className="flex-1">
                  <div className={`font-medium text-sm ${
                    task.status === 'completed' ? 'line-through text-gray-500' : 'text-gray-900'
                  }`}>
                    {task.title}
                  </div>
                  {task.due_at && (
                    <div className="text-xs text-gray-500 mt-1">
                      期日: {new Date(task.due_at).toLocaleDateString('ja-JP')}
                    </div>
                  )}
                </div>
                <div 
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: getPriorityColor(task.priority) }}
                  title={task.priority}
                ></div>
                <div 
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: getTaskTypeColor(task.task_type) }}
                  title={task.task_type_label}
                ></div>
              </div>
            ))}
            
            {personalTasks.length === 0 && (
              <div className="text-center text-gray-500 py-8">
                個人タスクがありません
              </div>
            )}
          </div>
        </div>
      </div>
    )
  }

  const renderProfile = () => {
    // プロフィール編集開始時の初期化
    const handleEditStart = () => {
      if (profile) {
        setDisplayName(profile.display_name)
        setCompany(profile.company)
        setIsEditingProfile(true)
      }
    }

    // プロフィール保存
    const handleSaveProfile = async () => {
      const result = await updateProfile({
        display_name: displayName.trim() || 'ユーザー',
        company: company.trim() || '会社名未設定'
      })

      if (result.success) {
        setIsEditingProfile(false)
      } else {
        alert('プロフィール更新に失敗しました: ' + result.error)
      }
    }

    return (
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
          <h3 className="text-lg font-semibold text-gray-900">プロフィール設定</h3>
          {!isEditingProfile ? (
            <button
              onClick={handleEditStart}
              className="px-3 py-1 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
            >
              編集
            </button>
          ) : (
            <div className="space-x-2">
              <button
                onClick={handleSaveProfile}
                className="px-3 py-1 text-sm bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
              >
                保存
              </button>
              <button
                onClick={() => setIsEditingProfile(false)}
                className="px-3 py-1 text-sm bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors"
              >
                キャンセル
              </button>
            </div>
          )}
        </div>
        <div className="p-6 space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              表示名
            </label>
            {isEditingProfile ? (
              <input
                type="text"
                value={displayName}
                onChange={(e) => setDisplayName(e.target.value)}
                placeholder="チャットや履歴で表示される名前"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            ) : (
              <div className="px-3 py-2 border border-gray-300 rounded-md bg-gray-50">
                {profile?.display_name || '未設定'}
              </div>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              会社名
            </label>
            {isEditingProfile ? (
              <input
                type="text"
                value={company}
                onChange={(e) => setCompany(e.target.value)}
                placeholder="所属する会社・組織名"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            ) : (
              <div className="px-3 py-2 border border-gray-300 rounded-md bg-gray-50">
                {profile?.company || '未設定'}
              </div>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              メールアドレス
            </label>
            <input
              type="email"
              value={user?.email || ''}
              disabled
              className="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50 text-gray-500"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              現在のロール
            </label>
            <div className="px-3 py-2 border border-gray-300 rounded-md bg-gray-50">
              <span className="px-3 py-1 text-sm font-medium bg-green-100 text-green-800 rounded-full">
                {userRoles.highestOrgRole === 'contributor' ? 'Contributor' : 
                 userRoles.highestOrgRole === 'viewer' ? 'Viewer' : 'Member'}
              </span>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              利用可能な機能
            </label>
            <div className="space-y-2">
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                </svg>
                タスク閲覧・更新
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                </svg>
                ファイルアップロード・ダウンロード
              </div>
              <div className="flex items-center text-sm text-gray-600">
                <svg className="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                </svg>
                チャット参加
              </div>
              {userRoles.highestOrgRole === 'viewer' && (
                <div className="flex items-center text-sm text-gray-400">
                  <svg className="w-4 h-4 mr-2 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                  </svg>
                  編集権限なし（閲覧のみ）
                </div>
              )}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              参加プロジェクト・ロール
            </label>
            <div className="space-y-2">
              {userRoles.projectRoles.map((role, index) => (
                <div key={index} className="flex items-center justify-between p-3 border border-gray-200 rounded-md">
                  <span className="text-sm text-gray-900">{role.name}</span>
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    role.role === 'project_manager' 
                      ? 'bg-blue-100 text-blue-800'
                      : role.role === 'contributor'
                      ? 'bg-green-100 text-green-800'
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {role.role}
                  </span>
                </div>
              ))}
              {userRoles.projectRoles.length === 0 && (
                <p className="text-sm text-gray-500 text-center py-4">
                  参加中のプロジェクトがありません
                </p>
              )}
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">マイページ</h1>
          <p className="mt-2 text-gray-600">個人ダッシュボード</p>
        </div>

        {/* タブナビゲーション */}
        <div className="mb-8">
          <nav className="flex space-x-8">
            {[
              { key: 'overview', label: '概要', icon: '📊' },
              { key: 'projects', label: 'プロジェクト', icon: '📋' },
              { key: 'activity', label: 'アクティビティ', icon: '📈' },
              { key: 'profile', label: 'プロフィール', icon: '👤' }
            ].map(({ key, label, icon }) => (
              <button
                key={key}
                onClick={() => setActiveTab(key as any)}
                className={`flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                  activeTab === key
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                }`}
              >
                <span className="mr-2">{icon}</span>
                {label}
              </button>
            ))}
          </nav>
        </div>

        {/* コンテンツ */}
        <div>
          {activeTab === 'overview' && renderOverview()}
          {activeTab === 'projects' && (
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">参加プロジェクト</h3>
          <div className="space-y-4">
            {projects.length === 0 ? (
              <p className="text-gray-500">参加中のプロジェクトはありません</p>
            ) : (
              projects.map(project => (
                <div key={project.id} className="border p-4 rounded-lg">
                  <h4 className="font-medium text-gray-900">{project.name}</h4>
                  <p className="text-gray-600 text-sm mt-1">説明なし</p>
                </div>
              ))
            )}
          </div>
        </div>
      )}
          {activeTab === 'activity' && renderActivity()}
          {activeTab === 'profile' && renderProfile()}
        </div>
      </div>
    </div>
  )
}
