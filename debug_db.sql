-- チャットメッセージのデータを確認
SELECT id, user_id, project_id, content, created_at FROM chat_messages ORDER BY created_at DESC LIMIT 10;

-- プロファイルテーブルの確認
SELECT user_id, display_name FROM profiles;

-- 認証ユーザーの確認  
SELECT id, email FROM auth.users;

-- プロジェクトメンバーの確認
SELECT user_id, project_id FROM project_members;
