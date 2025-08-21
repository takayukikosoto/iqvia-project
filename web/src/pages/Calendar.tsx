import { useCallback, useEffect, useMemo, useState } from 'react';
import { supabase } from '../supabaseClient';
import type { EventDTO } from '../types/event';

// FullCalendar + Plugins
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import listPlugin from '@fullcalendar/list';


export default function CalendarPage() {
  const [events, setEvents] = useState<EventDTO[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchEvents = useCallback(async (fromISO?: string, toISO?: string) => {
    try {
      const user = (await supabase.auth.getUser()).data.user;
      if (!user) {
        setLoading(false);
        return;
      }

      let query = supabase.from('events')
        .select('*')
        .eq('owner_user_id', user.id)
        .order('start', { ascending: true });

      if (fromISO) query = query.gte('start', fromISO);
      if (toISO)   query = query.lte('start', toISO);

      const { data, error } = await query;
      if (!error && data) {
        setEvents(data as EventDTO[]);
      } else if (error) {
        console.error('Error fetching events:', error);
      }
    } catch (err) {
      console.error('Error in fetchEvents:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const handleDatesSet = useCallback((arg: any) => {
    // 画面に映る範囲のデータを取得
    fetchEvents(arg.start.toISOString(), arg.end.toISOString());
  }, [fetchEvents]);

  const handleSelect = useCallback(async (arg: any) => {
    const title = window.prompt('イベントのタイトルを入力してください:');
    if (!title) return;
    
    try {
      const payload = {
        title,
        start: arg.startStr,
        end: arg.endStr,
        all_day: arg.allDay,
      };
      
      const { data, error } = await supabase.from('events').insert(payload).select().single();
      if (!error && data) {
        setEvents(prev => [...prev, data as EventDTO]);
      } else if (error) {
        console.error('Error creating event:', error);
        alert('イベントの作成に失敗しました。');
      }
    } catch (err) {
      console.error('Error in handleSelect:', err);
      alert('イベントの作成中にエラーが発生しました。');
    }
  }, []);

  const handleEventChange = useCallback(async (changeInfo: any) => {
    const e = changeInfo.event;
    try {
      const updates = {
        title: e.title,
        start: e.start?.toISOString() ?? null,
        end: e.end?.toISOString() ?? null,
        all_day: e.allDay,
      };
      
      const { error } = await supabase.from('events').update(updates).eq('id', e.id);
      if (error) {
        console.error('Error updating event:', error);
        changeInfo.revert();
        alert('イベントの更新に失敗しました。');
      }
    } catch (err) {
      console.error('Error in handleEventChange:', err);
      changeInfo.revert();
      alert('イベントの更新中にエラーが発生しました。');
    }
  }, []);

  const handleEventRemove = useCallback(async (removeInfo: any) => {
    const e = removeInfo.event;
    if (!window.confirm(`イベント「${e.title}」を削除しますか？`)) {
      return;
    }
    
    try {
      const { error } = await supabase.from('events').delete().eq('id', e.id);
      if (!error) {
        setEvents(prev => prev.filter(event => event.id !== e.id));
      } else {
        console.error('Error deleting event:', error);
        alert('イベントの削除に失敗しました。');
      }
    } catch (err) {
      console.error('Error in handleEventRemove:', err);
      alert('イベントの削除中にエラーが発生しました。');
    }
  }, []);

  // 初期ロード（ログイン済みを仮定）
  useEffect(() => { 
    fetchEvents(); 
  }, [fetchEvents]);

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

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">カレンダー</h1>
        <p className="text-gray-600 mt-2">空いている時間帯をドラッグしてイベントを作成できます</p>
      </div>
      
      <div className="bg-white rounded-lg shadow-sm border">
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
          eventDisplay="block"
          dayMaxEvents={3}
          moreLinkClick="popover"
        />
      </div>
    </div>
  );
}
