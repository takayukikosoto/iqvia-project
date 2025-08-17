-- 一時的にchat_messagesの外部キー制約を削除してテスト

-- chat_messagesのuser_id外部キー制約を削除
ALTER TABLE public.chat_messages 
DROP CONSTRAINT IF EXISTS chat_messages_user_id_fkey;

-- project_id外部キー制約も一時的に削除（必要であれば）
ALTER TABLE public.chat_messages 
DROP CONSTRAINT IF EXISTS chat_messages_project_id_fkey;
