-- Check if admin@kst.com exists in auth.users
SELECT id, email, raw_user_meta_data, email_confirmed_at, created_at 
FROM auth.users 
WHERE email = 'admin@kst.com';

-- Check all auth users
SELECT id, email, raw_user_meta_data, email_confirmed_at, created_at 
FROM auth.users 
ORDER BY created_at DESC;

-- Check profiles table
SELECT user_id, display_name, role, company, created_at 
FROM profiles 
ORDER BY created_at DESC;

-- Check organization members
SELECT user_id, organization_id, role 
FROM organization_members;

-- Check project members  
SELECT user_id, project_id, role 
FROM project_memberships;
