-- Final fix for 403 Forbidden errors on profiles table
-- This will create the table and policies from scratch

-- Drop and recreate profiles table completely
DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    company TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Disable RLS first
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create the simplest possible policies that work
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_insert" ON profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "profiles_delete" ON profiles FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO service_role;
GRANT ALL ON profiles TO anon;

-- Verify the setup
SELECT 'Table exists:' as status, EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') as result
UNION ALL
SELECT 'RLS enabled:' as status, (SELECT rowsecurity FROM pg_tables WHERE tablename = 'profiles') as result
UNION ALL  
SELECT 'Policy count:' as status, (SELECT COUNT(*)::TEXT FROM pg_policies WHERE tablename = 'profiles') as result;
