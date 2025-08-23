-- Check tasks and their storage_folder values
SELECT 
  id, 
  title, 
  storage_folder,
  project_id,
  created_at
FROM tasks 
ORDER BY created_at DESC 
LIMIT 10;
