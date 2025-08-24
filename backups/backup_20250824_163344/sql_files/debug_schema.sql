-- Check current schema
\d projects;
\d tasks;
SELECT COUNT(*) FROM projects;
SELECT COUNT(*) FROM tasks;
SELECT id, title FROM tasks LIMIT 3;
