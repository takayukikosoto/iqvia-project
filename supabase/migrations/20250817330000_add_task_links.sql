-- Add task links functionality
-- Supports external URLs and future file storage integration

-- Link type enum for extensibility
DO $$ 
BEGIN 
  CREATE TYPE public.link_type AS ENUM ('url', 'file', 'storage'); 
EXCEPTION 
  WHEN duplicate_object THEN NULL; 
END $$;

-- Task links table
CREATE TABLE IF NOT EXISTS public.task_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  title text NOT NULL,
  url text NOT NULL,
  link_type public.link_type NOT NULL DEFAULT 'url',
  description text,
  -- For future storage integration
  file_id uuid REFERENCES public.files(id) ON DELETE CASCADE,
  storage_provider text,
  storage_key text,
  -- Metadata
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users(id),
  updated_at timestamptz,
  updated_by uuid REFERENCES auth.users(id)
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_task_links_task_id ON public.task_links(task_id);
CREATE INDEX IF NOT EXISTS idx_task_links_type ON public.task_links(link_type);

-- Enable RLS (Row Level Security)
ALTER TABLE public.task_links ENABLE ROW LEVEL SECURITY;

-- RLS policies (disabled for now like other tables)
-- Policies will be enabled when chat RLS is re-enabled
