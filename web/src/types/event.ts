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
