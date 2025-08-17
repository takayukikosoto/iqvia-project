-- mentionsテーブルからchat_messagesへの依存を削除してチャット機能をシンプル化

-- mentionsテーブルの外部キー制約を削除
ALTER TABLE public.mentions 
DROP CONSTRAINT IF EXISTS mentions_message_id_fkey;

-- chat_messagesテーブルを削除して再作成
DROP TABLE IF EXISTS public.chat_messages CASCADE;

-- シンプルなchat_messagesテーブルを再作成
CREATE TABLE public.chat_messages (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    content text NOT NULL,
    user_id uuid,
    project_id uuid,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- RLS無効化
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;

-- 権限付与
GRANT ALL ON public.chat_messages TO anon;
GRANT ALL ON public.chat_messages TO authenticated;
GRANT ALL ON public.chat_messages TO service_role;
