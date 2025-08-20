import { supabase } from '../supabaseClient'

// Development helper to create a test user and log them in
export const createTestUser = async (email: string = 'test@example.com') => {
  try {
    // Sign up the test user
    const { data, error } = await supabase.auth.signUp({
      email,
      password: 'testpass123',
      options: {
        emailRedirectTo: undefined // Skip email confirmation in dev
      }
    })

    if (error) {
      console.error('Signup error:', error)
      return { success: false, error: error.message }
    }

    if (data.user) {
      // Skip profile creation for now to test authentication
      console.log('Test user created successfully, skipping profile creation')

      return { success: true, user: data.user }
    }

    return { success: false, error: 'No user created' }
  } catch (err: any) {
    console.error('Test user creation failed:', err)
    return { success: false, error: err.message }
  }
}

// Quick login for development
export const quickTestLogin = async () => {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: 'test@example.com',
      password: 'testpass123'
    })

    if (error) {
      // If user doesn't exist, create them
      if (error.message.includes('Invalid login credentials')) {
        return await createTestUser('test@example.com')
      }
      return { success: false, error: error.message }
    }

    return { success: true, user: data.user }
  } catch (err: any) {
    return { success: false, error: err.message }
  }
}

// Create user with specified role
export const createUserWithRole = async (email: string, password: string, role: string = 'admin') => {
  try {
    // シンプルにユーザー作成
    const { data, error } = await supabase.auth.signUp({
      email,
      password
    })

    if (error) {
      console.error('User signup error:', error)
      return { success: false, error: error.message }
    }

    if (data.user) {
      // プロファイルを直接作成（トリガーが失敗する場合のフォールバック）
      const { error: profileError } = await supabase
        .from('profiles')
        .upsert({
          user_id: data.user.id,
          display_name: email.split('@')[0],
          company: 'Test Company',
          role: role
        })

      if (profileError) {
        console.log('Profile creation handled by trigger or already exists')
      }

      console.log(`${role} user created successfully:`, data.user.id)
      return { success: true, user: data.user, role }
    }

    return { success: false, error: 'No user created' }
  } catch (err: any) {
    console.error('User creation failed:', err)
    return { success: false, error: err.message }
  }
}

// Create admin user using proper Supabase Auth API
export const createAdminUser = async () => {
  return await createUserWithRole('admin@test.com', 'password123', 'admin')
}
