-- Disable RLS for task_links table temporarily
-- Same approach as chat_messages to avoid 403 errors

ALTER TABLE public.task_links DISABLE ROW LEVEL SECURITY;
