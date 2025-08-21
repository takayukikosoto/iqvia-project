-- Debug admin user authentication
SELECT 
    id,
    email,
    role,
    encrypted_password IS NOT NULL as has_password,
    email_confirmed_at IS NOT NULL as email_confirmed,
    created_at,
    raw_user_meta_data
FROM auth.users 
WHERE email = 'admin@test.com';

-- Check if admin user exists at all
SELECT COUNT(*) as admin_count FROM auth.users WHERE email = 'admin@test.com';
