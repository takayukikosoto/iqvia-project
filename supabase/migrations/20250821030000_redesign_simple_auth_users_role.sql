-- Redesign: Use auth.users.role directly for all role management

-- Step 1: Update existing auth.users with proper roles from metadata
UPDATE auth.users 
SET role = CASE 
    WHEN raw_user_meta_data ->> 'role' = 'admin' THEN 'admin'
    WHEN raw_user_meta_data ->> 'role' = 'project_manager' THEN 'project_manager'
    WHEN raw_user_meta_data ->> 'role' = 'org_manager' THEN 'project_manager'
    ELSE 'viewer'
END;

-- Step 2: Ensure admin user has correct role
UPDATE auth.users 
SET role = 'admin' 
WHERE email = 'admin@test.com';

-- Step 3: Drop all complex RLS policies and functions
DROP POLICY IF EXISTS "admin_full_access" ON public.profiles;
DROP POLICY IF EXISTS "users_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_manage_orgs" ON public.organizations;
DROP POLICY IF EXISTS "members_view_orgs" ON public.organizations;
DROP POLICY IF EXISTS "admin_manage_projects" ON public.projects;
DROP POLICY IF EXISTS "project_managers_manage" ON public.projects;
DROP POLICY IF EXISTS "members_view_projects" ON public.projects;

DROP FUNCTION IF EXISTS public.get_user_role(UUID);

-- Step 4: Create super simple RLS policies using auth.users.role directly

-- Profiles: Admin can manage all, users can manage own
CREATE POLICY "profiles_admin_all" ON public.profiles
    FOR ALL USING (
        (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin'
    );

CREATE POLICY "profiles_user_own" ON public.profiles
    FOR ALL USING (auth.uid() = user_id);

-- Organizations: Admin can manage all, others view where they're members
CREATE POLICY "orgs_admin_all" ON public.organizations
    FOR ALL USING (
        (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin'
    );

CREATE POLICY "orgs_members_view" ON public.organizations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM organization_memberships om 
            WHERE om.org_id = id AND om.user_id = auth.uid()
        )
    );

-- Projects: Admin and project managers can manage, others view where they're members
CREATE POLICY "projects_admin_pm_all" ON public.projects
    FOR ALL USING (
        (SELECT role FROM auth.users WHERE id = auth.uid()) IN ('admin', 'project_manager')
    );

CREATE POLICY "projects_members_view" ON public.projects
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = id AND pm.user_id = auth.uid()
        )
    );

-- Step 5: Update trigger function to not manage roles (auth.users.role is set manually)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Only create profile with basic info (no role management)
    INSERT INTO public.profiles (user_id, display_name, company)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown')
    );
    
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Step 6: Clean up profiles table - remove role column (already done in previous migration)
-- Role is now managed only in auth.users.role
