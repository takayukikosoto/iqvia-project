-- Add sample organization and project for testing  
INSERT INTO organizations (id, name, created_at) VALUES 
('440e8400-e29b-41d4-a716-446655440000', 'サンプル組織', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO projects (id, organization_id, name, created_at) VALUES 
('550e8400-e29b-41d4-a716-446655440000', '440e8400-e29b-41d4-a716-446655440000', 'サンプルプロジェクト', NOW())
ON CONFLICT (id) DO NOTHING;

-- Add sample tasks
INSERT INTO tasks (id, title, description, status, priority, project_id, storage_folder, created_at) VALUES 
('660e8400-e29b-41d4-a716-446655440001', 'タスク1：要件定義', 'プロジェクトの要件を定義する', 'todo', 'high', '550e8400-e29b-41d4-a716-446655440000', 'task_660e8400-e29b-41d4-a716-446655440001', NOW()),
('660e8400-e29b-41d4-a716-446655440002', 'タスク2：設計書作成', 'システム設計書を作成する', 'review', 'medium', '550e8400-e29b-41d4-a716-446655440000', 'task_660e8400-e29b-41d4-a716-446655440002', NOW()),
('660e8400-e29b-41d4-a716-446655440003', 'タスク3：実装', 'フロントエンド実装を行う', 'done', 'urgent', '550e8400-e29b-41d4-a716-446655440000', 'task_660e8400-e29b-41d4-a716-446655440003', NOW())
ON CONFLICT (id) DO NOTHING;
