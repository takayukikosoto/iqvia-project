-- Add RPC functions to access admin.admins table from client

-- Function to get current admin user IDs
create or replace function public.get_current_admins()
returns table(user_id uuid)
language plpgsql
security definer
as $$
begin
  return query
  select a.user_id
  from admin.admins a
  where a.expires_at is null or a.expires_at > now();
end;
$$;

-- Function to check if a user is admin (for client-side use)
create or replace function public.is_user_admin(check_user_id uuid default auth.uid())
returns boolean
language plpgsql
security definer
as $$
begin
  return exists (
    select 1 
    from admin.admins a
    where a.user_id = check_user_id
    and (a.expires_at is null or a.expires_at > now())
  );
end;
$$;

-- Grant execute permissions
grant execute on function public.get_current_admins() to authenticated;
grant execute on function public.is_user_admin(uuid) to authenticated;
