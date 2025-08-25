-- Sample data for development
-- Note: Users will be created via Supabase Auth API, not in migrations
-- Removed manual user creation to prevent Auth API conflicts

-- Create profiles (moved to 20250820200000_create_profiles_table.sql)
-- Profiles will be created through auth system instead of seed data

-- Sample data structure only - no user references
-- Users and memberships will be added after auth creation

-- Create sample organization (without user references)
insert into public.organizations (id, name, created_at, updated_at) values
  ('11111111-1111-1111-1111-111111111111', 'IQVIA × JTB イベント管理', now(), now())
on conflict (id) do nothing;

-- Create sample project (without user references)  
insert into public.projects (id, org_id, name, start_date, end_date, created_at, updated_at) values
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Phase 3 Clinical Trial Event', '2025-01-01', '2025-06-30', now(), now())
on conflict (id) do nothing;

-- Note: Tasks, memberships, and assignments will be added after user creation through Supabase Auth
