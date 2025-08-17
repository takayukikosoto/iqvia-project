import React from 'react'
import { useMentions } from '../hooks/useMentions'

interface MentionNotificationsProps {
  projectId: string
}

export default function MentionNotifications({ projectId }: MentionNotificationsProps) {
  const { mentions, getUnreadMentionsCount, markMentionAsRead } = useMentions(projectId)

  const unreadCount = getUnreadMentionsCount()
  const unreadMentions = mentions.filter(mention => !mention.read_at).slice(0, 5) // 最新5件

  if (unreadCount === 0) {
    return null
  }

  return (
    <div style={{
      position: 'fixed',
      top: 16,
      right: 16,
      backgroundColor: 'white',
      border: '1px solid #d1d5db',
      borderRadius: 8,
      boxShadow: '0 10px 25px rgba(0, 0, 0, 0.1)',
      minWidth: 300,
      maxWidth: 400,
      zIndex: 1000
    }}>
      {/* Header */}
      <div style={{
        padding: '12px 16px',
        borderBottom: '1px solid #e5e7eb',
        backgroundColor: '#fef3c7',
        borderRadius: '8px 8px 0 0'
      }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between'
        }}>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8
          }}>
            <span style={{ fontSize: 16 }}>🔔</span>
            <span style={{ 
              fontWeight: 600, 
              fontSize: 14,
              color: '#92400e'
            }}>
              新しいメンション
            </span>
          </div>
          <div style={{
            backgroundColor: '#f59e0b',
            color: 'white',
            padding: '2px 8px',
            borderRadius: 12,
            fontSize: 12,
            fontWeight: 600
          }}>
            {unreadCount}
          </div>
        </div>
      </div>

      {/* Mentions List */}
      <div style={{ maxHeight: 300, overflowY: 'auto' }}>
        {unreadMentions.map((mention) => (
          <div
            key={mention.id}
            onClick={() => markMentionAsRead(mention.id)}
            style={{
              padding: '12px 16px',
              borderBottom: '1px solid #f3f4f6',
              cursor: 'pointer',
              transition: 'background-color 0.2s'
            }}
            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#f9fafb'}
            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'white'}
          >
            <div style={{
              display: 'flex',
              alignItems: 'flex-start',
              gap: 8
            }}>
              <div style={{
                width: 8,
                height: 8,
                backgroundColor: '#3b82f6',
                borderRadius: '50%',
                marginTop: 6,
                flexShrink: 0
              }} />
              <div style={{ flex: 1 }}>
                <div style={{
                  fontSize: 14,
                  fontWeight: 600,
                  color: '#374151',
                  marginBottom: 4
                }}>
                  チャットでメンションされました
                </div>
                <div style={{
                  fontSize: 13,
                  color: '#6b7280',
                  marginBottom: 4
                }}>
                  {mention.mention_text}
                </div>
                <div style={{
                  fontSize: 12,
                  color: '#9ca3af'
                }}>
                  {new Date(mention.created_at).toLocaleString('ja-JP', {
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                  })}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Footer */}
      {unreadCount > 5 && (
        <div style={{
          padding: '8px 16px',
          borderTop: '1px solid #e5e7eb',
          backgroundColor: '#f9fafb',
          textAlign: 'center',
          fontSize: 12,
          color: '#6b7280'
        }}>
          他に {unreadCount - 5} 件の未読メンションがあります
        </div>
      )}
    </div>
  )
}
