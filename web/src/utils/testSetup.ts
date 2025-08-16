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
      // Create profile
      await supabase.from('profiles').insert([{
        user_id: data.user.id,
        display_name: 'Test User',
        company: 'Test Co.'
      }])

      // Add to sample org and project
      await supabase.from('organization_memberships').insert([{
        org_id: '11111111-1111-1111-1111-111111111111',
        user_id: data.user.id,
        role: 'contributor'
      }])

      await supabase.from('project_memberships').insert([{
        project_id: '22222222-2222-2222-2222-222222222222',
        user_id: data.user.id,
        role: 'contributor'
      }])

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
