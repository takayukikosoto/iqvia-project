import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface AttendanceRecord {
  id: string
  user_id: string
  attendance_type: 'work_start' | 'work_end' | 'break_start' | 'break_end' | 'leave_start' | 'leave_end' | 'sick_leave' | 'overtime'
  recorded_at: string
  location_lat?: number
  location_lng?: number
  location_name?: string
  note?: string
  is_manual: boolean
  task_id?: string
  created_at: string
  updated_at?: string
}

export interface DailyAttendanceSummary {
  id: string
  user_id: string
  work_date: string
  work_start_time?: string
  work_end_time?: string
  total_work_hours: number
  total_break_hours: number
  overtime_hours: number
  leave_hours: number
  status: 'working' | 'completed' | 'leave' | 'sick'
  created_at: string
  updated_at?: string
}

export interface AttendanceStats {
  todayHours: number
  weekHours: number
  monthHours: number
  overtimeHours: number
  workDays: number
  avgDailyHours: number
  isWorking: boolean
  lastAction?: AttendanceRecord
}

export function useAttendance() {
  const { user } = useAuth()
  const [records, setRecords] = useState<AttendanceRecord[]>([])
  const [dailySummary, setDailySummary] = useState<DailyAttendanceSummary[]>([])
  const [todaySummary, setTodaySummary] = useState<DailyAttendanceSummary | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchAttendanceRecords = async (limit = 50) => {
    if (!user) {
      setRecords([])
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      setError(null)

      const { data, error: fetchError } = await supabase
        .from('attendance_records')
        .select('*')
        .eq('user_id', user.id)
        .order('recorded_at', { ascending: false })
        .limit(limit)

      if (fetchError) throw fetchError
      setRecords(data || [])
    } catch (err: any) {
      console.error('Error fetching attendance records:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const fetchDailySummary = async () => {
    if (!user) return

    try {
      // 今月のサマリーを取得
      const startOfMonth = new Date()
      startOfMonth.setDate(1)
      startOfMonth.setHours(0, 0, 0, 0)

      const { data, error: fetchError } = await supabase
        .from('daily_attendance_summary')
        .select('*')
        .eq('user_id', user.id)
        .gte('work_date', startOfMonth.toISOString().split('T')[0])
        .order('work_date', { ascending: false })

      if (fetchError) throw fetchError
      setDailySummary(data || [])

      // 今日のサマリーを設定
      const today = new Date().toISOString().split('T')[0]
      const todayData = (data || []).find(d => d.work_date === today)
      setTodaySummary(todayData || null)
    } catch (err: any) {
      console.error('Error fetching daily summary:', err)
      setError(err.message)
    }
  }

  // 出勤記録
  const clockIn = async (location?: { lat?: number; lng?: number; name?: string }) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const recordData = {
        user_id: user.id,
        attendance_type: 'work_start' as const,
        recorded_at: new Date().toISOString(),
        location_lat: location?.lat,
        location_lng: location?.lng,
        location_name: location?.name,
        is_manual: false
      }

      const { data, error } = await supabase
        .from('attendance_records')
        .insert(recordData)
        .select()
        .single()

      if (error) throw error

      setRecords(prev => [data, ...prev])
      await fetchDailySummary() // サマリー更新
      return { success: true, data }
    } catch (err: any) {
      console.error('Error clocking in:', err)
      return { success: false, error: err.message }
    }
  }

  // 退勤記録
  const clockOut = async (location?: { lat?: number; lng?: number; name?: string }) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const recordData = {
        user_id: user.id,
        attendance_type: 'work_end' as const,
        recorded_at: new Date().toISOString(),
        location_lat: location?.lat,
        location_lng: location?.lng,
        location_name: location?.name,
        is_manual: false
      }

      const { data, error } = await supabase
        .from('attendance_records')
        .insert(recordData)
        .select()
        .single()

      if (error) throw error

      setRecords(prev => [data, ...prev])
      await fetchDailySummary() // サマリー更新
      return { success: true, data }
    } catch (err: any) {
      console.error('Error clocking out:', err)
      return { success: false, error: err.message }
    }
  }

  // 休憩開始
  const startBreak = async () => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const recordData = {
        user_id: user.id,
        attendance_type: 'break_start' as const,
        recorded_at: new Date().toISOString(),
        is_manual: false
      }

      const { data, error } = await supabase
        .from('attendance_records')
        .insert(recordData)
        .select()
        .single()

      if (error) throw error

      setRecords(prev => [data, ...prev])
      return { success: true, data }
    } catch (err: any) {
      console.error('Error starting break:', err)
      return { success: false, error: err.message }
    }
  }

  // 休憩終了
  const endBreak = async () => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const recordData = {
        user_id: user.id,
        attendance_type: 'break_end' as const,
        recorded_at: new Date().toISOString(),
        is_manual: false
      }

      const { data, error } = await supabase
        .from('attendance_records')
        .insert(recordData)
        .select()
        .single()

      if (error) throw error

      setRecords(prev => [data, ...prev])
      return { success: true, data }
    } catch (err: any) {
      console.error('Error ending break:', err)
      return { success: false, error: err.message }
    }
  }

  // 手動記録追加
  const addManualRecord = async (
    attendanceType: AttendanceRecord['attendance_type'],
    recordedAt: string,
    note?: string
  ) => {
    if (!user) return { success: false, error: 'User not authenticated' }

    try {
      const recordData = {
        user_id: user.id,
        attendance_type: attendanceType,
        recorded_at: recordedAt,
        note: note,
        is_manual: true
      }

      const { data, error } = await supabase
        .from('attendance_records')
        .insert(recordData)
        .select()
        .single()

      if (error) throw error

      setRecords(prev => [data, ...prev].sort((a, b) => 
        new Date(b.recorded_at).getTime() - new Date(a.recorded_at).getTime()
      ))
      
      await fetchDailySummary()
      return { success: true, data }
    } catch (err: any) {
      console.error('Error adding manual record:', err)
      return { success: false, error: err.message }
    }
  }

  // 現在の勤務状況取得
  const getCurrentWorkStatus = () => {
    const today = new Date().toISOString().split('T')[0]
    const todayRecords = records.filter(r => 
      r.recorded_at.startsWith(today)
    ).sort((a, b) => 
      new Date(a.recorded_at).getTime() - new Date(b.recorded_at).getTime()
    )

    let isWorking = false
    let isOnBreak = false
    let lastAction = todayRecords[todayRecords.length - 1]

    for (const record of todayRecords) {
      if (record.attendance_type === 'work_start') {
        isWorking = true
        isOnBreak = false
      } else if (record.attendance_type === 'work_end') {
        isWorking = false
        isOnBreak = false
      } else if (record.attendance_type === 'break_start') {
        isOnBreak = true
      } else if (record.attendance_type === 'break_end') {
        isOnBreak = false
      }
    }

    return {
      isWorking,
      isOnBreak,
      lastAction,
      canClockIn: !isWorking,
      canClockOut: isWorking && !isOnBreak,
      canStartBreak: isWorking && !isOnBreak,
      canEndBreak: isWorking && isOnBreak
    }
  }

  // 勤怠統計計算
  const getAttendanceStats = (): AttendanceStats => {
    const today = new Date()
    const todayStr = today.toISOString().split('T')[0]
    
    // 今週の開始日（月曜日）
    const weekStart = new Date(today)
    const day = weekStart.getDay()
    const diff = weekStart.getDate() - day + (day === 0 ? -6 : 1)
    weekStart.setDate(diff)
    weekStart.setHours(0, 0, 0, 0)
    
    // 今月の開始日
    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1)
    
    // 今日の勤務時間
    const todayHours = todaySummary?.total_work_hours || 0
    
    // 今週の勤務時間
    const weekHours = dailySummary
      .filter(d => new Date(d.work_date) >= weekStart)
      .reduce((sum, d) => sum + d.total_work_hours, 0)
    
    // 今月の勤務時間
    const monthHours = dailySummary
      .filter(d => new Date(d.work_date) >= monthStart)
      .reduce((sum, d) => sum + d.total_work_hours, 0)
    
    // 残業時間
    const overtimeHours = dailySummary
      .filter(d => new Date(d.work_date) >= monthStart)
      .reduce((sum, d) => sum + d.overtime_hours, 0)
    
    // 勤務日数
    const workDays = dailySummary
      .filter(d => new Date(d.work_date) >= monthStart && d.total_work_hours > 0)
      .length
    
    // 平均勤務時間
    const avgDailyHours = workDays > 0 ? monthHours / workDays : 0
    
    const status = getCurrentWorkStatus()
    
    return {
      todayHours,
      weekHours,
      monthHours,
      overtimeHours,
      workDays,
      avgDailyHours,
      isWorking: status.isWorking,
      lastAction: status.lastAction
    }
  }

  // 今日の勤務時間をリアルタイム計算
  const getTodayRealTimeHours = () => {
    if (!todaySummary?.work_start_time) return 0
    
    const startTime = new Date(todaySummary.work_start_time)
    const endTime = todaySummary.work_end_time ? 
      new Date(todaySummary.work_end_time) : new Date()
    
    const diffMs = endTime.getTime() - startTime.getTime()
    const hours = diffMs / (1000 * 60 * 60)
    
    // 休憩時間を引く
    return Math.max(hours - todaySummary.total_break_hours, 0)
  }

  useEffect(() => {
    if (user) {
      fetchAttendanceRecords()
      fetchDailySummary()
    }
  }, [user])

  return {
    records,
    dailySummary,
    todaySummary,
    loading,
    error,
    clockIn,
    clockOut,
    startBreak,
    endBreak,
    addManualRecord,
    getCurrentWorkStatus,
    getAttendanceStats,
    getTodayRealTimeHours,
    refetch: () => {
      fetchAttendanceRecords()
      fetchDailySummary()
    }
  }
}

// ヘルパー関数
export function getAttendanceTypeLabel(type: AttendanceRecord['attendance_type']): string {
  const labels: Record<string, string> = {
    work_start: '出勤',
    work_end: '退勤',
    break_start: '休憩開始',
    break_end: '休憩終了',
    leave_start: '有給開始',
    leave_end: '有給終了',
    sick_leave: '病気休暇',
    overtime: '残業'
  }
  return labels[type] || type
}

export function formatHours(hours: number): string {
  const h = Math.floor(hours)
  const m = Math.round((hours - h) * 60)
  return `${h}時間${m}分`
}

export function formatTime(dateString: string): string {
  return new Date(dateString).toLocaleTimeString('ja-JP', {
    hour: '2-digit',
    minute: '2-digit'
  })
}
