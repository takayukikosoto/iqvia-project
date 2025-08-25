-- 個人タスク・勤怠システム統合設計
-- 1. タスク分類システム
-- 2. 個人タスク管理
-- 3. 勤怠管理システム
-- 4. カレンダー統合

-- ===================================
-- 1. タスク拡張・分類システム
-- ===================================

-- タスクタイプ定義
CREATE TYPE task_type AS ENUM (
    'personal',     -- 個人タスク
    'project',      -- プロジェクトタスク  
    'team',         -- チームタスク
    'company'       -- 全社タスク
);

-- タスクテーブル拡張
ALTER TABLE public.tasks 
ADD COLUMN IF NOT EXISTS task_type task_type DEFAULT 'project',
ADD COLUMN IF NOT EXISTS assigned_to uuid, -- 担当者
ADD COLUMN IF NOT EXISTS estimated_hours decimal(5,2), -- 予想作業時間
ADD COLUMN IF NOT EXISTS actual_hours decimal(5,2); -- 実際作業時間

-- project_idを任意にする（個人タスクの場合はNULL可能）
ALTER TABLE public.tasks 
ALTER COLUMN project_id DROP NOT NULL;

-- 担当者外部キー制約
ALTER TABLE public.tasks 
ADD CONSTRAINT fk_tasks_assigned_to 
FOREIGN KEY (assigned_to) REFERENCES auth.users(id);

-- ===================================
-- 2. 勤怠管理システム
-- ===================================

-- 勤怠タイプ
CREATE TYPE attendance_type AS ENUM (
    'work_start',   -- 出勤
    'work_end',     -- 退勤
    'break_start',  -- 休憩開始
    'break_end',    -- 休憩終了
    'leave_start',  -- 有給開始
    'leave_end',    -- 有給終了
    'sick_leave',   -- 病気休暇
    'overtime'      -- 残業
);

-- 勤怠記録テーブル
CREATE TABLE public.attendance_records (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    attendance_type attendance_type NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    location_lat decimal(10,8), -- GPS緯度
    location_lng decimal(11,8), -- GPS経度
    location_name text, -- 場所名
    note text, -- 備考
    is_manual boolean DEFAULT false, -- 手動記録フラグ
    task_id uuid REFERENCES public.tasks(id), -- 関連タスク
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 日次勤怠サマリーテーブル
CREATE TABLE public.daily_attendance_summary (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    work_date date NOT NULL,
    work_start_time timestamp with time zone,
    work_end_time timestamp with time zone,
    total_work_hours decimal(5,2) DEFAULT 0,
    total_break_hours decimal(5,2) DEFAULT 0,
    overtime_hours decimal(5,2) DEFAULT 0,
    leave_hours decimal(5,2) DEFAULT 0,
    status text DEFAULT 'working', -- working, completed, leave, sick
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    UNIQUE(user_id, work_date)
);

-- タスク時間記録テーブル
CREATE TABLE public.task_time_records (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    task_id uuid NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    hours_worked decimal(5,2),
    description text,
    is_completed boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);

-- ===================================
-- 3. RLSポリシー設定
-- ===================================

-- 勤怠記録のRLS
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY attendance_records_policy ON public.attendance_records
FOR ALL USING (
    user_id = auth.uid() OR 
    ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'hr', 'manager'))
);

-- 日次サマリーのRLS
ALTER TABLE public.daily_attendance_summary ENABLE ROW LEVEL SECURITY;
CREATE POLICY daily_summary_policy ON public.daily_attendance_summary
FOR ALL USING (
    user_id = auth.uid() OR 
    ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'hr', 'manager'))
);

-- タスク時間記録のRLS
ALTER TABLE public.task_time_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY task_time_records_policy ON public.task_time_records
FOR ALL USING (
    user_id = auth.uid() OR 
    task_id IN (
        SELECT id FROM tasks 
        WHERE assigned_to = auth.uid() OR created_by = auth.uid()
    ) OR
    ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'manager'))
);

-- 個人タスクのRLSポリシー更新
DROP POLICY IF EXISTS tasks_role_based ON public.tasks;
CREATE POLICY tasks_access ON public.tasks
FOR ALL USING (
    -- 管理者・マネージャーは全アクセス
    ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'manager')) OR
    -- プロジェクトタスク：プロジェクトメンバー
    (task_type = 'project' AND project_id IN (
        SELECT project_id FROM project_members WHERE user_id = auth.uid()
    )) OR
    -- 個人タスク：担当者または作成者
    (task_type = 'personal' AND (assigned_to = auth.uid() OR created_by = auth.uid())) OR
    -- チーム・全社タスク：担当者または作成者
    (task_type IN ('team', 'company') AND (assigned_to = auth.uid() OR created_by = auth.uid()))
);

-- ===================================
-- 4. 勤怠自動計算トリガー
-- ===================================

-- 勤怠記録更新時の自動サマリー計算
CREATE OR REPLACE FUNCTION calculate_daily_attendance()
RETURNS TRIGGER AS $$
DECLARE
    work_date_val date;
    start_time timestamp with time zone;
    end_time timestamp with time zone;
    total_hours decimal(5,2) := 0;
    break_hours decimal(5,2) := 0;
BEGIN
    work_date_val := NEW.recorded_at::date;
    
    -- その日の出勤・退勤時間を取得
    SELECT 
        MIN(CASE WHEN attendance_type = 'work_start' THEN recorded_at END),
        MAX(CASE WHEN attendance_type = 'work_end' THEN recorded_at END)
    INTO start_time, end_time
    FROM attendance_records 
    WHERE user_id = NEW.user_id 
    AND recorded_at::date = work_date_val;
    
    -- 労働時間計算
    IF start_time IS NOT NULL AND end_time IS NOT NULL THEN
        total_hours := EXTRACT(EPOCH FROM (end_time - start_time)) / 3600.0;
    END IF;
    
    -- 休憩時間計算（簡易版）
    SELECT COALESCE(SUM(
        CASE 
            WHEN attendance_type = 'break_start' THEN -EXTRACT(EPOCH FROM recorded_at) / 3600.0
            WHEN attendance_type = 'break_end' THEN EXTRACT(EPOCH FROM recorded_at) / 3600.0
            ELSE 0
        END
    ), 0) INTO break_hours
    FROM attendance_records 
    WHERE user_id = NEW.user_id 
    AND recorded_at::date = work_date_val
    AND attendance_type IN ('break_start', 'break_end');
    
    -- 日次サマリー更新
    INSERT INTO daily_attendance_summary (
        user_id, work_date, work_start_time, work_end_time, 
        total_work_hours, total_break_hours
    ) VALUES (
        NEW.user_id, work_date_val, start_time, end_time, 
        GREATEST(total_hours - ABS(break_hours), 0), ABS(break_hours)
    )
    ON CONFLICT (user_id, work_date) 
    DO UPDATE SET
        work_start_time = EXCLUDED.work_start_time,
        work_end_time = EXCLUDED.work_end_time,
        total_work_hours = EXCLUDED.total_work_hours,
        total_break_hours = EXCLUDED.total_break_hours,
        updated_at = now();
        
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- トリガー作成
DROP TRIGGER IF EXISTS trigger_calculate_attendance ON attendance_records;
CREATE TRIGGER trigger_calculate_attendance
    AFTER INSERT OR UPDATE ON attendance_records
    FOR EACH ROW
    EXECUTE FUNCTION calculate_daily_attendance();

-- ===================================
-- 5. サンプルデータ挿入
-- ===================================

-- 個人タスクサンプル（ログインユーザー用）
INSERT INTO public.tasks (
    title, description, task_type, assigned_to, created_by, 
    priority, status, due_at, estimated_hours
) 
SELECT 
    '個人学習: React Hook最適化', 
    '個人スキルアップのための学習タスク', 
    'personal',
    auth.uid(),
    auth.uid(),
    'medium',
    'todo',
    CURRENT_DATE + INTERVAL '3 days',
    4.0
WHERE auth.uid() IS NOT NULL;

INSERT INTO public.tasks (
    title, description, task_type, assigned_to, created_by, 
    priority, status, due_at, estimated_hours
) 
SELECT 
    '健康診断受診', 
    '年次健康診断の受診', 
    'personal',
    auth.uid(),
    auth.uid(),
    'high',
    'todo',
    CURRENT_DATE + INTERVAL '7 days',
    2.0
WHERE auth.uid() IS NOT NULL;

-- 本日の勤怠記録サンプル
INSERT INTO attendance_records (user_id, attendance_type, recorded_at, location_name)
SELECT 
    auth.uid(),
    'work_start',
    CURRENT_DATE + TIME '09:00:00',
    'オフィス'
WHERE auth.uid() IS NOT NULL;

-- ===================================
-- 6. 便利なビューの作成
-- ===================================

-- 個人タスクビュー
CREATE OR REPLACE VIEW personal_tasks_view AS
SELECT 
    t.*,
    p.display_name as assigned_to_name,
    CASE 
        WHEN t.task_type = 'personal' THEN '個人'
        WHEN t.task_type = 'project' THEN 'プロジェクト'
        WHEN t.task_type = 'team' THEN 'チーム'
        WHEN t.task_type = 'company' THEN '全社'
    END as task_type_label
FROM tasks t
LEFT JOIN profiles p ON t.assigned_to = p.user_id
WHERE t.assigned_to = auth.uid() OR t.created_by = auth.uid();

-- 今月の勤怠サマリービュー
CREATE OR REPLACE VIEW monthly_attendance_view AS
SELECT 
    user_id,
    DATE_TRUNC('month', work_date) as month,
    COUNT(*) as work_days,
    SUM(total_work_hours) as total_hours,
    AVG(total_work_hours) as avg_daily_hours,
    SUM(overtime_hours) as total_overtime
FROM daily_attendance_summary
WHERE work_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY user_id, DATE_TRUNC('month', work_date);

COMMENT ON TABLE public.attendance_records IS '勤怠記録：出退勤・休憩・残業などの記録';
COMMENT ON TABLE public.daily_attendance_summary IS '日次勤怠サマリー：1日の労働時間集計';
COMMENT ON TABLE public.task_time_records IS 'タスク時間記録：各タスクの作業時間追跡';
COMMENT ON COLUMN public.tasks.task_type IS 'タスク種別：personal/project/team/company';
COMMENT ON COLUMN public.tasks.assigned_to IS 'タスク担当者';
COMMENT ON COLUMN public.tasks.estimated_hours IS '予想作業時間';
COMMENT ON COLUMN public.tasks.actual_hours IS '実際作業時間';
