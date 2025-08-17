-- Chat messages RLS policy fix - 簡潔なポリシーに変更

-- 既存のinsertポリシーを削除
DROP POLICY IF EXISTS "Users can insert project chat messages" ON public.chat_messages;

-- 新しいinsertポリシーを作成（シンプルな形式）
CREATE POLICY "Users can insert project chat messages" ON public.chat_messages
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
  );

-- selectポリシーも確認・修正
DROP POLICY IF EXISTS "Users can view project chat messages" ON public.chat_messages;

CREATE POLICY "Users can view project chat messages" ON public.chat_messages
  FOR SELECT USING (
    user_id = auth.uid() OR
    project_id IN (
      SELECT pm.project_id 
      FROM public.project_memberships pm 
      WHERE pm.user_id = auth.uid()
    )
  );
