"use client";

import dynamic from "next/dynamic";
import { useCallback, useState } from "react";
import { formatISO } from "date-fns";
import type { EventDTO } from "@/types/event";

const FullCalendar: any = dynamic(() => import("@fullcalendar/react"), { ssr: false });
import dayGridPlugin from "@fullcalendar/daygrid";
import timeGridPlugin from "@fullcalendar/timegrid";
import interactionPlugin from "@fullcalendar/interaction";
import listPlugin from "@fullcalendar/list";

export default function CalendarClient() {
  const [events, setEvents] = useState<EventDTO[]>([]);

  const fetchEvents = useCallback(async (start: Date, end: Date) => {
    const url = `/api/events?from=${encodeURIComponent(start.toISOString())}&to=${encodeURIComponent(end.toISOString())}`;
    const res = await fetch(url, { cache: "no-store" });
    const data = await res.json();
    setEvents(data ?? []);
  }, []);

  const handleDatesSet = useCallback((arg: any) => {
    fetchEvents(arg.start, arg.end);
  }, [fetchEvents]);

  const handleSelect = useCallback(async (arg: any) => {
    const title = window.prompt("タイトル?");
    if (!title) return;
    const payload = {
      title,
      start: arg.startStr,
      end: arg.endStr,
      allDay: arg.allDay
    };
    const res = await fetch("/api/events", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    if (res.ok) {
      const created = await res.json();
      setEvents((prev) => [...prev, created]);
    }
  }, []);

  const handleEventChange = useCallback(async (changeInfo: any) => {
    const e = changeInfo.event;
    const payload = {
      title: e.title,
      start: e.start ? formatISO(e.start) : null,
      end: e.end ? formatISO(e.end) : null,
      allDay: e.allDay
    };
    await fetch(`/api/events/${e.id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
  }, []);

  const handleEventRemove = useCallback(async (removeInfo: any) => {
    const e = removeInfo.event;
    await fetch(`/api/events/${e.id}`, { method: "DELETE" });
  }, []);

  return (
    <FullCalendar
      height="auto"
      plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin]}
      initialView="dayGridMonth"
      headerToolbar={{
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay,listWeek"
      }}
      selectable
      selectMirror
      editable
      eventResizableFromStart
      events={events.map((e) => ({
        id: e.id,
        title: e.title,
        start: e.start,
        end: e.end ?? undefined,
        allDay: e.allDay,
        color: e.color ?? undefined
      }))}
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
  );
}
