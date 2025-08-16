export type Task = {
  id: string
  title: string
  description?: string
  status: 'todo' | 'doing' | 'review' | 'done' | 'blocked'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  due_at?: string
  project_id: string
  created_by?: string
  created_at: string
  updated_at?: string
}

export type TaskPriority = Task['priority']
export type TaskStatus = Task['status']

export type Project = {
  id: string
  name: string
  org_id: string
}

export type User = {
  id: string
  email?: string
  created_at: string
}

export type Profile = {
  user_id: string
  display_name?: string
  company?: string
  created_at: string
  updated_at?: string
}
