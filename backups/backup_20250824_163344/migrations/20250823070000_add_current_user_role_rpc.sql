-- Add RPC function to get current user with role information

CREATE OR REPLACE FUNCTION public.get_current_user_with_role()
RETURNS TABLE(
  user_id UUID,
  email TEXT,
  role_name TEXT,
  role_level INTEGER,
  role_display_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id as user_id,
    u.email,
    COALESCE(u.role, 'viewer') as role_name,
    COALESCE(rd.role_level, 1) as role_level,
    COALESCE(rd.display_name, 'ビュワー権限') as role_display_name
  FROM auth.users u
  LEFT JOIN public.role_definitions rd ON u.role = rd.role_name
  WHERE u.id = auth.uid()
  LIMIT 1;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_current_user_with_role() TO authenticated;
