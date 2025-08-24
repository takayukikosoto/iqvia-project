-- テスト用管理者ユーザー作成
-- ブラウザでSupabase認証を使って実際にユーザー作成後、この権限を付与する

-- 既存ユーザーを管理者に昇格
UPDATE auth.users 
SET role = 'admin' 
WHERE email IN ('admin@test.com', 'test@example.com')
   OR id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

-- 現在のユーザー一覧確認
SELECT 
    email, 
    role, 
    created_at,
    email_confirmed_at
FROM auth.users 
ORDER BY created_at DESC;

-- ロール統計確認
SELECT 
    rd.role_name,
    rd.display_name,
    COUNT(u.id) as user_count
FROM role_definitions rd
LEFT JOIN auth.users u ON rd.role_name = u.role
WHERE rd.is_active = true
GROUP BY rd.role_name, rd.display_name, rd.role_level
ORDER BY rd.role_level DESC;
