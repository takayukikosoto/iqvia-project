-- Fix files table missing uploaded_by field only
-- 2025-08-24 18:00:00

-- 1. Add missing uploaded_by field to files table
ALTER TABLE public.files 
ADD COLUMN IF NOT EXISTS uploaded_by UUID REFERENCES auth.users(id);

-- 2. Update existing files to have uploaded_by set to created_by where possible
UPDATE public.files 
SET uploaded_by = created_by 
WHERE uploaded_by IS NULL AND created_by IS NOT NULL;

-- 4. Update RLS policies for files table to include uploaded_by
DROP POLICY IF EXISTS "Users can view files they uploaded or are part of project" ON public.files;
CREATE POLICY "Users can view files they uploaded or are part of project" ON public.files
FOR SELECT USING (
    uploaded_by = auth.uid() OR
    created_by = auth.uid() OR
    project_id IN (
        SELECT pm.project_id 
        FROM project_memberships pm 
        WHERE pm.user_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Users can upload files to projects they are members of" ON public.files;
CREATE POLICY "Users can upload files to projects they are members of" ON public.files
FOR INSERT WITH CHECK (
    project_id IN (
        SELECT pm.project_id 
        FROM project_memberships pm 
        WHERE pm.user_id = auth.uid()
    )
);

-- 5. Ensure RLS is enabled on files table
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;
