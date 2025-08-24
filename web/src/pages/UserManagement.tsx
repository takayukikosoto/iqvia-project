import React, { useState, useEffect } from 'react'
import { useRole, type UserWithRole, type RoleStats } from '../hooks/useRole'

const UserManagement: React.FC = () => {
  const { 
    isAdmin, 
    allUsers, 
    allRoles, 
    roleStats,
    usersLoading, 
    fetchAllUsers, 
    updateUserRole, 
    fetchRoleStatistics 
  } = useRole()

  const [selectedUsers, setSelectedUsers] = useState<string[]>([])
  const [bulkRole, setBulkRole] = useState<string>('')
  const [searchTerm, setSearchTerm] = useState('')
  const [sortField, setSortField] = useState<'email' | 'role_level' | 'created_at'>('created_at')
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc')

  useEffect(() => {
    if (isAdmin()) {
      fetchAllUsers()
      fetchRoleStatistics()
    }
  }, [isAdmin])

  // Filter and sort users
  const filteredUsers = allUsers
    .filter(user => 
      user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.role_display_name.toLowerCase().includes(searchTerm.toLowerCase())
    )
    .sort((a, b) => {
      let aVal, bVal
      switch (sortField) {
        case 'email':
          aVal = a.email
          bVal = b.email
          break
        case 'role_level':
          aVal = a.role_level
          bVal = b.role_level
          break
        case 'created_at':
          aVal = new Date(a.created_at).getTime()
          bVal = new Date(b.created_at).getTime()
          break
        default:
          return 0
      }
      
      if (sortDirection === 'asc') {
        return aVal < bVal ? -1 : aVal > bVal ? 1 : 0
      } else {
        return aVal > bVal ? -1 : aVal < bVal ? 1 : 0
      }
    })

  const handleRoleChange = async (userId: string, newRole: string) => {
    try {
      await updateUserRole(userId, newRole)
      alert('ユーザーの権限を更新しました')
    } catch (error: any) {
      alert(`権限更新エラー: ${error.message}`)
    }
  }

  const handleBulkUpdate = async () => {
    if (selectedUsers.length === 0 || !bulkRole) {
      alert('ユーザーと権限を選択してください')
      return
    }

    try {
      for (const userId of selectedUsers) {
        await updateUserRole(userId, bulkRole)
      }
      setSelectedUsers([])
      setBulkRole('')
      alert(`${selectedUsers.length}人のユーザーの権限を更新しました`)
    } catch (error: any) {
      alert(`一括更新エラー: ${error.message}`)
    }
  }

  const toggleUserSelection = (userId: string) => {
    setSelectedUsers(prev => 
      prev.includes(userId) 
        ? prev.filter(id => id !== userId)
        : [...prev, userId]
    )
  }

  const getRoleBadgeColor = (roleLevel: number) => {
    switch (true) {
      case roleLevel >= 8: return '#dc3545' // Admin - Red
      case roleLevel >= 7: return '#fd7e14' // Organizer - Orange
      case roleLevel >= 6: return '#6f42c1' // Sponsor - Purple
      case roleLevel >= 5: return '#20c997' // Agency - Teal
      case roleLevel >= 4: return '#0d6efd' // Production - Blue
      case roleLevel >= 3: return '#198754' // Secretariat - Green
      case roleLevel >= 2: return '#ffc107' // Staff - Yellow
      default: return '#6c757d' // Viewer - Gray
    }
  }

  if (!isAdmin()) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600 mb-4">アクセス拒否</h1>
          <p className="text-gray-600">この機能は管理者権限が必要です</p>
        </div>
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-gray-800">ユーザー管理</h1>
        <button
          onClick={() => {
            fetchAllUsers()
            fetchRoleStatistics()
          }}
          className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          disabled={usersLoading}
        >
          {usersLoading ? '読み込み中...' : '更新'}
        </button>
      </div>

      {/* Role Statistics */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-4 mb-8">
        {roleStats.map((stat) => (
          <div key={stat.role_name} className="bg-white rounded-lg shadow p-4 text-center">
            <div 
              className="w-4 h-4 rounded-full mx-auto mb-2"
              style={{ backgroundColor: getRoleBadgeColor(stat.role_level) }}
            />
            <p className="text-sm font-medium text-gray-600">{stat.role_display_name}</p>
            <p className="text-2xl font-bold text-gray-800">{stat.user_count}</p>
          </div>
        ))}
      </div>

      {/* Search and Sort */}
      <div className="flex flex-wrap gap-4 mb-6">
        <input
          type="text"
          placeholder="ユーザー検索..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="flex-1 min-w-60 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        
        <select
          value={sortField}
          onChange={(e) => setSortField(e.target.value as any)}
          className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="created_at">作成日</option>
          <option value="email">メール</option>
          <option value="role_level">権限レベル</option>
        </select>

        <button
          onClick={() => setSortDirection(prev => prev === 'asc' ? 'desc' : 'asc')}
          className="px-3 py-2 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200"
        >
          {sortDirection === 'asc' ? '昇順 ↑' : '降順 ↓'}
        </button>
      </div>

      {/* Bulk Actions */}
      {selectedUsers.length > 0 && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <div className="flex flex-wrap gap-4 items-center">
            <span className="font-medium">{selectedUsers.length}人選択中</span>
            
            <select
              value={bulkRole}
              onChange={(e) => setBulkRole(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">権限を選択...</option>
              {allRoles.map((role) => (
                <option key={role.id} value={role.role_name}>
                  {role.display_name}
                </option>
              ))}
            </select>

            <button
              onClick={handleBulkUpdate}
              disabled={!bulkRole}
              className="bg-blue-500 hover:bg-blue-700 disabled:bg-gray-400 text-white font-bold py-2 px-4 rounded"
            >
              一括更新
            </button>

            <button
              onClick={() => setSelectedUsers([])}
              className="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded"
            >
              選択解除
            </button>
          </div>
        </div>
      )}

      {/* Users Table */}
      <div className="bg-white shadow-md rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <input
                    type="checkbox"
                    onChange={(e) => {
                      if (e.target.checked) {
                        setSelectedUsers(filteredUsers.map(u => u.user_id))
                      } else {
                        setSelectedUsers([])
                      }
                    }}
                    checked={filteredUsers.length > 0 && selectedUsers.length === filteredUsers.length}
                  />
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ユーザー
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  現在の権限
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  作成日
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  最終ログイン
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  権限変更
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredUsers.map((user) => (
                <tr key={user.user_id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <input
                      type="checkbox"
                      checked={selectedUsers.includes(user.user_id)}
                      onChange={() => toggleUserSelection(user.user_id)}
                    />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{user.email}</div>
                    <div className="text-sm text-gray-500">ID: {user.user_id.slice(0, 8)}...</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span 
                      className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium text-white"
                      style={{ backgroundColor: getRoleBadgeColor(user.role_level) }}
                    >
                      {user.role_display_name}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(user.created_at).toLocaleDateString('ja-JP')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {user.last_sign_in_at 
                      ? new Date(user.last_sign_in_at).toLocaleDateString('ja-JP')
                      : '未ログイン'
                    }
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <select
                      value={user.role_name}
                      onChange={(e) => handleRoleChange(user.user_id, e.target.value)}
                      className="text-sm border border-gray-300 rounded px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                      {allRoles.map((role) => (
                        <option key={role.id} value={role.role_name}>
                          {role.display_name}
                        </option>
                      ))}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {filteredUsers.length === 0 && !usersLoading && (
        <div className="text-center py-8 text-gray-500">
          ユーザーが見つかりませんでした
        </div>
      )}
      
      {usersLoading && (
        <div className="text-center py-8 text-gray-500">
          ユーザー情報を読み込み中...
        </div>
      )}
    </div>
  )
}

export default UserManagement
