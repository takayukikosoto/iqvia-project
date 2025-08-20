-- Storage bucket作成
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('files', 'files', true, 52428800, NULL)
ON CONFLICT (id) DO NOTHING;

-- Storage bucket policy設定
CREATE POLICY "Public file access" ON storage.objects
FOR SELECT USING (bucket_id = 'files');

CREATE POLICY "Public file upload" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'files');

CREATE POLICY "Public file delete" ON storage.objects
FOR DELETE USING (bucket_id = 'files');
