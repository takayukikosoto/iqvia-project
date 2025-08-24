-- Fix projects table schema to match admin dashboard expectations

-- Add description column
ALTER TABLE public.projects 
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add settings column for future use
ALTER TABLE public.projects 
ADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}';

-- Rename org_id to organization_id for consistency
ALTER TABLE public.projects 
RENAME COLUMN org_id TO organization_id;

-- Update foreign key constraint name
ALTER TABLE public.projects 
DROP CONSTRAINT IF EXISTS projects_org_id_fkey;

ALTER TABLE public.projects 
ADD CONSTRAINT projects_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;

-- Update project_memberships role values to match admin dashboard
ALTER TABLE public.project_memberships 
DROP CONSTRAINT IF EXISTS project_memberships_role_check;

-- Update existing roles to new values
UPDATE public.project_memberships 
SET role = CASE 
  WHEN role = 'project_manager' THEN 'admin'
  WHEN role = 'contributor' THEN 'member'
  WHEN role = 'viewer' THEN 'viewer'
  ELSE 'member'  -- Default fallback
END;

-- Add constraint after data is cleaned
ALTER TABLE public.project_memberships 
ADD CONSTRAINT project_memberships_role_check 
CHECK (role IN ('admin', 'member', 'viewer'));
