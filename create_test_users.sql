-- Create test users for authentication
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES 
(
  '00000000-0000-0000-0000-000000000000',
  '550e8400-e29b-41d4-a716-446655440001',
  'authenticated',
  'authenticated',
  'a@a.com',
  crypt('password', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"role": "admin"}',
  '{}',
  '',
  '',
  '',
  ''
),
(
  '00000000-0000-0000-0000-000000000000',
  '550e8400-e29b-41d4-a716-446655440002',
  'authenticated',
  'authenticated',
  'b@b.com',
  crypt('password', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"role": "manager"}',
  '{}',
  '',
  '',
  '',
  ''
)
ON CONFLICT (id) DO UPDATE SET
  encrypted_password = EXCLUDED.encrypted_password,
  raw_app_meta_data = EXCLUDED.raw_app_meta_data,
  email_confirmed_at = now(),
  updated_at = now();

-- Create corresponding profiles
INSERT INTO profiles (user_id, display_name, company, created_at, updated_at)
VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'Admin User', 'IQVIA', now(), now()),
('550e8400-e29b-41d4-a716-446655440002', 'Manager User', 'JTB', now(), now())
ON CONFLICT (user_id) DO UPDATE SET
  updated_at = now();
