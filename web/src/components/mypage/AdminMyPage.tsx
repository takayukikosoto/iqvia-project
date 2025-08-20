import React, { useState } from 'react'
import { useAuth } from '../../hooks/useAuth'
import { useUserRoles } from '../../hooks/useUserRoles'
import { useOrganizations } from '../../hooks/useOrganizations'
import { useProjects } from '../../hooks/useProjects'
import { useUsers } from '../../hooks/useUsers'
import { supabase } from '../../supabaseClient'

export default function AdminMyPage() {
  const { user } = useAuth()
  const { userRoles } = useUserRoles()
  const { organizations, loading: orgLoading } = useOrganizations()
  const { projects, loading: projectLoading } = useProjects()
  const { users, loading: usersLoading, updateUserRole } = useUsers()
  const [activeTab, setActiveTab] = useState<'overview' | 'organizations' | 'projects' | 'users' | 'profile'>('overview')
  const [editingUserId, setEditingUserId] = useState<string | null>(null)

  const renderOverview = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">システム管理者権限</h3>
        <p className="text-gray-600 mb-4">全組織・プロジェクトの管理が可能</p>
        <div className="flex items-center text-green-600">
          <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
          </svg>
          Admin権限
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">管理中の組織</h3>
        <p className="text-3xl font-bold text-blue-600">{organizations.length}</p>
        <p className="text-gray-600">組織</p>
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
            新しいプロジェクトが作成されました
          </div>
          <div className="flex items-center text-sm text-gray-600">
            <div className="w-2 h-2 bg-green-500 rounded-full mr-3"></div>
            システム設定が更新されました
          </div>
        </div>
      </div>
    </div>
  )

  const renderOrganizations = () => (
    <div className="bg-white rounded-lg shadow">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">管理組織一覧</h3>
      </div>
      <div className="p-6">
        {orgLoading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="space-y-4">
            {organizations.map((org) => (
              <div key={org.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                <div>
                  <h4 className="font-medium text-gray-900">{org.name}</h4>
                  <p className="text-sm text-gray-500">組織ID: {org.id.slice(0, 8)}...</p>
                </div>
                <div className="flex space-x-2">
                  <span className="px-3 py-1 text-xs font-medium bg-red-100 text-red-800 rounded-full">
                    Admin
                  </span>
                </div>
              </div>
            ))}
            {organizations.length === 0 && (
              <p className="text-center text-gray-500 py-8">管理中の組織がありません</p>
            )}
          </div>
        )}
      </div>
    </div>
  )

  const renderProjects = () => (
    <div className="bg-white rounded-lg shadow">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">参加プロジェクト一覧</h3>
      </div>
      <div className="p-6">
        {projectLoading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="space-y-4">
            {projects.map((project) => (
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
                  <span className="px-3 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
                    {userRoles.projectRoles.find(r => r.id === project.id)?.role || 'Admin'}
                  </span>
                </div>
              </div>
            ))}
            {projects.length === 0 && (
              <p className="text-center text-gray-500 py-8">参加中のプロジェクトがありません</p>
            )}
          </div>
        )}
      </div>
    </div>
  )

  const handleRoleUpdate = async (userId: string, newRole: string) => {
    const result = await updateUserRole(userId, newRole)
    if (result.success) {
      setEditingUserId(null)
    } else {
      alert(`ロール更新に失敗しました: ${result.error}`)
    }
  }


  const renderUsers = () => (
    <div className="bg-white rounded-lg shadow">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">登録ユーザー一覧</h3>
        <p className="text-sm text-gray-600 mt-1">システムに登録されているすべてのユーザーを管理できます</p>
      </div>
      <div className="p-6">
        {usersLoading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : (
          <div className="space-y-4">
            {users.map((userProfile) => (
              <div key={userProfile.user_id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                <div className="flex-1">
                  <div className="flex items-center space-x-3">
                    <div className="flex-shrink-0 w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                      <span className="text-sm font-medium text-gray-700">
                        {(userProfile.display_name || userProfile.email || 'U').charAt(0).toUpperCase()}
                      </span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {userProfile.display_name || 'ユーザー名未設定'}
                      </p>
                      <p className="text-sm text-gray-500 truncate">{userProfile.email}</p>
                      <p className="text-xs text-gray-400">{userProfile.company || '会社名未設定'}</p>
                    </div>
                  </div>
                </div>
                
                <div className="flex items-center space-x-3">
                  <div className="text-right">
                    <p className="text-xs text-gray-500">登録日</p>
                    <p className="text-sm text-gray-900">
                      {new Date(userProfile.created_at).toLocaleDateString('ja-JP')}
                    </p>
                  </div>
                  
                  <div className="flex items-center space-x-2">
                    {editingUserId === userProfile.user_id ? (
                      <select
                        value={userProfile.role}
                        onChange={(e) => handleRoleUpdate(userProfile.user_id, e.target.value)}
                        className="text-xs px-2 py-1 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                      >
                        <option value="admin">管理者</option>
                        <option value="org_manager">組織マネージャー</option>
                        <option value="project_manager">プロジェクトマネージャー</option>
                        <option value="contributor">貢献者</option>
                        <option value="viewer">閲覧者</option>
                      </select>
                    ) : (
                      <span 
                        className={`px-3 py-1 text-xs font-medium rounded-full cursor-pointer hover:opacity-75 ${
                          userProfile.role === 'admin' 
                            ? 'bg-red-100 text-red-800' 
                            : userProfile.role === 'org_manager'
                            ? 'bg-purple-100 text-purple-800'
                            : userProfile.role === 'project_manager'
                            ? 'bg-blue-100 text-blue-800'
                            : userProfile.role === 'contributor'
                            ? 'bg-green-100 text-green-800'
                            : 'bg-gray-100 text-gray-800'
                        }`}
                        onClick={() => setEditingUserId(userProfile.user_id)}
                        title="クリックしてロールを変更"
                      >
                        {userProfile.role === 'admin' ? '管理者' :
                         userProfile.role === 'org_manager' ? '組織マネージャー' :
                         userProfile.role === 'project_manager' ? 'プロジェクトマネージャー' :
                         userProfile.role === 'contributor' ? '貢献者' : '閲覧者'}
                      </span>
                    )}
                    
                    {userProfile.user_id === user?.id && (
                      <span className="px-2 py-1 text-xs bg-yellow-100 text-yellow-800 rounded-full">
                        自分
                      </span>
                    )}
                  </div>
                </div>
              </div>
            ))}
            {users.length === 0 && (
              <p className="text-center text-gray-500 py-8">登録ユーザーがありません</p>
            )}
          </div>
        )}
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
            ユーザーID
          </label>
          <input
            type="text"
            value={user?.id || ''}
            disabled
            className="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50 text-gray-500 font-mono text-sm"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            最高権限ロール
          </label>
          <div className="px-3 py-2 border border-gray-300 rounded-md bg-gray-50">
            <span className="px-3 py-1 text-sm font-medium bg-red-100 text-red-800 rounded-full">
              System Administrator
            </span>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            所属組織・ロール
          </label>
          <div className="space-y-2">
            {userRoles.organizationRoles.map((role, index) => (
              <div key={index} className="flex items-center justify-between p-3 border border-gray-200 rounded-md">
                <span className="text-sm text-gray-900">{role.name}</span>
                <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
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
          <h1 className="text-3xl font-bold text-gray-900">管理者マイページ</h1>
          <p className="mt-2 text-gray-600">システム管理者ダッシュボード</p>
        </div>

        {/* タブナビゲーション */}
        <div className="mb-8">
          <nav className="flex space-x-8">
            {[
              { key: 'overview', label: '概要', icon: '📊' },
              { key: 'organizations', label: '組織管理', icon: '🏢' },
              { key: 'projects', label: 'プロジェクト', icon: '📋' },
              { key: 'users', label: 'ユーザー管理', icon: '👥' },
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
          {activeTab === 'organizations' && renderOrganizations()}
          {activeTab === 'projects' && renderProjects()}
          {activeTab === 'users' && renderUsers()}
          {activeTab === 'profile' && renderProfile()}
        </div>
      </div>
    </div>
  )
}
