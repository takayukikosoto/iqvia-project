import React, { useState, useEffect, useRef } from 'react'
import { supabase } from '../supabaseClient'
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
  const messagesEndRef = useRef<HTMLDivElement>(null)

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
      .select('id, project_id, user_id, content, created_at')
      .eq('project_id', projectId)
      .order('created_at', { ascending: true })
      .limit(50)

    if (error) {
      console.error('メッセージ読み込みエラー:', error)
      setMessages([])
    } else {
      const messagesWithUsers = data.map(msg => ({
        ...msg,
        user: {
          email: `User ${msg.user_id.slice(0, 8)}`,
          name: `User ${msg.user_id.slice(0, 8)}`
        }
      }))
      
      setMessages(messagesWithUsers)
    }
    setLoading(false)
  }

  const sendMessage = async () => {
    if (!newMessage.trim() || !user || !projectId) return

    const messageData = {
      content: newMessage.trim(),
      project_id: projectId,
      user_id: user.id
    }

    const { error } = await supabase
      .from('chat_messages')
      .insert([messageData])

    if (error) {
      console.error('メッセージ送信エラー:', error)
    } else {
      setNewMessage('')
      loadMessages()
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      e.preventDefault()
      sendMessage()
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
      .channel(`chat_${projectId}`)
      .on('postgres_changes', 
        { event: 'INSERT', schema: 'public', table: 'chat_messages', filter: `project_id=eq.${projectId}` },
        () => loadMessages()
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [projectId])

  const formatTime = (dateString: string) => {
    return new Date(dateString).toLocaleTimeString('ja-JP', { 
      hour: '2-digit', 
      minute: '2-digit'
    })
  }

  if (!projectId) {
    return (
      <div className="p-4 text-center text-gray-500">
        プロジェクトを選択してください
      </div>
    )
  }

  return (
    <div className="flex flex-col h-full bg-white rounded-lg shadow border">
      {/* Header */}
      <div className="p-3 border-b bg-gray-50 rounded-t-lg">
        <h3 className="font-medium text-gray-900">💬 チャット</h3>
      </div>

      {/* Messages */}
      <div className="flex-1 p-3 overflow-y-auto space-y-3">
        {loading ? (
          <div className="text-center text-gray-500">読み込み中...</div>
        ) : messages.length === 0 ? (
          <div className="text-center text-gray-500 text-sm">
            まだメッセージがありません
          </div>
        ) : (
          messages.map((message) => {
            const isCurrentUser = message.user_id === user?.id
            return (
              <div
                key={message.id}
                className={`flex ${isCurrentUser ? 'justify-end' : 'justify-start'}`}
              >
                <div
                  className={`max-w-xs px-3 py-2 rounded-lg text-sm ${
                    isCurrentUser
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-100 text-gray-800'
                  }`}
                >
                  {!isCurrentUser && (
                    <div className="text-xs opacity-70 mb-1">
                      {message.user?.name}
                    </div>
                  )}
                  <div>{message.content}</div>
                  <div className="text-xs opacity-70 mt-1">
                    {formatTime(message.created_at)}
                  </div>
                </div>
              </div>
            )
          })
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-3 border-t bg-gray-50 rounded-b-lg">
        <div className="flex gap-2">
          <input
            type="text"
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="メッセージを入力..."
            className="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={sendMessage}
            disabled={!newMessage.trim()}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            送信
          </button>
        </div>
      </div>
    </div>
  )
}
