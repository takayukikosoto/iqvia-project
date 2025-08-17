-- 一時的にchat_messagesのRLSを無効化してテスト

-- 既存のポリシーを全て削除
DROP POLICY IF EXISTS "Users can insert project chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can view project chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_insert_simple" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_select_simple" ON public.chat_messages;

-- RLS自体を無効化
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;
