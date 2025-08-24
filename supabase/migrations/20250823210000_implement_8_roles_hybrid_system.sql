-- Implement 8-role system following the same hybrid pattern as admin.admins
-- This matches the existing admin schema structure

-- Step 1: Clean up existing complex permission system
DROP FUNCTION IF EXISTS public.has_permission(uuid, text);
DROP FUNCTION IF EXISTS public.get_user_role(uuid);
DROP FUNCTION IF EXISTS public.get_current_user_with_role();
DROP FUNCTION IF EXISTS public.get_all_users_with_roles();
DROP FUNCTION IF EXISTS public.update_user_role(uuid, text);
DROP TABLE IF EXISTS public.role_permissions;
DROP TABLE IF EXISTS public.permission_definitions;
DROP TABLE IF EXISTS public.role_definitions;

-- Drop complex permission policies
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

-- Step 2: Create roles schema and user_roles table
CREATE SCHEMA IF NOT EXISTS roles;

CREATE TABLE IF NOT EXISTS roles.user_roles(
  user_id uuid PRIMARY KEY REFERENCES auth.users(id),
  role_name text NOT NULL CHECK (role_name IN ('admin', 'organizer', 'sponsor', 'agency', 'production', 'secretariat', 'staff', 'viewer')),
  granted_by uuid REFERENCES auth.users(id),
  granted_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON roles.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_name ON roles.user_roles(role_name);

-- Enable RLS on roles.user_roles
ALTER TABLE roles.user_roles ENABLE ROW LEVEL SECURITY;

-- Only authenticated users can read role status (for RLS policies)
CREATE POLICY "authenticated_read_roles" ON roles.user_roles
  FOR SELECT USING (auth.role() = 'authenticated');

-- Step 3: Create function to sync role to app_metadata
CREATE OR REPLACE FUNCTION roles.sync_role_metadata()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_record record;
BEGIN
  -- Update all users with their current role
  FOR user_record IN 
    SELECT u.id, COALESCE(ur.role_name, 'viewer') as user_role
    FROM auth.users u
    LEFT JOIN roles.user_roles ur ON u.id = ur.user_id
  LOOP
    UPDATE auth.users 
    SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', user_record.user_role)
    WHERE id = user_record.id;
  END LOOP;
END;
$$;

-- Step 4: Create function to assign role
CREATE OR REPLACE FUNCTION roles.assign_role(target_user_id uuid, new_role text, granter_user_id uuid DEFAULT auth.uid())
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if granter is admin (bootstrap case allows if no roles exist)
  IF NOT EXISTS (SELECT 1 FROM admin.admins WHERE user_id = granter_user_id AND (expires_at IS NULL OR expires_at > now())) THEN
    IF EXISTS (SELECT 1 FROM roles.user_roles) THEN
      RAISE EXCEPTION 'Only admins can assign roles';
    END IF;
  END IF;
  
  -- Validate role
  IF new_role NOT IN ('admin', 'organizer', 'sponsor', 'agency', 'production', 'secretariat', 'staff', 'viewer') THEN
    RAISE EXCEPTION 'Invalid role: %', new_role;
  END IF;
  
  -- Insert or update role record
  INSERT INTO roles.user_roles (user_id, role_name, granted_by)
  VALUES (target_user_id, new_role, granter_user_id)
  ON CONFLICT (user_id) DO UPDATE SET
    role_name = excluded.role_name,
    granted_by = excluded.granted_by,
    updated_at = now();
    
  -- Sync metadata
  PERFORM roles.sync_role_metadata();
END;
$$;

-- Step 5: Update RLS policies to use JWT app_metadata (same pattern as admin)
-- Simple role-based policies using JWT app_metadata
CREATE POLICY "organizations_role_based" ON public.organizations
  FOR ALL USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'sponsor') OR
    EXISTS (SELECT 1 FROM organization_memberships om WHERE om.org_id = id AND om.user_id = auth.uid())
  );

CREATE POLICY "projects_role_based" ON public.projects
  FOR ALL USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'agency', 'production') OR
    created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM project_memberships pm WHERE pm.project_id = id AND pm.user_id = auth.uid())
  );

CREATE POLICY "tasks_role_based" ON public.tasks
  FOR ALL USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'agency', 'production', 'secretariat', 'staff') OR
    created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM project_memberships pm WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid())
  );

CREATE POLICY "events_role_based" ON public.events
  FOR ALL USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'secretariat') OR
    owner_user_id = auth.uid()
  );

-- Step 6: Grant necessary permissions
GRANT USAGE ON SCHEMA roles TO authenticated;
GRANT SELECT ON roles.user_roles TO authenticated;
GRANT EXECUTE ON FUNCTION roles.assign_role(uuid, text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION roles.sync_role_metadata() TO authenticated;
