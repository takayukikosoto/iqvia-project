import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface Mention {
  id: string
  message_id: string
  mentioned_user_id: string
  mentioned_by_user_id: string
  project_id: string
  mention_text: string
  read_at?: string
  created_at: string
}

export interface ProjectMember {
  user_id: string
  display_name: string
  username: string
}

export function useMentions(projectId: string) {
  const [mentions, setMentions] = useState<Mention[]>([])
  const [projectMembers, setProjectMembers] = useState<ProjectMember[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // プロジェクトメンバー一覧取得
  const fetchProjectMembers = async () => {
    if (!projectId) return

    try {
      // project_membershipsからuser_idを取得し、profilesを別途取得
      const { data: memberships, error: membershipError } = await supabase
        .from('project_memberships')
        .select('user_id')
        .eq('project_id', projectId)

      if (membershipError) throw membershipError

      if (!memberships || memberships.length === 0) {
        setProjectMembers([])
        return
      }

      // ユーザーIDのリストを作成
      const userIds = memberships.map(m => m.user_id)

      // profilesテーブルから対応するプロフィール情報を取得
      const { data: profiles, error: profilesError } = await supabase
        .from('profiles')
        .select('user_id, display_name')
        .in('user_id', userIds)

      if (profilesError) throw profilesError

      // メンバー情報を作成
      const members: ProjectMember[] = []
      if (profiles) {
        profiles.forEach((profile: any) => {
          members.push({
            user_id: profile.user_id,
            display_name: profile.display_name || 'Unknown User',
            username: profile.display_name || 'user'
          })
        })
      }
      setProjectMembers(members)
    } catch (err) {
      console.error('Error fetching project members:', err)
      setError('Failed to fetch project members')
    }
  }

  // 自分へのメンション一覧取得
  const fetchMyMentions = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return

      const { data, error } = await supabase
        .from('mentions')
        .select('*')
        .eq('mentioned_user_id', user.id)
        .eq('project_id', projectId)
        .order('created_at', { ascending: false })

      if (error) throw error
      setMentions(data || [])
    } catch (err) {
      console.error('Error fetching mentions:', err)
      setError(err instanceof Error ? err.message : 'Failed to fetch mentions')
    } finally {
      setLoading(false)
    }
  }

  // メンションを既読にする
  const markMentionAsRead = async (mentionId: string) => {
    try {
      const { error } = await supabase
        .from('mentions')
        .update({ read_at: new Date().toISOString() })
        .eq('id', mentionId)

      if (error) throw error

      // ローカル状態更新
      setMentions(prev => 
        prev.map(mention => 
          mention.id === mentionId 
            ? { ...mention, read_at: new Date().toISOString() }
            : mention
        )
      )
    } catch (err) {
      console.error('Error marking mention as read:', err)
    }
  }

  // 未読メンション数取得
  const getUnreadMentionsCount = () => {
    return mentions.filter(mention => !mention.read_at).length
  }

  // メンション候補検索（@入力時のオートコンプリート用）
  const searchMentionCandidates = (query: string): ProjectMember[] => {
    if (!query || query.length < 1) return []
    
    const searchTerm = query.toLowerCase()
    return projectMembers.filter(member => 
      member.username.toLowerCase().includes(searchTerm) ||
      member.display_name.toLowerCase().includes(searchTerm)
    ).slice(0, 5) // 最大5件
  }

  // メッセージ内のメンションをハイライト
  const highlightMentions = (text: string): string => {
    const mentionRegex = /@([a-zA-Z0-9._-]+)/g
    return text.replace(mentionRegex, '<span class="mention-highlight">$&</span>')
  }

  // リアルタイム購読設定
  useEffect(() => {
    if (!projectId) return

    const channel = supabase
      .channel('mentions-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'mentions',
          filter: `project_id=eq.${projectId}`
        },
        (payload) => {
          console.log('Mention change received:', payload)
          fetchMyMentions() // メンション一覧を再取得
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [projectId])

  useEffect(() => {
    if (projectId) {
      fetchProjectMembers()
      fetchMyMentions()
    }
  }, [projectId])

  return {
    mentions,
    projectMembers,
    loading,
    error,
    markMentionAsRead,
    getUnreadMentionsCount,
    searchMentionCandidates,
    highlightMentions,
    refetch: fetchMyMentions
  }
}
