-- Create chat system tables and views

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_chat_messages_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Create updated_at trigger for chat_messages
CREATE TRIGGER chat_messages_updated_at
    BEFORE UPDATE ON chat_messages
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Enable RLS on chat_messages
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for chat_messages
CREATE POLICY "chat_messages_select_authenticated" ON chat_messages 
FOR SELECT TO authenticated USING (true);

CREATE POLICY "chat_messages_insert_own" ON chat_messages 
FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "chat_messages_update_own" ON chat_messages 
FOR UPDATE TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "chat_messages_delete_own" ON chat_messages 
FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Create chat_messages_with_profiles view
CREATE OR REPLACE VIEW chat_messages_with_profiles AS
SELECT 
    cm.id,
    cm.project_id,
    cm.user_id,
    cm.content,
    cm.created_at,
    cm.updated_at,
    p.display_name,
    p.company
FROM chat_messages cm
LEFT JOIN profiles p ON cm.user_id = p.user_id;

-- Grant permissions on view
GRANT SELECT ON chat_messages_with_profiles TO authenticated;
GRANT SELECT ON chat_messages_with_profiles TO anon;
