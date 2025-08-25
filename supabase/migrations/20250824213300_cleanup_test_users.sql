-- Remove all test users and fix authentication system to work properly

-- Delete test users from profiles first (due to foreign key)
DELETE FROM profiles WHERE user_id IN (
    '6fd817e5-d68c-4dc2-b65e-e5aaf23f76fa',
    '100de6b2-1b82-4611-92b3-0771fbb56dae'
);

-- Delete test users from auth.users
DELETE FROM auth.users WHERE id IN (
    '6fd817e5-d68c-4dc2-b65e-e5aaf23f76fa',
    '100de6b2-1b82-4611-92b3-0771fbb56dae'
);

-- Make profiles.user_id foreign key constraint more flexible
-- to handle real user registration flow
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_user_id_fkey;
ALTER TABLE profiles ADD CONSTRAINT profiles_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Update RLS policies for profiles to work with real authentication
DROP POLICY IF EXISTS profiles_select_policy ON profiles;
DROP POLICY IF EXISTS profiles_insert_policy ON profiles;
DROP POLICY IF EXISTS profiles_update_policy ON profiles;
DROP POLICY IF EXISTS profiles_delete_policy ON profiles;

-- Create proper RLS policies for profiles
CREATE POLICY profiles_select_policy ON profiles
    FOR SELECT USING (
        auth.uid() = user_id OR
        -- Allow viewing other profiles for project collaboration
        EXISTS (
            SELECT 1 FROM project_memberships pm1, project_memberships pm2
            WHERE pm1.user_id = auth.uid() 
            AND pm2.user_id = profiles.user_id
            AND pm1.project_id = pm2.project_id
        )
    );

CREATE POLICY profiles_insert_policy ON profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY profiles_update_policy ON profiles
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY profiles_delete_policy ON profiles
    FOR DELETE USING (auth.uid() = user_id);

-- Create function to handle new user profile creation
CREATE OR REPLACE FUNCTION handle_new_user() 
RETURNS trigger AS $$
BEGIN
    INSERT INTO profiles (user_id, display_name, company, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email),
        COALESCE(NEW.raw_user_meta_data->>'company', ''),
        NOW(),
        NOW()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic profile creation on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
