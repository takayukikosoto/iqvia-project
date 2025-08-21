import { NextResponse } from "next/server";
import { createSupabaseServer } from "@/lib/supabase/server";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const from = searchParams.get("from");
  const to = searchParams.get("to");

  const supabase = await createSupabaseServer();
  const { data: { user }, error: userErr } = await supabase.auth.getUser();
  if (userErr || !user) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  let query = supabase.from("events").select("*").eq("owner_user_id", user.id);
  if (from) query = query.gte("start", from);
  if (to)   query = query.lte("start", to);

  const { data, error } = await query.order("start", { ascending: true });
  if (error) return NextResponse.json({ error: error.message }, { status: 400 });
  return NextResponse.json(data);
}

export async function POST(req: Request) {
  const supabase = await createSupabaseServer();
  const { data: { user }, error: userErr } = await supabase.auth.getUser();
  if (userErr || !user) return NextResponse.json({ error: "unauthorized" }, { status: 401 });

  const body = await req.json();
  const payload = {
    title: body.title,
    description: body.description ?? null,
    start: body.start,
    end: body.end ?? null,
    all_day: !!body.allDay,
    color: body.color ?? null,
    location: body.location ?? null,
    owner_user_id: user.id
  };

  const { data, error } = await supabase.from("events").insert(payload).select().single();
  if (error) return NextResponse.json({ error: error.message }, { status: 400 });
  return NextResponse.json(data);
}
