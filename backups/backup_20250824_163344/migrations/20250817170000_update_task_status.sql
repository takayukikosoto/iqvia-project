-- タスクステータスの更新
-- doing (進行中) を削除、blocked (停止中) を resolved (対応済み) に変更

-- 1. 新しいenum型を作成
CREATE TYPE public.task_status_new AS ENUM ('todo', 'review', 'done', 'resolved');

-- 2. 新しいカラムを追加
ALTER TABLE public.tasks ADD COLUMN status_new public.task_status_new;

-- 3. データを移行（マッピング処理）
UPDATE public.tasks SET status_new = 
  CASE 
    WHEN status = 'todo' THEN 'todo'::public.task_status_new
    WHEN status = 'doing' THEN 'todo'::public.task_status_new  -- doing -> todo
    WHEN status = 'review' THEN 'review'::public.task_status_new
    WHEN status = 'done' THEN 'done'::public.task_status_new
    WHEN status = 'blocked' THEN 'resolved'::public.task_status_new  -- blocked -> resolved
    ELSE 'todo'::public.task_status_new
  END;

-- 4. インデックスを削除
DROP INDEX IF EXISTS idx_tasks_project_status_prio;

-- 5. 古いカラムを削除
ALTER TABLE public.tasks DROP COLUMN status;

-- 6. 新しいカラムをリネーム
ALTER TABLE public.tasks RENAME COLUMN status_new TO status;

-- 7. NOT NULL制約とデフォルト値を設定
ALTER TABLE public.tasks ALTER COLUMN status SET NOT NULL;
ALTER TABLE public.tasks ALTER COLUMN status SET DEFAULT 'todo';

-- 8. 古いenum型を削除して新しいものをリネーム
DROP TYPE IF EXISTS public.task_status CASCADE;
ALTER TYPE public.task_status_new RENAME TO task_status;

-- 9. インデックスを再作成
CREATE INDEX idx_tasks_project_status_prio ON public.tasks(project_id, status, priority);
