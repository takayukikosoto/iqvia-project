import React, { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface UserActivity {
  id: string
  activity_type: string
  entity_type?: string
  entity_id?: string
  entity_name?: string
  description: string
  metadata?: any
  created_at: string
}

export function useUserActivity() {
  const { user } = useAuth()
  const [activities, setActivities] = useState<UserActivity[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchActivities = async () => {
    if (!user) {
      setActivities([])
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('user_activities')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(20)

      if (fetchError) {
        throw fetchError
      }

      setActivities(data || [])
    } catch (err: any) {
      console.error('Error fetching user activities:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // アクティビティを手動で記録する関数
  const logActivity = async (
    activityType: string,
    description: string,
    entityType?: string,
    entityId?: string,
    entityName?: string,
    metadata?: any
  ) => {
    if (!user) return null

    try {
      const { data, error } = await supabase
        .from('user_activities')
        .insert({
          user_id: user.id,
          activity_type: activityType,
          entity_type: entityType,
          entity_id: entityId,
          entity_name: entityName,
          description,
          metadata: metadata || {}
        })
        .select()
        .single()

      if (error) throw error

      // 新しいアクティビティを先頭に追加
      setActivities(prev => [data, ...prev.slice(0, 19)])
      
      return data
    } catch (err: any) {
      console.error('Error logging activity:', err)
      return null
    }
  }

  // 今週のアクティビティ統計を取得
  const getWeeklyStats = () => {
    const weekStart = new Date()
    weekStart.setDate(weekStart.getDate() - weekStart.getDay() + 1) // 月曜日
    weekStart.setHours(0, 0, 0, 0)

    const thisWeekActivities = activities.filter(activity => 
      new Date(activity.created_at) >= weekStart
    )

    const stats = {
      tasksCompleted: thisWeekActivities.filter(a => a.activity_type === 'task_completed').length,
      filesUploaded: thisWeekActivities.filter(a => a.activity_type === 'file_uploaded').length,
      commentsPosted: thisWeekActivities.filter(a => a.activity_type === 'comment_posted').length,
      totalActivities: thisWeekActivities.length
    }

    return stats
  }

  // アクティビティタイプに応じたアイコンとスタイル
  const getActivityDisplay = (activity: UserActivity) => {
    switch (activity.activity_type) {
      case 'task_completed':
        return {
          icon: '✅',
          bgColor: 'bg-green-100',
          iconColor: 'text-green-600',
          iconSvg: React.createElement('svg', {
            className: 'w-4 h-4 text-green-600',
            fill: 'currentColor',
            viewBox: '0 0 20 20'
          }, React.createElement('path', {
            fillRule: 'evenodd',
            d: 'M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z',
            clipRule: 'evenodd'
          }))
        }
      case 'task_created':
        return {
          icon: '📝',
          bgColor: 'bg-blue-100',
          iconColor: 'text-blue-600',
          iconSvg: React.createElement('svg', {
            className: 'w-4 h-4 text-blue-600',
            fill: 'currentColor',
            viewBox: '0 0 20 20'
          }, React.createElement('path', {
            fillRule: 'evenodd',
            d: 'M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z',
            clipRule: 'evenodd'
          }))
        }
      case 'file_uploaded':
        return {
          icon: '📎',
          bgColor: 'bg-blue-100',
          iconColor: 'text-blue-600',
          iconSvg: React.createElement('svg', {
            className: 'w-4 h-4 text-blue-600',
            fill: 'currentColor',
            viewBox: '0 0 20 20'
          }, React.createElement('path', {
            fillRule: 'evenodd',
            d: 'M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z',
            clipRule: 'evenodd'
          }))
        }
      case 'comment_posted':
        return {
          icon: '💬',
          bgColor: 'bg-purple-100', 
          iconColor: 'text-purple-600',
          iconSvg: React.createElement('svg', {
            className: 'w-4 h-4 text-purple-600',
            fill: 'currentColor',
            viewBox: '0 0 20 20'
          }, React.createElement('path', {
            fillRule: 'evenodd',
            d: 'M18 5v8a2 2 0 01-2 2h-5l-5 4v-4H4a2 2 0 01-2-2V5a2 2 0 012-2h12a2 2 0 012 2zM7 8H5v2h2V8zm2 0h2v2H9V8zm6 0h-2v2h2V8z',
            clipRule: 'evenodd'
          }))
        }
      default:
        return {
          icon: '📌',
          bgColor: 'bg-gray-100',
          iconColor: 'text-gray-600',
          iconSvg: React.createElement('svg', {
            className: 'w-4 h-4 text-gray-600',
            fill: 'currentColor',
            viewBox: '0 0 20 20'
          }, React.createElement('path', {
            fillRule: 'evenodd',
            d: 'M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z',
            clipRule: 'evenodd'
          }))
        }
    }
  }

  useEffect(() => {
    fetchActivities()
  }, [user])

  return {
    activities,
    loading,
    error,
    logActivity,
    getWeeklyStats,
    getActivityDisplay,
    refetch: fetchActivities
  }
}
