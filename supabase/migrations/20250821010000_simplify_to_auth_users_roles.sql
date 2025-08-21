-- Simplify role management to use auth.users directly

-- Step 1: Update existing auth.users with roles from profiles
UPDATE auth.users 
SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', p.role)
FROM profiles p 
WHERE auth.users.id = p.user_id;

-- Step 2: Create simple RLS policies using auth.users roles

-- Helper function to get user role from JWT/metadata
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID DEFAULT auth.uid())
RETURNS TEXT AS $$
BEGIN
    RETURN COALESCE(
        auth.jwt() ->> 'role',  -- From JWT if available
        (SELECT raw_user_meta_data ->> 'role' FROM auth.users WHERE id = user_id), -- From metadata
        'viewer' -- Default
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Simple RLS policies for profiles table

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can insert profiles" ON public.profiles;

-- New simple policies
CREATE POLICY "admin_full_access" ON public.profiles
    FOR ALL USING (public.get_user_role() = 'admin');

CREATE POLICY "users_own_profile" ON public.profiles  
    FOR ALL USING (auth.uid() = user_id);

-- Step 4: Apply to other important tables

-- Organizations (admin can manage all, others can view where they're members)
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_manage_orgs" ON public.organizations
    FOR ALL USING (public.get_user_role() = 'admin');

CREATE POLICY "members_view_orgs" ON public.organizations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM organization_memberships om 
            WHERE om.org_id = id AND om.user_id = auth.uid()
        )
    );

-- Projects (similar pattern)
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_manage_projects" ON public.projects
    FOR ALL USING (public.get_user_role() = 'admin');

CREATE POLICY "project_managers_manage" ON public.projects
    FOR ALL USING (public.get_user_role() IN ('admin', 'project_manager'));

CREATE POLICY "members_view_projects" ON public.projects
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = id AND pm.user_id = auth.uid()
        )
    );

-- Step 5: Update user creation function to be simpler
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role text;
BEGIN
    -- Get role from metadata, default to viewer
    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'viewer');
    
    -- Create profile with minimal info (role now managed in auth.users)
    INSERT INTO public.profiles (user_id, display_name, company)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown')
    );
    
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Step 6: Remove role column from profiles (for full simplification)
ALTER TABLE public.profiles DROP COLUMN IF EXISTS role;
