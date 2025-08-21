export const dynamic = "force-dynamic";

import CalendarClient from "./CalendarClient";

export default async function CalendarPage() {
  return (
    <div className="container mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">カレンダー</h1>
      <CalendarClient />
    </div>
  );
}
