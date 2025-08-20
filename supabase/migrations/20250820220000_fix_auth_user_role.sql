-- Fix auth.users role assignment on user creation
-- Remove direct auth.users update to avoid permission errors

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role text;
BEGIN
    -- ロールを取得
    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'viewer');
    
    -- プロファイルを作成
    INSERT INTO public.profiles (user_id, display_name, company, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown'),
        user_role
    );
    
    -- auth.users直接更新は権限エラーを起こすため削除
    -- 代わりにraw_user_meta_dataにロール情報を保存済み
    
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;
