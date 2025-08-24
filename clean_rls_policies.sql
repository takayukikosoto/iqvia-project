-- SIMPLIFIED RLS POLICIES - 8 Role System
-- Replace complex has_permission() functions with simple role level checks

-- Helper function: Get user role level from JWT
CREATE OR REPLACE FUNCTION get_user_role_level()
RETURNS INTEGER AS $$
BEGIN
  RETURN CASE COALESCE((auth.jwt() ->> 'app_metadata')::json ->> 'role', 'viewer')
    WHEN 'admin' THEN 8
    WHEN 'organizer' THEN 7
    WHEN 'sponsor' THEN 6
    WHEN 'agency' THEN 5
    WHEN 'production' THEN 4
    WHEN 'secretariat' THEN 3
    WHEN 'staff' THEN 2
    ELSE 1 -- viewer
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop all existing complex policies
DO $$ 
BEGIN
  -- Organizations
  DROP POLICY IF EXISTS "organizations_read" ON organizations;
  DROP POLICY IF EXISTS "organizations_create" ON organizations;
  DROP POLICY IF EXISTS "organizations_update" ON organizations;
  DROP POLICY IF EXISTS "organizations_delete" ON organizations;
  
  -- Projects  
  DROP POLICY IF EXISTS "projects_read" ON projects;
  DROP POLICY IF EXISTS "projects_create" ON projects;
  DROP POLICY IF EXISTS "projects_update" ON projects;
  DROP POLICY IF EXISTS "projects_delete" ON projects;
  
  -- Tasks
  DROP POLICY IF EXISTS "tasks_read" ON tasks;
  DROP POLICY IF EXISTS "tasks_create" ON tasks;
  DROP POLICY IF EXISTS "tasks_update" ON tasks;
  DROP POLICY IF EXISTS "tasks_delete" ON tasks;
  DROP POLICY IF EXISTS "Users can create tasks" ON tasks;
  DROP POLICY IF EXISTS "Users can delete tasks" ON tasks;
  
  -- Events
  DROP POLICY IF EXISTS "events_read" ON events;
  DROP POLICY IF EXISTS "events_create" ON events;
  DROP POLICY IF EXISTS "events_update" ON events;
  DROP POLICY IF EXISTS "events_delete" ON events;
  DROP POLICY IF EXISTS "events_read_own" ON events;
  DROP POLICY IF EXISTS "events_insert_own" ON events;
  DROP POLICY IF EXISTS "events_delete_own" ON events;
  
  -- Files
  DROP POLICY IF EXISTS "Enable read access for project members" ON files;
  DROP POLICY IF EXISTS "Enable insert for project members" ON files;
  DROP POLICY IF EXISTS "Enable update for project members" ON files;
  DROP POLICY IF EXISTS "Enable delete for project members" ON files;
  
  -- Comments
  DROP POLICY IF EXISTS "Users can create comments" ON comments;
  DROP POLICY IF EXISTS "Comment authors can update their comments" ON comments;
  
  -- Profiles
  DROP POLICY IF EXISTS "profiles_read" ON profiles;
  DROP POLICY IF EXISTS "profiles_update" ON profiles;
  
EXCEPTION WHEN undefined_object THEN
  -- Ignore if policies don't exist
  NULL;
END $$;

-- SIMPLE UNIFIED POLICIES

-- Organizations: Admin/Organizer can manage, others read-only
CREATE POLICY "org_access" ON organizations FOR ALL 
USING (auth.role() = 'authenticated')
WITH CHECK (get_user_role_level() >= 7);

-- Projects: Agency+ can manage, others read-only
CREATE POLICY "project_access" ON projects FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (get_user_role_level() >= 5);

-- Tasks: Staff+ can manage, others read-only
CREATE POLICY "task_access" ON tasks FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (get_user_role_level() >= 2);

-- Events: Secretariat+ can manage, others read-only
CREATE POLICY "event_access" ON events FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (get_user_role_level() >= 3);

-- Files: Staff+ can manage, others read-only
CREATE POLICY "file_access" ON files FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (get_user_role_level() >= 2);

-- Profiles: Users can manage own profile, admin can manage all
CREATE POLICY "profile_access" ON profiles FOR ALL
USING (auth.uid() = user_id OR get_user_role_level() >= 8)
WITH CHECK (auth.uid() = user_id OR get_user_role_level() >= 8);

-- Comments: All authenticated can read/create, authors can modify
CREATE POLICY "comment_read_create" ON comments FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "comment_insert" ON comments FOR INSERT
WITH CHECK (auth.role() = 'authenticated' AND created_by = auth.uid());

CREATE POLICY "comment_modify" ON comments FOR UPDATE
USING (created_by = auth.uid() OR get_user_role_level() >= 8);

CREATE POLICY "comment_delete" ON comments FOR DELETE
USING (created_by = auth.uid() OR get_user_role_level() >= 8);

-- Chat Messages: Project members can access
CREATE POLICY "chat_access" ON chat_messages FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.uid() = user_id);

-- Notifications: Users can access own notifications
CREATE POLICY "notification_access" ON notifications FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
