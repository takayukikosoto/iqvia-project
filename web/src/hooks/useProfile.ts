import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useAuth } from './useAuth'

export interface Profile {
  user_id: string
  display_name: string
  company: string
  created_at: string
  updated_at: string
}

export function useProfile() {
  const { user } = useAuth()
  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchProfile = async () => {
    if (!user) return

    try {
      setLoading(true)
      setError(null)

      const { data, error: profileError } = await supabase
        .from('profiles')
        .select('user_id, display_name, company, created_at, updated_at')
        .eq('user_id', user.id)
        .single()

      if (profileError) {
        // プロフィールが存在しない場合は初期プロフィールを作成
        if (profileError.code === 'PGRST116') {
          const newProfile = {
            user_id: user.id,
            display_name: user.email?.split('@')[0] || 'ユーザー',
            company: '会社名未設定'
          }

          const { data: createdProfile, error: createError } = await supabase
            .from('profiles')
            .insert(newProfile)
            .select()
            .single()

          if (createError) throw createError
          setProfile(createdProfile)
        } else {
          throw profileError
        }
      } else {
        setProfile(data)
      }
    } catch (err: any) {
      console.error('Error fetching profile:', err)
      setError(err.message || 'プロフィール取得に失敗しました')
    } finally {
      setLoading(false)
    }
  }

  const updateProfile = async (updates: Partial<Pick<Profile, 'display_name' | 'company'>>) => {
    if (!user || !profile) return { success: false, error: 'ユーザーまたはプロフィール情報がありません' }

    try {
      const { data, error } = await supabase
        .from('profiles')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('user_id', user.id)
        .select()
        .single()

      if (error) throw error

      setProfile(data)
      return { success: true }
    } catch (err: any) {
      console.error('Error updating profile:', err)
      return { success: false, error: err.message || 'プロフィール更新に失敗しました' }
    }
  }

  useEffect(() => {
    fetchProfile()
  }, [user])

  return {
    profile,
    loading,
    error,
    updateProfile,
    refetch: fetchProfile
  }
}
