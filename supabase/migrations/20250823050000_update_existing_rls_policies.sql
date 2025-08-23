-- Update existing RLS policies to support 8-role permission system

-- 1. Drop all existing role-based policies
DROP POLICY IF EXISTS "profiles_admin_all" ON public.profiles;
DROP POLICY IF EXISTS "profiles_user_own" ON public.profiles;
DROP POLICY IF EXISTS "orgs_admin_all" ON public.organizations;
DROP POLICY IF EXISTS "orgs_members_view" ON public.organizations;
DROP POLICY IF EXISTS "projects_admin_pm_all" ON public.projects;
DROP POLICY IF EXISTS "projects_members_view" ON public.projects;

-- 2. Create new permission-based policies using role_permissions system

-- Profiles: Users can manage their own, admins can manage all
CREATE POLICY "profiles_own_manage" ON public.profiles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "profiles_admin_manage" ON public.profiles
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM auth.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

-- Organizations: Permission-based access
CREATE POLICY "organizations_create" ON public.organizations
  FOR INSERT WITH CHECK (
    public.has_permission(auth.uid(), 'organizations_create')
  );

CREATE POLICY "organizations_read" ON public.organizations
  FOR SELECT USING (
    public.has_permission(auth.uid(), 'organizations_read') OR
    EXISTS (
      SELECT 1 FROM organization_memberships om 
      WHERE om.org_id = id AND om.user_id = auth.uid()
    )
  );

CREATE POLICY "organizations_update" ON public.organizations
  FOR UPDATE USING (
    public.has_permission(auth.uid(), 'organizations_update')
  );

CREATE POLICY "organizations_delete" ON public.organizations
  FOR DELETE USING (
    public.has_permission(auth.uid(), 'organizations_delete')
  );

-- Projects: Permission-based access
CREATE POLICY "projects_create" ON public.projects
  FOR INSERT WITH CHECK (
    public.has_permission(auth.uid(), 'projects_create')
  );

CREATE POLICY "projects_read" ON public.projects
  FOR SELECT USING (
    public.has_permission(auth.uid(), 'projects_read') OR
    EXISTS (
      SELECT 1 FROM project_memberships pm 
      WHERE pm.project_id = id AND pm.user_id = auth.uid()
    )
  );

CREATE POLICY "projects_update" ON public.projects
  FOR UPDATE USING (
    public.has_permission(auth.uid(), 'projects_update') OR
    (created_by = auth.uid())
  );

CREATE POLICY "projects_delete" ON public.projects
  FOR DELETE USING (
    public.has_permission(auth.uid(), 'projects_delete')
  );

-- Tasks: Permission-based access
CREATE POLICY "tasks_create" ON public.tasks
  FOR INSERT WITH CHECK (
    public.has_permission(auth.uid(), 'tasks_create')
  );

CREATE POLICY "tasks_read" ON public.tasks
  FOR SELECT USING (
    public.has_permission(auth.uid(), 'tasks_read') OR
    EXISTS (
      SELECT 1 FROM project_memberships pm 
      WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid()
    )
  );

CREATE POLICY "tasks_update" ON public.tasks
  FOR UPDATE USING (
    public.has_permission(auth.uid(), 'tasks_update') OR
    (created_by = auth.uid())
  );

CREATE POLICY "tasks_delete" ON public.tasks
  FOR DELETE USING (
    public.has_permission(auth.uid(), 'tasks_delete')
  );

-- Events: Permission-based access
CREATE POLICY "events_create" ON public.events
  FOR INSERT WITH CHECK (
    public.has_permission(auth.uid(), 'events_create')
  );

CREATE POLICY "events_read" ON public.events
  FOR SELECT USING (
    public.has_permission(auth.uid(), 'events_read') OR
    owner_user_id = auth.uid()
  );

CREATE POLICY "events_update" ON public.events
  FOR UPDATE USING (
    public.has_permission(auth.uid(), 'events_update') OR
    owner_user_id = auth.uid()
  );

CREATE POLICY "events_delete" ON public.events
  FOR DELETE USING (
    public.has_permission(auth.uid(), 'events_delete') OR
    owner_user_id = auth.uid()
  );
