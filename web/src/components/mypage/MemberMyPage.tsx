import React, { useState } from 'react'
import { useAuth } from '../../hooks/useAuth'
import { useUserRoles } from '../../hooks/useUserRoles'
import { useProjects } from '../../hooks/useProjects'

export default function MemberMyPage() {
  const { user } = useAuth()
  const { userRoles } = useUserRoles()
  const { projects, loading: projectLoading } = useProjects()
  const [activeTab, setActiveTab] = useState<'overview' | 'projects' | 'activity' | 'profile'>('overview')

  const renderOverview = () => (
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
        <h3 className="text-lg font-semibold text-gray-900 mb-2">アクティブタスク</h3>
        <p className="text-3xl font-bold text-yellow-600">5</p>
        <p className="text-gray-600">進行中のタスク</p>
      </div>

      <div className="bg-white p-6 rounded-lg shadow md:col-span-2 lg:col-span-3">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">今週の進捗</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="text-center">
            <div className="text-2xl font-bold text-green-600">3</div>
            <div className="text-sm text-gray-600">完了済みタスク</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-600">12</div>
            <div className="text-sm text-gray-600">ファイルアップロード</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-purple-600">8</div>
            <div className="text-sm text-gray-600">チャットメッセージ</div>
          </div>
        </div>
      </div>
    </div>
  )

  const renderProjects = () => (
    <div className="bg-white rounded-lg shadow">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">参加中のプロジェクト</h3>
      </div>
      <div className="p-6">
        {projectLoading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="space-y-4">
            {projects.map((project) => {
              const userRole = userRoles.projectRoles.find(r => r.id === project.id)
              return (
                <div key={project.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-900">{project.name}</h4>
                    <p className="text-sm text-gray-500">
                      {project.organization?.name || '組織情報なし'}
                    </p>
                    <div className="flex items-center mt-2 text-xs text-gray-400">
                      <span>作成日: {new Date(project.created_at).toLocaleDateString('ja-JP')}</span>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <span className={`px-3 py-1 text-xs font-medium rounded-full ${
                      project.status === 'active' 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {project.status}
                    </span>
                    <span className={`px-3 py-1 text-xs font-medium rounded-full ${
                      userRole?.role === 'project_manager'
                        ? 'bg-blue-100 text-blue-800'
                        : userRole?.role === 'contributor'
                        ? 'bg-green-100 text-green-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {userRole?.role || 'Member'}
                    </span>
                  </div>
                </div>
              )
            })}
            {projects.length === 0 && (
              <div className="text-center py-8">
                <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <p className="mt-2 text-gray-500">参加中のプロジェクトがありません</p>
                <p className="text-sm text-gray-400">管理者に相談してプロジェクトに参加してください</p>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )

  const renderActivity = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">最近のアクティビティ</h3>
        </div>
        <div className="p-6">
          <div className="space-y-4">
            <div className="flex items-start space-x-3">
              <div className="flex-shrink-0">
                <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                  <svg className="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                </div>
              </div>
              <div className="flex-1">
                <p className="text-sm text-gray-900">タスク「API設計書作成」を完了しました</p>
                <p className="text-xs text-gray-500">2時間前</p>
              </div>
            </div>

            <div className="flex items-start space-x-3">
              <div className="flex-shrink-0">
                <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <svg className="w-4 h-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                  </svg>
                </div>
              </div>
              <div className="flex-1">
                <p className="text-sm text-gray-900">ファイル「requirements.pdf」をアップロードしました</p>
                <p className="text-xs text-gray-500">4時間前</p>
              </div>
            </div>

            <div className="flex items-start space-x-3">
              <div className="flex-shrink-0">
                <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                  <svg className="w-4 h-4 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 5v8a2 2 0 01-2 2h-5l-5 4v-4H4a2 2 0 01-2-2V5a2 2 0 012-2h12a2 2 0 012 2zM7 8H5v2h2V8zm2 0h2v2H9V8zm6 0h-2v2h2V8z" clipRule="evenodd" />
                  </svg>
                </div>
              </div>
              <div className="flex-1">
                <p className="text-sm text-gray-900">プロジェクトチャットにメッセージを投稿しました</p>
                <p className="text-xs text-gray-500">昨日</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">今週の目標</h3>
        </div>
        <div className="p-6">
          <div className="space-y-3">
            <div className="flex items-center">
              <input type="checkbox" checked className="h-4 w-4 text-blue-600 rounded border-gray-300" readOnly />
              <label className="ml-3 text-sm text-gray-900 line-through">データベース設計完了</label>
            </div>
            <div className="flex items-center">
              <input type="checkbox" className="h-4 w-4 text-blue-600 rounded border-gray-300" readOnly />
              <label className="ml-3 text-sm text-gray-900">UI mockup作成</label>
            </div>
            <div className="flex items-center">
              <input type="checkbox" className="h-4 w-4 text-blue-600 rounded border-gray-300" readOnly />
              <label className="ml-3 text-sm text-gray-900">テストケース作成</label>
            </div>
          </div>
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
          {activeTab === 'projects' && renderProjects()}
          {activeTab === 'activity' && renderActivity()}
          {activeTab === 'profile' && renderProfile()}
        </div>
      </div>
    </div>
  )
}
