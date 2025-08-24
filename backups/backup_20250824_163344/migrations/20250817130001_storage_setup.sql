-- Supabase Storage setup for file management
-- Created: 2025-08-17

-- Create storage bucket for files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'files',
  'files', 
  false,
  52428800, -- 50MB limit
  NULL -- Allow all file types
) ON CONFLICT (id) DO NOTHING;

-- Storage policies for files bucket
-- Allow authenticated users to upload files
CREATE POLICY "Authenticated users can upload files" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'files' 
    AND auth.role() = 'authenticated'
  );

-- Allow users to read files from projects they are members of
CREATE POLICY "Users can read project files" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'files' 
    AND auth.role() = 'authenticated'
    AND (
      -- Extract project_id from path (format: project_id/filename)
      EXISTS (
        SELECT 1 FROM project_memberships pm 
        WHERE pm.project_id = split_part(name, '/', 1)::uuid
        AND pm.user_id = auth.uid()
      )
    )
  );

-- Allow users to update files in projects they are members of
CREATE POLICY "Users can update project files" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'files' 
    AND auth.role() = 'authenticated'
    AND (
      EXISTS (
        SELECT 1 FROM project_memberships pm 
        WHERE pm.project_id = split_part(name, '/', 1)::uuid
        AND pm.user_id = auth.uid()
      )
    )
  );

-- Allow users to delete files in projects they are members of
CREATE POLICY "Users can delete project files" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'files' 
    AND auth.role() = 'authenticated'
    AND (
      EXISTS (
        SELECT 1 FROM project_memberships pm 
        WHERE pm.project_id = split_part(name, '/', 1)::uuid
        AND pm.user_id = auth.uid()
      )
    )
  );
