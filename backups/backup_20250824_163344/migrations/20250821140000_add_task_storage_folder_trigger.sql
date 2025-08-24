-- Add trigger to automatically generate storage_folder for tasks
-- This ensures every task has a unique storage folder for file organization

-- Function to generate storage folder for new tasks
CREATE OR REPLACE FUNCTION generate_task_storage_folder()
RETURNS TRIGGER AS $$
BEGIN
  -- Generate unique storage folder: task_{task_id}
  NEW.storage_folder = 'task_' || NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the function before insert
CREATE TRIGGER trg_generate_task_storage_folder
  BEFORE INSERT ON public.tasks
  FOR EACH ROW
  EXECUTE FUNCTION generate_task_storage_folder();

-- Update existing tasks to have storage folders
UPDATE public.tasks 
SET storage_folder = 'task_' || id 
WHERE storage_folder IS NULL;

-- Create index on storage_folder for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_storage_folder ON public.tasks(storage_folder);
