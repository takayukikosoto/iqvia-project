-- Restore missing personal task and attendance system tables
-- 2025-08-24 20:00:00

-- 1. Create task_type enum if not exists
DO $$ BEGIN
    CREATE TYPE task_type AS ENUM ('personal', 'project', 'team', 'company');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Add missing columns to tasks table
ALTER TABLE public.tasks 
ADD COLUMN IF NOT EXISTS task_type task_type DEFAULT 'project',
ADD COLUMN IF NOT EXISTS assigned_to UUID REFERENCES public.profiles(user_id) ON DELETE SET NULL;

-- 3. Create personal_todos table
CREATE TABLE IF NOT EXISTS public.personal_todos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT false,
    priority INTEGER DEFAULT 2 CHECK (priority BETWEEN 1 AND 5),
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    category TEXT DEFAULT 'general'
);

-- 4. Create attendance_action_type enum
DO $$ BEGIN
    CREATE TYPE attendance_action_type AS ENUM ('clock_in', 'clock_out', 'break_start', 'break_end', 'leave', 'overtime_start', 'overtime_end');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 5. Create attendance_records table
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    action_type attendance_action_type NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6. Create daily_attendance_summary table
CREATE TABLE IF NOT EXISTS public.daily_attendance_summary (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    work_date DATE NOT NULL,
    clock_in_time TIME,
    clock_out_time TIME,
    total_work_minutes INTEGER DEFAULT 0,
    total_break_minutes INTEGER DEFAULT 0,
    total_overtime_minutes INTEGER DEFAULT 0,
    status TEXT DEFAULT 'absent',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, work_date)
);

-- 7. Create task_time_records table
CREATE TABLE IF NOT EXISTS public.task_time_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    total_minutes INTEGER,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 8. Enable RLS on all tables
ALTER TABLE public.personal_todos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_attendance_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_time_records ENABLE ROW LEVEL SECURITY;

-- 9. Create RLS policies for personal_todos
DROP POLICY IF EXISTS "personal_todos_user_policy" ON public.personal_todos;
CREATE POLICY "personal_todos_user_policy" ON public.personal_todos
FOR ALL USING (user_id = auth.uid());

-- 10. Create RLS policies for attendance_records
DROP POLICY IF EXISTS "attendance_records_user_policy" ON public.attendance_records;
CREATE POLICY "attendance_records_user_policy" ON public.attendance_records
FOR ALL USING (user_id = auth.uid());

-- 11. Create RLS policies for daily_attendance_summary
DROP POLICY IF EXISTS "daily_attendance_summary_user_policy" ON public.daily_attendance_summary;
CREATE POLICY "daily_attendance_summary_user_policy" ON public.daily_attendance_summary
FOR ALL USING (user_id = auth.uid());

-- 12. Create RLS policies for task_time_records
DROP POLICY IF EXISTS "task_time_records_user_policy" ON public.task_time_records;
CREATE POLICY "task_time_records_user_policy" ON public.task_time_records
FOR ALL USING (user_id = auth.uid());

-- 13. Create function to calculate daily attendance summary
CREATE OR REPLACE FUNCTION public.calculate_daily_attendance_summary()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert or update daily summary when attendance records change
    INSERT INTO public.daily_attendance_summary (user_id, work_date, status, updated_at)
    VALUES (NEW.user_id, DATE(NEW.recorded_at), 'present', now())
    ON CONFLICT (user_id, work_date)
    DO UPDATE SET 
        status = 'present',
        updated_at = now();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 14. Create trigger for attendance summary calculation
DROP TRIGGER IF EXISTS trg_attendance_summary ON public.attendance_records;
CREATE TRIGGER trg_attendance_summary
    AFTER INSERT OR UPDATE ON public.attendance_records
    FOR EACH ROW EXECUTE FUNCTION public.calculate_daily_attendance_summary();

-- 15. Create personal calendar events table
CREATE TABLE IF NOT EXISTS public.personal_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    all_day BOOLEAN DEFAULT false,
    color TEXT DEFAULT '#3b82f6',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 16. Enable RLS on personal_events
ALTER TABLE public.personal_events ENABLE ROW LEVEL SECURITY;

-- 17. Create RLS policy for personal_events
DROP POLICY IF EXISTS "personal_events_user_policy" ON public.personal_events;
CREATE POLICY "personal_events_user_policy" ON public.personal_events
FOR ALL USING (user_id = auth.uid());
