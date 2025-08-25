-- Fix attendance_records table and personal tasks support

-- Add attendance_type column to attendance_records
ALTER TABLE attendance_records 
    ADD COLUMN IF NOT EXISTS attendance_type TEXT;

-- Make project_id nullable in tasks table to support personal tasks
ALTER TABLE tasks 
    ALTER COLUMN project_id DROP NOT NULL;

-- Update tasks table constraint to allow personal tasks
-- Personal tasks should have task_type = 'personal' and project_id = NULL
ALTER TABLE tasks 
    ADD CONSTRAINT check_personal_task_project 
    CHECK (
        (task_type = 'personal' AND project_id IS NULL) OR 
        (task_type != 'personal' AND project_id IS NOT NULL)
    );

-- Update RLS policies for tasks to handle personal tasks
DROP POLICY IF EXISTS tasks_select_policy ON tasks;
DROP POLICY IF EXISTS tasks_insert_policy ON tasks;
DROP POLICY IF EXISTS tasks_update_policy ON tasks;
DROP POLICY IF EXISTS tasks_delete_policy ON tasks;

-- New RLS policies for tasks including personal tasks
CREATE POLICY tasks_select_policy ON tasks
    FOR SELECT USING (
        -- Personal tasks: only creator can see
        (task_type = 'personal' AND created_by = auth.uid()) OR
        -- Project tasks: members can see
        (task_type != 'personal' AND EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid()
        )) OR
        -- Assigned users can see their tasks
        assigned_to = auth.uid()
    );

CREATE POLICY tasks_insert_policy ON tasks
    FOR INSERT WITH CHECK (
        -- Personal tasks: must be created by authenticated user
        (task_type = 'personal' AND created_by = auth.uid() AND project_id IS NULL) OR
        -- Project tasks: user must be member of project
        (task_type != 'personal' AND project_id IS NOT NULL AND EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid()
        ))
    );

CREATE POLICY tasks_update_policy ON tasks
    FOR UPDATE USING (
        -- Personal tasks: only creator can update
        (task_type = 'personal' AND created_by = auth.uid()) OR
        -- Project tasks: members can update
        (task_type != 'personal' AND EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid()
        )) OR
        -- Assigned users can update their tasks
        assigned_to = auth.uid()
    );

CREATE POLICY tasks_delete_policy ON tasks
    FOR DELETE USING (
        -- Personal tasks: only creator can delete
        (task_type = 'personal' AND created_by = auth.uid()) OR
        -- Project tasks: members can delete
        (task_type != 'personal' AND EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid()
        ))
    );
