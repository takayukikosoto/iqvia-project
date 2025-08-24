-- User Management RPC Functions for 8-Role Permission System

-- 1. Get all users with their role information (admin only)
CREATE OR REPLACE FUNCTION public.get_all_users_with_roles()
RETURNS TABLE(
  user_id UUID,
  email TEXT,
  role_name TEXT,
  role_level INTEGER,
  role_display_name TEXT,
  created_at TIMESTAMPTZ,
  last_sign_in_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if current user is admin
  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    u.id as user_id,
    u.email,
    COALESCE(u.role, 'viewer') as role_name,
    COALESCE(rd.role_level, 1) as role_level,
    COALESCE(rd.display_name, 'ビュワー権限') as role_display_name,
    u.created_at,
    u.last_sign_in_at
  FROM auth.users u
  LEFT JOIN public.role_definitions rd ON u.role = rd.role_name
  WHERE u.aud = 'authenticated'
  ORDER BY u.created_at DESC;
END;
$$;

-- 2. Update user role (admin only)
CREATE OR REPLACE FUNCTION public.update_user_role(
  target_user_id UUID,
  new_role_name TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if current user is admin
  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  -- Validate role exists
  IF NOT EXISTS (SELECT 1 FROM public.role_definitions WHERE role_name = new_role_name AND is_active = true) THEN
    RAISE EXCEPTION 'Invalid role: %', new_role_name;
  END IF;

  -- Prevent removing admin role from the last admin
  IF (SELECT role FROM auth.users WHERE id = target_user_id) = 'admin' 
     AND new_role_name != 'admin' 
     AND (SELECT COUNT(*) FROM auth.users WHERE role = 'admin') <= 1 THEN
    RAISE EXCEPTION 'Cannot remove admin role from the last admin user';
  END IF;

  -- Update user role
  UPDATE auth.users 
  SET 
    role = new_role_name,
    updated_at = NOW()
  WHERE id = target_user_id;

  -- Log the role change (if you want to track changes)
  INSERT INTO public.role_change_history (user_id, old_role, new_role, changed_by, changed_at)
  VALUES (
    target_user_id, 
    (SELECT role FROM auth.users WHERE id = target_user_id),
    new_role_name,
    auth.uid(),
    NOW()
  ) ON CONFLICT DO NOTHING;
END;
$$;

-- 3. Get user role history (admin only)
CREATE OR REPLACE FUNCTION public.get_user_role_history(target_user_id UUID)
RETURNS TABLE(
  old_role TEXT,
  new_role TEXT,
  changed_by_email TEXT,
  changed_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if current user is admin
  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    rch.old_role,
    rch.new_role,
    u.email as changed_by_email,
    rch.changed_at
  FROM public.role_change_history rch
  LEFT JOIN auth.users u ON rch.changed_by = u.id
  WHERE rch.user_id = target_user_id
  ORDER BY rch.changed_at DESC;
END;
$$;

-- 4. Create role change history table
CREATE TABLE IF NOT EXISTS public.role_change_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  old_role TEXT,
  new_role TEXT NOT NULL,
  changed_by UUID,
  changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Bulk update user roles (admin only)
CREATE OR REPLACE FUNCTION public.bulk_update_user_roles(
  user_role_updates JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  update_item JSONB;
BEGIN
  -- Check if current user is admin
  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  -- Process each update
  FOR update_item IN SELECT * FROM jsonb_array_elements(user_role_updates)
  LOOP
    PERFORM public.update_user_role(
      (update_item->>'user_id')::UUID,
      update_item->>'role_name'
    );
  END LOOP;
END;
$$;

-- 6. Get role statistics (admin only)
CREATE OR REPLACE FUNCTION public.get_role_statistics()
RETURNS TABLE(
  role_name TEXT,
  role_display_name TEXT,
  role_level INTEGER,
  user_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if current user is admin
  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;

  RETURN QUERY
  SELECT 
    rd.role_name,
    rd.display_name as role_display_name,
    rd.role_level,
    COUNT(u.id) as user_count
  FROM public.role_definitions rd
  LEFT JOIN auth.users u ON rd.role_name = u.role
  WHERE rd.is_active = true
  GROUP BY rd.role_name, rd.display_name, rd.role_level
  ORDER BY rd.role_level DESC;
END;
$$;

-- Grant execute permissions to authenticated users (RLS will handle admin check)
GRANT EXECUTE ON FUNCTION public.get_all_users_with_roles() TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_user_role(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_role_history(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.bulk_update_user_roles(JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_role_statistics() TO authenticated;

-- Enable RLS on role_change_history
ALTER TABLE public.role_change_history ENABLE ROW LEVEL SECURITY;

-- Admin can manage all role history
CREATE POLICY "role_history_admin_all" ON public.role_change_history
  FOR ALL USING (
    (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin'
  );
