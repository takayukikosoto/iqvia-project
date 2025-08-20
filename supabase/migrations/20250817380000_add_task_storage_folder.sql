-- Add storage_folder column to tasks table for file organization
-- Each task will have its own dedicated storage folder

-- Add storage_folder column
ALTER TABLE public.tasks 
ADD COLUMN storage_folder TEXT;
