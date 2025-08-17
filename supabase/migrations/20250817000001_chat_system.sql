-- Chat messages table
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.chat_messages enable row level security;

-- Create policies for chat messages
create policy "Users can view project chat messages" on public.chat_messages
  for select using (
    exists (
      select 1 from public.project_memberships pm
      where pm.project_id = chat_messages.project_id
      and pm.user_id = auth.uid()
    )
  );

create policy "Users can insert project chat messages" on public.chat_messages
  for insert with check (
    user_id = auth.uid()
  );

create policy "Users can update own chat messages" on public.chat_messages
  for update using (user_id = auth.uid());

create policy "Users can delete own chat messages" on public.chat_messages
  for delete using (user_id = auth.uid());

-- Create index for better performance
create index if not exists idx_chat_messages_project_created on public.chat_messages(project_id, created_at desc);

-- Enable realtime
alter publication supabase_realtime add table public.chat_messages;
