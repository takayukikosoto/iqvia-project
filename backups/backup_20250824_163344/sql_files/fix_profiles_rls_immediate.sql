-- Fix profiles RLS policies immediately
-- Check current policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'profiles';

-- Drop all existing policies on profiles
DROP POLICY IF EXISTS "profiles_admin_all" ON profiles;
DROP POLICY IF EXISTS "profiles_user_own" ON profiles;
DROP POLICY IF EXISTS "profiles_admin_manage" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "admin_full_access" ON profiles;
DROP POLICY IF EXISTS "users_own_profile" ON profiles;

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create simple working policies
CREATE POLICY "profiles_select_all" ON profiles 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "profiles_insert_own" ON profiles 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profiles_update_own" ON profiles 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id);

-- Admin can do everything via JWT role
CREATE POLICY "profiles_admin_all" ON profiles 
FOR ALL 
TO authenticated 
USING (
  COALESCE(
    (auth.jwt() ->> 'app_metadata')::json ->> 'role',
    'viewer'
  ) = 'admin'
);

-- Check the policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'profiles';
