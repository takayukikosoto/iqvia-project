-- Fix missing user_activities table and personal_todos week_start column

-- Create user_activities table
CREATE TABLE IF NOT EXISTS user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add week_start column to personal_todos if it doesn't exist
ALTER TABLE personal_todos 
    ADD COLUMN IF NOT EXISTS week_start DATE;

-- Create index on user_activities for performance
CREATE INDEX IF NOT EXISTS idx_user_activities_user_id_created_at 
    ON user_activities(user_id, created_at DESC);

-- Enable RLS for user_activities
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;

-- RLS policy for user_activities - users can only see their own activities
CREATE POLICY user_activities_select_policy ON user_activities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY user_activities_insert_policy ON user_activities
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY user_activities_update_policy ON user_activities
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY user_activities_delete_policy ON user_activities
    FOR DELETE USING (auth.uid() = user_id);

-- Update trigger for user_activities
CREATE OR REPLACE FUNCTION update_user_activities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_activities_updated_at
    BEFORE UPDATE ON user_activities
    FOR EACH ROW
    EXECUTE FUNCTION update_user_activities_updated_at();
