-- profiles テーブルのRLSポリシーの競合を解決

-- 既存の全てのポリシーを削除
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_full_access" ON public.profiles;
DROP POLICY IF EXISTS "users_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "profiles_admin_all" ON public.profiles;
DROP POLICY IF EXISTS "profiles_user_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_own_manage" ON public.profiles;
DROP POLICY IF EXISTS "profiles_admin_manage" ON public.profiles;

-- 新しい統合されたポリシーを作成
-- ユーザーは自分のプロフィールを管理可能
CREATE POLICY "profiles_user_own_access" ON public.profiles
  FOR ALL 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 管理者は全プロフィールを管理可能
CREATE POLICY "profiles_admin_full_access" ON public.profiles
  FOR ALL 
  USING ((SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin')
  WITH CHECK ((SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin');

-- プロフィールは認証ユーザーによって読み取り可能（メンション機能などで必要）
CREATE POLICY "profiles_authenticated_read" ON public.profiles
  FOR SELECT 
  USING (auth.role() = 'authenticated');
