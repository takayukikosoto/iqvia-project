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
	(NULL, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, 'admin', 'admin@test.com', '$2a$06$5QwWhY8yh.Naeqf28l6gdezwsNLRLC9mIqZKH.lG2kVcFSaE7bOAi', '2025-08-21 05:21:54.175098+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": true, "provider": "email", "providers": ["email"]}', '{"role": "admin", "company": "IQVIA", "display_name": "Administrator"}', false, '2025-08-21 05:21:54.175098+00', '2025-08-21 05:21:54.175098+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '71e8083b-d4a0-4ac6-9282-2b75cfb701bc', 'authenticated', 'authenticated', 'b@b.com', '$2a$10$zDLGBWccyXqDuW2EggukN.bVridyY3uYRxAFVcJWaHre.pUHgWxDS', '2025-08-21 07:05:16.318404+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-08-21 07:05:29.303503+00', '{"is_admin": true, "provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-08-21 07:05:16.315527+00', '2025-08-21 07:05:29.304645+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	(NULL, '550e8400-e29b-41d4-a716-446655440001', NULL, 'viewer', 'admin@iqvia.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": false}', NULL, NULL, '2025-08-21 05:21:54.112217+00', NULL, NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	(NULL, '550e8400-e29b-41d4-a716-446655440002', NULL, 'viewer', 'pm@jtb.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": false}', NULL, NULL, '2025-08-21 05:21:54.112217+00', NULL, NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	(NULL, '550e8400-e29b-41d4-a716-446655440003', NULL, 'viewer', 'dev@vendor.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"is_admin": false}', NULL, NULL, '2025-08-21 05:21:54.112217+00', NULL, NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'authenticated', 'authenticated', 'a@a.com', '$2a$10$MEvLHHpzpYQuhJC8mysIZeVNkikUKi.5DrVGsn4pSgNw4tmT.NUgu', '2025-08-21 05:39:37.751563+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-08-21 05:39:46.313787+00', '{"is_admin": false, "provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2025-08-21 05:39:37.748174+00', '2025-08-21 06:38:10.421639+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: admin; Owner: postgres
--

INSERT INTO "admin"."admins" ("user_id", "granted_by", "granted_at", "expires_at") VALUES
	('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, '2025-08-21 05:21:54.210716+00', NULL),
	('71e8083b-d4a0-4ac6-9282-2b75cfb701bc', NULL, '2025-08-21 07:08:40.638108+00', NULL);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES
	('00000000-0000-0000-0000-000000000000', '7a2044ab-5344-46de-9d26-fd97dec96c85', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"a@a.com","user_id":"92341194-eb79-4f7c-ae1b-677f8ab52759","user_phone":""}}', '2025-08-21 05:39:37.75047+00', ''),
	('00000000-0000-0000-0000-000000000000', '943534db-9b67-4aa7-abd6-e3e290e4fd44', '{"action":"login","actor_id":"92341194-eb79-4f7c-ae1b-677f8ab52759","actor_username":"a@a.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-21 05:39:46.313318+00', ''),
	('00000000-0000-0000-0000-000000000000', '4f6da672-2866-41ff-a0dd-02542bb1f650', '{"action":"token_refreshed","actor_id":"92341194-eb79-4f7c-ae1b-677f8ab52759","actor_username":"a@a.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 06:38:10.418401+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e64d4371-2031-4a4d-b1c2-c4c7fe20d8ef', '{"action":"token_revoked","actor_id":"92341194-eb79-4f7c-ae1b-677f8ab52759","actor_username":"a@a.com","actor_via_sso":false,"log_type":"token"}', '2025-08-21 06:38:10.419273+00', ''),
	('00000000-0000-0000-0000-000000000000', '22959a74-3a79-463c-9ea8-02107b49f253', '{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"b@b.com","user_id":"71e8083b-d4a0-4ac6-9282-2b75cfb701bc","user_phone":""}}', '2025-08-21 07:05:16.317767+00', ''),
	('00000000-0000-0000-0000-000000000000', '002e00e7-7e7b-4679-9583-1230ea254528', '{"action":"logout","actor_id":"92341194-eb79-4f7c-ae1b-677f8ab52759","actor_username":"a@a.com","actor_via_sso":false,"log_type":"account"}', '2025-08-21 07:05:23.391283+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ce655661-e673-4234-aaa8-d3b8b0387709', '{"action":"login","actor_id":"71e8083b-d4a0-4ac6-9282-2b75cfb701bc","actor_username":"b@b.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-08-21 07:05:29.303001+00', '');


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('92341194-eb79-4f7c-ae1b-677f8ab52759', '92341194-eb79-4f7c-ae1b-677f8ab52759', '{"sub": "92341194-eb79-4f7c-ae1b-677f8ab52759", "email": "a@a.com", "email_verified": false, "phone_verified": false}', 'email', '2025-08-21 05:39:37.749919+00', '2025-08-21 05:39:37.749946+00', '2025-08-21 05:39:37.749946+00', 'cc5e69de-e7fa-47a8-8a49-703cff1bf828'),
	('71e8083b-d4a0-4ac6-9282-2b75cfb701bc', '71e8083b-d4a0-4ac6-9282-2b75cfb701bc', '{"sub": "71e8083b-d4a0-4ac6-9282-2b75cfb701bc", "email": "b@b.com", "email_verified": false, "phone_verified": false}', 'email', '2025-08-21 07:05:16.317282+00', '2025-08-21 07:05:16.317315+00', '2025-08-21 07:05:16.317315+00', '356e4753-0a37-4c0b-b7ca-97ee90b1c090');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag") VALUES
	('1d2e6b87-a66c-42b1-862d-40632cdd8979', '71e8083b-d4a0-4ac6-9282-2b75cfb701bc', '2025-08-21 07:05:29.303562+00', '2025-08-21 07:05:29.303562+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36', '192.168.65.1', NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('1d2e6b87-a66c-42b1-862d-40632cdd8979', '2025-08-21 07:05:29.304808+00', '2025-08-21 07:05:29.304808+00', 'password', 'e003aee4-693a-4c03-b337-823a5054dab5');


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

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 3, 'afwrjlw62yb6', '71e8083b-d4a0-4ac6-9282-2b75cfb701bc', false, '2025-08-21 07:05:29.30407+00', '2025-08-21 07:05:29.30407+00', NULL, '1d2e6b87-a66c-42b1-862d-40632cdd8979');


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

INSERT INTO "public"."chat_messages" ("id", "content", "user_id", "project_id", "created_at", "updated_at") VALUES
	('806e77ce-4a63-4362-b162-76294dde805d', 'メッセ', '92341194-eb79-4f7c-ae1b-677f8ab52759', '22222222-2222-2222-2222-222222222222', '2025-08-21 05:42:11.497868+00', '2025-08-21 05:42:11.497868+00'),
	('45840afa-a53f-442c-bedb-42e78745a3fc', 'メッセージ', '71e8083b-d4a0-4ac6-9282-2b75cfb701bc', '22222222-2222-2222-2222-222222222222', '2025-08-21 07:05:36.01056+00', '2025-08-21 07:05:36.01056+00');


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."organizations" ("id", "name", "created_at", "created_by", "updated_at", "updated_by") VALUES
	('11111111-1111-1111-1111-111111111111', 'テスト組織', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.160666+00', NULL),
	('c048b303-e901-430d-9c37-fda833f80019', 'あああ', '2025-08-21 05:42:45.115748+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL);


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."projects" ("id", "organization_id", "name", "start_date", "end_date", "status", "created_at", "created_by", "updated_at", "updated_by", "description", "settings") VALUES
	('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'テストプロジェクト', '2025-01-01', '2025-06-30', 'active', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.160666+00', NULL, NULL, '{}'),
	('6700d1d0-b8fc-4ffe-9331-cb2c46fb6818', 'c048b303-e901-430d-9c37-fda833f80019', 'ああああ', NULL, NULL, 'active', '2025-08-21 05:42:52.235865+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, NULL, '{}'),
	('6cd097f2-5dce-4ef7-9343-08a413b812ef', 'c048b303-e901-430d-9c37-fda833f80019', 'dfsだあ', NULL, NULL, 'active', '2025-08-21 07:04:06.063726+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, NULL, '{}');


--
-- Data for Name: custom_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."events" ("id", "title", "description", "start", "end", "all_day", "owner_user_id", "color", "location", "created_at", "updated_at") VALUES
	('3b680c7e-3180-4584-a44e-8869fb15ec89', 'イベントタイトル', NULL, '2025-08-07 00:00:00+00', '2025-08-08 00:00:00+00', true, '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, '2025-08-21 06:14:27.962897+00', '2025-08-21 06:14:27.962897+00'),
	('a9580bf5-23fc-455e-bf05-77243d066fe5', 'あああああ', NULL, '2025-08-14 00:00:00+00', '2025-08-15 00:00:00+00', true, '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, '2025-08-21 06:18:07.787247+00', '2025-08-21 06:18:07.787247+00');


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tasks" ("id", "project_id", "title", "description", "priority", "due_at", "created_at", "created_by", "updated_at", "updated_by", "status", "custom_status_id", "storage_folder") VALUES
	('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '会場選定・予約', '治験イベント会場の調査と予約手配を行う', 'high', '2025-02-15 00:00:00+00', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.22673+00', NULL, 'todo', NULL, 'task_11111111-1111-1111-1111-111111111111'),
	('11111111-1111-1111-1111-111111111112', '22222222-2222-2222-2222-222222222222', '講演者調整', 'キーオピニオンリーダーおよび治験責任医師との連絡調整', 'high', '2025-02-28 00:00:00+00', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.22673+00', NULL, 'todo', NULL, 'task_11111111-1111-1111-1111-111111111112'),
	('11111111-1111-1111-1111-111111111113', '22222222-2222-2222-2222-222222222222', 'マーケティング資料作成', 'パンフレット、バナー、デジタル素材の制作', 'medium', '2025-03-10 00:00:00+00', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.22673+00', NULL, 'review', NULL, 'task_11111111-1111-1111-1111-111111111113'),
	('11111111-1111-1111-1111-111111111115', '22222222-2222-2222-2222-222222222222', 'ケータリング手配', 'メニュー企画と食事制限対応の準備', 'low', '2025-03-01 00:00:00+00', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.22673+00', NULL, 'resolved', NULL, 'task_11111111-1111-1111-1111-111111111115'),
	('11111111-1111-1111-1111-111111111114', '22222222-2222-2222-2222-222222222222', '参加登録システム構築', 'オンライン参加登録システムとバッジ印刷機能の実装', 'medium', '2025-08-28 00:00:00+00', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 06:43:22.120755+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'done', NULL, 'task_11111111-1111-1111-1111-111111111114'),
	('6c8c72e7-3698-43dc-8ad4-3126b64c661d', '22222222-2222-2222-2222-222222222222', '印刷期限', 'まるまる印刷期限', 'high', '2025-08-19 15:00:00+00', '2025-08-21 06:53:22.236581+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:53:49.004255+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'review', NULL, 'task_6c8c72e7-3698-43dc-8ad4-3126b64c661d'),
	('63659791-63ed-412a-882e-a1041fab519c', '22222222-2222-2222-2222-222222222222', '新しいタスク', NULL, 'urgent', '2025-08-14 15:00:00+00', '2025-08-21 06:49:03.423146+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:55:25.800571+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'todo', NULL, 'task_63659791-63ed-412a-882e-a1041fab519c'),
	('fe51ba7d-3b2e-4c57-9a86-35f8117c137b', '22222222-2222-2222-2222-222222222222', '飛行機のチケット期限', '飛行機のチケットをとってください。', 'high', '2025-08-21 15:00:00+00', '2025-08-21 06:56:28.031871+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:57:04.783219+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'todo', NULL, 'task_fe51ba7d-3b2e-4c57-9a86-35f8117c137b'),
	('d348bbb0-dfa0-4b4b-b6d9-19b9ca0976dc', '22222222-2222-2222-2222-222222222222', '岩崎テスト', '適当なコメント', 'medium', '2025-07-31 15:00:00+00', '2025-08-21 07:02:13.286117+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 07:03:34.105697+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'todo', NULL, 'task_d348bbb0-dfa0-4b4b-b6d9-19b9ca0976dc');


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."files" ("id", "project_id", "name", "provider", "external_id", "external_url", "current_version", "created_at", "created_by", "updated_at", "updated_by", "description", "file_type", "mime_type", "storage_path", "total_versions", "total_size_bytes", "current_version_id", "task_id") VALUES
	('13975090-5667-4621-abc6-6cf374429831', '22222222-2222-2222-2222-222222222222', 'calendar_feature_routeA.zip', 'supabase', NULL, NULL, 1, '2025-08-21 05:39:57.298504+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 05:39:57.311136+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, NULL, 'task_11111111-1111-1111-1111-111111111113/1755754797242_calendar_feature_routeA.zip', 1, 4817, NULL, '11111111-1111-1111-1111-111111111113'),
	('16995dd4-5b7b-4a42-bf9f-77cb3b005d75', '22222222-2222-2222-2222-222222222222', 'calendar_feature_routeA.zip', 'supabase', NULL, NULL, 1, '2025-08-21 05:41:42.244434+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 05:41:42.258934+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, NULL, 'task_11111111-1111-1111-1111-111111111113/1755754902171_calendar_feature_routeA.zip', 1, 4817, NULL, '11111111-1111-1111-1111-111111111113'),
	('d4ba70c4-c5e5-42e9-9b77-af534651551d', '22222222-2222-2222-2222-222222222222', 'calendar_feature_routeA.zip', 'supabase', NULL, NULL, 1, '2025-08-21 06:54:11.686369+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:54:24.529315+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, NULL, '22222222-2222-2222-2222-222222222222/1755759264493_v2.json', 2, 10837, '2f6f4abc-0b31-49f0-b75d-7b8e1e8b7fe9', '6c8c72e7-3698-43dc-8ad4-3126b64c661d'),
	('1cd5941d-892e-4525-872b-568bdd8fe22e', '22222222-2222-2222-2222-222222222222', 'users_rows (1).sql', 'supabase', NULL, NULL, 1, '2025-08-21 07:02:25.341705+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 07:02:34.909655+00', '92341194-eb79-4f7c-ae1b-677f8ab52759', NULL, NULL, NULL, '22222222-2222-2222-2222-222222222222/1755759754890_v2.zip', 2, 8004, 'c2f414e8-100c-4e32-9667-545e133993b4', 'd348bbb0-dfa0-4b4b-b6d9-19b9ca0976dc');


--
-- Data for Name: file_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."file_versions" ("id", "file_id", "version", "size_bytes", "checksum", "storage_key", "uploaded_at", "uploaded_by", "name", "storage_path", "external_id", "upload_status", "change_notes", "created_by", "created_at", "version_number") VALUES
	('e0e94b05-fe9f-4f85-a27f-f81e05ce6df8', '13975090-5667-4621-abc6-6cf374429831', 1, 4817, NULL, 'task_11111111-1111-1111-1111-111111111113/1755754797242_calendar_feature_routeA.zip', '2025-08-21 05:39:57.306295+00', NULL, NULL, 'task_11111111-1111-1111-1111-111111111113/1755754797242_calendar_feature_routeA.zip', NULL, 'completed', NULL, '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 05:39:57.306295+00', 1),
	('0049570d-e282-4033-9567-23dfb061aef3', '16995dd4-5b7b-4a42-bf9f-77cb3b005d75', 1, 4817, NULL, 'task_11111111-1111-1111-1111-111111111113/1755754902171_calendar_feature_routeA.zip', '2025-08-21 05:41:42.253453+00', NULL, NULL, 'task_11111111-1111-1111-1111-111111111113/1755754902171_calendar_feature_routeA.zip', NULL, 'completed', NULL, '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 05:41:42.253453+00', 1),
	('dc114bd1-c4e3-489f-973a-b0e7e8b7250c', 'd4ba70c4-c5e5-42e9-9b77-af534651551d', 1, 4817, NULL, 'task_6c8c72e7-3698-43dc-8ad4-3126b64c661d/1755759251629_calendar_feature_routeA.zip', '2025-08-21 06:54:11.693875+00', NULL, NULL, 'task_6c8c72e7-3698-43dc-8ad4-3126b64c661d/1755759251629_calendar_feature_routeA.zip', NULL, 'completed', NULL, '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:54:11.693875+00', 1),
	('2f6f4abc-0b31-49f0-b75d-7b8e1e8b7fe9', 'd4ba70c4-c5e5-42e9-9b77-af534651551d', 2, 6020, NULL, NULL, '2025-08-21 06:54:24.523607+00', NULL, 'users_rows.json', '22222222-2222-2222-2222-222222222222/1755759264493_v2.json', NULL, 'completed', NULL, '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:54:24.523607+00', 2),
	('74031d8f-0be3-4445-b974-c2209ef4ded2', '1cd5941d-892e-4525-872b-568bdd8fe22e', 1, 3187, NULL, 'task_d348bbb0-dfa0-4b4b-b6d9-19b9ca0976dc/1755759745280_users_rows__1_.sql', '2025-08-21 07:02:25.349178+00', NULL, NULL, 'task_d348bbb0-dfa0-4b4b-b6d9-19b9ca0976dc/1755759745280_users_rows__1_.sql', NULL, 'completed', NULL, '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 07:02:25.349178+00', 1),
	('c2f414e8-100c-4e32-9667-545e133993b4', '1cd5941d-892e-4525-872b-568bdd8fe22e', 2, 4817, NULL, NULL, '2025-08-21 07:02:34.90586+00', NULL, 'calendar_feature_routeA.zip', '22222222-2222-2222-2222-222222222222/1755759754890_v2.zip', NULL, 'completed', 'コメント', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 07:02:34.90586+00', 2);


--
-- Data for Name: mentions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."notifications" ("id", "user_id", "type", "payload", "read_at", "created_at") VALUES
	('3892d33b-c5ab-4f8c-b744-e2f0420714cc', '550e8400-e29b-41d4-a716-446655440003', 'task_updated', '{"task_id": "11111111-1111-1111-1111-111111111114", "changed_by": "92341194-eb79-4f7c-ae1b-677f8ab52759", "new_status": "done", "old_status": "done", "project_id": "22222222-2222-2222-2222-222222222222", "task_title": "参加登録システム構築", "change_type": "updated"}', NULL, '2025-08-21 06:43:22.120755+00');


--
-- Data for Name: organization_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."organization_memberships" ("org_id", "user_id", "role", "created_at", "created_by") VALUES
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', 'admin', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', 'project_manager', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440003', 'contributor', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'admin', '2025-08-21 05:21:54.175098+00', NULL),
	('c048b303-e901-430d-9c37-fda833f80019', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'admin', '2025-08-21 05:42:45.123016+00', NULL);


--
-- Data for Name: priority_change_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."priority_change_history" ("id", "task_id", "user_id", "old_priority", "new_priority", "changed_at", "reason") VALUES
	('235ccce0-569a-423b-9170-fcd1c5d31fcc', '63659791-63ed-412a-882e-a1041fab519c', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'medium', 'urgent', '2025-08-21 06:49:15.071131+00', 'Priority updated via UI'),
	('d6756fc6-8cca-41e2-af18-3be42be341a7', '6c8c72e7-3698-43dc-8ad4-3126b64c661d', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'medium', 'high', '2025-08-21 06:53:29.448694+00', 'Priority updated via UI'),
	('bbbd290a-5a7b-472a-a025-e557edc0cc95', 'fe51ba7d-3b2e-4c57-9a86-35f8117c137b', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'medium', 'urgent', '2025-08-21 06:56:34.798606+00', 'Priority updated via UI'),
	('bf6b81fa-20a5-40af-92ec-11fe5161de27', 'fe51ba7d-3b2e-4c57-9a86-35f8117c137b', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'urgent', 'high', '2025-08-21 06:57:04.783219+00', 'Priority updated via UI');


--
-- Data for Name: priority_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."priority_options" ("id", "name", "label", "color", "weight", "is_active", "created_at", "updated_at") VALUES
	('fe763ebc-a959-480d-8bd4-1af6fe4020a7', 'low', '低', '#28a745', 1, true, '2025-08-21 05:21:54.124676+00', '2025-08-21 05:21:54.189177+00'),
	('84948c30-4235-4951-a7ff-4e0003d6c2c9', 'medium', '中', '#007bff', 2, true, '2025-08-21 05:21:54.124676+00', '2025-08-21 05:21:54.189177+00'),
	('16e90f46-906c-4260-a4bc-87b0ff7c6fcd', 'high', '高', '#ffc107', 3, true, '2025-08-21 05:21:54.124676+00', '2025-08-21 05:21:54.189177+00'),
	('d9bdbb3d-9596-4ca4-bbcb-be6421bd4320', 'urgent', '緊急', '#dc3545', 4, true, '2025-08-21 05:21:54.124676+00', '2025-08-21 05:21:54.189177+00');


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "user_id", "display_name", "company", "created_at", "updated_at") VALUES
	('d8cacf47-ff8c-48ea-8db3-aaead43f8c29', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'aああああ', 'Unknownっっっd', '2025-08-21 05:39:37.747938+00', '2025-08-21 05:43:24.109825+00'),
	('e6b701b4-3daf-4115-9db2-5f1f627787dc', '71e8083b-d4a0-4ac6-9282-2b75cfb701bc', 'b', 'Unknown', '2025-08-21 07:05:16.31525+00', '2025-08-21 07:05:16.31525+00');


--
-- Data for Name: project_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."project_memberships" ("project_id", "user_id", "role", "created_at", "created_by") VALUES
	('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440001', 'admin', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440002', 'admin', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440003', 'member', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'admin', '2025-08-21 05:21:54.175098+00', NULL),
	('6700d1d0-b8fc-4ffe-9331-cb2c46fb6818', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'admin', '2025-08-21 05:42:52.242616+00', NULL),
	('6cd097f2-5dce-4ef7-9343-08a413b812ef', '92341194-eb79-4f7c-ae1b-677f8ab52759', 'admin', '2025-08-21 07:04:06.071559+00', NULL);


--
-- Data for Name: task_assignees; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."task_assignees" ("task_id", "user_id", "created_at", "created_by") VALUES
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440003', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111114', '550e8400-e29b-41d4-a716-446655440003', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111115', '550e8400-e29b-41d4-a716-446655440002', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001');


--
-- Data for Name: task_links; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: task_watchers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."task_watchers" ("task_id", "user_id", "created_at", "created_by") VALUES
	('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440002', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001'),
	('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440001', '2025-08-21 05:21:54.112217+00', '550e8400-e29b-41d4-a716-446655440001');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") VALUES
	('files', 'files', NULL, '2025-08-21 05:21:54.14049+00', '2025-08-21 05:21:54.14049+00', false, false, 52428800, NULL, NULL, 'STANDARD'),
	('task-files', 'task-files', NULL, '2025-08-21 05:21:54.225266+00', '2025-08-21 05:21:54.225266+00', true, false, 52428800, NULL, NULL, 'STANDARD');


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

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata", "level") VALUES
	('84c5efe0-0cf7-41ec-90fc-dfd69c6a328d', 'task-files', 'task_11111111-1111-1111-1111-111111111113/1755754797242_calendar_feature_routeA.zip', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 05:39:57.282873+00', '2025-08-21 05:39:57.282873+00', '2025-08-21 05:39:57.282873+00', '{"eTag": "\"d5d3fd5c45840abb637dd7cce06d4b5d\"", "size": 4817, "mimetype": "application/zip", "cacheControl": "max-age=3600", "lastModified": "2025-08-21T05:39:57.279Z", "contentLength": 4817, "httpStatusCode": 200}', 'e23272c3-7b66-427a-a08c-b5d9fac7a476', '92341194-eb79-4f7c-ae1b-677f8ab52759', '{}', 2),
	('a5712e22-c9ba-47a6-9c07-7dbc10c75f53', 'task-files', 'task_11111111-1111-1111-1111-111111111113/1755754902171_calendar_feature_routeA.zip', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 05:41:42.227759+00', '2025-08-21 05:41:42.227759+00', '2025-08-21 05:41:42.227759+00', '{"eTag": "\"d5d3fd5c45840abb637dd7cce06d4b5d\"", "size": 4817, "mimetype": "application/zip", "cacheControl": "max-age=3600", "lastModified": "2025-08-21T05:41:42.223Z", "contentLength": 4817, "httpStatusCode": 200}', '2fefbe09-688a-4440-911e-74b1af84dcf1', '92341194-eb79-4f7c-ae1b-677f8ab52759', '{}', 2),
	('817a37c8-b557-416a-8991-ed6d74cb7cea', 'task-files', 'task_6c8c72e7-3698-43dc-8ad4-3126b64c661d/1755759251629_calendar_feature_routeA.zip', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:54:11.67381+00', '2025-08-21 06:54:11.67381+00', '2025-08-21 06:54:11.67381+00', '{"eTag": "\"d5d3fd5c45840abb637dd7cce06d4b5d\"", "size": 4817, "mimetype": "application/zip", "cacheControl": "max-age=3600", "lastModified": "2025-08-21T06:54:11.670Z", "contentLength": 4817, "httpStatusCode": 200}', '3856c971-32d4-45af-aba6-f0214e7c67e9', '92341194-eb79-4f7c-ae1b-677f8ab52759', '{}', 2),
	('c6ccb8c0-b083-4e00-af2f-8ce02269cd25', 'files', '22222222-2222-2222-2222-222222222222/1755759264493_v2.json', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 06:54:24.509314+00', '2025-08-21 06:54:24.509314+00', '2025-08-21 06:54:24.509314+00', '{"eTag": "\"6af836b8a5a80bcf565c3abc5fa048e7\"", "size": 6020, "mimetype": "application/json", "cacheControl": "max-age=3600", "lastModified": "2025-08-21T06:54:24.506Z", "contentLength": 6020, "httpStatusCode": 200}', '11a15daa-2a52-4986-978c-19f5e86cacde', '92341194-eb79-4f7c-ae1b-677f8ab52759', '{}', 2),
	('b1308468-821d-444d-a69c-0217c9085c60', 'task-files', 'task_d348bbb0-dfa0-4b4b-b6d9-19b9ca0976dc/1755759745280_users_rows__1_.sql', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 07:02:25.327075+00', '2025-08-21 07:02:25.327075+00', '2025-08-21 07:02:25.327075+00', '{"eTag": "\"68bdefa3eb04678789918b91d4214134\"", "size": 3187, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-08-21T07:02:25.322Z", "contentLength": 3187, "httpStatusCode": 200}', 'f721c031-1252-4b09-aedb-ec1f3aceb069', '92341194-eb79-4f7c-ae1b-677f8ab52759', '{}', 2),
	('3fd55fb6-9805-4b12-9d0c-8765406bb10d', 'files', '22222222-2222-2222-2222-222222222222/1755759754890_v2.zip', '92341194-eb79-4f7c-ae1b-677f8ab52759', '2025-08-21 07:02:34.897776+00', '2025-08-21 07:02:34.897776+00', '2025-08-21 07:02:34.897776+00', '{"eTag": "\"d5d3fd5c45840abb637dd7cce06d4b5d\"", "size": 4817, "mimetype": "application/zip", "cacheControl": "max-age=3600", "lastModified": "2025-08-21T07:02:34.895Z", "contentLength": 4817, "httpStatusCode": 200}', '197686be-aecc-4ad8-8421-25f89f8943dc', '92341194-eb79-4f7c-ae1b-677f8ab52759', '{}', 2);


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."prefixes" ("bucket_id", "name", "created_at", "updated_at") VALUES
	('task-files', 'task_11111111-1111-1111-1111-111111111113', '2025-08-21 05:39:57.282873+00', '2025-08-21 05:39:57.282873+00'),
	('task-files', 'task_6c8c72e7-3698-43dc-8ad4-3126b64c661d', '2025-08-21 06:54:11.67381+00', '2025-08-21 06:54:11.67381+00'),
	('files', '22222222-2222-2222-2222-222222222222', '2025-08-21 06:54:24.509314+00', '2025-08-21 06:54:24.509314+00'),
	('task-files', 'task_d348bbb0-dfa0-4b4b-b6d9-19b9ca0976dc', '2025-08-21 07:02:25.327075+00', '2025-08-21 07:02:25.327075+00');


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

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 3, true);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

RESET ALL;
