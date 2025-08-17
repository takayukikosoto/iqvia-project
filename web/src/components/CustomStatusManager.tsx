import { useState } from 'react'
import { CustomStatus } from '../types'
import { useCustomStatuses } from '../hooks/useCustomStatuses'

interface CustomStatusManagerProps {
  projectId: string | null
  onClose: () => void
}

export default function CustomStatusManager({ projectId, onClose }: CustomStatusManagerProps) {
  const { customStatuses, loading, createCustomStatus, updateCustomStatus, deleteCustomStatus } = useCustomStatuses(projectId)
  const [editingStatus, setEditingStatus] = useState<CustomStatus | null>(null)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    label: '',
    color: '#3B82F6'
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!projectId) return

    const statusData = {
      project_id: projectId,
      name: formData.name,
      label: formData.label,
      color: formData.color,
      order_index: editingStatus ? editingStatus.order_index : customStatuses.length,
      is_active: true
    }

    let success = false
    if (editingStatus) {
      success = await updateCustomStatus(editingStatus.id, statusData)
    } else {
      success = await createCustomStatus(statusData)
    }

    if (success) {
      resetForm()
      setShowCreateForm(false)
      setEditingStatus(null)
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      label: '',
      color: '#3B82F6'
    })
  }

  const handleEdit = (status: CustomStatus) => {
    setEditingStatus(status)
    setFormData({
      name: status.name,
      label: status.label,
      color: status.color
    })
    setShowCreateForm(true)
  }

  const handleDelete = async (status: CustomStatus) => {
    if (confirm(`「${status.label}」ステータスを削除しますか？`)) {
      await deleteCustomStatus(status.id)
    }
  }

  const cancelEdit = () => {
    setEditingStatus(null)
    setShowCreateForm(false)
    resetForm()
  }

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6">
          <p>読み込み中...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-2xl max-h-[80vh] overflow-y-auto">
        <div className="p-6 border-b">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-semibold">カスタムステータス管理</h2>
            <button 
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600"
            >
              <span className="text-2xl">&times;</span>
            </button>
          </div>
        </div>

        <div className="p-6">
          {/* 既存のカスタムステータス一覧 */}
          <div className="mb-6">
            <h3 className="text-lg font-medium mb-4">現在のカスタムステータス</h3>
            {customStatuses.length === 0 ? (
              <p className="text-gray-500">カスタムステータスはまだ作成されていません</p>
            ) : (
              <div className="space-y-2">
                {customStatuses.map((status) => (
                  <div key={status.id} className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center space-x-3">
                      <div 
                        className="w-4 h-4 rounded-full" 
                        style={{ backgroundColor: status.color }}
                      ></div>
                      <div>
                        <span className="font-medium">{status.label}</span>
                        <span className="text-gray-500 text-sm ml-2">({status.name})</span>
                      </div>
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => handleEdit(status)}
                        className="px-3 py-1 text-sm bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
                      >
                        編集
                      </button>
                      <button
                        onClick={() => handleDelete(status)}
                        className="px-3 py-1 text-sm bg-red-100 text-red-700 rounded hover:bg-red-200"
                      >
                        削除
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* 新規作成・編集フォーム */}
          {showCreateForm ? (
            <div className="border-t pt-6">
              <h3 className="text-lg font-medium mb-4">
                {editingStatus ? 'ステータスを編集' : '新しいステータスを作成'}
              </h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    ステータス名 (システム用)
                  </label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    placeholder="例: in_development"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                  <p className="text-xs text-gray-500 mt-1">
                    半角英数字とアンダースコアのみ使用可能
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    表示ラベル
                  </label>
                  <input
                    type="text"
                    value={formData.label}
                    onChange={(e) => setFormData({ ...formData, label: e.target.value })}
                    placeholder="例: 開発中"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    色
                  </label>
                  <div className="flex items-center space-x-2">
                    <input
                      type="color"
                      value={formData.color}
                      onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                      className="w-12 h-10 border border-gray-300 rounded cursor-pointer"
                    />
                    <input
                      type="text"
                      value={formData.color}
                      onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                      className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      pattern="^#[0-9A-Fa-f]{6}$"
                    />
                  </div>
                </div>

                <div className="flex space-x-2 pt-4">
                  <button
                    type="submit"
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                  >
                    {editingStatus ? '更新' : '作成'}
                  </button>
                  <button
                    type="button"
                    onClick={cancelEdit}
                    className="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
                  >
                    キャンセル
                  </button>
                </div>
              </form>
            </div>
          ) : (
            <button
              onClick={() => setShowCreateForm(true)}
              className="w-full py-3 border-2 border-dashed border-gray-300 rounded-lg text-gray-500 hover:border-gray-400 hover:text-gray-600"
            >
              + 新しいステータスを追加
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
