-- Quick check of auth.users after reset
SELECT 
    email, 
    raw_user_meta_data->>'role' as role_from_metadata,
    raw_user_meta_data,
    created_at
FROM auth.users 
ORDER BY created_at DESC;

-- Check profiles
SELECT 
    user_id,
    display_name,
    role,
    company 
FROM profiles 
ORDER BY created_at DESC;
