# 新規アプリ要件定義書（IQVIA × JTB 関係者タスク管理ツール）

## 1. 背景・目的 / Problem & Goal
- 現状の課題：イベント準備時のタスク管理がMicrosoft365のExcel共有依存で、変更通知が届かず関係者が見落とす。IQVIAとJTBの制作間で連携不十分。
- ターゲット：IQVIA（治験グローバル代理店）、JTB（日本側エージェンシー）、制作会社。将来は製薬会社主催者も参画予定。
- 目的：単一のRDBとRealtime通知で、関係者全員にタスクやファイル更新の変更を即時に伝達する。
- 成功指標：通知遅延5秒以内、タスク見落とし80％削減、初期導入3案件でアクティブ関係者60人/案件。

## 2. スコープ / Scope
- リリース対象：Web（PC/モバイル対応）、PWA、管理画面。
- 対象範囲：タスク管理、ファイルメタデータ管理、チャット、通知機能。
- 対象外：決済、ライブ配信、在庫・販売管理。
- 依存関係：Supabase（Auth/DB/Realtime/Storage）、Box（当面のファイル保管）。

## 3. 価値仮説 / Value Hypothesis
- 関係者間のタスク・ファイル・チャットの一元管理で、認識齟齬や手戻りを削減。
- Excelからの移行で、権限管理・監査ログの確実な適用が可能。

## 4. 利用者・ロール / Personas & Roles
- 管理者（KST Admin）
- IQVIA PM/担当者
- JTB PM/制作
- 制作会社（外注）
- 主催製薬企業（閲覧専用）

## 5. 主要ユースケース / Top Use Cases
1. タスク更新→関係者へ即時通知（Web/Email）
2. ファイル更新の版管理＋スレッドチャット
3. プロジェクト別のタスクボード表示（Kanban/List）
4. モバイルからのチャット・通知受信
5. 監査ログの参照

## 6. 非機能要件 / NFRs
- パフォーマンス：P95 API < 300ms、同時接続100〜300
- 可用性：SLO 99.9%
- セキュリティ：RLS適用、監査ログ90日保持
- プライバシー：PII最小化
- 運用性：APM/Logs監視、日次バックアップ

## 7. データモデル（初版） / Data Model v0
- Organization(1) - Project(N)
- Project(1) - Task(N)
- Task(N) - User(N)（Assignee/Watcher）
- Project(1) - File(N) - FileVersion(N)
- Task/File(1) - Comment(N)
- Notification(N) - User(1)

## 8. API / 外部連携
- 認証：Supabase Auth（Email/Magic Link）
- 通知：Realtime＋Email
- ストレージ：Box（外部IDとURLをDB管理）

## 9. セキュリティ・認証 / AuthZ & AuthN
- RLSキー：org_id, project_id
- 更新権限：担当者、PM以上
- 閲覧権限：プロジェクトメンバー
- 監査ログ：全テーブルにcreated_by/updated_by

## 10. 運用・SRE / Ops
- 監視：APIエラー率、通知遅延
- デプロイ：Vercel/Netlify（Front）、Supabase（Back）
- バックアップ：日次スナップショット

## 11. リリース計画 / Milestones
- M0：タスク・コメント・通知の最小機能
- M1：ファイル版管理＋メンション
- M2：RBAC完成、検索機能
- M3：Viewer導入、SSO検討

## 12. KPI / 計測
- 通知既読率（24h）> 90%
- 更新→気づき中央値 < 30秒
- 週あたりコア行動 >= 5/ユーザー

## 13. リスク・対策
- Box依存：抽象化レイヤで将来移行可能に
- メールドメイン差異：Magic Link招待制
- オフライン時対応：将来キャッシュ実装

---
## 付録：Supabase用DDL概要
- profiles
- organizations / organization_memberships
- projects / project_memberships
- tasks / task_assignees / task_watchers
- files / file_versions
- comments
- notifications
- Enum: task_status, task_priority, storage_provider, comment_target, notify_type
- RLSポリシー：プロジェクトメンバー判定関数とテーブルごとのselect/insert/update/delete制御
- 通知トリガ：タスク更新→ウォッチャーに通知
