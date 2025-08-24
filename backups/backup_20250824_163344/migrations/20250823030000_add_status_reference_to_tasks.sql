-- Add reference to status_options in tasks table
-- This will allow dynamic status management

-- 1. Add status_option_id column to tasks table
ALTER TABLE public.tasks ADD COLUMN status_option_id UUID REFERENCES public.status_options(id);

-- 2. Create index for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_status_option_id ON public.tasks(status_option_id);

-- 3. Update existing tasks to reference status_options
-- Map current enum values to corresponding status_options records
UPDATE public.tasks 
SET status_option_id = (
  SELECT id FROM public.status_options 
  WHERE name = tasks.status::text
)
WHERE status_option_id IS NULL;

-- 4. Function to get status info from status_options
CREATE OR REPLACE FUNCTION get_task_status_info(task_status TEXT)
RETURNS TABLE(
  id UUID,
  name TEXT,
  label TEXT,
  color TEXT,
  weight INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    so.id,
    so.name,
    so.label,
    so.color,
    so.weight
  FROM public.status_options so
  WHERE so.name = task_status AND so.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. View to get tasks with status information
CREATE OR REPLACE VIEW public.tasks_with_status_info AS
SELECT 
  t.*,
  so.label as status_label,
  so.color as status_color,
  so.weight as status_weight
FROM public.tasks t
LEFT JOIN public.status_options so ON t.status_option_id = so.id;

-- 6. Grant permissions for the view
GRANT SELECT ON public.tasks_with_status_info TO authenticated;

-- 7. Enable RLS for the view (inherits from tasks table)
ALTER VIEW public.tasks_with_status_info SET (security_invoker = on);
