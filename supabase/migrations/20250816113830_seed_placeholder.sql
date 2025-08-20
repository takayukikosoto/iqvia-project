-- Sample data for development
-- Note: In production, auth.users will be created via Supabase Auth

-- Create sample users (mock UUIDs for dev)
-- These would normally be created via Supabase Auth signup
insert into auth.users (id, email, created_at) values 
  ('550e8400-e29b-41d4-a716-446655440001', 'admin@iqvia.com', now()),
  ('550e8400-e29b-41d4-a716-446655440002', 'pm@jtb.com', now()),
  ('550e8400-e29b-41d4-a716-446655440003', 'dev@vendor.com', now())
on conflict (id) do nothing;

-- Create profiles (moved to 20250820200000_create_profiles_table.sql)
-- Profiles will be created through auth system instead of seed data

-- Create sample organization
insert into public.organizations (id, name, created_by) values
  ('11111111-1111-1111-1111-111111111111', 'IQVIA × JTB Alliance', '550e8400-e29b-41d4-a716-446655440001')
on conflict (id) do nothing;

-- Create organization memberships
insert into public.organization_memberships (org_id, user_id, role, created_by) values
  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', 'admin', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', 'project_manager', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440003', 'contributor', '550e8400-e29b-41d4-a716-446655440001')
on conflict (org_id, user_id) do nothing;

-- Create sample project
insert into public.projects (id, org_id, name, start_date, end_date, created_by) values
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Phase 3 Clinical Trial Event', '2025-01-01', '2025-06-30', '550e8400-e29b-41d4-a716-446655440001')
on conflict (id) do nothing;

-- Create project memberships
insert into public.project_memberships (project_id, user_id, role, created_by) values
  ('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440001', 'project_manager', '550e8400-e29b-41d4-a716-446655440001'),
  ('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440002', 'project_manager', '550e8400-e29b-41d4-a716-446655440001'),
  ('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440003', 'contributor', '550e8400-e29b-41d4-a716-446655440001')
on conflict (project_id, user_id) do nothing;

-- Insert sample tasks
insert into public.tasks (id, title, description, status, priority, project_id, due_at, created_by, updated_by) values
('11111111-1111-1111-1111-111111111111', '会場選定・予約', '治験イベント会場の調査と予約手配を行う', 'todo', 'high', '22222222-2222-2222-2222-222222222222', '2025-02-15T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
('11111111-1111-1111-1111-111111111112', '講演者調整', 'キーオピニオンリーダーおよび治験責任医師との連絡調整', 'doing', 'high', '22222222-2222-2222-2222-222222222222', '2025-02-28T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
('11111111-1111-1111-1111-111111111113', 'マーケティング資料作成', 'パンフレット、バナー、デジタル素材の制作', 'review', 'medium', '22222222-2222-2222-2222-222222222222', '2025-03-10T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
('11111111-1111-1111-1111-111111111114', '参加登録システム構築', 'オンライン参加登録システムとバッジ印刷機能の実装', 'done', 'medium', '22222222-2222-2222-2222-222222222222', '2025-01-30T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
('11111111-1111-1111-1111-111111111115', 'ケータリング手配', 'メニュー企画と食事制限対応の準備', 'blocked', 'low', '22222222-2222-2222-2222-222222222222', '2025-03-01T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001')
on conflict (id) do nothing;

-- Create task assignments
insert into public.task_assignees (task_id, user_id, created_by) values
  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111114', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111115', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001')
on conflict (task_id, user_id) do nothing;

-- Create task watchers
insert into public.task_watchers (task_id, user_id, created_by) values
  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
  ('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001')
on conflict (task_id, user_id) do nothing;
