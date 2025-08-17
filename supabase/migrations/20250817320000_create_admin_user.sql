-- Delete existing admin@test.com user if exists
DELETE FROM auth.users WHERE email = 'admin@test.com';

-- Create admin@test.com user
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role
) VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'admin@test.com',
  crypt('password123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  false,
  'authenticated'
);

-- Add admin user to organization if not exists
INSERT INTO organization_memberships (
  user_id,
  org_id,
  role,
  created_at
) VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '11111111-1111-1111-1111-111111111111',
  'admin',
  now()
) ON CONFLICT (org_id, user_id) DO NOTHING;

-- Add admin user to project as project_manager if not exists
INSERT INTO project_memberships (
  user_id,
  project_id,
  role,
  created_at
) VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '22222222-2222-2222-2222-222222222222',
  'project_manager',
  now()
) ON CONFLICT (project_id, user_id) DO NOTHING;
