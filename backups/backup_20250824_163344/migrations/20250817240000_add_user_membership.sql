-- 現在のログインユーザーをプロジェクトメンバーに確実に追加

-- 1. テスト組織を確実に存在させる
INSERT INTO public.organizations (id, name, created_at, updated_at) VALUES 
('11111111-1111-1111-1111-111111111111', 'テスト組織', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    updated_at = NOW();

-- 2. テストプロジェクトを確実に存在させる  
INSERT INTO public.projects (id, name, org_id, created_at, updated_at) VALUES 
('22222222-2222-2222-2222-222222222222', 'テストプロジェクト', '11111111-1111-1111-1111-111111111111', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    updated_at = NOW();

-- 3. auth.usersテーブルに直接ユーザーを挿入（存在しない場合のみ）
INSERT INTO auth.users (
    id, 
    email, 
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    role,
    aud
) VALUES (
    'ac8ded90-9943-4a1a-b917-9d8d29967a23',
    'admin@test.com',
    '$2a$10$dummy.encrypted.password.hash.for.test.user.only',
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
) ON CONFLICT (id) DO NOTHING;

-- 4. 組織メンバーシップを追加
INSERT INTO public.organization_memberships (org_id, user_id, role, created_at) VALUES 
('11111111-1111-1111-1111-111111111111', 'ac8ded90-9943-4a1a-b917-9d8d29967a23', 'admin', NOW())
ON CONFLICT (org_id, user_id) DO UPDATE SET 
    role = EXCLUDED.role;

-- 5. プロジェクトメンバーシップを追加
INSERT INTO public.project_memberships (project_id, user_id, role, created_at) VALUES 
('22222222-2222-2222-2222-222222222222', 'ac8ded90-9943-4a1a-b917-9d8d29967a23', 'project_manager', NOW())
ON CONFLICT (project_id, user_id) DO UPDATE SET 
    role = EXCLUDED.role;
