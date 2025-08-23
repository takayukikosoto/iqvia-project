-- Status options table (similar to priority_options)
-- Allows dynamic management of task statuses

-- 1. Create status_options table
CREATE TABLE IF NOT EXISTS public.status_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL UNIQUE,
  label VARCHAR(100) NOT NULL,
  color VARCHAR(7) NOT NULL,
  weight INTEGER NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create status change history table
CREATE TABLE IF NOT EXISTS public.status_change_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  old_status VARCHAR(50),
  new_status VARCHAR(50) NOT NULL,
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  reason TEXT
);

-- 3. Insert default status options
INSERT INTO public.status_options (name, label, color, weight) VALUES
  ('todo', '未着手', '#6c757d', 1),
  ('review', 'レビュー中', '#ffc107', 2),
  ('done', '作業完了', '#28a745', 3),
  ('resolved', '対応済み', '#17a2b8', 4),
  ('completed', '完了済み', '#6f42c1', 5)
ON CONFLICT (name) DO NOTHING;

-- 4. Enable RLS
ALTER TABLE public.status_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.status_change_history ENABLE ROW LEVEL SECURITY;

-- 5. RLS policies for status_options (read-only for authenticated users)
CREATE POLICY "All users can view status options" ON public.status_options
  FOR SELECT USING (auth.role() = 'authenticated');

-- 6. RLS policies for status_change_history
CREATE POLICY "Users can view all status history" ON public.status_change_history
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert status history entries" ON public.status_change_history
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- 7. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_status_change_history_task_id ON public.status_change_history(task_id);
CREATE INDEX IF NOT EXISTS idx_status_change_history_user_id ON public.status_change_history(user_id);
CREATE INDEX IF NOT EXISTS idx_status_change_history_changed_at ON public.status_change_history(changed_at DESC);

-- 8. Update trigger for status_options
CREATE OR REPLACE FUNCTION update_status_options_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_status_options_updated_at
  BEFORE UPDATE ON public.status_options
  FOR EACH ROW EXECUTE FUNCTION update_status_options_updated_at();

-- 9. Function to log status changes
CREATE OR REPLACE FUNCTION log_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Only log if status actually changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO public.status_change_history (
      task_id,
      user_id,
      old_status,
      new_status,
      reason
    ) VALUES (
      NEW.id,
      auth.uid(),
      OLD.status,
      NEW.status,
      'Status updated via UI'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Trigger to automatically log status changes
CREATE TRIGGER trigger_log_status_change
  AFTER UPDATE ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION log_status_change();
