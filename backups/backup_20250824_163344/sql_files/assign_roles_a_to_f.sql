-- a@a.com から f@f.com までの6ユーザーにロール権限付与
-- Supabase Studio SQL Editor で実行

-- a@a.com: admin（管理者）- 全権限
UPDATE auth.users SET role = 'admin' WHERE email = 'a@a.com';

-- b@b.com: organizer（主催者）- イベント企画・承認、予算管理
UPDATE auth.users SET role = 'organizer' WHERE email = 'b@b.com';

-- c@c.com: sponsor（スポンサー）- スポンサー関連情報管理
UPDATE auth.users SET role = 'sponsor' WHERE email = 'c@c.com';

-- d@d.com: agency（代理店）- 営業・顧客管理、契約関連
UPDATE auth.users SET role = 'agency' WHERE email = 'd@d.com';

-- e@e.com: production（制作会社）- コンテンツ制作、デザイン管理
UPDATE auth.users SET role = 'production' WHERE email = 'e@e.com';

-- f@f.com: secretariat（事務局）- 運営業務、参加者管理
UPDATE auth.users SET role = 'secretariat' WHERE email = 'f@f.com';

-- 確認クエリ（シンプル）
SELECT email, role FROM auth.users 
WHERE email IN ('a@a.com', 'b@b.com', 'c@c.com', 'd@d.com', 'e@e.com', 'f@f.com');
