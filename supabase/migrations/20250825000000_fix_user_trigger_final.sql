-- Ensure handle_new_user trigger and function are properly configured

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Recreate the handle_new_user function with proper security settings
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    -- Insert profile with bypassing RLS by using SECURITY DEFINER
    INSERT INTO public.profiles (user_id, display_name, company, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'company', ''),
        NOW(),
        NOW()
    );
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail user creation
        RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Ensure profiles table has proper RLS policies
DROP POLICY IF EXISTS profiles_auth_insert ON public.profiles;
DROP POLICY IF EXISTS profiles_user_select ON public.profiles;  
DROP POLICY IF EXISTS profiles_user_update ON public.profiles;

-- Create permissive RLS policies for profiles
CREATE POLICY profiles_auth_insert 
ON public.profiles FOR INSERT 
WITH CHECK (true);

CREATE POLICY profiles_user_select 
ON public.profiles FOR SELECT 
USING (auth.uid() = user_id OR auth.uid() IS NULL);

CREATE POLICY profiles_user_update 
ON public.profiles FOR UPDATE 
USING (auth.uid() = user_id);

-- Ensure RLS is enabled on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
