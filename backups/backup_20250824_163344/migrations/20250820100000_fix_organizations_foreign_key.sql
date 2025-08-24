-- Fix organizations.created_by foreign key constraint to reference auth.users
-- This fixes the issue where organizations cannot be created due to missing public.users table

-- Drop existing foreign key constraint if it exists
ALTER TABLE public.organizations 
DROP CONSTRAINT IF EXISTS organizations_created_by_fkey;

-- Add new foreign key constraint referencing auth.users
ALTER TABLE public.organizations 
ADD CONSTRAINT organizations_created_by_fkey 
FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Also fix updated_by if it has similar constraint
ALTER TABLE public.organizations 
DROP CONSTRAINT IF EXISTS organizations_updated_by_fkey;

ALTER TABLE public.organizations 
ADD CONSTRAINT organizations_updated_by_fkey 
FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Fix projects table as well for consistency
ALTER TABLE public.projects 
DROP CONSTRAINT IF EXISTS projects_created_by_fkey;

ALTER TABLE public.projects 
ADD CONSTRAINT projects_created_by_fkey 
FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE public.projects 
DROP CONSTRAINT IF EXISTS projects_updated_by_fkey;

ALTER TABLE public.projects 
ADD CONSTRAINT projects_updated_by_fkey 
FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Fix tasks table as well for consistency
ALTER TABLE public.tasks 
DROP CONSTRAINT IF EXISTS tasks_created_by_fkey;

ALTER TABLE public.tasks 
ADD CONSTRAINT tasks_created_by_fkey 
FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE public.tasks 
DROP CONSTRAINT IF EXISTS tasks_updated_by_fkey;

ALTER TABLE public.tasks 
ADD CONSTRAINT tasks_updated_by_fkey 
FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;
