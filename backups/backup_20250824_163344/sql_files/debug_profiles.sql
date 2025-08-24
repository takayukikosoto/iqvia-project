-- Debug profiles table and fix 403 errors

-- Check if profiles table exists
SELECT 
    table_name, 
    table_schema 
FROM information_schema.tables 
WHERE table_name = 'profiles';

-- Check table structure
\d profiles

-- Check current RLS policies
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

-- Check if RLS is enabled
SELECT 
    schemaname, 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE tablename = 'profiles';

-- If table doesn't exist, create it
CREATE TABLE IF NOT EXISTS profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    company TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Disable RLS temporarily
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "profiles_select_all" ON profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON profiles;
DROP POLICY IF EXISTS "profiles_delete_own" ON profiles;

-- Create simple policies that work
CREATE POLICY "profiles_select_all" ON profiles 
FOR SELECT TO authenticated USING (true);

CREATE POLICY "profiles_insert_own" ON profiles 
FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profiles_update_own" ON profiles 
FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Verify final state
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    roles, 
    cmd 
FROM pg_policies 
WHERE tablename = 'profiles' 
ORDER BY policyname;
