import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface TaskComment {
  id: string
  target_type: 'task' | 'file'
  target_id: string
  body: string
  parent_id?: string
  created_at: string
  created_by: string
  author?: {
    display_name: string
    company?: string
  }
}

export function useTaskComments(taskId: string) {
  const [comments, setComments] = useState<TaskComment[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchComments = async () => {
    try {
      setLoading(true)
      // First get comments
      const { data: commentsData, error: commentsError } = await supabase
        .from('comments')
        .select('*')
        .eq('target_type', 'task')
        .eq('target_id', taskId)
        .order('created_at', { ascending: true })

      if (commentsError) throw commentsError

      // Then get user profiles for each comment
      const commentsWithAuthors = await Promise.all(
        (commentsData || []).map(async (comment) => {
          try {
            const { data: profile, error } = await supabase
              .from('profiles')
              .select('display_name, company')
              .eq('user_id', comment.created_by)
              .maybeSingle()
            
            // If no profile found or error, create a default author
            if (error || !profile) {
              console.log(`No profile found for user ${comment.created_by}, using default`)
              return {
                ...comment,
                author: {
                  display_name: 'Unknown User',
                  company: null
                }
              }
            }
            
            return {
              ...comment,
              author: profile
            }
          } catch (err) {
            console.error(`Error fetching profile for user ${comment.created_by}:`, err)
            return {
              ...comment,
              author: {
                display_name: 'Unknown User',
                company: null
              }
            }
          }
        })
      )

      setComments(commentsWithAuthors)
    } catch (err) {
      console.error('Error fetching comments:', err)
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  const addComment = async (body: string, parentId?: string) => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('User not authenticated')

      const { data, error } = await supabase
        .from('comments')
        .insert([
          {
            target_type: 'task',
            target_id: taskId,
            body,
            parent_id: parentId || null,
            created_by: user.id
          }
        ])
        .select('*')
        .single()

      if (error) throw error
      
      // Get user profile separately
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('display_name, company')
        .eq('user_id', user.id)
        .maybeSingle()

      const commentWithAuthor = {
        ...data,
        author: profile || {
          display_name: 'Unknown User',
          company: null
        }
      }
      
      // Add to local state
      setComments(prev => [...prev, commentWithAuthor])
      return commentWithAuthor
    } catch (err) {
      console.error('Error adding comment:', err)
      setError(err instanceof Error ? err.message : 'Failed to add comment')
      throw err
    }
  }

  const updateComment = async (commentId: string, body: string) => {
    try {
      const { data, error } = await supabase
        .from('comments')
        .update({ body })
        .eq('id', commentId)
        .select('*')
        .single()

      if (error) throw error
      
      // Get user profile separately
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('display_name, company')
        .eq('user_id', data.created_by)
        .maybeSingle()

      const commentWithAuthor = {
        ...data,
        author: profile || {
          display_name: 'Unknown User',
          company: null
        }
      }
      
      // Update local state
      setComments(prev => 
        prev.map(comment => 
          comment.id === commentId ? commentWithAuthor : comment
        )
      )
      return commentWithAuthor
    } catch (err) {
      console.error('Error updating comment:', err)
      setError(err instanceof Error ? err.message : 'Failed to update comment')
      throw err
    }
  }

  const deleteComment = async (commentId: string) => {
    try {
      const { error } = await supabase
        .from('comments')
        .delete()
        .eq('id', commentId)

      if (error) throw error
      
      // Remove from local state
      setComments(prev => prev.filter(comment => comment.id !== commentId))
    } catch (err) {
      console.error('Error deleting comment:', err)
      setError(err instanceof Error ? err.message : 'Failed to delete comment')
      throw err
    }
  }

  useEffect(() => {
    if (taskId) {
      fetchComments()
    }
  }, [taskId])

  // Set up real-time subscription
  useEffect(() => {
    if (taskId) {
      fetchComments()
      
      // Subscribe to real-time changes
      const subscription = supabase
        .channel(`comments_${taskId}`)
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'comments',
            filter: `target_type=eq.task,target_id=eq.${taskId}`
          },
          () => {
            fetchComments() // Refetch comments when changes occur
          }
        )
        .subscribe()

      return () => {
        subscription.unsubscribe()
      }
    }
  }, [taskId])

  return {
    comments,
    loading,
    error,
    addComment,
    updateComment,
    deleteComment,
    refreshComments: fetchComments
  }
}
