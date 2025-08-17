-- Chat RLS policy を完全に削除して再作成

-- 全てのchat_messagesのRLSポリシーを削除
DROP POLICY IF EXISTS "Users can insert project chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can view project chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can select project chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_messages_insert_policy" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_messages_select_policy" ON public.chat_messages;

-- 最もシンプルなポリシーで再作成
CREATE POLICY "chat_insert_simple" ON public.chat_messages
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "chat_select_simple" ON public.chat_messages
  FOR SELECT USING (true);
