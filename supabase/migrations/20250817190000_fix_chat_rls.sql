-- Chat messages RLS policy fix
-- insertポリシーにプロジェクトメンバーシップのチェックを追加

-- 既存のinsertポリシーを削除
DROP POLICY IF EXISTS "Users can insert project chat messages" ON public.chat_messages;

-- 新しいinsertポリシーを作成（プロジェクトメンバーシップをチェック）
CREATE POLICY "Users can insert project chat messages" ON public.chat_messages
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.project_memberships pm
      WHERE pm.project_id = chat_messages.project_id
      AND pm.user_id = auth.uid()
    )
  );
