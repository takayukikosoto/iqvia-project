-- データベースのテーブル構造とデータを確認
SELECT 'Projects table structure:' as info;
\d projects;

SELECT 'Tasks table structure:' as info;
\d tasks;

SELECT 'Projects data:' as info;
SELECT * FROM projects LIMIT 3;

SELECT 'Tasks data:' as info;
SELECT * FROM tasks LIMIT 5;

SELECT 'Task count by project:' as info;
SELECT project_id, COUNT(*) as task_count FROM tasks GROUP BY project_id;
