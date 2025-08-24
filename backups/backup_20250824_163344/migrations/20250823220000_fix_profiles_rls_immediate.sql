-- Fix profiles RLS policies to resolve 403 Forbidden errors
-- Drop all existing policies on profiles table
DROP POLICY IF EXISTS "profiles_admin_all" ON profiles;
DROP POLICY IF EXISTS "profiles_user_own" ON profiles;
DROP POLICY IF EXISTS "profiles_admin_manage" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "admin_full_access" ON profiles;
DROP POLICY IF EXISTS "users_own_profile" ON profiles;

-- Ensure RLS is enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create working policies for profiles access
-- Allow all authenticated users to read profiles (needed for project members, mentions, etc.)
CREATE POLICY "profiles_select_authenticated" ON profiles 
FOR SELECT 
TO authenticated 
USING (true);

-- Users can insert their own profile
CREATE POLICY "profiles_insert_own" ON profiles 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- Users can update their own profile
CREATE POLICY "profiles_update_own" ON profiles 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id);

-- Admins can do everything via JWT role check
CREATE POLICY "profiles_admin_all" ON profiles 
FOR ALL 
TO authenticated 
USING (
  COALESCE(
    (auth.jwt() ->> 'app_metadata')::json ->> 'role',
    'viewer'
  ) = 'admin'
);
