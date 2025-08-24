-- メンション機能: mentions テーブルとトリガー作成
-- Created: 2025-08-17

-- mentions テーブル (メンション履歴)
CREATE TABLE IF NOT EXISTS mentions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,
    mentioned_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    mentioned_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    mention_text TEXT NOT NULL, -- @username の形式
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(message_id, mentioned_user_id)
);

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_mentions_mentioned_user_id ON mentions(mentioned_user_id);
CREATE INDEX IF NOT EXISTS idx_mentions_project_id ON mentions(project_id);
CREATE INDEX IF NOT EXISTS idx_mentions_read_at ON mentions(read_at);
CREATE INDEX IF NOT EXISTS idx_mentions_created_at ON mentions(created_at);

-- RLS (Row Level Security) 有効化
ALTER TABLE mentions ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: mentions
-- メンションされたユーザーのみ自分のメンションを閲覧可能
CREATE POLICY "Users can read their own mentions" ON mentions
    FOR SELECT USING (
        mentioned_user_id = auth.uid()
    );

-- プロジェクトメンバーのみメンション作成可能
CREATE POLICY "Project members can create mentions" ON mentions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM project_memberships pm 
            WHERE pm.project_id = mentions.project_id 
            AND pm.user_id = auth.uid()
        )
        AND mentioned_by_user_id = auth.uid()
    );

-- メンションされたユーザーのみ自分のメンション更新可能（既読状態更新）
CREATE POLICY "Users can update their own mentions" ON mentions
    FOR UPDATE USING (
        mentioned_user_id = auth.uid()
    );

-- メンション作成者のみ削除可能
CREATE POLICY "Mention creators can delete mentions" ON mentions
    FOR DELETE USING (
        mentioned_by_user_id = auth.uid()
    );

-- メンション検出・作成用の関数
CREATE OR REPLACE FUNCTION extract_mentions_from_message()
RETURNS TRIGGER AS $$
DECLARE
    mention_regex TEXT := '@([a-zA-Z0-9._-]+)';
    mention_match TEXT;
    mentioned_user_record RECORD;
    user_email TEXT;
BEGIN
    -- メッセージからメンション（@username）を抽出
    FOR mention_match IN 
        SELECT unnest(regexp_split_to_array(NEW.content, '\s+'))
        WHERE unnest(regexp_split_to_array(NEW.content, '\s+')) ~ mention_regex
    LOOP
        -- @を除去してユーザー名を取得
        user_email := substring(mention_match from 2);
        
        -- ユーザーが存在するかチェック（emailで検索）
        SELECT au.id, p.display_name 
        INTO mentioned_user_record
        FROM auth.users au
        LEFT JOIN profiles p ON p.user_id = au.id
        WHERE au.email = user_email || '@example.com' -- 仮のドメイン追加
           OR au.email = user_email
           OR p.display_name = user_email;
           
        -- ユーザーが見つかり、プロジェクトメンバーの場合、メンションを作成
        IF mentioned_user_record.id IS NOT NULL THEN
            -- プロジェクトメンバーかチェック
            IF EXISTS (
                SELECT 1 FROM project_memberships pm 
                WHERE pm.project_id = NEW.project_id 
                AND pm.user_id = mentioned_user_record.id
            ) THEN
                -- メンション作成（重複チェック）
                INSERT INTO mentions (
                    message_id,
                    mentioned_user_id,
                    mentioned_by_user_id,
                    project_id,
                    mention_text
                ) VALUES (
                    NEW.id,
                    mentioned_user_record.id,
                    NEW.user_id,
                    NEW.project_id,
                    mention_match
                ) ON CONFLICT (message_id, mentioned_user_id) DO NOTHING;
            END IF;
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- チャットメッセージ挿入時にメンション検出トリガー
CREATE TRIGGER trigger_extract_mentions
    AFTER INSERT ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION extract_mentions_from_message();

-- リアルタイム通知設定
ALTER PUBLICATION supabase_realtime ADD TABLE mentions;
