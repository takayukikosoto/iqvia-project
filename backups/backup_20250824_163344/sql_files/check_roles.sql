-- Current auth.users roles check
SELECT 
    id, 
    email, 
    role as auth_role,
    raw_user_meta_data,
    raw_app_meta_data,
    email_confirmed_at,
    created_at 
FROM auth.users 
ORDER BY created_at DESC;
