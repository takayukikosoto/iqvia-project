-- カレンダー機能用eventsテーブル作成

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  start timestamptz not null,
  "end" timestamptz,
  all_day boolean not null default false,
  -- 所有者: デフォルトでログインユーザー
  owner_user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  color text,
  location text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.events enable row level security;

create policy "events_read_own"
on public.events for select
using (owner_user_id = auth.uid());

create policy "events_insert_own"
on public.events for insert
with check (owner_user_id = auth.uid());

create policy "events_update_own"
on public.events for update
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

create policy "events_delete_own"
on public.events for delete
using (owner_user_id = auth.uid());

create or replace function public.set_events_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_events_updated on public.events;
create trigger trg_events_updated before update on public.events
for each row execute function public.set_events_updated_at();

create index if not exists idx_events_owner_start_end
on public.events (owner_user_id, start, "end");
