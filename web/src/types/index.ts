export type Task = {
  id: string
  title: string
  description?: string
  status: 'todo' | 'review' | 'done' | 'resolved'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  due_at?: string
  project_id: string
  created_by?: string
  created_at: string
  updated_at?: string
}

export type TaskPriority = Task['priority']
export type TaskStatus = Task['status']

export type CustomStatus = {
  id: string
  project_id: string
  name: string
  label: string
  color: string
  order_index: number
  is_active: boolean
  created_by?: string
  created_at: string
  updated_by?: string
  updated_at?: string
}

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

export type TaskLink = {
  id: string
  task_id: string
  title: string
  url: string
  link_type: 'url' | 'file' | 'storage'
  description?: string
  file_id?: string
  storage_provider?: string
  storage_key?: string
  created_at: string
  created_by?: string
  updated_at?: string
  updated_by?: string
}
