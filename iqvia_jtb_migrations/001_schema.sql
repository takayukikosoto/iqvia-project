-- 001_schema.sql
-- Schema for IQVIA × JTB Task Management Tool (Supabase/PostgreSQL)
create extension if not exists pgcrypto;
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  company text,
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz
);
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  updated_at timestamptz,
  updated_by uuid references auth.users(id)
);
create table if not exists public.organization_memberships (
  org_id uuid references public.organizations(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','org_manager','project_manager','contributor','viewer')),
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  primary key (org_id, user_id)
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organizations(id) on delete cascade,
  name text not null,
  start_date date,
  end_date date,
  status text default 'active',
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  updated_at timestamptz,
  updated_by uuid references auth.users(id)
);
create table if not exists public.project_memberships (
  project_id uuid references public.projects(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text not null check (role in ('project_manager','contributor','viewer')),
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  primary key (project_id, user_id)
);
do $$ begin create type public.task_status as enum ('todo','doing','review','done','blocked'); exception when duplicate_object then null; end $$;
do $$ begin create type public.task_priority as enum ('low','medium','high','urgent'); exception when duplicate_object then null; end $$;
do $$ begin create type public.storage_provider as enum ('box','supabase'); exception when duplicate_object then null; end $$;
do $$ begin create type public.comment_target as enum ('task','file'); exception when duplicate_object then null; end $$;
do $$ begin create type public.notify_type as enum ('task_updated','task_commented','file_versioned','mention'); exception when duplicate_object then null; end $$;
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  title text not null,
  description text,
  status public.task_status not null default 'todo',
  priority public.task_priority not null default 'medium',
  due_at timestamptz,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  updated_at timestamptz,
  updated_by uuid references auth.users(id)
);
create table if not exists public.task_assignees (
  task_id uuid references public.tasks(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  primary key (task_id, user_id)
);
create table if not exists public.task_watchers (
  task_id uuid references public.tasks(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  primary key (task_id, user_id)
);
create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null,
  provider public.storage_provider not null,
  external_id text,
  external_url text,
  current_version int default 1,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id),
  updated_at timestamptz,
  updated_by uuid references auth.users(id)
);
create table if not exists public.file_versions (
  id uuid primary key default gen_random_uuid(),
  file_id uuid not null references public.files(id) on delete cascade,
  version int not null,
  size_bytes bigint,
  checksum text,
  storage_key text,
  uploaded_at timestamptz default now(),
  uploaded_by uuid references auth.users(id)
);
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  target_type public.comment_target not null,
  target_id uuid not null,
  body text not null,
  parent_id uuid,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id)
);
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type public.notify_type not null,
  payload jsonb not null,
  read_at timestamptz,
  created_at timestamptz default now()
);
create index if not exists idx_tasks_project_status_prio on public.tasks(project_id, status, priority);
create index if not exists idx_comments_target_created on public.comments(target_type, target_id, created_at);
create index if not exists idx_notifications_user_created on public.notifications(user_id, created_at);
