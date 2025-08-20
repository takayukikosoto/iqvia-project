import React, { useState } from 'react'
import { useAuth } from '../../hooks/useAuth'
import { useUserRoles } from '../../hooks/useUserRoles'
import { useProjects } from '../../hooks/useProjects'

export default function ProjectManagerMyPage() {
  const { user } = useAuth()
  const { userRoles } = useUserRoles()
  const { projects, loading: projectLoading } = useProjects()
  const [activeTab, setActiveTab] = useState<'overview' | 'projects' | 'tasks' | 'profile'>('overview')

  // プロジェクトマネージャーとして管理しているプロジェクト
  const managedProjects = projects.filter(project => 
    userRoles.projectRoles.find(role => 
      role.id === project.id && role.role === 'project_manager'
    )
  )

  const renderOverview = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">プロジェクトマネージャー</h3>
        <p className="text-gray-600 mb-4">プロジェクトの管理・運営権限</p>
        <div className="flex items-center text-blue-600">
          <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
          </svg>
          PM権限
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">管理プロジェクト</h3>
        <p className="text-3xl font-bold text-blue-600">{managedProjects.length}</p>
        <p className="text-gray-600">プロジェクト</p>
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">参加プロジェクト</h3>
        <p className="text-3xl font-bold text-green-600">{projects.length}</p>
        <p className="text-gray-600">プロジェクト</p>
      </div>

      <div className="bg-white p-6 rounded-lg shadow md:col-span-2 lg:col-span-3">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">最近のアクティビティ</h3>
        <div className="space-y-3">
          <div className="flex items-center text-sm text-gray-600">
            <div className="w-2 h-2 bg-blue-500 rounded-full mr-3"></div>
            新しいタスクが追加されました
          </div>
          <div className="flex items-center text-sm text-gray-600">
            <div className="w-2 h-2 bg-green-500 rounded-full mr-3"></div>
            プロジェクトステータスが更新されました
          </div>
          <div className="flex items-center text-sm text-gray-600">
            <div className="w-2 h-2 bg-yellow-500 rounded-full mr-3"></div>
            チームメンバーが追加されました
          </div>
        </div>
      </div>
    </div>
  )

  const renderProjects = () => (
    <div className="space-y-6">
      {/* 管理プロジェクト */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">管理中のプロジェクト</h3>
        </div>
        <div className="p-6">
          {projectLoading ? (
            <div className="flex justify-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
          ) : (
            <div className="space-y-4">
              {managedProjects.map((project) => (
                <div key={project.id} className="flex items-center justify-between p-4 border-l-4 border-blue-500 bg-blue-50 rounded-lg">
                  <div>
                    <h4 className="font-medium text-gray-900">{project.name}</h4>
                    <p className="text-sm text-gray-500">
                      {project.organization?.name || '組織情報なし'}
                    </p>
                  </div>
                  <div className="flex items-center space-x-2">
                    <span className={`px-3 py-1 text-xs font-medium rounded-full ${
                      project.status === 'active' 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {project.status}
                    </span>
                    <span className="px-3 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
                      Manager
                    </span>
                  </div>
                </div>
              ))}
              {managedProjects.length === 0 && (
                <p className="text-center text-gray-500 py-8">管理中のプロジェクトがありません</p>
              )}
            </div>
          )}
        </div>
      </div>

      {/* 参加プロジェクト */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">参加中のプロジェクト</h3>
        </div>
        <div className="p-6">
          <div className="space-y-4">
            {projects.filter(project => 
              !managedProjects.some(mp => mp.id === project.id)
            ).map((project) => (
              <div key={project.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                <div>
                  <h4 className="font-medium text-gray-900">{project.name}</h4>
                  <p className="text-sm text-gray-500">
                    {project.organization?.name || '組織情報なし'}
                  </p>
                </div>
                <div className="flex items-center space-x-2">
                  <span className={`px-3 py-1 text-xs font-medium rounded-full ${
                    project.status === 'active' 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {project.status}
                  </span>
                  <span className="px-3 py-1 text-xs font-medium bg-gray-100 text-gray-800 rounded-full">
                    {userRoles.projectRoles.find(r => r.id === project.id)?.role || 'Member'}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )

  const renderTasks = () => (
    <div className="bg-white rounded-lg shadow">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">タスク管理</h3>
      </div>
      <div className="p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="text-center">
            <div className="text-3xl font-bold text-yellow-600">12</div>
            <div className="text-sm text-gray-600">進行中</div>
          </div>
          <div className="text-center">
            <div className="text-3xl font-bold text-green-600">8</div>
            <div className="text-sm text-gray-600">完了済み</div>
          </div>
          <div className="text-center">
            <div className="text-3xl font-bold text-red-600">3</div>
            <div className="text-sm text-gray-600">期限超過</div>
          </div>
        </div>
        
        <div className="text-center text-gray-500 py-8">
          <p>詳細なタスク管理は「タスク管理」ページをご利用ください</p>
          <button className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
            タスク管理へ移動
          </button>
        </div>
      </div>
    </div>
  )

  const renderProfile = () => (
    <div className="bg-white rounded-lg shadow">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">プロフィール設定</h3>
      </div>
      <div className="p-6 space-y-6">
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
            最高権限ロール
          </label>
          <div className="px-3 py-2 border border-gray-300 rounded-md bg-gray-50">
            <span className="px-3 py-1 text-sm font-medium bg-blue-100 text-blue-800 rounded-full">
              Project Manager
            </span>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            管理権限
          </label>
          <div className="space-y-2">
            <div className="flex items-center text-sm text-gray-600">
              <svg className="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
              </svg>
              プロジェクト管理
            </div>
            <div className="flex items-center text-sm text-gray-600">
              <svg className="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
              </svg>
              タスク管理
            </div>
            <div className="flex items-center text-sm text-gray-600">
              <svg className="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
              </svg>
              メンバー管理
            </div>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            プロジェクト・ロール
          </label>
          <div className="space-y-2">
            {userRoles.projectRoles.map((role, index) => (
              <div key={index} className="flex items-center justify-between p-3 border border-gray-200 rounded-md">
                <span className="text-sm text-gray-900">{role.name}</span>
                <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                  role.role === 'project_manager' 
                    ? 'bg-blue-100 text-blue-800' 
                    : 'bg-gray-100 text-gray-800'
                }`}>
                  {role.role}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">プロジェクトマネージャー マイページ</h1>
          <p className="mt-2 text-gray-600">プロジェクト管理ダッシュボード</p>
        </div>

        {/* タブナビゲーション */}
        <div className="mb-8">
          <nav className="flex space-x-8">
            {[
              { key: 'overview', label: '概要', icon: '📊' },
              { key: 'projects', label: 'プロジェクト', icon: '📋' },
              { key: 'tasks', label: 'タスク', icon: '✅' },
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
          {activeTab === 'projects' && renderProjects()}
          {activeTab === 'tasks' && renderTasks()}
          {activeTab === 'profile' && renderProfile()}
        </div>
      </div>
    </div>
  )
}
