-- Implement Hybrid Admin System according to design guide

-- Step 1: Create admin schema and admins table
create schema if not exists admin;

create table if not exists admin.admins(
  user_id uuid primary key references auth.users(id),
  granted_by uuid references auth.users(id),
  granted_at timestamptz not null default now(),
  expires_at timestamptz
);
create index if not exists idx_admins_user_id on admin.admins(user_id);

-- Enable RLS on admin.admins
alter table admin.admins enable row level security;

-- Only authenticated users can read admin status (for RLS policies)
create policy "authenticated_read_admins" on admin.admins
  for select using (auth.role() = 'authenticated');

-- Step 2: Create function to sync admin status to app_metadata
create or replace function admin.sync_admin_metadata()
returns void
language plpgsql
security definer
as $$
declare
  admin_user record;
begin
  -- Update all current admins to have is_admin = true
  for admin_user in 
    select user_id from admin.admins 
    where expires_at is null or expires_at > now()
  loop
    update auth.users 
    set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"is_admin": true}'::jsonb
    where id = admin_user.user_id;
  end loop;
  
  -- Update non-admins to have is_admin = false or remove the flag
  update auth.users 
  set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"is_admin": false}'::jsonb
  where id not in (
    select user_id from admin.admins 
    where expires_at is null or expires_at > now()
  );
end;
$$;

-- Step 3: Create function to grant admin privileges
create or replace function admin.grant_admin_privileges(target_user_id uuid, granter_user_id uuid default auth.uid())
returns void
language plpgsql
security definer
as $$
begin
  -- Check if granter is admin (or allow if no admins exist yet for bootstrap)
  if not exists (select 1 from admin.admins where expires_at is null or expires_at > now()) then
    -- Bootstrap case: allow if no admins exist
    null;
  elsif not exists (
    select 1 from admin.admins 
    where user_id = granter_user_id 
    and (expires_at is null or expires_at > now())
  ) then
    raise exception 'Only admins can grant admin privileges';
  end if;
  
  -- Insert or update admin record
  insert into admin.admins (user_id, granted_by)
  values (target_user_id, granter_user_id)
  on conflict (user_id) do update set
    granted_by = excluded.granted_by,
    granted_at = now(),
    expires_at = null;
    
  -- Sync metadata
  perform admin.sync_admin_metadata();
end;
$$;

-- Step 4: Create function to revoke admin privileges
create or replace function admin.revoke_admin_privileges(target_user_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  -- Check if caller is admin
  if not exists (
    select 1 from admin.admins 
    where user_id = auth.uid() 
    and (expires_at is null or expires_at > now())
  ) then
    raise exception 'Only admins can revoke admin privileges';
  end if;
  
  -- Remove admin record
  delete from admin.admins where user_id = target_user_id;
  
  -- Sync metadata
  perform admin.sync_admin_metadata();
end;
$$;

-- Step 5: Update existing RLS policies to use hybrid approach

-- Drop old policies
drop policy if exists "profiles_admin_all" on public.profiles;
drop policy if exists "profiles_user_own" on public.profiles;
drop policy if exists "orgs_admin_all" on public.organizations;
drop policy if exists "orgs_members_view" on public.organizations;
drop policy if exists "projects_admin_pm_all" on public.projects;
drop policy if exists "projects_members_view" on public.projects;

-- New hybrid policies for profiles
create policy "profiles_admin_all" on public.profiles
  for all using (
    coalesce((auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, false)
  );

create policy "profiles_user_own" on public.profiles
  for all using (auth.uid() = user_id);

-- New hybrid policies for organizations
create policy "orgs_admin_all" on public.organizations
  for all using (
    coalesce((auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, false)
  );

create policy "orgs_members_view" on public.organizations
  for select using (
    exists (
      select 1 from organization_memberships om 
      where om.org_id = id and om.user_id = auth.uid()
    )
  );

-- New hybrid policies for projects
create policy "projects_admin_all" on public.projects
  for all using (
    coalesce((auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, false)
  );

create policy "projects_members_view" on public.projects
  for select using (
    exists (
      select 1 from project_memberships pm 
      where pm.project_id = id and pm.user_id = auth.uid()
    )
  );

-- Step 6: Bootstrap initial admin user
-- Create admin@test.com as initial admin (bootstrap)
do $$
begin
  -- Ensure admin@test.com exists
  if exists (select 1 from auth.users where email = 'admin@test.com') then
    -- Grant admin privileges to admin@test.com (bootstrap case)
    perform admin.grant_admin_privileges(
      (select id from auth.users where email = 'admin@test.com'),
      null -- bootstrap case
    );
  end if;
end $$;

-- Step 7: Grant necessary permissions
grant usage on schema admin to authenticated;
grant select on admin.admins to authenticated;
grant execute on function admin.grant_admin_privileges(uuid, uuid) to authenticated;
grant execute on function admin.revoke_admin_privileges(uuid) to authenticated;
grant execute on function admin.sync_admin_metadata() to authenticated;
