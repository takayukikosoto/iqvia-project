-- kosoto@t-kst.com を管理者に設定する

-- 方法1: 直接admin.adminsテーブルに挿入（bootstrapとして実行）
INSERT INTO admin.admins (user_id, granted_by, granted_at)
VALUES ('0a403252-cfaf-4ac1-94ca-1c5ae0b5449f', NULL, NOW())
ON CONFLICT (user_id) DO UPDATE SET
  granted_at = NOW(),
  expires_at = NULL;

-- メタデータ同期を実行
SELECT admin.sync_admin_metadata();

-- 方法2: 既存の管理者としてRPC関数を使用
-- （既に管理者権限を持つユーザーでログインしている場合のみ有効）
/*
SELECT admin.grant_admin_privileges('0a403252-cfaf-4ac1-94ca-1c5ae0b5449f');
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
WHERE u.id = '0a403252-cfaf-4ac1-94ca-1c5ae0b5449f';
