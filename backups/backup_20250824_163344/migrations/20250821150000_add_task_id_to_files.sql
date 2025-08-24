-- Add task_id column to files table for task-specific file organization
-- This allows files to be associated with specific tasks

-- Add task_id column with foreign key constraint
ALTER TABLE public.files 
ADD COLUMN task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_files_task_id ON public.files(task_id);

-- Update RLS policies to include task-based file access
-- Drop existing policies first
DROP POLICY IF EXISTS "Enable read access for project members" ON files;
DROP POLICY IF EXISTS "Enable insert for project members" ON files;
DROP POLICY IF EXISTS "Enable update for project members" ON files;
DROP POLICY IF EXISTS "Enable delete for project members" ON files;

-- Recreate policies with task support
CREATE POLICY "Enable read access for project members" ON files
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable insert for project members" ON files
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable update for project members" ON files
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable delete for project members" ON files
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );
