-- Check if admin@test.com exists in auth.users
SELECT id, email, email_confirmed_at, created_at 
FROM auth.users 
WHERE email = 'admin@test.com';

-- Check all auth users
SELECT id, email, email_confirmed_at, created_at 
FROM auth.users 
ORDER BY created_at DESC;

-- Check organization members
SELECT user_id, organization_id, role 
FROM organization_members;

-- Check project members  
SELECT user_id, project_id, role 
FROM project_memberships;
