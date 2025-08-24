-- b@b.com を管理者に設定する
-- User UID: 71e8083b-d4a0-4ac6-9282-2b75cfb701bc

-- 方法1: 直接admin.adminsテーブルに挿入（bootstrapとして実行）
INSERT INTO admin.admins (user_id, granted_by, granted_at)
VALUES ('71e8083b-d4a0-4ac6-9282-2b75cfb701bc', NULL, NOW())
ON CONFLICT (user_id) DO UPDATE SET
  granted_at = NOW(),
  expires_at = NULL;

-- メタデータ同期を実行
SELECT admin.sync_admin_metadata();

-- 方法2: 既存の管理者としてRPC関数を使用
-- （既に管理者権限を持つユーザーでログインしている場合のみ有効）
/*
SELECT admin.grant_admin_privileges('71e8083b-d4a0-4ac6-9282-2b75cfb701bc');
*/

-- 確認クエリ: 管理者権限が付与されたかチェック
SELECT 
  u.email,
  u.raw_app_meta_data->>'is_admin' as is_admin_metadata,
  EXISTS(
    SELECT 1 FROM admin.admins a 
    WHERE a.user_id = u.id 
    AND (a.expires_at IS NULL OR a.expires_at > NOW())
  ) as is_admin_table
FROM auth.users u 
WHERE u.id = '71e8083b-d4a0-4ac6-9282-2b75cfb701bc';
