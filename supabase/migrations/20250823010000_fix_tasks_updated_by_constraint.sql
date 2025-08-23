-- Fix tasks_updated_by foreign key constraint error
-- The updated_by column should be nullable and reference valid users

-- First, drop the foreign key constraint if it exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'tasks_updated_by_fkey' 
        AND table_name = 'tasks'
    ) THEN
        ALTER TABLE tasks DROP CONSTRAINT tasks_updated_by_fkey;
    END IF;
END $$;

-- Make updated_by nullable
ALTER TABLE tasks ALTER COLUMN updated_by DROP NOT NULL;

-- Update existing tasks that have invalid updated_by references
UPDATE tasks 
SET updated_by = created_by 
WHERE updated_by IS NOT NULL 
  AND NOT EXISTS (SELECT 1 FROM auth.users WHERE id = tasks.updated_by);

-- Set updated_by to NULL for tasks where created_by is also invalid
UPDATE tasks 
SET updated_by = NULL 
WHERE updated_by IS NOT NULL 
  AND created_by IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM auth.users WHERE id = tasks.created_by);

-- Add back the foreign key constraint as nullable
ALTER TABLE tasks 
ADD CONSTRAINT tasks_updated_by_fkey 
FOREIGN KEY (updated_by) REFERENCES auth.users(id);
