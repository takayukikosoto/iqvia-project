-- Check if messages are actually in the database
SELECT 
  id, 
  user_id, 
  project_id, 
  content, 
  created_at 
FROM chat_messages 
ORDER BY created_at DESC 
LIMIT 10;

-- Check RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'chat_messages';

-- Check if there are any policies still active
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'chat_messages';

-- Check project exists
SELECT id, name FROM projects WHERE id = '22222222-2222-2222-2222-222222222222';
