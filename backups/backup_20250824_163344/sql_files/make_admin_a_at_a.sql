-- a@a.com ユーザーを管理者権限に変更
-- Supabase Studio SQL Editor で実行してください

UPDATE auth.users 
SET role = 'admin', updated_at = NOW()
WHERE id = '287bf62a-51d6-4387-a7ff-ce00fee08e30'
   OR email = 'a@a.com';

-- 変更確認
SELECT 
    email,
    role,
    id,
    updated_at
FROM auth.users 
WHERE id = '287bf62a-51d6-4387-a7ff-ce00fee08e30'
   OR email = 'a@a.com';
