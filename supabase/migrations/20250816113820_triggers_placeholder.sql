-- Triggers for automatic timestamp and notification handling

-- Function to set updated_at and updated_by columns
create or replace function public.set_updated_columns()
returns trigger as $$
begin
  new.updated_at = now();
  new.updated_by = auth.uid();
  return new;
end;
$$ language plpgsql;

-- Function to create notifications for task updates
create or replace function public.notify_task_update()
returns trigger as $$
declare
  watcher_id uuid;
  assignee_id uuid;
  payload_data jsonb;
begin
  -- Build notification payload
  payload_data = jsonb_build_object(
    'task_id', new.id,
    'task_title', new.title,
    'project_id', new.project_id,
    'changed_by', auth.uid(),
    'old_status', coalesce(old.status::text, 'new'),
    'new_status', new.status::text,
    'change_type', case when old is null then 'created' else 'updated' end
  );

  -- Notify task watchers
  for watcher_id in 
    select user_id from public.task_watchers 
    where task_id = new.id and user_id != auth.uid()
  loop
    insert into public.notifications (user_id, type, payload)
    values (watcher_id, 'task_updated', payload_data);
  end loop;

  -- Notify task assignees (if not already notified as watcher)
  for assignee_id in 
    select user_id from public.task_assignees 
    where task_id = new.id 
      and user_id != auth.uid()
      and not exists (
        select 1 from public.task_watchers 
        where task_id = new.id and user_id = assignee_id
      )
  loop
    insert into public.notifications (user_id, type, payload)
    values (assignee_id, 'task_updated', payload_data);
  end loop;

  return new;
end;
$$ language plpgsql security definer;

-- Function to create notifications for comments
create or replace function public.notify_comment_created()
returns trigger as $$
declare
  target_project_id uuid;
  member_id uuid;
  payload_data jsonb;
begin
  -- Get project ID based on comment target
  if new.target_type = 'task' then
    select project_id into target_project_id
    from public.tasks where id = new.target_id;
  elsif new.target_type = 'file' then
    select project_id into target_project_id
    from public.files where id = new.target_id;
  end if;

  -- Build notification payload
  payload_data = jsonb_build_object(
    'comment_id', new.id,
    'target_type', new.target_type,
    'target_id', new.target_id,
    'project_id', target_project_id,
    'comment_body', left(new.body, 100),
    'commented_by', auth.uid()
  );

  -- Notify all project members except the comment author
  for member_id in 
    select user_id from public.project_memberships 
    where project_id = target_project_id and user_id != auth.uid()
  loop
    insert into public.notifications (user_id, type, payload)
    values (member_id, 'task_commented', payload_data);
  end loop;

  return new;
end;
$$ language plpgsql security definer;

-- Apply triggers to relevant tables
-- Updated at/by triggers
create trigger set_updated_at_organizations
  before update on public.organizations
  for each row execute function public.set_updated_columns();

create trigger set_updated_at_projects
  before update on public.projects
  for each row execute function public.set_updated_columns();

create trigger set_updated_at_tasks
  before update on public.tasks
  for each row execute function public.set_updated_columns();

create trigger set_updated_at_files
  before update on public.files
  for each row execute function public.set_updated_columns();

create trigger set_updated_at_profiles
  before update on public.profiles
  for each row execute function public.set_updated_columns();

-- Notification triggers
create trigger notify_on_task_change
  after insert or update on public.tasks
  for each row execute function public.notify_task_update();

create trigger notify_on_comment_insert
  after insert on public.comments
  for each row execute function public.notify_comment_created();
