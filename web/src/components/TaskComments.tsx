import React, { useState } from 'react'
import { useTaskComments, TaskComment } from '../hooks/useTaskComments'

interface TaskCommentsProps {
  taskId: string
}

export default function TaskComments({ taskId }: TaskCommentsProps) {
  const { comments, loading, addComment, updateComment, deleteComment } = useTaskComments(taskId)
  const [newComment, setNewComment] = useState('')
  const [editingId, setEditingId] = useState<string | null>(null)
  const [editingText, setEditingText] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newComment.trim() || isSubmitting) return

    try {
      setIsSubmitting(true)
      await addComment(newComment.trim())
      setNewComment('')
    } catch (error) {
      console.error('Failed to add comment:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleEdit = (comment: TaskComment) => {
    setEditingId(comment.id)
    setEditingText(comment.body)
  }

  const handleSaveEdit = async () => {
    if (!editingId || !editingText.trim()) return

    try {
      await updateComment(editingId, editingText.trim())
      setEditingId(null)
      setEditingText('')
    } catch (error) {
      console.error('Failed to update comment:', error)
    }
  }

  const handleCancelEdit = () => {
    setEditingId(null)
    setEditingText('')
  }

  const handleDelete = async (commentId: string) => {
    if (!confirm('このコメントを削除しますか？')) return

    try {
      await deleteComment(commentId)
    } catch (error) {
      console.error('Failed to delete comment:', error)
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('ja-JP', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const getAuthorName = (comment: TaskComment) => {
    if (comment.author?.display_name) {
      return comment.author.display_name
    }
    return 'Unknown User'
  }

  if (loading) {
    return (
      <div style={{
        padding: 16,
        backgroundColor: '#f8f9fa',
        borderRadius: 8,
        border: '1px solid #e9ecef'
      }}>
        <div style={{ fontSize: 14, color: '#666' }}>コメントを読み込み中...</div>
      </div>
    )
  }

  return (
    <div style={{
      padding: 16,
      backgroundColor: '#f8f9fa',
      borderRadius: 8,
      border: '1px solid #e9ecef'
    }}>
      <h3 style={{
        margin: '0 0 16px 0',
        fontSize: 16,
        fontWeight: 600,
        color: '#333',
        display: 'flex',
        alignItems: 'center',
        gap: 8
      }}>
        💬 コメント ({comments.length})
      </h3>

      {/* コメント一覧 */}
      <div style={{ marginBottom: 16 }}>
        {comments.length === 0 ? (
          <div style={{
            padding: 16,
            textAlign: 'center',
            color: '#666',
            fontSize: 14,
            fontStyle: 'italic'
          }}>
            まだコメントがありません
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {comments.map((comment) => (
              <div
                key={comment.id}
                style={{
                  padding: 12,
                  backgroundColor: '#fff',
                  borderRadius: 6,
                  border: '1px solid #e9ecef',
                  boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
                }}
              >
                <div style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'flex-start',
                  marginBottom: 8
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', marginBottom: '4px' }}>
                    <div style={{ 
                      width: '32px', 
                      height: '32px', 
                      borderRadius: '50%', 
                      backgroundColor: '#3b82f6',
                      color: 'white',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '14px',
                      fontWeight: 'bold',
                      marginRight: '8px'
                    }}>
                      {comment.author?.display_name ? comment.author.display_name.charAt(0) : 'U'}
                    </div>
                    <div>
                      <div style={{ fontWeight: 'bold', fontSize: '14px' }}>
                        {comment.author?.display_name || 'Unknown User'}
                      </div>
                      <div style={{ fontSize: '12px', color: '#666' }}>
                        {new Date(comment.created_at).toLocaleDateString('ja-JP', {
                          year: 'numeric',
                          month: '2-digit',
                          day: '2-digit',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </div>
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: 4 }}>
                    <button
                      onClick={() => handleEdit(comment)}
                      style={{
                        padding: '4px 8px',
                        fontSize: 11,
                        backgroundColor: 'transparent',
                        border: '1px solid #e9ecef',
                        borderRadius: 3,
                        cursor: 'pointer',
                        color: '#666'
                      }}
                    >
                      編集
                    </button>
                    <button
                      onClick={() => handleDelete(comment.id)}
                      style={{
                        padding: '4px 8px',
                        fontSize: 11,
                        backgroundColor: 'transparent',
                        border: '1px solid #dc3545',
                        borderRadius: 3,
                        cursor: 'pointer',
                        color: '#dc3545'
                      }}
                    >
                      削除
                    </button>
                  </div>
                </div>

                {editingId === comment.id ? (
                  <div>
                    <textarea
                      value={editingText}
                      onChange={(e) => setEditingText(e.target.value)}
                      style={{
                        width: '100%',
                        minHeight: 80,
                        padding: 8,
                        border: '1px solid #e9ecef',
                        borderRadius: 4,
                        fontSize: 14,
                        resize: 'vertical',
                        marginBottom: 8
                      }}
                    />
                    <div style={{ display: 'flex', gap: 8 }}>
                      <button
                        onClick={handleSaveEdit}
                        style={{
                          padding: '6px 12px',
                          fontSize: 12,
                          backgroundColor: '#007bff',
                          color: '#fff',
                          border: 'none',
                          borderRadius: 4,
                          cursor: 'pointer'
                        }}
                      >
                        保存
                      </button>
                      <button
                        onClick={handleCancelEdit}
                        style={{
                          padding: '6px 12px',
                          fontSize: 12,
                          backgroundColor: '#6c757d',
                          color: '#fff',
                          border: 'none',
                          borderRadius: 4,
                          cursor: 'pointer'
                        }}
                      >
                        キャンセル
                      </button>
                    </div>
                  </div>
                ) : (
                  <div style={{
                    fontSize: 14,
                    lineHeight: 1.5,
                    color: '#333',
                    whiteSpace: 'pre-wrap'
                  }}>
                    {comment.body}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* 新しいコメント入力 */}
      <form onSubmit={handleSubmit}>
        <textarea
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          placeholder="コメントを入力してください..."
          style={{
            width: '100%',
            minHeight: 80,
            padding: 12,
            border: '1px solid #e9ecef',
            borderRadius: 6,
            fontSize: 14,
            resize: 'vertical',
            marginBottom: 12
          }}
        />
        <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
          <button
            type="submit"
            disabled={!newComment.trim() || isSubmitting}
            style={{
              padding: '8px 16px',
              fontSize: 14,
              backgroundColor: newComment.trim() && !isSubmitting ? '#007bff' : '#e9ecef',
              color: newComment.trim() && !isSubmitting ? '#fff' : '#6c757d',
              border: 'none',
              borderRadius: 4,
              cursor: newComment.trim() && !isSubmitting ? 'pointer' : 'not-allowed',
              fontWeight: 500
            }}
          >
            {isSubmitting ? 'コメント中...' : 'コメントする'}
          </button>
        </div>
      </form>
    </div>
  )
}
