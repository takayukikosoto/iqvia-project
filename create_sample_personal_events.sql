-- 個人カレンダー用サンプルデータ作成
-- 各ユーザーが自分専用のイベントを持つことを確認

-- 現在のユーザーIDを取得して個人イベントを作成
DO $$
DECLARE
    current_user_id uuid;
    today_date date := CURRENT_DATE;
BEGIN
    -- 認証済みユーザーのIDを取得
    SELECT auth.uid() INTO current_user_id;
    
    -- ユーザーがログインしている場合のみサンプルデータ挿入
    IF current_user_id IS NOT NULL THEN
        
        -- 今週の個人イベント
        INSERT INTO public.events (title, description, start, "end", all_day, owner_user_id, color, location) VALUES
        ('朝の運動', '毎日のランニング', today_date + INTERVAL '1 day' + TIME '07:00', today_date + INTERVAL '1 day' + TIME '08:00', false, current_user_id, '#10b981', '近所の公園'),
        ('チームミーティング', 'プロジェクト進捗確認', today_date + INTERVAL '2 days' + TIME '10:00', today_date + INTERVAL '2 days' + TIME '11:30', false, current_user_id, '#3b82f6', 'オンライン'),
        ('歯科検診', '定期健診', today_date + INTERVAL '3 days' + TIME '14:00', today_date + INTERVAL '3 days' + TIME '15:00', false, current_user_id, '#ef4444', 'ABC歯科医院'),
        ('読書タイム', 'React学習', today_date + INTERVAL '4 days' + TIME '19:00', today_date + INTERVAL '4 days' + TIME '21:00', false, current_user_id, '#8b5cf6', '自宅'),
        ('友人との食事', '久しぶりの再会', today_date + INTERVAL '6 days' + TIME '18:00', today_date + INTERVAL '6 days' + TIME '21:00', false, current_user_id, '#f59e0b', '新宿のレストラン');
        
        -- 来週の個人イベント
        INSERT INTO public.events (title, description, start, "end", all_day, owner_user_id, color, location) VALUES
        ('英語レッスン', 'オンライン英会話', today_date + INTERVAL '7 days' + TIME '20:00', today_date + INTERVAL '7 days' + TIME '21:00', false, current_user_id, '#06b6d4', 'オンライン'),
        ('家族旅行', '温泉旅行', today_date + INTERVAL '9 days', today_date + INTERVAL '10 days', true, current_user_id, '#f97316', '箱根'),
        ('プロジェクト発表', '四半期レビュー', today_date + INTERVAL '12 days' + TIME '13:00', today_date + INTERVAL '12 days' + TIME '17:00', false, current_user_id, '#dc2626', '会議室A'),
        ('ヨガクラス', 'リフレッシュタイム', today_date + INTERVAL '14 days' + TIME '19:30', today_date + INTERVAL '14 days' + TIME '20:30', false, current_user_id, '#10b981', 'ヨガスタジオ');
        
        -- 終日イベント
        INSERT INTO public.events (title, description, start, all_day, owner_user_id, color) VALUES
        ('有給休暇', '休息日', today_date + INTERVAL '5 days', true, current_user_id, '#6b7280'),
        ('会社創立記念日', '全社休業日', today_date + INTERVAL '15 days', true, current_user_id, '#ef4444');
        
        RAISE NOTICE 'サンプル個人イベントを作成しました (ユーザーID: %)', current_user_id;
        
    ELSE
        RAISE NOTICE 'ログインユーザーが見つかりません。認証後に実行してください。';
    END IF;
END $$;
