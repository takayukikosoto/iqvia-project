import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { supabase } from '../supabaseClient';
import type { EventDTO } from '../types/event';
import { usePersonalTasks, getTaskTypeColor, getPriorityColor } from '../hooks/usePersonalTasks';
import { useAttendance } from '../hooks/useAttendance';
import TaskDetail from './TaskDetail';

interface Task {
  id: string;
  title: string;
  description?: string;
  due_at?: string;
  status: string;
  priority: string;
  project_id: string;
}

// FullCalendar + Plugins
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import listPlugin from '@fullcalendar/list';

// タスクタイプのアイコンを取得するヘルパー関数
function getTaskTypeIcon(taskType: string): string {
  const icons: Record<string, string> = {
    personal: '👤',
    project: '📊', 
    team: '👥',
    company: '🏢'
  }
  return icons[taskType] || '📋'
}

export default function CalendarPage() {
  const [events, setEvents] = useState<EventDTO[]>([]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const { tasks: personalTasks } = usePersonalTasks();
  const { getAttendanceStats } = useAttendance();
  const [isCreatingEvent, setIsCreatingEvent] = useState(false);
  const [showEventModal, setShowEventModal] = useState(false);
  const [eventTitle, setEventTitle] = useState('');
  const [selectedDateInfo, setSelectedDateInfo] = useState<any>(null);
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null);
  const isCreatingEventRef = useRef(false);
  const lastSelectTimeRef = useRef(0);

  const fetchTasks = useCallback(async (fromISO?: string, toISO?: string) => {
    try {
      const user = (await supabase.auth.getUser()).data.user;
      if (!user) return;

      let query = supabase.from('tasks')
        .select('id, title, description, due_at, status, priority, project_id')
        .not('due_at', 'is', null)
        .order('due_at', { ascending: true });

      if (fromISO) query = query.gte('due_at', fromISO);
      if (toISO) query = query.lte('due_at', toISO);

      const { data, error } = await query;
      if (!error && data) {
        setTasks(data as Task[]);
      } else if (error) {
        console.error('Error fetching tasks:', error);
      }
    } catch (err) {
      console.error('Error in fetchTasks:', err);
    }
  }, []);

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
    const startISO = arg.start.toISOString();
    const endISO = arg.end.toISOString();
    fetchEvents(startISO, endISO);
    fetchTasks(startISO, endISO);
  }, [fetchEvents, fetchTasks]);

  const handleSelect = useCallback((arg: any) => {
    const currentTime = Date.now();
    
    // デバウンス: 500ms以内の連続呼び出しを無視
    if (currentTime - lastSelectTimeRef.current < 500) {
      console.log('🚫 Debounced select event, ignoring');
      return;
    }
    
    // useRefで即座にチェック（同期的）
    if (isCreatingEventRef.current) {
      console.log('🚫 Already creating event, ignoring (ref check)');
      return;
    }
    
    lastSelectTimeRef.current = currentTime;
    console.log('📅 Calendar select triggered:', arg);
    
    // 選択をクリアして重複呼び出しを防ぐ
    arg.view.calendar.unselect();
    
    // 選択された日付情報を保存してモーダルを表示
    setSelectedDateInfo(arg);
    setShowEventModal(true);
    setEventTitle('');
  }, []);

  const handleCreateEvent = useCallback(async () => {
    if (!eventTitle.trim() || !selectedDateInfo) {
      return;
    }
    
    setIsCreatingEvent(true);
    isCreatingEventRef.current = true;
    
    try {
      const user = (await supabase.auth.getUser()).data.user;
      if (!user) {
        alert('ログインが必要です。');
        return;
      }

      const payload = {
        title: eventTitle.trim(),
        start: selectedDateInfo.startStr,
        end: selectedDateInfo.endStr,
        all_day: selectedDateInfo.allDay,
        owner_user_id: user.id,
      };
      
      console.log('📤 Creating event with payload:', payload);
      
      const { data, error } = await supabase.from('events').insert(payload).select().single();
      if (!error && data) {
        console.log('✅ Event created successfully:', data);
        setEvents(prev => [...prev, data as EventDTO]);
        setShowEventModal(false);
        setEventTitle('');
        setSelectedDateInfo(null);
      } else if (error) {
        console.error('❌ Error creating event:', error);
        alert(`イベントの作成に失敗しました: ${error.message}`);
      }
    } catch (err) {
      console.error('❌ Error in handleCreateEvent:', err);
      alert('イベントの作成中にエラーが発生しました。');
    } finally {
      isCreatingEventRef.current = false;
      setIsCreatingEvent(false);
    }
  }, [eventTitle, selectedDateInfo]);

  const handleCloseModal = useCallback(() => {
    setShowEventModal(false);
    setEventTitle('');
    setSelectedDateInfo(null);
    setIsCreatingEvent(false);
    isCreatingEventRef.current = false;
  }, []);

  const handleEventClick = useCallback((info: any) => {
    const eventType = info.event.extendedProps?.type;
    
    if (eventType === 'task' || eventType === 'personal_task') {
      // タスクイベントをクリックした場合、タスク詳細画面に遷移
      const taskId = info.event.extendedProps.taskId;
      const isPersonal = eventType === 'personal_task';
      
      // 個人タスクの場合は特別な処理を追加可能
      if (isPersonal) {
        console.log('個人タスクがクリックされました:', info.event.title);
      }
      
      setSelectedTaskId(taskId);
    } else {
      // 通常のイベントをクリックした場合
      console.log('通常のイベントがクリックされました:', info.event);
    }
  }, []);

  const handleEventChange = useCallback(async (changeInfo: any) => {
    const e = changeInfo.event;
    const eventType = e.extendedProps?.type;
    
    try {
      if (eventType === 'task') {
        // タスクイベントの場合: tasksテーブルのdue_atを更新
        const taskId = e.extendedProps.taskId;
        const newDueDate = e.start?.toISOString() ?? null;
        
        const { error } = await supabase
          .from('tasks')
          .update({ due_at: newDueDate })
          .eq('id', taskId);
          
        if (error) {
          console.error('Error updating task due date:', error);
          changeInfo.revert();
          alert('タスクの期日更新に失敗しました。');
        } else {
          console.log(`✅ タスク期日更新成功: ${taskId} → ${newDueDate}`);
          // タスクデータを再取得して同期
          await fetchTasks();
        }
      } else {
        // 通常のイベントの場合: eventsテーブルを更新
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
      }
    } catch (err) {
      console.error('Error in handleEventChange:', err);
      changeInfo.revert();
      alert('イベントの更新中にエラーが発生しました。');
    }
  }, [fetchTasks]);

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
    fetchTasks();
  }, [fetchEvents, fetchTasks]);

  const fcEvents = useMemo(() => {
    // 通常のイベント
    const eventItems = events.map(e => ({
      id: e.id,
      title: e.title,
      start: e.start,
      end: e.end ?? undefined,
      allDay: e.all_day ?? false,
      color: e.color ?? undefined,
      extendedProps: {
        type: 'event'
      }
    }));

    // 個人タスクをイベントとして変換（改善版）
    const personalTaskItems = personalTasks
      .filter(task => task.due_at)
      .map(task => ({
        id: `personal-task-${task.id}`,
        title: `${getTaskTypeIcon(task.task_type)} ${task.title}`,
        start: task.due_at!,
        allDay: true,
        color: getTaskTypeColor(task.task_type),
        borderColor: getPriorityColor(task.priority),
        extendedProps: {
          type: 'personal_task',
          taskId: task.id,
          taskType: task.task_type,
          status: task.status,
          priority: task.priority,
          description: task.description,
          isPersonal: task.task_type === 'personal'
        }
      }));

    // 従来のタスクをイベントとして変換
    const taskItems = tasks.map(task => ({
      id: `task-${task.id}`,
      title: `📋 ${task.title}`,
      start: task.due_at!,
      allDay: true,
      color: task.priority === 'urgent' ? '#dc2626' : 
             task.priority === 'high' ? '#ea580c' :
             task.priority === 'medium' ? '#0891b2' : '#059669',
      extendedProps: {
        type: 'task',
        taskId: task.id,
        status: task.status,
        priority: task.priority,
        description: task.description
      }
    }));

    return [...eventItems, ...personalTaskItems, ...taskItems];
  }, [events, tasks, personalTasks]);

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
        
        {/* タスク種別凡例 */}
        <div className="mt-3 flex flex-wrap gap-4 text-sm">
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 rounded" style={{backgroundColor: getTaskTypeColor('personal')}}></span>
            <span>👤 個人タスク</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 rounded" style={{backgroundColor: getTaskTypeColor('project')}}></span>
            <span>📊 プロジェクトタスク</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 rounded" style={{backgroundColor: getTaskTypeColor('team')}}></span>
            <span>👥 チームタスク</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="w-3 h-3 rounded" style={{backgroundColor: getTaskTypeColor('company')}}></span>
            <span>🏢 全社タスク</span>
          </div>
        </div>
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
          selectable={!isCreatingEvent && !showEventModal}
          selectMirror={false}
          editable
          eventResizableFromStart
          events={fcEvents}
          datesSet={handleDatesSet}
          select={handleSelect}
          eventClick={handleEventClick}
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
          selectOverlap={false}
          unselectAuto={true}
        />
      </div>

      {/* イベント作成モーダル */}
      {showEventModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-96 shadow-xl">
            <h3 className="text-lg font-semibold mb-4">新しいイベントを作成</h3>
            
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                イベントタイトル
              </label>
              <input
                type="text"
                value={eventTitle}
                onChange={(e) => setEventTitle(e.target.value)}
                placeholder="イベントのタイトルを入力..."
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && eventTitle.trim()) {
                    handleCreateEvent();
                  } else if (e.key === 'Escape') {
                    handleCloseModal();
                  }
                }}
              />
            </div>

            {selectedDateInfo && (
              <div className="mb-4 text-sm text-gray-600">
                📅 {selectedDateInfo.allDay ? '終日' : '時間指定'}: {' '}
                {new Date(selectedDateInfo.start).toLocaleDateString('ja-JP')}
                {!selectedDateInfo.allDay && (
                  <>
                    {' '}
                    {new Date(selectedDateInfo.start).toLocaleTimeString('ja-JP', { 
                      hour: '2-digit', 
                      minute: '2-digit' 
                    })}
                    {' - '}
                    {new Date(selectedDateInfo.end).toLocaleTimeString('ja-JP', { 
                      hour: '2-digit', 
                      minute: '2-digit' 
                    })}
                  </>
                )}
              </div>
            )}

            <div className="flex justify-end space-x-3">
              <button
                onClick={handleCloseModal}
                className="px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
                disabled={isCreatingEvent}
              >
                キャンセル
              </button>
              <button
                onClick={handleCreateEvent}
                disabled={!eventTitle.trim() || isCreatingEvent}
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isCreatingEvent ? '作成中...' : '作成'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* タスク詳細画面 */}
      {selectedTaskId && (
        <div className="fixed inset-0 bg-white z-50 overflow-y-auto">
          <TaskDetail
            taskId={selectedTaskId}
            onBack={() => setSelectedTaskId(null)}
          />
        </div>
      )}
    </div>
  );
}
