-- ファイル管理システム強化: 既存テーブルに列追加
-- Created: 2025-08-17

-- files テーブルに追加列を追加
ALTER TABLE files ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE files ADD COLUMN IF NOT EXISTS file_type VARCHAR(100); -- 'document', 'image', 'video', 'other'
ALTER TABLE files ADD COLUMN IF NOT EXISTS mime_type VARCHAR(255);
ALTER TABLE files ADD COLUMN IF NOT EXISTS storage_path TEXT; -- Supabase Storage path
ALTER TABLE files ADD COLUMN IF NOT EXISTS total_versions INTEGER DEFAULT 1;
ALTER TABLE files ADD COLUMN IF NOT EXISTS total_size_bytes BIGINT DEFAULT 0;

-- current_version列をcurrent_version_idに変更
ALTER TABLE files ADD COLUMN IF NOT EXISTS current_version_id UUID;

-- file_versionsテーブルに追加列を追加
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS name VARCHAR(255);
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS storage_path TEXT;
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS upload_status VARCHAR(50) DEFAULT 'completed';
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS change_notes TEXT;
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- version列をversion_number列に統一
ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS version_number INTEGER;

-- 既存データの整合性を保つため、version_numberに既存のversionデータをコピー
UPDATE file_versions SET version_number = version WHERE version_number IS NULL;

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_files_project_id ON files(project_id);
CREATE INDEX IF NOT EXISTS idx_files_created_by ON files(created_by);
CREATE INDEX IF NOT EXISTS idx_files_file_type ON files(file_type);
CREATE INDEX IF NOT EXISTS idx_file_versions_file_id ON file_versions(file_id);
CREATE INDEX IF NOT EXISTS idx_file_versions_created_by ON file_versions(created_by);

-- UNIQUE制約を追加（存在しない場合のみ）
DO $$ 
BEGIN
    BEGIN
        ALTER TABLE file_versions ADD CONSTRAINT unique_file_version UNIQUE(file_id, version_number);
    EXCEPTION 
        WHEN duplicate_object THEN NULL;
    END;
END $$;

-- current_version_id の外部キー制約を後から追加（エラーを無視）
DO $$ 
BEGIN
    BEGIN
        ALTER TABLE files 
        ADD CONSTRAINT fk_files_current_version 
        FOREIGN KEY (current_version_id) REFERENCES file_versions(id);
    EXCEPTION 
        WHEN duplicate_object THEN NULL;
    END;
END $$;

-- RLS (Row Level Security) 有効化
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_versions ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: files
-- プロジェクトメンバーのみアクセス可能
CREATE POLICY "Enable read access for project members" ON files
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable insert for project members" ON files
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable update for project members" ON files
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable delete for project members" ON files
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = files.project_id 
            AND pm.user_id = auth.uid()
        )
    );

-- RLSポリシー: file_versions
-- ファイルの親プロジェクトメンバーのみアクセス可能
CREATE POLICY "Enable read access for project members" ON file_versions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM files f
            JOIN project_memberships pm ON pm.project_id = f.project_id
            WHERE f.id = file_versions.file_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable insert for project members" ON file_versions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM files f
            JOIN project_memberships pm ON pm.project_id = f.project_id
            WHERE f.id = file_versions.file_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable update for project members" ON file_versions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM files f
            JOIN project_memberships pm ON pm.project_id = f.project_id
            WHERE f.id = file_versions.file_id 
            AND pm.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable delete for project members" ON file_versions
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM files f
            JOIN project_memberships pm ON pm.project_id = f.project_id
            WHERE f.id = file_versions.file_id 
            AND pm.user_id = auth.uid()
        )
    );

-- トリガー: updated_at自動更新
CREATE OR REPLACE FUNCTION update_files_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_files_updated_at
    BEFORE UPDATE ON files
    FOR EACH ROW
    EXECUTE FUNCTION update_files_updated_at();

-- リアルタイム通知設定
ALTER PUBLICATION supabase_realtime ADD TABLE files;
ALTER PUBLICATION supabase_realtime ADD TABLE file_versions;
