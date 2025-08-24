-- Add 'completed' status to task_status enum
-- This allows tasks to be marked as completed
ALTER TYPE task_status ADD VALUE IF NOT EXISTS 'completed';
