-- Current database admin permissions status check

-- 1. Check all auth users and their basic info
SELECT 
    id, 
    email, 
    role as auth_role,
    raw_user_meta_data,
    email_confirmed_at,
    created_at 
FROM auth.users 
ORDER BY created_at DESC;

-- 2. Check all profiles and their roles
SELECT 
    user_id, 
    display_name, 
    role as profile_role, 
    company, 
    email,
    created_at 
FROM profiles 
ORDER BY created_at DESC;

-- 3. Check if profiles match auth users
SELECT 
    u.id as auth_user_id,
    u.email,
    u.role as auth_role,
    p.role as profile_role,
    p.display_name,
    p.company,
    CASE 
        WHEN p.user_id IS NULL THEN 'NO PROFILE'
        ELSE 'HAS PROFILE'
    END as profile_status
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.user_id
ORDER BY u.created_at DESC;

-- 4. Count users by role
SELECT 
    role as profile_role,
    COUNT(*) as user_count
FROM profiles 
GROUP BY role
ORDER BY user_count DESC;

-- 5. Check RLS policies on profiles table
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- 6. Check if RLS is enabled on profiles table
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'profiles';
