-- Fix profiles table 403 Forbidden errors
-- This script will completely reset and fix the profiles RLS policies

-- Drop all existing policies
DROP POLICY IF EXISTS "profiles_select_authenticated" ON profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON profiles;
DROP POLICY IF EXISTS "profiles_admin_all" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "admin_full_access" ON profiles;
DROP POLICY IF EXISTS "users_own_profile" ON profiles;

-- Disable RLS temporarily
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create simple, working policies
-- Allow all authenticated users to read all profiles
CREATE POLICY "profiles_select_all" ON profiles 
FOR SELECT 
TO authenticated 
USING (true);

-- Allow users to insert their own profile
CREATE POLICY "profiles_insert_own" ON profiles 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own profile
CREATE POLICY "profiles_update_own" ON profiles 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own profile (optional)
CREATE POLICY "profiles_delete_own" ON profiles 
FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- Verify policies were created
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual 
FROM pg_policies 
WHERE tablename = 'profiles';
