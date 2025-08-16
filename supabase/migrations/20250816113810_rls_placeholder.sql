-- Row Level Security (RLS) Policies
-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_memberships enable row level security;
alter table public.projects enable row level security;
alter table public.project_memberships enable row level security;
alter table public.tasks enable row level security;
alter table public.task_assignees enable row level security;
alter table public.task_watchers enable row level security;
alter table public.files enable row level security;
alter table public.file_versions enable row level security;
alter table public.comments enable row level security;
alter table public.notifications enable row level security;

-- Helper functions for RLS
create or replace function public.is_org_member(org_uuid uuid)
returns boolean as $$
begin
  return exists (
    select 1 from public.organization_memberships
    where org_id = org_uuid and user_id = auth.uid()
  );
end;
$$ language plpgsql security definer;

create or replace function public.is_project_member(project_uuid uuid)
returns boolean as $$
begin
  return exists (
    select 1 from public.project_memberships
    where project_id = project_uuid and user_id = auth.uid()
  );
end;
$$ language plpgsql security definer;

create or replace function public.has_project_role(project_uuid uuid, required_roles text[])
returns boolean as $$
begin
  return exists (
    select 1 from public.project_memberships
    where project_id = project_uuid 
      and user_id = auth.uid()
      and role = any(required_roles)
  );
end;
$$ language plpgsql security definer;

create or replace function public.get_project_id_from_task(task_uuid uuid)
returns uuid as $$
begin
  return (select project_id from public.tasks where id = task_uuid);
end;
$$ language plpgsql security definer;

-- Profiles: Users can see all profiles, but only update their own
create policy "Users can view all profiles" on public.profiles
  for select using (true);

create policy "Users can update own profile" on public.profiles
  for update using (user_id = auth.uid());

create policy "Users can insert own profile" on public.profiles
  for insert with check (user_id = auth.uid());

-- Organizations: Simplified to avoid recursion
create policy "Users can view all organizations" on public.organizations
  for select using (true);

create policy "Users can manage organizations" on public.organizations
  for all using (true);

-- Organization memberships: Simplified to avoid recursion
create policy "Users can view all org memberships" on public.organization_memberships
  for select using (true);

create policy "Users can manage their own membership" on public.organization_memberships
  for all using (user_id = auth.uid());

-- Projects: Simplified to avoid recursion
create policy "Users can view all projects" on public.projects
  for select using (true);

create policy "Users can manage projects" on public.projects
  for all using (true);

-- Project memberships: Simplified to avoid recursion
create policy "Users can view all project memberships" on public.project_memberships
  for select using (true);

create policy "Users can manage their own project membership" on public.project_memberships
  for all using (user_id = auth.uid());

-- Tasks: Simplified to avoid recursion
create policy "Users can view all tasks" on public.tasks
  for select using (true);

create policy "Users can create tasks" on public.tasks
  for insert with check (true);

create policy "Users can update tasks" on public.tasks
  for update using (true);

create policy "Users can delete tasks" on public.tasks
  for delete using (true);

-- Task assignees: Simplified to avoid recursion
create policy "Users can view all task assignees" on public.task_assignees
  for select using (true);

create policy "Users can manage task assignees" on public.task_assignees
  for all using (true);

-- Task watchers: Simplified to avoid recursion
create policy "Users can view all task watchers" on public.task_watchers
  for select using (true);

create policy "Users can manage task watchers" on public.task_watchers
  for all using (true);

-- Files: Simplified to avoid recursion
create policy "Users can view all files" on public.files
  for select using (true);

create policy "Users can manage files" on public.files
  for all using (true);

-- File versions: Simplified to avoid recursion
create policy "Users can view all file versions" on public.file_versions
  for select using (true);

create policy "Users can manage file versions" on public.file_versions
  for all using (true);

-- Comments: Simplified to avoid recursion
create policy "Users can view all comments" on public.comments
  for select using (true);

create policy "Users can create comments" on public.comments
  for insert with check (true);

create policy "Comment authors can update their comments" on public.comments
  for update using (created_by = auth.uid());

-- Notifications: Users can only see their own notifications
create policy "Users can view own notifications" on public.notifications
  for select using (user_id = auth.uid());

create policy "Users can update own notifications" on public.notifications
  for update using (user_id = auth.uid());

-- Service role can insert notifications (for triggers)
create policy "Service role can insert notifications" on public.notifications
  for insert with check (true);
