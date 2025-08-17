-- 強制的にchat_messagesのRLSを完全に無効化

-- すべてのポリシーを強制削除
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' AND tablename = 'chat_messages'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', pol.policyname, pol.schemaname, pol.tablename);
    END LOOP;
END $$;

-- RLS完全無効化
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;

-- 外部キー制約も完全削除
ALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_user_id_fkey;
ALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_project_id_fkey;

-- テーブルの権限設定
GRANT ALL ON public.chat_messages TO anon;
GRANT ALL ON public.chat_messages TO authenticated;
