# IQVIA × JTB タスク管理ツール

企業間連携プロジェクト向けのタスク管理アプリケーション

## 🚀 技術スタック

### フロントエンド
- **React 18** + TypeScript + Vite
- **Supabase** (認証・データベース・リアルタイム同期)
- レスポンシブデザイン

### バックエンド
- **Supabase PostgreSQL** データベース
- **Row Level Security (RLS)** によるセキュリティ
- リアルタイム更新機能

## ✨ 主な機能

- 🔐 **認証システム** - Supabase Auth
- 📋 **タスク管理** - 作成・編集・削除・ステータス管理
- 👥 **プロジェクト管理** - 組織・プロジェクト・メンバー管理
- 🔄 **リアルタイム同期** - 複数ユーザー間でのリアルタイム更新
- 🇯🇵 **日本語完全対応** - UI・データ・日付表示すべて日本語化
- 📱 **レスポンシブUI** - デスクトップ・タブレット・モバイル対応

## 🎯 タスク管理機能

### ステータス管理
- **未着手** (todo) - 新規作成されたタスク
- **進行中** (doing) - 実行中のタスク
- **レビュー中** (review) - 確認・承認待ち
- **完了** (done) - 完了済みタスク
- **停止中** (blocked) - 何らかの理由で停止

### 優先度管理
- **緊急** (urgent) - 最優先対応
- **高** (high) - 優先度高
- **中** (medium) - 標準優先度
- **低** (low) - 優先度低

## 🔧 セットアップ

### 必要条件
- Node.js 18+ 
- npm または yarn
- Supabase CLI

### ローカル環境構築

1. **リポジトリクローン**
```bash
git clone <repository-url>
cd iqvia_project
```

2. **Supabaseローカル環境開始**
```bash
npx supabase start
```

3. **フロントエンド依存関係インストール**
```bash
cd web
npm install
```

4. **環境変数設定**
```bash
cp .env.example .env
# .envファイルでSupabase URLとAPI Keyを設定
```

5. **開発サーバー起動**
```bash
npm run dev
```

アプリケーションは `http://localhost:5174` でアクセス可能

## 📊 データベース構造

### 主要テーブル
- `organizations` - 組織情報
- `projects` - プロジェクト管理
- `tasks` - タスク情報
- `profiles` - ユーザープロフィール
- `organization_memberships` - 組織メンバーシップ
- `project_memberships` - プロジェクトメンバーシップ

### セキュリティ
- Row Level Security (RLS) 適用済み
- 組織・プロジェクト単位でのアクセス制御
- 認証されたユーザーのみアクセス可能

## 🚀 本番デプロイ

### Supabase
1. Supabaseプロジェクト作成
2. マイグレーション適用
3. 環境変数設定

### Netlify / Vercel
1. リポジトリ連携
2. ビルド設定: `cd web && npm run build`
3. 公開ディレクトリ: `web/dist`

## 🤝 開発

### コミット規約
- `feat:` 新機能
- `fix:` バグ修正
- `docs:` ドキュメント更新
- `style:` コードスタイル
- `refactor:` リファクタリング
- `test:` テスト追加・修正

### ブランチ戦略
- `main` - 本番環境
- `develop` - 開発統合
- `feature/*` - 機能開発
- `hotfix/*` - 緊急修正

## 📝 ライセンス

このプロジェクトは IQVIA × JTB の企業間連携用途で開発されています。

## 📞 サポート

技術的な問題や質問がある場合は、開発チームまでお問い合わせください。
