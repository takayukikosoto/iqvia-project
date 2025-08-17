-- Priority options table
create table if not exists public.priority_options (
  id uuid primary key default gen_random_uuid(),
  name varchar(50) not null unique,
  label varchar(100) not null,
  color varchar(7) not null,
  weight integer not null unique,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Priority change history table
create table if not exists public.priority_change_history (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  old_priority varchar(50),
  new_priority varchar(50) not null,
  changed_at timestamptz default now(),
  reason text
);

-- Insert default priority options
insert into public.priority_options (name, label, color, weight) values
  ('low', '低', '#28a745', 1),
  ('medium', '中', '#ffc107', 2),
  ('high', '高', '#fd7e14', 3),
  ('urgent', '緊急', '#dc3545', 4);

-- Enable RLS
alter table public.priority_options enable row level security;
alter table public.priority_change_history enable row level security;

-- RLS policies for priority_options (read-only for authenticated users)
create policy "All users can view priority options" on public.priority_options
  for select using (auth.role() = 'authenticated');

-- RLS policies for priority_change_history
create policy "Users can view all priority history" on public.priority_change_history
  for select using (auth.role() = 'authenticated');

create policy "Users can insert priority history entries" on public.priority_change_history
  for insert with check (user_id = auth.uid());

-- Create indexes for better performance
create index if not exists idx_priority_change_history_task_id on public.priority_change_history(task_id);
create index if not exists idx_priority_change_history_user_id on public.priority_change_history(user_id);
create index if not exists idx_priority_change_history_changed_at on public.priority_change_history(changed_at desc);

-- Update trigger for priority_options
create or replace function update_priority_options_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trigger_update_priority_options_updated_at
  before update on public.priority_options
  for each row execute function update_priority_options_updated_at();

-- Function to log priority changes
create or replace function log_priority_change()
returns trigger as $$
begin
  -- Only log if priority actually changed
  if old.priority is distinct from new.priority then
    insert into public.priority_change_history (
      task_id,
      user_id,
      old_priority,
      new_priority,
      reason
    ) values (
      new.id,
      auth.uid(),
      old.priority,
      new.priority,
      'Priority updated via UI'
    );
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to automatically log priority changes
create trigger trigger_log_priority_change
  after update on public.tasks
  for each row execute function log_priority_change();
