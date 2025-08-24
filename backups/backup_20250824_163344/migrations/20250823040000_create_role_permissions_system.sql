-- 8-Role Permission System for Event Management
-- 管理権限, 主催者権限, スポンサー権限, 代理店権限, 制作会社権限, 事務局権限, スタッフ権限, ビュワー権限

-- 1. Role definitions table
CREATE TABLE IF NOT EXISTS public.role_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name VARCHAR(50) NOT NULL UNIQUE,
  role_level INTEGER NOT NULL UNIQUE,
  display_name VARCHAR(100) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Permission definitions table
CREATE TABLE IF NOT EXISTS public.permission_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  permission_name VARCHAR(50) NOT NULL UNIQUE,
  resource VARCHAR(50) NOT NULL, -- 'organizations', 'projects', 'tasks', etc.
  action VARCHAR(20) NOT NULL,   -- 'create', 'read', 'update', 'delete'
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Role-Permission mapping table
CREATE TABLE IF NOT EXISTS public.role_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name VARCHAR(50) NOT NULL REFERENCES public.role_definitions(role_name),
  permission_name VARCHAR(50) NOT NULL REFERENCES public.permission_definitions(permission_name),
  is_granted BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(role_name, permission_name)
);

-- 4. Insert role definitions (level 8 = highest)
INSERT INTO public.role_definitions (role_name, role_level, display_name, description) VALUES
  ('admin', 8, '管理権限', 'システム全体管理、全権限'),
  ('organizer', 7, '主催者権限', 'イベント企画・承認、予算管理'),
  ('sponsor', 6, 'スポンサー権限', 'スポンサー関連情報管理'),
  ('agency', 5, '代理店権限', '営業・顧客管理、契約関連'),
  ('production', 4, '制作会社権限', 'コンテンツ制作、デザイン管理'),
  ('secretariat', 3, '事務局権限', '運営業務、参加者管理'),
  ('staff', 2, 'スタッフ権限', '当日運営、限定的操作'),
  ('viewer', 1, 'ビュワー権限', '閲覧のみ')
ON CONFLICT (role_name) DO NOTHING;

-- 5. Insert permission definitions
INSERT INTO public.permission_definitions (permission_name, resource, action, description) VALUES
  ('organizations_create', 'organizations', 'create', '組織作成'),
  ('organizations_read', 'organizations', 'read', '組織閲覧'),
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

-- 6. Insert role-permission mappings
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
  ('sponsor', 'projects_read'),
  ('sponsor', 'events_read'),
  ('sponsor', 'tasks_read')
ON CONFLICT DO NOTHING;

-- Agency (level 5) - Sales, customer management
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('agency', 'projects_read'), ('agency', 'projects_update'),
  ('agency', 'events_read'),
  ('agency', 'tasks_create'), ('agency', 'tasks_read'), ('agency', 'tasks_update'),
  ('agency', 'contracts_manage'),
  ('agency', 'participants_manage')
ON CONFLICT DO NOTHING;

-- Production (level 4) - Content creation
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('production', 'projects_read'),
  ('production', 'events_read'),
  ('production', 'tasks_create'), ('production', 'tasks_read'), ('production', 'tasks_update'),
  ('production', 'content_create')
ON CONFLICT DO NOTHING;

-- Secretariat (level 3) - Operations, participant management
INSERT INTO public.role_permissions (role_name, permission_name) VALUES
  ('secretariat', 'projects_read'),
  ('secretariat', 'events_read'), ('secretariat', 'events_update'),
  ('secretariat', 'tasks_create'), ('secretariat', 'tasks_read'), ('secretariat', 'tasks_update'),
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

-- 7. Helper functions
CREATE OR REPLACE FUNCTION public.get_user_role_level(user_id UUID DEFAULT auth.uid())
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT rd.role_level 
    FROM auth.users u
    JOIN public.role_definitions rd ON u.role = rd.role_name
    WHERE u.id = user_id
    LIMIT 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.has_permission(user_id UUID, permission VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM auth.users u
    JOIN public.role_permissions rp ON u.role = rp.role_name
    WHERE u.id = user_id 
    AND rp.permission_name = permission 
    AND rp.is_granted = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Enable RLS
ALTER TABLE public.role_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permission_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

-- Everyone can read role definitions (for UI dropdowns)
CREATE POLICY "role_definitions_read_all" ON public.role_definitions FOR SELECT USING (true);
CREATE POLICY "permission_definitions_read_all" ON public.permission_definitions FOR SELECT USING (true);
CREATE POLICY "role_permissions_read_all" ON public.role_permissions FOR SELECT USING (true);
