import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface CalendarEvent {
  id: string
  title: string
  description?: string
  start: string
  end?: string
  all_day: boolean
  owner_user_id: string
  color?: string
  location?: string
  created_at: string
  updated_at: string
}

export interface CreateEventData {
  title: string
  description?: string
  start: string
  end?: string
  all_day?: boolean
  color?: string
  location?: string
}

export interface UpdateEventData {
  title?: string
  description?: string
  start?: string
  end?: string
  all_day?: boolean
  color?: string
  location?: string
}

export function usePersonalCalendar() {
  const { user } = useAuth()
  const [events, setEvents] = useState<CalendarEvent[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchEvents = async () => {
    if (!user) {
      setEvents([])
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('events')
        .select('*')
        .eq('owner_user_id', user.id)
        .order('start', { ascending: true })

      if (fetchError) {
        throw fetchError
      }

      setEvents(data || [])
    } catch (err: any) {
      console.error('Error fetching calendar events:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  // イベント作成
  const createEvent = async (eventData: CreateEventData) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const newEvent = {
        title: eventData.title,
        description: eventData.description || null,
        start: eventData.start,
        end: eventData.end || null,
        all_day: eventData.all_day || false,
        color: eventData.color || '#3b82f6',
        location: eventData.location || null,
        owner_user_id: user.id
      }

      const { data, error } = await supabase
        .from('events')
        .insert(newEvent)
        .select()
        .single()

      if (error) throw error

      setEvents(prev => [...prev, data].sort((a, b) => 
        new Date(a.start).getTime() - new Date(b.start).getTime()
      ))

      return { success: true, data }
    } catch (err: any) {
      console.error('Error creating event:', err)
      return { success: false, error: err.message }
    }
  }

  // イベント更新
  const updateEvent = async (id: string, updates: UpdateEventData) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const updateData = { 
        ...updates,
        updated_at: new Date().toISOString()
      }

      const { data, error } = await supabase
        .from('events')
        .update(updateData)
        .eq('id', id)
        .eq('owner_user_id', user.id)
        .select()
        .single()

      if (error) throw error

      setEvents(prev => prev.map(event => 
        event.id === id ? data : event
      ).sort((a, b) => 
        new Date(a.start).getTime() - new Date(b.start).getTime()
      ))

      return { success: true, data }
    } catch (err: any) {
      console.error('Error updating event:', err)
      return { success: false, error: err.message }
    }
  }

  // イベント削除
  const deleteEvent = async (id: string) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const { error } = await supabase
        .from('events')
        .delete()
        .eq('id', id)
        .eq('owner_user_id', user.id)

      if (error) throw error

      setEvents(prev => prev.filter(event => event.id !== id))
      return { success: true }
    } catch (err: any) {
      console.error('Error deleting event:', err)
      return { success: false, error: err.message }
    }
  }

  // 今月のイベント取得
  const getThisMonthEvents = () => {
    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
    const monthEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59)
    
    return events.filter(event => {
      const eventStart = new Date(event.start)
      return eventStart >= monthStart && eventStart <= monthEnd
    })
  }

  // 今週のイベント取得
  const getThisWeekEvents = () => {
    const now = new Date()
    const weekStart = new Date(now)
    const day = weekStart.getDay()
    const diff = weekStart.getDate() - day + (day === 0 ? -6 : 1) // Monday
    weekStart.setDate(diff)
    weekStart.setHours(0, 0, 0, 0)
    
    const weekEnd = new Date(weekStart)
    weekEnd.setDate(weekEnd.getDate() + 6)
    weekEnd.setHours(23, 59, 59, 999)
    
    return events.filter(event => {
      const eventStart = new Date(event.start)
      return eventStart >= weekStart && eventStart <= weekEnd
    })
  }

  // 今日のイベント取得
  const getTodayEvents = () => {
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const tomorrow = new Date(today)
    tomorrow.setDate(tomorrow.getDate() + 1)
    
    return events.filter(event => {
      const eventStart = new Date(event.start)
      return eventStart >= today && eventStart < tomorrow
    })
  }

  // FullCalendar用のイベントフォーマット
  const getFullCalendarEvents = () => {
    return events.map(event => ({
      id: event.id,
      title: event.title,
      start: event.start,
      end: event.end,
      allDay: event.all_day,
      backgroundColor: event.color || '#3b82f6',
      borderColor: event.color || '#3b82f6',
      extendedProps: {
        description: event.description,
        location: event.location,
        owner_user_id: event.owner_user_id
      }
    }))
  }

  // カレンダー統計
  const getCalendarStats = () => {
    const today = getTodayEvents()
    const thisWeek = getThisWeekEvents()
    const thisMonth = getThisMonthEvents()
    
    return {
      todayCount: today.length,
      weekCount: thisWeek.length,
      monthCount: thisMonth.length,
      totalCount: events.length
    }
  }

  useEffect(() => {
    fetchEvents()
  }, [user])

  return {
    events,
    loading,
    error,
    createEvent,
    updateEvent,
    deleteEvent,
    getThisMonthEvents,
    getThisWeekEvents,
    getTodayEvents,
    getFullCalendarEvents,
    getCalendarStats,
    refetch: fetchEvents
  }
}
