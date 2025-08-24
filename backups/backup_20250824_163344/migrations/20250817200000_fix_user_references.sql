-- Fix foreign key constraint issues by making user references nullable
-- This prevents errors when users don't exist in auth.users table after database reset

-- Tasks table
ALTER TABLE public.tasks ALTER COLUMN created_by DROP NOT NULL;
ALTER TABLE public.tasks ALTER COLUMN updated_by DROP NOT NULL;

-- Files table  
ALTER TABLE public.files ALTER COLUMN created_by DROP NOT NULL;
ALTER TABLE public.files ALTER COLUMN updated_by DROP NOT NULL;

-- Projects table
ALTER TABLE public.projects ALTER COLUMN created_by DROP NOT NULL;
ALTER TABLE public.projects ALTER COLUMN updated_by DROP NOT NULL;

-- Organizations table
ALTER TABLE public.organizations ALTER COLUMN created_by DROP NOT NULL;
ALTER TABLE public.organizations ALTER COLUMN updated_by DROP NOT NULL;

-- Custom statuses table
ALTER TABLE public.custom_statuses ALTER COLUMN created_by DROP NOT NULL;
ALTER TABLE public.custom_statuses ALTER COLUMN updated_by DROP NOT NULL;
