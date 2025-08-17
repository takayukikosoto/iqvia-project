import React, { useState, useEffect, useRef } from 'react'
import { supabase } from '../supabaseClient'
import { useMentions, ProjectMember } from '../hooks/useMentions'
import { useAuth } from '../hooks/useAuth'

interface ChatMessage {
  id: string
  project_id: string
  user_id: string
  content: string
  created_at: string
  user?: {
    email: string
    name?: string
  }
}

interface ChatProps {
  projectId: string
}

export default function Chat({ projectId }: ChatProps) {
  const { user } = useAuth()
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [newMessage, setNewMessage] = useState('')
  const [loading, setLoading] = useState(true)
  const [showMentionSuggestions, setShowMentionSuggestions] = useState(false)
  const [mentionQuery, setMentionQuery] = useState('')
  const [cursorPosition, setCursorPosition] = useState(0)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  
  // Mentions hook
  const { projectMembers, searchMentionCandidates, highlightMentions } = useMentions(projectId)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const loadMessages = async () => {
    if (!projectId) return
    
    setLoading(true)
    const { data, error } = await supabase
      .from('chat_messages')
      .select(`
        id,
        project_id,
        user_id,
        content,
        created_at
      `)
      .eq('project_id', projectId)
      .order('created_at', { ascending: true })
      .limit(100)

    if (error) {
      console.error('Chat messages load error:', error)
    } else {
      // Get user profiles for messages
      const userIds = [...new Set(data.map(msg => msg.user_id))]
      const { data: profiles } = await supabase
        .from('profiles')
        .select('user_id, display_name')
        .in('user_id', userIds)
      
      const profileMap = profiles?.reduce((acc, profile) => {
        acc[profile.user_id] = profile.display_name
        return acc
      }, {} as Record<string, string>) || {}

      const messagesWithUsers = data.map(msg => ({
        ...msg,
        user: {
          email: profileMap[msg.user_id] || 'Unknown User',
          name: profileMap[msg.user_id]
        }
      }))
      
      setMessages(messagesWithUsers)
    }
    setLoading(false)
  }

  // メンション検出とサジェスト表示
  const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value
    const position = e.target.selectionStart
    
    setNewMessage(value)
    setCursorPosition(position)
    
    // @の後の文字列を検出
    const beforeCursor = value.substring(0, position)
    const mentionMatch = beforeCursor.match(/@([a-zA-Z0-9._-]*)$/)
    
    if (mentionMatch) {
      setMentionQuery(mentionMatch[1])
      setShowMentionSuggestions(true)
    } else {
      setShowMentionSuggestions(false)
      setMentionQuery('')
    }
  }

  // メンション候補選択
  const selectMention = (member: ProjectMember) => {
    const beforeCursor = newMessage.substring(0, cursorPosition)
    const afterCursor = newMessage.substring(cursorPosition)
    
    // @query を @email に置換
    const mentionText = `@${member.email.split('@')[0]}`
    const beforeMention = beforeCursor.replace(/@[a-zA-Z0-9._-]*$/, '')
    const newText = beforeMention + mentionText + ' ' + afterCursor
    
    setNewMessage(newText)
    setShowMentionSuggestions(false)
    setMentionQuery('')
    
    // フォーカスを戻す
    setTimeout(() => {
      textareaRef.current?.focus()
      const newPosition = beforeMention.length + mentionText.length + 1
      textareaRef.current?.setSelectionRange(newPosition, newPosition)
    }, 0)
  }

  const sendMessage = async () => {
    if (!newMessage.trim() || !user || !projectId) {
      console.log('Send message blocked:', { 
        hasMessage: !!newMessage.trim(), 
        hasUser: !!user, 
        hasProjectId: !!projectId 
      })
      return
    }

    console.log('Sending message:', newMessage)
    console.log('Project ID:', projectId)
    console.log('User ID:', user.id)

    const messageData = {
      content: newMessage,
      project_id: projectId,
      user_id: user.id
    }

    const { data, error } = await supabase
      .from('chat_messages')
      .insert([messageData])
      .select()

    if (error) {
      console.error('Send message error:', error)
    } else {
      console.log('Message sent successfully:', data)
      setNewMessage('')
      setShowMentionSuggestions(false)
    }
  }

  // キーボードイベント処理
  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      if (showMentionSuggestions) {
        // メンション候補が表示中の場合は何もしない
        return
      }
      sendMessage()
    } else if (e.key === 'Escape' && showMentionSuggestions) {
      setShowMentionSuggestions(false)
    }
  }

  useEffect(() => {
    if (projectId) {
      loadMessages()
    }
  }, [projectId])

  useEffect(() => {
    if (!projectId) return

    const channel = supabase
      .channel('chat_messages')
      .on('postgres_changes', 
        { event: 'INSERT', schema: 'public', table: 'chat_messages', filter: `project_id=eq.${projectId}` },
        () => {
          loadMessages()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [projectId])

  const formatTime = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleTimeString('ja-JP', { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: false 
    })
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)

    if (date.toDateString() === today.toDateString()) {
      return '今日'
    } else if (date.toDateString() === yesterday.toDateString()) {
      return '昨日'
    } else {
      return date.toLocaleDateString('ja-JP', { month: 'short', day: 'numeric' })
    }
  }

  if (!projectId) {
    return (
      <div style={{ 
        padding: 16, 
        textAlign: 'center', 
        color: '#666',
        fontSize: 14
      }}>
        プロジェクトを選択してください
      </div>
    )
  }

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      height: '100%',
      backgroundColor: 'white',
      borderRadius: 8,
      boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
      overflow: 'hidden'
    }}>
      {/* Header */}
      <div style={{
        padding: '12px 16px',
        borderBottom: '1px solid #e5e7eb',
        backgroundColor: '#f8f9fa'
      }}>
        <h3 style={{ 
          margin: 0, 
          fontSize: 16, 
          fontWeight: 'bold',
          color: '#374151'
        }}>
          💬 プロジェクトチャット
        </h3>
      </div>

      {/* Messages */}
      <div style={{
        flex: 1,
        padding: 16,
        overflowY: 'auto',
        minHeight: 0
      }}>
        {loading ? (
          <div style={{ textAlign: 'center', color: '#666' }}>
            読み込み中...
          </div>
        ) : messages.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#666', fontSize: 14 }}>
            まだメッセージがありません。<br />
            最初のメッセージを送信してみましょう！
          </div>
        ) : (
          messages.map((message, index) => {
            const prevMessage = messages[index - 1]
            const showDate = !prevMessage || 
              formatDate(message.created_at) !== formatDate(prevMessage.created_at)
            const isCurrentUser = message.user_id === user?.id

            return (
              <div key={message.id}>
                {showDate && (
                  <div style={{
                    textAlign: 'center',
                    margin: '16px 0 8px',
                    fontSize: 12,
                    color: '#9ca3af'
                  }}>
                    {formatDate(message.created_at)}
                  </div>
                )}
                <div style={{
                  display: 'flex',
                  justifyContent: isCurrentUser ? 'flex-end' : 'flex-start',
                  marginBottom: 12
                }}>
                  <div style={{
                    maxWidth: '70%',
                    backgroundColor: isCurrentUser ? '#3b82f6' : '#f3f4f6',
                    color: isCurrentUser ? 'white' : '#374151',
                    padding: '8px 12px',
                    borderRadius: 12,
                    fontSize: 14
                  }}>
                    {!isCurrentUser && (
                      <div style={{
                        fontSize: 12,
                        opacity: 0.7,
                        marginBottom: 4
                      }}>
                        {message.user?.name || message.user?.email}
                      </div>
                    )}
                    <div style={{ wordBreak: 'break-word' }}>
                      {message.content}
                    </div>
                    <div style={{
                      fontSize: 11,
                      opacity: 0.7,
                      marginTop: 4,
                      textAlign: 'right'
                    }}>
                      {formatTime(message.created_at)}
                    </div>
                  </div>
                </div>
              </div>
            )
          })
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <form onSubmit={(e) => { e.preventDefault(); sendMessage(); }} style={{
        padding: 16,
        borderTop: '1px solid #e5e7eb',
        display: 'flex',
        gap: 8
      }}>
        <div style={{ position: 'relative', flex: 1 }}>
          <textarea
            ref={textareaRef}
            value={newMessage}
            onChange={handleInputChange}
            onKeyDown={handleKeyDown}
            placeholder="メッセージを入力... (@でメンション)"
            style={{
              width: '100%',
              padding: '8px 12px',
              border: '1px solid #d1d5db',
              borderRadius: 20,
              fontSize: 14,
              outline: 'none',
              resize: 'none',
              minHeight: 40
            }}
            onFocus={(e) => e.target.style.borderColor = '#3b82f6'}
            onBlur={(e) => e.target.style.borderColor = '#d1d5db'}
          />
          
          {/* Mention Suggestions */}
          {showMentionSuggestions && (
            <div style={{
              position: 'absolute',
              bottom: '100%',
              left: 0,
              right: 0,
              backgroundColor: 'white',
              border: '1px solid #d1d5db',
              borderRadius: 8,
              boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
              maxHeight: 200,
              overflowY: 'auto',
              zIndex: 1000
            }}>
              {searchMentionCandidates(mentionQuery).map((member, index) => (
                <div
                  key={member.user_id}
                  onClick={() => selectMention(member)}
                  style={{
                    padding: '8px 12px',
                    cursor: 'pointer',
                    borderBottom: index < searchMentionCandidates(mentionQuery).length - 1 ? '1px solid #f3f4f6' : 'none'
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#f3f4f6'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'white'}
                >
                  <div style={{ fontWeight: 600, fontSize: 14 }}>
                    @{member.email.split('@')[0]}
                  </div>
                  {member.display_name && (
                    <div style={{ fontSize: 12, color: '#6b7280' }}>
                      {member.display_name}
                    </div>
                  )}
                </div>
              ))}
              {searchMentionCandidates(mentionQuery).length === 0 && (
                <div style={{ padding: '8px 12px', color: '#6b7280', fontSize: 12 }}>
                  メンション候補が見つかりません
                </div>
              )}
            </div>
          )}
        </div>
        <button
          type="submit"
          disabled={!newMessage.trim()}
          style={{
            padding: '8px 16px',
            backgroundColor: newMessage.trim() ? '#3b82f6' : '#9ca3af',
            color: 'white',
            border: 'none',
            borderRadius: 20,
            fontSize: 14,
            cursor: newMessage.trim() ? 'pointer' : 'not-allowed',
            transition: 'background-color 0.2s'
          }}
        >
          送信
        </button>
      </form>
    </div>
  )
}
