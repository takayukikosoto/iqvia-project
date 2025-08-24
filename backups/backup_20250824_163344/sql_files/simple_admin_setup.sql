-- ユーザー作成後に実行するシンプルなSQL
-- 作成したユーザーのIDを確認
SELECT id, email, role FROM auth.users WHERE email = 'your-email@example.com';

-- admin権限に変更（上記で取得したIDを使用）
UPDATE auth.users SET role = 'admin' WHERE id = 'USER_ID_HERE';
