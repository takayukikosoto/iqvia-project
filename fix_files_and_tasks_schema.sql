-- Fix critical database schema issues for file upload and task-profile relationships
-- 2025-08-24

-- 1. Add missing uploaded_by field to files table
ALTER TABLE public.files 
ADD COLUMN IF NOT EXISTS uploaded_by UUID REFERENCES auth.users(id);

-- 2. Update files table to match expected schema for uploads
ALTER TABLE public.files 
ADD COLUMN IF NOT EXISTS uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 3. Fix tasks table foreign key reference to profiles
-- First check if the foreign key exists and drop if necessary
DO $$ 
BEGIN
    -- Check if the constraint exists and drop it
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'tasks_assigned_to_fkey' 
        AND table_name = 'tasks'
    ) THEN
        ALTER TABLE public.tasks DROP CONSTRAINT tasks_assigned_to_fkey;
    END IF;
END $$;

-- Add the correct foreign key relationship for tasks.assigned_to -> profiles.user_id
ALTER TABLE public.tasks 
ADD CONSTRAINT tasks_assigned_to_fkey 
FOREIGN KEY (assigned_to) REFERENCES public.profiles(user_id) ON DELETE SET NULL;

-- 4. Add RLS policies for files with uploaded_by field
DROP POLICY IF EXISTS "Users can view files they uploaded or are part of project" ON public.files;
CREATE POLICY "Users can view files they uploaded or are part of project" ON public.files
FOR SELECT USING (
    uploaded_by = auth.uid() OR
    project_id IN (
        SELECT pm.project_id 
        FROM project_members pm 
        WHERE pm.user_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Users can upload files to projects they are members of" ON public.files;
CREATE POLICY "Users can upload files to projects they are members of" ON public.files
FOR INSERT WITH CHECK (
    project_id IN (
        SELECT pm.project_id 
        FROM project_members pm 
        WHERE pm.user_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Users can update files they uploaded" ON public.files;
CREATE POLICY "Users can update files they uploaded" ON public.files
FOR UPDATE USING (uploaded_by = auth.uid());

-- 5. Ensure RLS is enabled on files table
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

-- 6. Update any existing files to have correct uploaded_by values
-- Set uploaded_by to created_by where possible
UPDATE public.files 
SET uploaded_by = created_by 
WHERE uploaded_by IS NULL AND created_by IS NOT NULL;

-- 7. Refresh schema cache
NOTIFY pgrst, 'reload schema';

-- 8. Verify the changes
SELECT 
    'files table columns' as check_type,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'files' 
AND table_schema = 'public'
AND column_name IN ('uploaded_by', 'uploaded_at')
ORDER BY column_name;

SELECT 
    'tasks foreign keys' as check_type,
    constraint_name,
    table_name,
    column_name,
    foreign_table_name,
    foreign_column_name
FROM information_schema.key_column_usage kcu
JOIN information_schema.referential_constraints rc ON kcu.constraint_name = rc.constraint_name
JOIN information_schema.key_column_usage kcu2 ON rc.unique_constraint_name = kcu2.constraint_name
WHERE kcu.table_name = 'tasks' 
AND kcu.column_name = 'assigned_to'
AND kcu.table_schema = 'public';
