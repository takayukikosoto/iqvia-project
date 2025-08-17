-- Update priority colors to be more intuitive
-- 緊急:赤、高:黄色、中:青、低:緑

-- Update custom statuses colors if they exist
UPDATE public.custom_statuses 
SET color = CASE 
    WHEN name = 'low' THEN '#28a745'    -- 緑
    WHEN name = 'medium' THEN '#007bff' -- 青  
    WHEN name = 'high' THEN '#ffc107'   -- 黄色
    WHEN name = 'urgent' THEN '#dc3545' -- 赤
    ELSE color
END
WHERE type = 'priority';

-- Insert default priority options if they don't exist
INSERT INTO public.custom_statuses (project_id, name, label, color, type, "order", is_default)
VALUES 
    (null, 'low', '低', '#28a745', 'priority', 1, true),
    (null, 'medium', '中', '#007bff', 'priority', 2, true),
    (null, 'high', '高', '#ffc107', 'priority', 3, true),
    (null, 'urgent', '緊急', '#dc3545', 'priority', 4, true)
ON CONFLICT (project_id, name, type) DO UPDATE SET
    color = EXCLUDED.color,
    label = EXCLUDED.label;
