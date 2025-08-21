export interface EventDTO {
  id: string;
  title: string;
  start: string;
  end?: string | null;
  allDay?: boolean;
  color?: string | null;
  description?: string | null;
  location?: string | null;
}
