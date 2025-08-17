-- カスタムステータス機能の追加
-- プロジェクト別にカスタムステータスを管理

-- 1. カスタムステータステーブルの作成
CREATE TABLE public.custom_statuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  label VARCHAR(100) NOT NULL,
  color VARCHAR(7) NOT NULL, -- hex color code (e.g., #ff0000)
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by UUID REFERENCES auth.users(id),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- プロジェクト内でのステータス名の一意制約
  UNIQUE(project_id, name)
);

-- 2. タスクテーブルにカスタムステータス参照を追加
ALTER TABLE public.tasks ADD COLUMN custom_status_id UUID REFERENCES public.custom_statuses(id);

-- 3. インデックスの作成
CREATE INDEX idx_custom_statuses_project_id ON public.custom_statuses(project_id);
CREATE INDEX idx_custom_statuses_project_order ON public.custom_statuses(project_id, order_index);
CREATE INDEX idx_tasks_custom_status ON public.tasks(custom_status_id);

-- 4. RLS (Row Level Security) の設定
ALTER TABLE public.custom_statuses ENABLE ROW LEVEL SECURITY;

-- プロジェクトメンバーのみアクセス可能
CREATE POLICY "Enable read access for project members" ON public.custom_statuses
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.project_memberships pm
      WHERE pm.project_id = custom_statuses.project_id 
      AND pm.user_id = auth.uid()
    )
  );

CREATE POLICY "Enable insert for project members" ON public.custom_statuses
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.project_memberships pm
      WHERE pm.project_id = custom_statuses.project_id 
      AND pm.user_id = auth.uid()
    )
  );

CREATE POLICY "Enable update for project members" ON public.custom_statuses
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.project_memberships pm
      WHERE pm.project_id = custom_statuses.project_id 
      AND pm.user_id = auth.uid()
    )
  );

CREATE POLICY "Enable delete for project members" ON public.custom_statuses
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.project_memberships pm
      WHERE pm.project_id = custom_statuses.project_id 
      AND pm.user_id = auth.uid()
    )
  );

-- 5. 更新時刻を自動で更新するトリガー
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_custom_statuses_updated_at
  BEFORE UPDATE ON public.custom_statuses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 6. リアルタイム通知の設定
ALTER PUBLICATION supabase_realtime ADD TABLE public.custom_statuses;
