# カレンダー機能 実装ガイド（**React + Vite** 版 / Route A: 自前UI）

Next.js 依存を外し、**React + Vite** プロジェクトに FullCalendar + Supabase で「表示・作成・更新・削除」を組み込むための手順です。Windsurf はこの文書を前提にコード生成・改変を行ってください。

---

## 0. 前提
- ランタイム: React 18+, Vite 5+（TypeScript）
- 認証: Supabase Auth（`auth.users.id`）
- セキュリティ: RLS で「所有者のみ操作」
- 画面: FullCalendar（クライアント描画）

---

## 1. 依存パッケージ

```bash
# FullCalendar
pnpm add @fullcalendar/core @fullcalendar/daygrid @fullcalendar/timegrid @fullcalendar/interaction @fullcalendar/list @fullcalendar/react

# Supabase
pnpm add @supabase/supabase-js
```

CSSは各プラグインのCSSを読み込みます（後述）。

---

## 2. Supabase スキーマ（SQL / そのまま利用可能）

> Next.js版と同様ですが、**owner_user_id のデフォルトを auth.uid()** に変更し、クライアントから列を送らなくてもよい形にします。

```sql
-- 02_calendar_schema_vite.sql

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
```

> **timestamptz**（UTC保管）推奨。クライアントはローカルタイムで扱い、ISO8601文字列でI/O。

---

## 3. 環境変数（Vite）

`.env`（開発用）
```
VITE_SUPABASE_URL=https://XXXX.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJ...
```

---

## 4. Supabase クライアント

`src/lib/supabase.ts`
```ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});
```

---

## 5. 型定義

`src/types/event.ts`
```ts
export interface EventDTO {
  id: string;
  title: string;
  start: string;       // ISO string
  end?: string | null;
  all_day?: boolean;
  color?: string | null;
  description?: string | null;
  location?: string | null;
}
```

---

## 6. カレンダーページ（React + Vite）

`src/pages/Calendar.tsx`（ルーティングは任意: react-router-dom 等）
```tsx
import { useCallback, useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { EventDTO } from '../types/event';

// FullCalendar + Plugins
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import listPlugin from '@fullcalendar/list';

// CSS（必要なものを読み込み）
import '@fullcalendar/core/index.css';
import '@fullcalendar/daygrid/index.css';
import '@fullcalendar/timegrid/index.css';
import '@fullcalendar/list/index.css';

export default function CalendarPage() {
  const [events, setEvents] = useState<EventDTO[]>([]);

  const fetchEvents = useCallback(async (fromISO?: string, toISO?: string) => {
    const user = (await supabase.auth.getUser()).data.user;
    if (!user) return;

    let query = supabase.from('events')
      .select('*')
      .eq('owner_user_id', user.id)
      .order('start', { ascending: true });

    if (fromISO) query = query.gte('start', fromISO);
    if (toISO)   query = query.lte('start', toISO);

    const { data, error } = await query;
    if (!error && data) setEvents(data as EventDTO[]);
  }, []);

  const handleDatesSet = useCallback((arg: any) => {
    // 画面に映る範囲のデータを取得
    fetchEvents(arg.start.toISOString(), arg.end.toISOString());
  }, [fetchEvents]);

  const handleSelect = useCallback(async (arg: any) => {
    const title = window.prompt('タイトル?');
    if (!title) return;
    const payload = {
      title,
      start: arg.startStr,
      end: arg.endStr,
      all_day: arg.allDay,
    };
    const { data, error } = await supabase.from('events').insert(payload).select().single();
    if (!error && data) setEvents(prev => [...prev, data as EventDTO]);
  }, []);

  const handleEventChange = useCallback(async (changeInfo: any) => {
    const e = changeInfo.event;
    const updates = {
      title: e.title,
      start: e.start?.toISOString() ?? null,
      end: e.end?.toISOString() ?? null,
      all_day: e.allDay,
    };
    await supabase.from('events').update(updates).eq('id', e.id);
  }, []);

  const handleEventRemove = useCallback(async (removeInfo: any) => {
    const e = removeInfo.event;
    await supabase.from('events').delete().eq('id', e.id);
  }, []);

  // 初期ロード（ログイン済みを仮定）
  useEffect(() => { fetchEvents(); }, [fetchEvents]);

  const fcEvents = useMemo(() => (
    events.map(e => ({
      id: e.id,
      title: e.title,
      start: e.start,
      end: e.end ?? undefined,
      allDay: e.all_day ?? false,
      color: e.color ?? undefined,
    }))
  ), [events]);

  return (
    <div style={{ padding: 16 }}>
      <h1 style={{ fontWeight: 700, marginBottom: 12 }}>カレンダー</h1>
      <FullCalendar
        height="auto"
        plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin]}
        initialView="dayGridMonth"
        headerToolbar={{
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek',
        }}
        selectable
        selectMirror
        editable
        eventResizableFromStart
        events={fcEvents}
        datesSet={handleDatesSet}
        select={handleSelect}
        eventChange={handleEventChange}
        eventRemove={handleEventRemove}
        nowIndicator
        firstDay={1}
        slotMinTime="06:00:00"
        slotMaxTime="22:00:00"
        locale="ja"
      />
    </div>
  );
}
```

> ルーティングが無ければ `src/App.tsx` にこのコンポーネントを配置してください。

---

## 7. 認証（最小）
- すでにアプリで Supabase Auth を運用している前提。未導入なら `supabase.auth.signInWithOtp` などでログイン UI を別途用意。
- `events.owner_user_id` は **DB側で `default auth.uid()`** を付与しているため、Insert 時に明示不要。RLS により他人の行は操作不可。

---

## 8. よくある落とし穴
- **CSSの未読込** → FullCalendarの表示が崩れる。必ずCSS importを追加。
- **タイムゾーン** → DBはUTC、クライアントはローカル表示（ISO文字列でOK）。
- **RLSでinsert失敗** → ログインしていない／JWTが無いと `auth.uid()` がNULLになり失敗。まず `supabase.auth.getUser()` でユーザーを確認。

---

## 9. 追加オプション
- **色/タグ**：`color` 列をUIから編集。カテゴリは `event_tags` 中間テーブルで拡張可。
- **繰り返し予定**：初期は複製生成で対応→RRULE採用に発展。
- **多トラック表示**：`@fullcalendar/resource-timegrid` を追加（別パッケージ）。
- **通知/Webhooks**：Supabase Edge Functions か外部ジョブから送信。

---

## 10. 動作確認
1) ログイン後に `/calendar`（または配置先ルート）へアクセス  
2) 空き枠ドラッグで作成 → 画面反映  
3) ドラッグ/リサイズで更新 → 画面反映  
4) 再読込でもデータが出る（DB保存）ことを確認
