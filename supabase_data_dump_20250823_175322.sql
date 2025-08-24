SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	(NULL, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, 'admin', 'admin@test.com', '$2a$06$vTQni8.FUPQ6CHiHr7TiP.RPV89flXIO4lwUMe8ZZHR14MrfvElDu', '2025-08-23 08:52:09.350254+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": true, "provider": "email", "providers": ["email"]}', '{"role": "admin", "company": "IQVIA", "display_name": "Administrator"}', false, '2025-08-23 08:52:09.350254+00', '2025-08-23 08:52:09.350254+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	(NULL, '550e8400-e29b-41d4-a716-446655440001', NULL, 'viewer', 'admin@iqvia.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": false}', NULL, NULL, '2025-08-23 08:52:09.291818+00', NULL, NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	(NULL, '550e8400-e29b-41d4-a716-446655440002', NULL, 'viewer', 'pm@jtb.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": false}', NULL, NULL, '2025-08-23 08:52:09.291818+00', NULL, NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	(NULL, '550e8400-e29b-41d4-a716-446655440003', NULL, 'viewer', 'dev@vendor.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": false}', NULL, NULL, '2025-08-23 08:52:09.291818+00', NULL, NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: admin; Owner: postgres
--

INSERT INTO "admin"."admins" ("user_id", "granted_by", "granted_at", "expires_at") VALUES
	('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, '2025-08-23 08:52:09.389516+00', NULL);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."organizations" ("id", "name", "created_at", "created_by", "updated_at", "updated_by") VALUES
	('11111111-1111-1111-1111-111111111111', 'テスト組織', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.334751+00', NULL);


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."projects" ("id", "organization_id", "name", "start_date", "end_date", "status", "created_at", "created_by", "updated_at", "updated_by", "description", "settings") VALUES
	('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'テストプロジェクト', '2025-01-01', '2025-06-30', 'active', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.334751+00', NULL, NULL, '{}');


--
-- Data for Name: custom_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: status_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."status_options" ("id", "name", "label", "color", "weight", "is_active", "created_at", "updated_at") VALUES
	('c19a99c3-4510-4ec6-bc27-815a2bb6d67d', 'todo', '未着手', '#6c757d', 1, true, '2025-08-23 08:52:09.422902+00', '2025-08-23 08:52:09.422902+00'),
	('9a385955-463d-4216-bcc2-28ea6b68ed55', 'review', 'レビュー中', '#ffc107', 2, true, '2025-08-23 08:52:09.422902+00', '2025-08-23 08:52:09.422902+00'),
	('cc29777c-ec36-444e-aaf2-071896a326b5', 'done', '作業完了', '#28a745', 3, true, '2025-08-23 08:52:09.422902+00', '2025-08-23 08:52:09.422902+00'),
	('528427f9-3f71-4fc3-b1be-5ba7b4cfc206', 'resolved', '対応済み', '#17a2b8', 4, true, '2025-08-23 08:52:09.422902+00', '2025-08-23 08:52:09.422902+00'),
	('61826bf0-f591-4bd7-a608-36a8c467f7d5', 'completed', '完了済み', '#6f42c1', 5, true, '2025-08-23 08:52:09.422902+00', '2025-08-23 08:52:09.422902+00');


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tasks" ("id", "project_id", "title", "description", "priority", "due_at", "created_at", "created_by", "updated_at", "updated_by", "status", "custom_status_id", "storage_folder", "status_option_id") VALUES
	('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '会場選定・予約', '治験イベント会場の調査と予約手配を行う', 'high', '2025-02-15 00:00:00+00', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.428102+00', NULL, 'todo', NULL, 'task_11111111-1111-1111-1111-111111111111', 'c19a99c3-4510-4ec6-bc27-815a2bb6d67d'),
	('11111111-1111-1111-1111-111111111112', '22222222-2222-2222-2222-222222222222', '講演者調整', 'キーオピニオンリーダーおよび治験責任医師との連絡調整', 'high', '2025-02-28 00:00:00+00', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.428102+00', NULL, 'todo', NULL, 'task_11111111-1111-1111-1111-111111111112', 'c19a99c3-4510-4ec6-bc27-815a2bb6d67d'),
	('11111111-1111-1111-1111-111111111113', '22222222-2222-2222-2222-222222222222', 'マーケティング資料作成', 'パンフレット、バナー、デジタル素材の制作', 'medium', '2025-03-10 00:00:00+00', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.428102+00', NULL, 'review', NULL, 'task_11111111-1111-1111-1111-111111111113', '9a385955-463d-4216-bcc2-28ea6b68ed55'),
	('11111111-1111-1111-1111-111111111114', '22222222-2222-2222-2222-222222222222', '参加登録システム構築', 'オンライン参加登録システムとバッジ印刷機能の実装', 'medium', '2025-01-30 00:00:00+00', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.428102+00', NULL, 'done', NULL, 'task_11111111-1111-1111-1111-111111111114', 'cc29777c-ec36-444e-aaf2-071896a326b5'),
	('11111111-1111-1111-1111-111111111115', '22222222-2222-2222-2222-222222222222', 'ケータリング手配', 'メニュー企画と食事制限対応の準備', 'low', '2025-03-01 00:00:00+00', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.428102+00', NULL, 'resolved', NULL, 'task_11111111-1111-1111-1111-111111111115', '528427f9-3f71-4fc3-b1be-5ba7b4cfc206');


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: file_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: mentions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: organization_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."organization_memberships" ("org_id", "user_id", "role", "created_at", "created_by") VALUES
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', 'admin', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', 'project_manager', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440003', 'contributor', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'admin', '2025-08-23 08:52:09.350254+00', NULL);


--
-- Data for Name: permission_definitions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."permission_definitions" ("id", "permission_name", "resource", "action", "description", "is_active", "created_at") VALUES
	('c8ac2563-03cc-4be8-8b3a-793d863b1d3c', 'organizations_create', 'organizations', 'create', '組織作成', true, '2025-08-23 08:52:09.431969+00'),
	('4fe42f44-21f2-4526-9e09-d93784f2c10a', 'organizations_read', 'organizations', 'read', '組織閲覧', true, '2025-08-23 08:52:09.431969+00'),
	('02118d23-43df-4382-96dc-96aa9b637dbf', 'organizations_update', 'organizations', 'update', '組織更新', true, '2025-08-23 08:52:09.431969+00'),
	('e05ff18d-8053-4bc0-b1b7-a50a0434efa9', 'organizations_delete', 'organizations', 'delete', '組織削除', true, '2025-08-23 08:52:09.431969+00'),
	('db8b6d25-c069-4e80-9ec1-6c867db5bad4', 'projects_create', 'projects', 'create', 'プロジェクト作成', true, '2025-08-23 08:52:09.431969+00'),
	('5dae7345-2b9b-4315-8fcc-36bc9a95d95b', 'projects_read', 'projects', 'read', 'プロジェクト閲覧', true, '2025-08-23 08:52:09.431969+00'),
	('c13089f6-53a6-4f55-9fbc-b8c479a692d6', 'projects_update', 'projects', 'update', 'プロジェクト更新', true, '2025-08-23 08:52:09.431969+00'),
	('de63713c-5dc7-4feb-8525-b565d340abde', 'projects_delete', 'projects', 'delete', 'プロジェクト削除', true, '2025-08-23 08:52:09.431969+00'),
	('6326eff5-fe62-4e97-825b-1c00fa6caf86', 'tasks_create', 'tasks', 'create', 'タスク作成', true, '2025-08-23 08:52:09.431969+00'),
	('76741e25-c989-4d92-9a3f-e67eb742e472', 'tasks_read', 'tasks', 'read', 'タスク閲覧', true, '2025-08-23 08:52:09.431969+00'),
	('faf0a868-38e2-4f8a-8d12-0773ae2807ec', 'tasks_update', 'tasks', 'update', 'タスク更新', true, '2025-08-23 08:52:09.431969+00'),
	('6481fd52-d70c-4f65-938b-e465a091b17a', 'tasks_delete', 'tasks', 'delete', 'タスク削除', true, '2025-08-23 08:52:09.431969+00'),
	('872c6bde-64ac-4eda-a420-b46e7c1427a5', 'events_create', 'events', 'create', 'イベント作成', true, '2025-08-23 08:52:09.431969+00'),
	('6844bdad-dcf5-42d0-adaf-55316fcc0669', 'events_read', 'events', 'read', 'イベント閲覧', true, '2025-08-23 08:52:09.431969+00'),
	('2a3294a8-335b-4118-b04b-c1ad86c3243f', 'events_update', 'events', 'update', 'イベント更新', true, '2025-08-23 08:52:09.431969+00'),
	('6549da99-d769-4a3b-bcc7-824da02feb65', 'events_delete', 'events', 'delete', 'イベント削除', true, '2025-08-23 08:52:09.431969+00'),
	('19fc1012-4093-4914-9952-b75c9f43faef', 'users_manage', 'users', 'manage', 'ユーザー管理', true, '2025-08-23 08:52:09.431969+00'),
	('5978ce23-1d17-4965-be19-f07ace3d94cb', 'budget_manage', 'budget', 'manage', '予算管理', true, '2025-08-23 08:52:09.431969+00'),
	('d4a7098e-3b27-4981-9a3e-853e65de4721', 'contracts_manage', 'contracts', 'manage', '契約管理', true, '2025-08-23 08:52:09.431969+00'),
	('b8d5d20e-2761-4bd6-aa09-85f1e61166a1', 'content_create', 'content', 'create', 'コンテンツ作成', true, '2025-08-23 08:52:09.431969+00'),
	('a18756a1-7f4a-487e-8458-024ff39881c9', 'participants_manage', 'participants', 'manage', '参加者管理', true, '2025-08-23 08:52:09.431969+00');


--
-- Data for Name: priority_change_history; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: priority_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."priority_options" ("id", "name", "label", "color", "weight", "is_active", "created_at", "updated_at") VALUES
	('c63d7175-eb9f-4bd9-aaa3-64727b278cac', 'low', '低', '#28a745', 1, true, '2025-08-23 08:52:09.300954+00', '2025-08-23 08:52:09.36505+00'),
	('e4b4164a-2ec9-41d3-823b-07ea148542df', 'medium', '中', '#007bff', 2, true, '2025-08-23 08:52:09.300954+00', '2025-08-23 08:52:09.36505+00'),
	('b1870891-4646-44d3-91e7-9afa80224424', 'high', '高', '#ffc107', 3, true, '2025-08-23 08:52:09.300954+00', '2025-08-23 08:52:09.36505+00'),
	('d300639a-dc23-4ac7-8f37-8bbd75d51825', 'urgent', '緊急', '#dc3545', 4, true, '2025-08-23 08:52:09.300954+00', '2025-08-23 08:52:09.36505+00');


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: project_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."project_memberships" ("project_id", "user_id", "role", "created_at", "created_by") VALUES
	('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440001', 'admin', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440002', 'admin', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440003', 'member', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'admin', '2025-08-23 08:52:09.350254+00', NULL);


--
-- Data for Name: role_definitions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."role_definitions" ("id", "role_name", "role_level", "display_name", "description", "is_active", "created_at") VALUES
	('fc50f669-3560-4bdf-bfc5-be9d7b90eb09', 'admin', 8, '管理権限', 'システム全体管理、全権限', true, '2025-08-23 08:52:09.431969+00'),
	('fc3ac501-0566-40bf-8958-e5e5e69b1c67', 'organizer', 7, '主催者権限', 'イベント企画・承認、予算管理', true, '2025-08-23 08:52:09.431969+00'),
	('8ad5e147-0bfc-490d-9ede-1f8a463d23f2', 'sponsor', 6, 'スポンサー権限', 'スポンサー関連情報管理', true, '2025-08-23 08:52:09.431969+00'),
	('68828fa6-eb48-40d9-9ca4-2eeed7a19c46', 'agency', 5, '代理店権限', '営業・顧客管理、契約関連', true, '2025-08-23 08:52:09.431969+00'),
	('f1eede11-b058-485e-9462-a4f9c6661b45', 'production', 4, '制作会社権限', 'コンテンツ制作、デザイン管理', true, '2025-08-23 08:52:09.431969+00'),
	('0322ba46-0445-4acb-bdbf-b0f379928d4a', 'secretariat', 3, '事務局権限', '運営業務、参加者管理', true, '2025-08-23 08:52:09.431969+00'),
	('3f631d8e-38d2-4c87-86d1-188f06a64533', 'staff', 2, 'スタッフ権限', '当日運営、限定的操作', true, '2025-08-23 08:52:09.431969+00'),
	('f672d551-0f2c-4fc2-8b80-8e6b498e301d', 'viewer', 1, 'ビュワー権限', '閲覧のみ', true, '2025-08-23 08:52:09.431969+00');


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."role_permissions" ("id", "role_name", "permission_name", "is_granted", "created_at") VALUES
	('76c71284-95f4-43b6-b1ba-142c01e7006e', 'admin', 'organizations_create', true, '2025-08-23 08:52:09.431969+00'),
	('06eddcef-920d-466c-a93e-5dc839eeebb9', 'admin', 'organizations_read', true, '2025-08-23 08:52:09.431969+00'),
	('af68c9ac-5c34-49b3-b3cd-0ccce5710fbd', 'admin', 'organizations_update', true, '2025-08-23 08:52:09.431969+00'),
	('ae01c9a7-446b-4789-85e7-92f074c530be', 'admin', 'organizations_delete', true, '2025-08-23 08:52:09.431969+00'),
	('fd7daaba-2de7-4a15-9ec5-5cf10dd00c46', 'admin', 'projects_create', true, '2025-08-23 08:52:09.431969+00'),
	('b735dde6-fd37-46e2-9197-5b3090a44578', 'admin', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('7fec7dd4-bfaa-4087-9ec0-392cbc76c032', 'admin', 'projects_update', true, '2025-08-23 08:52:09.431969+00'),
	('de9733a3-ab8a-49cb-aa00-48bda564b8ce', 'admin', 'projects_delete', true, '2025-08-23 08:52:09.431969+00'),
	('d52c2f19-7c2b-4e82-8203-976f1acec5b1', 'admin', 'tasks_create', true, '2025-08-23 08:52:09.431969+00'),
	('6dbb8995-a199-4c55-a7a0-fd42c32a7a3b', 'admin', 'tasks_read', true, '2025-08-23 08:52:09.431969+00'),
	('fc16be53-8b89-4d6b-9f2f-c44b845def62', 'admin', 'tasks_update', true, '2025-08-23 08:52:09.431969+00'),
	('da57da0b-1703-4c38-af71-9f9378a5a11c', 'admin', 'tasks_delete', true, '2025-08-23 08:52:09.431969+00'),
	('3db623d5-ff4f-4f59-954c-d0f66fb9d25e', 'admin', 'events_create', true, '2025-08-23 08:52:09.431969+00'),
	('2566cc66-6da8-4a15-bfce-74a182994b50', 'admin', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('cf3e928b-88d6-45bf-9eaf-67859dc4faa0', 'admin', 'events_update', true, '2025-08-23 08:52:09.431969+00'),
	('bbf75491-8b23-41e5-b83b-1ea27f7eae78', 'admin', 'events_delete', true, '2025-08-23 08:52:09.431969+00'),
	('57f9e67d-c889-4a4d-8b12-1f3d6b8e8293', 'admin', 'users_manage', true, '2025-08-23 08:52:09.431969+00'),
	('67145b78-26bb-4a49-935e-acbac841b0c2', 'admin', 'budget_manage', true, '2025-08-23 08:52:09.431969+00'),
	('5847983d-b8bc-4482-ac5c-499765a8c1aa', 'admin', 'contracts_manage', true, '2025-08-23 08:52:09.431969+00'),
	('5a1d9e5b-99e6-46ff-b571-ee64b179a6e5', 'admin', 'content_create', true, '2025-08-23 08:52:09.431969+00'),
	('6809a9ca-59ea-4aea-9e25-567f97b78c2d', 'admin', 'participants_manage', true, '2025-08-23 08:52:09.431969+00'),
	('b624d1e5-5025-4052-9db4-29b13c52aa1c', 'organizer', 'organizations_read', true, '2025-08-23 08:52:09.431969+00'),
	('2c6b4568-b844-4918-a78b-51c1fa71aeb1', 'organizer', 'projects_create', true, '2025-08-23 08:52:09.431969+00'),
	('966b07a1-83f3-4077-a956-4a1705cfd202', 'organizer', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('3e360ba0-fde8-496b-997d-23e8221ff586', 'organizer', 'projects_update', true, '2025-08-23 08:52:09.431969+00'),
	('9c7c42ec-df3b-4d9d-bcf9-4a5e48ebff5a', 'organizer', 'projects_delete', true, '2025-08-23 08:52:09.431969+00'),
	('fdb5e856-5fb5-4d69-8287-2e2969cb8df6', 'organizer', 'tasks_create', true, '2025-08-23 08:52:09.431969+00'),
	('303a9cf7-3a17-45ff-9d95-e33cf31766e6', 'organizer', 'tasks_read', true, '2025-08-23 08:52:09.431969+00'),
	('556e71c3-0cf6-40d7-aa5d-ff3b6edb444a', 'organizer', 'tasks_update', true, '2025-08-23 08:52:09.431969+00'),
	('5dc70fe7-b9ef-44cf-ba7e-e21a7b86e6f0', 'organizer', 'tasks_delete', true, '2025-08-23 08:52:09.431969+00'),
	('865f3d66-5378-4016-93ed-bc9eb7a2078b', 'organizer', 'events_create', true, '2025-08-23 08:52:09.431969+00'),
	('c5ee0173-ca53-46be-b2c8-d25d8a754993', 'organizer', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('76a5fdb2-0a59-4fa0-a402-2a831d17dbf2', 'organizer', 'events_update', true, '2025-08-23 08:52:09.431969+00'),
	('d54e249a-dcec-4da4-ae6e-6848bd7592a0', 'organizer', 'events_delete', true, '2025-08-23 08:52:09.431969+00'),
	('a68694b3-667f-4328-a6f2-b1380c6a584f', 'organizer', 'budget_manage', true, '2025-08-23 08:52:09.431969+00'),
	('6cabe178-0c81-43b9-9f5a-1b7534580c0e', 'organizer', 'participants_manage', true, '2025-08-23 08:52:09.431969+00'),
	('b9ff77f6-2366-428f-a762-671865ee3c48', 'sponsor', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('a6e56c21-46b7-45e4-a25a-69c8733e815f', 'sponsor', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('cc1937f8-399b-4396-a8e2-3984245ee87a', 'sponsor', 'tasks_read', true, '2025-08-23 08:52:09.431969+00'),
	('3121919b-bfed-45da-bc63-dd746c531a5e', 'agency', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('79200c2b-e5bc-43ca-91c5-9178c43133c3', 'agency', 'projects_update', true, '2025-08-23 08:52:09.431969+00'),
	('329aab4b-46bf-48d1-a6dd-bfee2e17b1d5', 'agency', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('2ed9b53b-55f3-4845-b20a-f8ab71284364', 'agency', 'tasks_create', true, '2025-08-23 08:52:09.431969+00'),
	('6f136e01-9564-47d8-8ba9-17f06f2a353f', 'agency', 'tasks_read', true, '2025-08-23 08:52:09.431969+00'),
	('05fa3c95-edfc-46f1-9df8-93e380ee4296', 'agency', 'tasks_update', true, '2025-08-23 08:52:09.431969+00'),
	('7be528f4-03c8-4f6b-b2f7-fbdb976d70bb', 'agency', 'contracts_manage', true, '2025-08-23 08:52:09.431969+00'),
	('f2b4ed63-bec7-42a1-bf7d-0c47dbed57c8', 'agency', 'participants_manage', true, '2025-08-23 08:52:09.431969+00'),
	('55bb65bd-5bfb-4af1-9962-e8e5bb783615', 'production', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('1fc3e9e7-f37d-4baf-a381-3e78a9f4b698', 'production', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('83dac068-8e67-4678-b7c6-ae6fda08f0a0', 'production', 'tasks_create', true, '2025-08-23 08:52:09.431969+00'),
	('52366a10-7cd7-4e12-a1f7-c7442f0c0ce3', 'production', 'tasks_read', true, '2025-08-23 08:52:09.431969+00'),
	('fde54df1-d6cb-4098-8282-97f1a1eacdb2', 'production', 'tasks_update', true, '2025-08-23 08:52:09.431969+00'),
	('c2f84d94-4289-4be8-ae73-6ca0429a5dc5', 'production', 'content_create', true, '2025-08-23 08:52:09.431969+00'),
	('842cdfac-e48a-42d0-91ef-f238ed15f41f', 'secretariat', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('5b5409c4-5d71-4760-b6ab-f30ca7b0f493', 'secretariat', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('dc13f506-a697-451c-8905-8375ca6a9644', 'secretariat', 'events_update', true, '2025-08-23 08:52:09.431969+00'),
	('799faf93-8c7c-4eca-bae2-d837b138d56a', 'secretariat', 'tasks_create', true, '2025-08-23 08:52:09.431969+00'),
	('9710ae59-af2c-4690-9fa8-1706226fa629', 'secretariat', 'tasks_read', true, '2025-08-23 08:52:09.431969+00'),
	('bd720d71-8dab-4103-82b9-49f73a6a6071', 'secretariat', 'tasks_update', true, '2025-08-23 08:52:09.431969+00'),
	('1f41ff20-a3d2-4150-8dbe-45ae21d8b904', 'secretariat', 'participants_manage', true, '2025-08-23 08:52:09.431969+00'),
	('06856ef8-3349-4ffb-a62e-aa170763aa98', 'staff', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('c5d75241-5d5d-46e0-98df-3b3ce0d492c1', 'staff', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('102df0d8-9c77-4f27-a09c-cdce895e90e3', 'staff', 'tasks_read', true, '2025-08-23 08:52:09.431969+00'),
	('5afe86df-2a4b-4473-90b2-90ed84334613', 'staff', 'tasks_update', true, '2025-08-23 08:52:09.431969+00'),
	('c40d558e-bf36-445f-a140-39d07eecadbd', 'viewer', 'projects_read', true, '2025-08-23 08:52:09.431969+00'),
	('f83b29be-b088-4367-9ced-76c0813259ef', 'viewer', 'events_read', true, '2025-08-23 08:52:09.431969+00'),
	('79d5625c-2a8b-4b8f-90d4-b7ddc103be1a', 'viewer', 'tasks_read', true, '2025-08-23 08:52:09.431969+00');


--
-- Data for Name: status_change_history; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: task_assignees; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."task_assignees" ("task_id", "user_id", "created_at", "created_by") VALUES
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440003', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111114', '550e8400-e29b-41d4-a716-446655440003', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111115', '550e8400-e29b-41d4-a716-446655440002', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001');


--
-- Data for Name: task_links; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: task_watchers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."task_watchers" ("task_id", "user_id", "created_at", "created_by") VALUES
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440002', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440001', '2025-08-23 08:52:09.291818+00', '550e8400-e29b-41d4-a716-446655440001');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('files', 'files', NULL, '2025-08-23 08:52:09.314545+00', '2025-08-23 08:52:09.314545+00', false, false, 52428800, NULL, NULL, 'STANDARD'),
	('task-files', 'task-files', NULL, '2025-08-23 08:52:09.40356+00', '2025-08-23 08:52:09.40356+00', true, false, 52428800, NULL, NULL, 'STANDARD');


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

RESET ALL;
