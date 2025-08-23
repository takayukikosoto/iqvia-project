-- Create task-files storage bucket for task-specific file storage
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('task-files', 'task-files', true, 52428800, NULL)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for task-files bucket
CREATE POLICY "Authenticated users can view task files" ON storage.objects
FOR SELECT USING (
  bucket_id = 'task-files' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can upload task files" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'task-files' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can update task files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'task-files' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can delete task files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'task-files' 
  AND auth.role() = 'authenticated'
);
