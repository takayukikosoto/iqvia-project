-- kosoto@t-kst.com を管理者に昇格させるSQLスニペット
-- Supabase Studio のSQL Editorで実行してください

-- Step 1: admin.adminsテーブルに追加（ハイブリッドシステムのソース・オブ・トゥルース）
INSERT INTO admin.admins (user_id, granted_by, granted_at)
VALUES (
  'fe2fbe7e-a6d4-4a4c-b5a8-b69d21f1ccb0',  -- kosoto@t-kst.com のユーザーID
  'fe2fbe7e-a6d4-4a4c-b5a8-b69d21f1ccb0',  -- 自己承認（ブートストラップ）
  now()
)
ON CONFLICT (user_id) DO UPDATE SET
  granted_by = excluded.granted_by,
  granted_at = now(),
  expires_at = null;

-- Step 2: app_metadataにis_admin = trueを設定（高速判定用）
UPDATE auth.users 
SET raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"is_admin": true}'::jsonb
WHERE id = 'fe2fbe7e-a6d4-4a4c-b5a8-b69d21f1ccb0';

-- Step 3: 確認クエリ - 管理者権限が付与されたかチェック
SELECT 
  u.email,
  u.raw_app_meta_data ->> 'is_admin' as is_admin_metadata,
  a.user_id IS NOT NULL as in_admin_table,
  a.granted_at
FROM auth.users u
LEFT JOIN admin.admins a ON u.id = a.user_id
WHERE u.id = 'fe2fbe7e-a6d4-4a4c-b5a8-b69d21f1ccb0';

-- 実行後、kosoto@t-kst.com でログインして管理者機能が使えることを確認してください
