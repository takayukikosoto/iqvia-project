-- Update priority colors to be more intuitive
-- 緊急:赤、高:黄色、中:青、低:緑

-- Update priority_options colors if they exist
UPDATE public.priority_options 
SET color = CASE 
    WHEN name = 'low' THEN '#28a745'    -- 緑
    WHEN name = 'medium' THEN '#007bff' -- 青  
    WHEN name = 'high' THEN '#ffc107'   -- 黄色
    WHEN name = 'urgent' THEN '#dc3545' -- 赤
    ELSE color
END
WHERE name IN ('low', 'medium', 'high', 'urgent');

-- Insert default priority options if they don't exist
INSERT INTO public.priority_options (name, label, color, weight, is_active)
VALUES 
    ('low', '低', '#28a745', 1, true),
    ('medium', '中', '#007bff', 2, true),
    ('high', '高', '#ffc107', 3, true),
    ('urgent', '緊急', '#dc3545', 4, true)
ON CONFLICT (name) DO UPDATE SET
    color = EXCLUDED.color,
    label = EXCLUDED.label;
