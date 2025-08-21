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

// Create user with admin privileges using hybrid system
export const createUserWithRole = async (email: string, password: string, role: string = 'admin') => {
  try {
    // ユーザー作成
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          display_name: email.split('@')[0],
          company: 'Test Company'
        }
      }
    })

    if (error) {
      console.error('User signup error:', error)
      return { success: false, error: error.message }
    }

    if (data.user && role === 'admin') {
      // ハイブリッドシステム：admin権限の場合はadmin.adminsテーブルに登録
      const { error: adminError } = await supabase.rpc('grant_admin_privileges', {
        target_user_id: data.user.id
      })

      if (adminError) {
        console.error('Admin privileges error:', adminError)
        return { success: false, error: adminError.message }
      }

      console.log(`${role} user created successfully:`, data.user.id)
      return { success: true, user: data.user, role }
    }

    if (data.user) {
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
