-- Removed manual user creation - users will be created through Supabase Auth API
-- Sample organizations and projects structure only

-- 1. Create sample organization
INSERT INTO public.organizations (id, name, created_at, updated_at) VALUES 
('11111111-1111-1111-1111-111111111111', 'イベント管理組織', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    updated_at = NOW();

-- 2. Create sample project
INSERT INTO public.projects (id, name, org_id, created_at, updated_at) VALUES 
('22222222-2222-2222-2222-222222222222', 'サンプルイベントプロジェクト', '11111111-1111-1111-1111-111111111111', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    updated_at = NOW();

-- Note: User memberships will be added after user creation through Supabase Auth
