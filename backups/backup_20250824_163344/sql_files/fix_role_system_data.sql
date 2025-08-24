-- 8ロールシステムのデータを手動で挿入
-- role_definitionsテーブルが空のため、データを手動挿入

-- 5. Insert role definitions
INSERT INTO public.role_definitions (role_name, display_name, description, role_level, is_active) VALUES
  ('admin', '管理者', '全システム管理権限', 8, true),
  ('organizer', '主催者', 'イベント主催権限', 7, true),
  ('sponsor', 'スポンサー', 'スポンサー関連権限', 6, true),
  ('agency', '代理店', '代理店業務権限', 5, true),
  ('production', '制作会社', '制作関連権限', 4, true),
  ('secretariat', '事務局', '事務局業務権限', 3, true),
  ('staff', 'スタッフ', '一般スタッフ権限', 2, true),
  ('viewer', 'ビュワー', '閲覧のみ権限', 1, true)
ON CONFLICT (role_name) DO NOTHING;

-- Insert permission definitions
INSERT INTO public.permission_definitions (permission_name, resource_type, action_type, display_name) VALUES
  ('organizations_read', 'organizations', 'read', '組織閲覧'),
  ('organizations_create', 'organizations', 'create', '組織作成'),
  ('organizations_update', 'organizations', 'update', '組織更新'),
  ('organizations_delete', 'organizations', 'delete', '組織削除'),
  ('projects_create', 'projects', 'create', 'プロジェクト作成'),
  ('projects_read', 'projects', 'read', 'プロジェクト閲覧'),
  ('projects_update', 'projects', 'update', 'プロジェクト更新'),
  ('projects_delete', 'projects', 'delete', 'プロジェクト削除'),
  ('tasks_create', 'tasks', 'create', 'タスク作成'),
  ('tasks_read', 'tasks', 'read', 'タスク閲覧'),
  ('tasks_update', 'tasks', 'update', 'タスク更新'),
  ('tasks_delete', 'tasks', 'delete', 'タスク削除'),
  ('events_create', 'events', 'create', 'イベント作成'),
  ('events_read', 'events', 'read', 'イベント閲覧'),
  ('events_update', 'events', 'update', 'イベント更新'),
  ('events_delete', 'events', 'delete', 'イベント削除'),
  ('users_manage', 'users', 'manage', 'ユーザー管理'),
  ('budget_manage', 'budget', 'manage', '予算管理'),
  ('contracts_manage', 'contracts', 'manage', '契約管理'),
  ('content_create', 'content', 'create', 'コンテンツ作成'),
  ('participants_manage', 'participants', 'manage', '参加者管理')
ON CONFLICT (permission_name) DO NOTHING;

-- Insert role-permission mappings
-- Admin (level 8) - All permissions
INSERT INTO public.role_permissions (role_name, permission_name) 
SELECT 'admin', permission_name FROM public.permission_definitions
ON CONFLICT DO NOTHING;

-- Organizer (level 7) - Event management, budget, high-level permissions
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('organizer', 'organizations_read'),
  ('organizer', 'projects_create'), ('organizer', 'projects_read'), ('organizer', 'projects_update'), ('organizer', 'projects_delete'),
  ('organizer', 'tasks_create'), ('organizer', 'tasks_read'), ('organizer', 'tasks_update'), ('organizer', 'tasks_delete'),
  ('organizer', 'events_create'), ('organizer', 'events_read'), ('organizer', 'events_update'), ('organizer', 'events_delete'),
  ('organizer', 'budget_manage'),
  ('organizer', 'participants_manage')
ON CONFLICT DO NOTHING;

-- Sponsor (level 6) - Sponsor-related permissions
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('sponsor', 'organizations_read'),
  ('sponsor', 'projects_read'),
  ('sponsor', 'events_read'),
  ('sponsor', 'tasks_read'),
  ('sponsor', 'budget_manage'),
  ('sponsor', 'contracts_manage')
ON CONFLICT DO NOTHING;

-- Agency (level 5) - Agency operations
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('agency', 'organizations_read'),
  ('agency', 'projects_create'), ('agency', 'projects_read'), ('agency', 'projects_update'),
  ('agency', 'tasks_create'), ('agency', 'tasks_read'), ('agency', 'tasks_update'),
  ('agency', 'events_read'), ('agency', 'events_update'),
  ('agency', 'content_create')
ON CONFLICT DO NOTHING;

-- Production (level 4) - Content creation and project work
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('production', 'projects_read'),
  ('production', 'tasks_create'), ('production', 'tasks_read'), ('production', 'tasks_update'),
  ('production', 'events_read'),
  ('production', 'content_create')
ON CONFLICT DO NOTHING;

-- Secretariat (level 3) - Administrative support
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('secretariat', 'projects_read'),
  ('secretariat', 'tasks_read'), ('secretariat', 'tasks_update'),
  ('secretariat', 'events_read'), ('secretariat', 'events_update'),
  ('secretariat', 'participants_manage')
ON CONFLICT DO NOTHING;

-- Staff (level 2) - Limited operations
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('staff', 'projects_read'),
  ('staff', 'events_read'),
  ('staff', 'tasks_read'), ('staff', 'tasks_update')
ON CONFLICT DO NOTHING;

-- Viewer (level 1) - Read only
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('viewer', 'projects_read'),
  ('viewer', 'events_read'),
  ('viewer', 'tasks_read')
ON CONFLICT DO NOTHING;

-- a@a.com ユーザーを管理者権限に変更
UPDATE auth.users 
SET role = 'admin', updated_at = NOW()
WHERE id = '287bf62a-51d6-4387-a7ff-ce00fee08e30'
   OR email = 'a@a.com';

-- 確認クエリ
SELECT 'Role Definitions:' as info;
SELECT role_name, display_name, role_level FROM role_definitions ORDER BY role_level DESC;

SELECT 'Permission Definitions:' as info;
SELECT COUNT(*) as permission_count FROM permission_definitions;

SELECT 'Role Permissions:' as info;
SELECT role_name, COUNT(*) as permission_count FROM role_permissions GROUP BY role_name ORDER BY permission_count DESC;

SELECT 'User Role:' as info;
SELECT email, role, id FROM auth.users WHERE email = 'a@a.com' OR id = '287bf62a-51d6-4387-a7ff-ce00fee08e30';
