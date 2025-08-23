import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface RecentCommentInfo {
  taskId: string
  latestCommentAt: string | null
  hasRecentComments: boolean
  commentCount: number
}

export function useRecentComments(taskIds: string[]) {
  const [commentInfo, setCommentInfo] = useState<Record<string, RecentCommentInfo>>({})
  const [loading, setLoading] = useState(true)

  const fetchRecentComments = async () => {
    if (taskIds.length === 0) {
      setCommentInfo({})
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      
      // Get latest comment for each task
      const { data: comments, error } = await supabase
        .from('comments')
        .select('target_id, created_at')
        .eq('target_type', 'task')
        .in('target_id', taskIds)
        .order('created_at', { ascending: false })

      if (error) throw error

      // Process comments to get latest info for each task
      const info: Record<string, RecentCommentInfo> = {}
      const now = new Date()
      const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000) // 24 hours ago

      // Initialize all tasks with no comments
      taskIds.forEach(taskId => {
        info[taskId] = {
          taskId,
          latestCommentAt: null,
          hasRecentComments: false,
          commentCount: 0
        }
      })

      // Group comments by task
      const commentsByTask: Record<string, any[]> = {}
      comments?.forEach(comment => {
        if (!commentsByTask[comment.target_id]) {
          commentsByTask[comment.target_id] = []
        }
        commentsByTask[comment.target_id].push(comment)
      })

      // Process each task's comments
      Object.entries(commentsByTask).forEach(([taskId, taskComments]) => {
        const latestComment = taskComments[0] // Already sorted by created_at desc
        const commentCount = taskComments.length
        const latestCommentDate = new Date(latestComment.created_at)
        const hasRecentComments = latestCommentDate > oneDayAgo

        info[taskId] = {
          taskId,
          latestCommentAt: latestComment.created_at,
          hasRecentComments,
          commentCount
        }
      })

      setCommentInfo(info)
    } catch (err) {
      console.error('Error fetching recent comments:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchRecentComments()
  }, [taskIds.join(',')])

  // Subscribe to real-time comment changes
  useEffect(() => {
    if (taskIds.length === 0) return

    const subscription = supabase
      .channel('recent_comments')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'comments',
          filter: `target_type=eq.task`
        },
        () => {
          fetchRecentComments() // Refetch when comments change
        }
      )
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [taskIds.join(',')])

  return {
    commentInfo,
    loading,
    refreshComments: fetchRecentComments
  }
}
