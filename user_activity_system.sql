-- USER ACTIVITY TRACKING SYSTEM
-- リアルなユーザーアクティビティを記録・表示するシステム

-- 1. アクティビティテーブル作成
CREATE TABLE IF NOT EXISTS user_activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  activity_type VARCHAR(50) NOT NULL, -- 'task_completed', 'file_uploaded', 'comment_posted', 'project_joined', etc.
  entity_type VARCHAR(50), -- 'task', 'file', 'comment', 'project'  
  entity_id UUID, -- 関連するエンティティのID
  entity_name TEXT, -- エンティティの名前（タスク名、ファイル名など）
  description TEXT NOT NULL, -- アクティビティの説明
  metadata JSONB DEFAULT '{}', -- 追加情報
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 個人TODOテーブル作成
CREATE TABLE IF NOT EXISTS personal_todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  priority INTEGER DEFAULT 2, -- 1: Low, 2: Medium, 3: High
  due_date DATE,
  week_start DATE, -- その週の月曜日を記録
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- 3. RLS設定
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_todos ENABLE ROW LEVEL SECURITY;

-- アクティビティ: 自分の記録のみ閲覧可能
CREATE POLICY "user_activities_own_access" ON user_activities FOR ALL 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 個人TODO: 自分のTODOのみ管理可能
CREATE POLICY "personal_todos_own_access" ON personal_todos FOR ALL
USING (auth.uid() = user_id)  
WITH CHECK (auth.uid() = user_id);

-- 4. アクティビティ記録用のヘルパー関数
CREATE OR REPLACE FUNCTION log_user_activity(
  p_user_id UUID,
  p_activity_type VARCHAR(50),
  p_description TEXT,
  p_entity_type VARCHAR(50) DEFAULT NULL,
  p_entity_id UUID DEFAULT NULL,
  p_entity_name TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
  activity_id UUID;
BEGIN
  INSERT INTO user_activities (
    user_id, activity_type, entity_type, entity_id, entity_name, description, metadata
  ) VALUES (
    p_user_id, p_activity_type, p_entity_type, p_entity_id, p_entity_name, p_description, p_metadata
  ) RETURNING id INTO activity_id;
  
  RETURN activity_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. 今週の開始日（月曜日）を取得する関数
CREATE OR REPLACE FUNCTION get_week_start(input_date DATE DEFAULT CURRENT_DATE) 
RETURNS DATE AS $$
BEGIN
  -- 月曜日を週の開始とする（ISO 8601準拠）
  RETURN input_date - (EXTRACT(DOW FROM input_date)::INTEGER - 1) * INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 6. アクティビティ自動記録トリガー

-- タスク完了時のアクティビティ記録
CREATE OR REPLACE FUNCTION trigger_task_activity() RETURNS TRIGGER AS $$
BEGIN
  -- タスクが完了状態に変更された場合
  IF OLD.status != 'completed' AND NEW.status = 'completed' THEN
    PERFORM log_user_activity(
      auth.uid(),
      'task_completed',
      'タスク「' || NEW.title || '」を完了しました',
      'task',
      NEW.id,
      NEW.title,
      jsonb_build_object('project_id', NEW.project_id)
    );
  END IF;
  
  -- タスクが作成された場合  
  IF TG_OP = 'INSERT' THEN
    PERFORM log_user_activity(
      NEW.created_by,
      'task_created',
      'タスク「' || NEW.title || '」を作成しました',
      'task',
      NEW.id,
      NEW.title,
      jsonb_build_object('project_id', NEW.project_id)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ファイルアップロード時のアクティビティ記録
CREATE OR REPLACE FUNCTION trigger_file_activity() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM log_user_activity(
      NEW.uploaded_by,
      'file_uploaded',
      'ファイル「' || NEW.filename || '」をアップロードしました',
      'file',
      NEW.id,
      NEW.filename,
      jsonb_build_object('project_id', NEW.project_id, 'file_size', NEW.file_size)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- コメント投稿時のアクティビティ記録  
CREATE OR REPLACE FUNCTION trigger_comment_activity() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM log_user_activity(
      NEW.created_by,
      'comment_posted', 
      CASE NEW.entity_type
        WHEN 'task' THEN 'タスクにコメントを投稿しました'
        WHEN 'project' THEN 'プロジェクトチャットにメッセージを投稿しました'
        ELSE 'コメントを投稿しました'
      END,
      'comment',
      NEW.id,
      LEFT(NEW.content, 50) || CASE WHEN LENGTH(NEW.content) > 50 THEN '...' ELSE '' END,
      jsonb_build_object('entity_type', NEW.entity_type, 'entity_id', NEW.entity_id)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. トリガー作成（既存のものがあれば削除して再作成）
DROP TRIGGER IF EXISTS task_activity_trigger ON tasks;
CREATE TRIGGER task_activity_trigger
  AFTER INSERT OR UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION trigger_task_activity();

DROP TRIGGER IF EXISTS file_activity_trigger ON files;  
CREATE TRIGGER file_activity_trigger
  AFTER INSERT ON files
  FOR EACH ROW EXECUTE FUNCTION trigger_file_activity();

DROP TRIGGER IF EXISTS comment_activity_trigger ON comments;
CREATE TRIGGER comment_activity_trigger
  AFTER INSERT ON comments  
  FOR EACH ROW EXECUTE FUNCTION trigger_comment_activity();

-- 8. サンプルデータ（テスト用）
-- 既存のuser_idを使用してサンプルアクティビティを作成
INSERT INTO user_activities (user_id, activity_type, description, entity_type, created_at)
SELECT 
  user_id,
  'task_completed',
  'タスク「サンプルタスク」を完了しました',
  'task',
  NOW() - INTERVAL '2 hours'
FROM profiles 
LIMIT 1
ON CONFLICT DO NOTHING;
