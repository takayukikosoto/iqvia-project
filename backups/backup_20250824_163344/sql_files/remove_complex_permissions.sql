-- 複雑な権限システムを削除してSupabase Authをシンプルに戻す

-- 1. 複雑なRLSポリシーを削除
DROP POLICY IF EXISTS "organizations_create" ON public.organizations;
DROP POLICY IF EXISTS "organizations_read" ON public.organizations;
DROP POLICY IF EXISTS "organizations_update" ON public.organizations;
DROP POLICY IF EXISTS "organizations_delete" ON public.organizations;
DROP POLICY IF EXISTS "projects_create" ON public.projects;
DROP POLICY IF EXISTS "projects_read" ON public.projects;
DROP POLICY IF EXISTS "projects_update" ON public.projects;
DROP POLICY IF EXISTS "projects_delete" ON public.projects;
DROP POLICY IF EXISTS "tasks_create" ON public.tasks;
DROP POLICY IF EXISTS "tasks_read" ON public.tasks;
DROP POLICY IF EXISTS "tasks_update" ON public.tasks;
DROP POLICY IF EXISTS "tasks_delete" ON public.tasks;
DROP POLICY IF EXISTS "events_create" ON public.events;
DROP POLICY IF EXISTS "events_read" ON public.events;
DROP POLICY IF EXISTS "events_update" ON public.events;
DROP POLICY IF EXISTS "events_delete" ON public.events;
DROP POLICY IF EXISTS "profiles_admin_manage" ON public.profiles;

-- 2. 複雑な権限関数を削除
DROP FUNCTION IF EXISTS public.has_permission(uuid, text);
DROP FUNCTION IF EXISTS public.get_user_role(uuid);

-- 3. 複雑な権限テーブルを削除
DROP TABLE IF EXISTS public.role_permissions;
DROP TABLE IF EXISTS public.permission_definitions;
DROP TABLE IF EXISTS public.role_definitions;

-- 4. 複雑なRPC関数を削除
DROP FUNCTION IF EXISTS public.get_current_user_with_role();
DROP FUNCTION IF EXISTS public.get_all_users_with_roles();
DROP FUNCTION IF EXISTS public.update_user_role(uuid, text);

-- 5. シンプルなRLSポリシーを再設定（auth.users.roleのみ使用）
CREATE POLICY "profiles_own_manage" ON public.profiles
  FOR ALL USING (auth.uid() = user_id);

-- 管理者は全てアクセス可能（シンプル）
CREATE POLICY "admin_all_access" ON public.profiles
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM auth.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

CREATE POLICY "organizations_simple" ON public.organizations
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM auth.users u
      WHERE u.id = auth.uid() AND u.role IN ('admin', 'organizer', 'sponsor')
    )
  );

CREATE POLICY "projects_simple" ON public.projects
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM auth.users u
      WHERE u.id = auth.uid() AND u.role IN ('admin', 'organizer', 'agency', 'production')
    ) OR created_by = auth.uid()
  );

CREATE POLICY "tasks_simple" ON public.tasks
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM auth.users u
      WHERE u.id = auth.uid() AND u.role IN ('admin', 'organizer', 'agency', 'production', 'secretariat', 'staff')
    ) OR created_by = auth.uid()
  );

CREATE POLICY "events_simple" ON public.events
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM auth.users u
      WHERE u.id = auth.uid() AND u.role IN ('admin', 'organizer', 'secretariat')
    ) OR owner_user_id = auth.uid()
  );
