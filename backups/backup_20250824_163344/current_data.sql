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
-- Data for Name: tenants; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.tenants (id, name, external_id, jwt_secret, max_concurrent_users, inserted_at, updated_at, max_events_per_second, postgres_cdc_default, max_bytes_per_second, max_channels_per_client, max_joins_per_second, suspend, jwt_jwks, notify_private_alpha, private_only, migrations_ran, broadcast_adapter) FROM stdin;
76e4e9b0-8188-4cda-9f5a-a59a4dc10047	realtime-dev	realtime-dev	iNjicxc4+llvc9wovDvqymwfnj9teWMlyOIbJ8Fh6j2WNU8CIJ2ZgjR6MUIKqSmeDmvpsKLsZ9jgXJmQPpwL8w==	200	2025-08-24 07:14:18	2025-08-24 07:14:18	100	postgres_cdc_rls	100000	100	100	f	{"keys": [{"k": "c3VwZXItc2VjcmV0LWp3dC10b2tlbi13aXRoLWF0LWxlYXN0LTMyLWNoYXJhY3RlcnMtbG9uZw", "kty": "oct"}]}	f	f	63	gen_rpc
\.


--
-- Data for Name: extensions; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.extensions (id, type, settings, tenant_external_id, inserted_at, updated_at) FROM stdin;
6546be44-5348-4e50-bbdc-083cd02e11cf	postgres_cdc_rls	{"region": "us-east-1", "db_host": "XMTSkoa3B0TZC9Wh76MWosU1Qurx9uDoLaPduPjE8no=", "db_name": "sWBpZNdjggEPTQVlI52Zfw==", "db_port": "+enMDFi1J/3IrrquHHwUmA==", "db_user": "uxbEq/zz8DXVD53TOI1zmw==", "slot_name": "supabase_realtime_replication_slot", "db_password": "sWBpZNdjggEPTQVlI52Zfw==", "publication": "supabase_realtime", "ssl_enforced": false, "poll_interval_ms": 100, "poll_max_changes": 100, "poll_max_record_bytes": 1048576}	realtime-dev	2025-08-24 07:14:18	2025-08-24 07:14:18
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.schema_migrations (version, inserted_at) FROM stdin;
20210706140551	2025-08-23 15:20:46
20220329161857	2025-08-23 15:20:46
20220410212326	2025-08-23 15:20:46
20220506102948	2025-08-23 15:20:46
20220527210857	2025-08-23 15:20:46
20220815211129	2025-08-23 15:20:46
20220815215024	2025-08-23 15:20:46
20220818141501	2025-08-23 15:20:46
20221018173709	2025-08-23 15:20:46
20221102172703	2025-08-23 15:20:46
20221223010058	2025-08-23 15:20:46
20230110180046	2025-08-23 15:20:46
20230810220907	2025-08-23 15:20:46
20230810220924	2025-08-23 15:20:46
20231024094642	2025-08-23 15:20:46
20240306114423	2025-08-23 15:20:46
20240418082835	2025-08-23 15:20:46
20240625211759	2025-08-23 15:20:46
20240704172020	2025-08-23 15:20:46
20240902173232	2025-08-23 15:20:46
20241106103258	2025-08-23 15:20:46
20250424203323	2025-08-23 15:20:46
20250613072131	2025-08-23 15:20:46
20250711044927	2025-08-23 15:20:46
\.


--
-- Data for Name: admins; Type: TABLE DATA; Schema: admin; Owner: postgres
--

COPY admin.admins (user_id, granted_by, granted_at, expires_at) FROM stdin;
bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	\N	2025-08-23 15:20:50.530126+00	\N
\.


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	d03e1e11-7a03-4a79-9079-8607e5e6b37d	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"provider":"email","user_email":"a@a.com","user_id":"3cde03f2-7fd4-4f43-a268-da72b3e2b60e","user_phone":""}}	2025-08-24 07:17:29.939199+00	
00000000-0000-0000-0000-000000000000	1e9b6385-dbdb-4b83-a3e8-e9bb3227efe1	{"action":"login","actor_id":"3cde03f2-7fd4-4f43-a268-da72b3e2b60e","actor_username":"a@a.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-08-24 07:17:35.972048+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
3cde03f2-7fd4-4f43-a268-da72b3e2b60e	3cde03f2-7fd4-4f43-a268-da72b3e2b60e	{"sub": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e", "email": "a@a.com", "email_verified": false, "phone_verified": false}	email	2025-08-24 07:17:29.938148+00	2025-08-24 07:17:29.938167+00	2025-08-24 07:17:29.938167+00	3d99201c-d258-4e38-aabb-9211b5b7efb3
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
4371417d-b004-4f18-9126-ff4c82e6659c	3cde03f2-7fd4-4f43-a268-da72b3e2b60e	2025-08-24 07:17:35.97272+00	2025-08-24 07:17:35.97272+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	192.168.65.1	\N
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
4371417d-b004-4f18-9126-ff4c82e6659c	2025-08-24 07:17:35.979541+00	2025-08-24 07:17:35.979541+00	password	7263ea65-c49f-4109-a556-b4106e1a85e4
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	1	gn76s54ew3dj	3cde03f2-7fd4-4f43-a268-da72b3e2b60e	f	2025-08-24 07:17:35.976898+00	2025-08-24 07:17:35.976898+00	\N	4371417d-b004-4f18-9126-ff4c82e6659c
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, content, user_id, project_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (id, target_type, target_id, body, parent_id, created_at, created_by) FROM stdin;
845a482c-eafc-4a19-9d77-ee4b04ff706b	task	11111111-1111-1111-1111-111111111112	コメント入れます。	\N	2025-08-24 07:19:14.544271+00	3cde03f2-7fd4-4f43-a268-da72b3e2b60e
ab5012fc-9717-4599-8809-05eb25b82d86	task	11111111-1111-1111-1111-111111111112	そうそう。入れますよ。	\N	2025-08-24 07:19:28.349899+00	3cde03f2-7fd4-4f43-a268-da72b3e2b60e
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, created_at, created_by, updated_at, updated_by) FROM stdin;
11111111-1111-1111-1111-111111111111	テスト組織	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.46756+00	\N
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, organization_id, name, start_date, end_date, status, created_at, created_by, updated_at, updated_by, description, settings) FROM stdin;
22222222-2222-2222-2222-222222222222	11111111-1111-1111-1111-111111111111	テストプロジェクト	2025-01-01	2025-06-30	active	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.46756+00	\N	\N	{}
\.


--
-- Data for Name: custom_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_statuses (id, project_id, name, label, color, order_index, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, title, description, start, "end", all_day, owner_user_id, color, location, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: status_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status_options (id, name, label, color, weight, is_active, created_at, updated_at) FROM stdin;
a2e76851-f8aa-4cb5-b18c-358595035432	todo	未着手	#6c757d	1	t	2025-08-23 15:20:50.567295+00	2025-08-23 15:20:50.567295+00
999832e7-3bbe-40b9-9f3a-a11734da8b30	review	レビュー中	#ffc107	2	t	2025-08-23 15:20:50.567295+00	2025-08-23 15:20:50.567295+00
5e989a60-3a4d-48fe-8a06-acf3af383800	done	作業完了	#28a745	3	t	2025-08-23 15:20:50.567295+00	2025-08-23 15:20:50.567295+00
84e6ba57-c8a8-431e-8124-de32870e35aa	resolved	対応済み	#17a2b8	4	t	2025-08-23 15:20:50.567295+00	2025-08-23 15:20:50.567295+00
eaefd296-532f-4deb-9073-3ef470f1f282	completed	完了済み	#6f42c1	5	t	2025-08-23 15:20:50.567295+00	2025-08-23 15:20:50.567295+00
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, project_id, title, description, priority, due_at, created_at, created_by, updated_at, updated_by, status, custom_status_id, storage_folder, status_option_id) FROM stdin;
11111111-1111-1111-1111-111111111112	22222222-2222-2222-2222-222222222222	講演者調整	キーオピニオンリーダーおよび治験責任医師との連絡調整	high	2025-02-28 00:00:00+00	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.574885+00	\N	todo	\N	task_11111111-1111-1111-1111-111111111112	a2e76851-f8aa-4cb5-b18c-358595035432
11111111-1111-1111-1111-111111111113	22222222-2222-2222-2222-222222222222	マーケティング資料作成	パンフレット、バナー、デジタル素材の制作	medium	2025-03-10 00:00:00+00	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.574885+00	\N	review	\N	task_11111111-1111-1111-1111-111111111113	999832e7-3bbe-40b9-9f3a-a11734da8b30
11111111-1111-1111-1111-111111111114	22222222-2222-2222-2222-222222222222	参加登録システム構築	オンライン参加登録システムとバッジ印刷機能の実装	medium	2025-01-30 00:00:00+00	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.574885+00	\N	done	\N	task_11111111-1111-1111-1111-111111111114	5e989a60-3a4d-48fe-8a06-acf3af383800
11111111-1111-1111-1111-111111111115	22222222-2222-2222-2222-222222222222	ケータリング手配	メニュー企画と食事制限対応の準備	low	2025-03-01 00:00:00+00	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.574885+00	\N	resolved	\N	task_11111111-1111-1111-1111-111111111115	84e6ba57-c8a8-431e-8124-de32870e35aa
11111111-1111-1111-1111-111111111111	22222222-2222-2222-2222-222222222222	会場選定・予約	治験イベント会場の調査と予約手配を行う	high	2025-02-15 00:00:00+00	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001	2025-08-24 07:18:59.397673+00	3cde03f2-7fd4-4f43-a268-da72b3e2b60e	todo	\N	task_11111111-1111-1111-1111-111111111111	a2e76851-f8aa-4cb5-b18c-358595035432
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.files (id, project_id, name, provider, external_id, external_url, current_version, created_at, created_by, updated_at, updated_by, description, file_type, mime_type, storage_path, total_versions, total_size_bytes, current_version_id, task_id) FROM stdin;
\.


--
-- Data for Name: file_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.file_versions (id, file_id, version, size_bytes, checksum, storage_key, uploaded_at, uploaded_by, name, storage_path, external_id, upload_status, change_notes, created_by, created_at, version_number) FROM stdin;
\.


--
-- Data for Name: mentions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mentions (id, message_id, mentioned_user_id, mentioned_by_user_id, project_id, mention_text, read_at, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, payload, read_at, created_at) FROM stdin;
e339a5e6-de96-47d4-b095-56e86929f594	550e8400-e29b-41d4-a716-446655440001	task_updated	{"task_id": "11111111-1111-1111-1111-111111111111", "changed_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e", "new_status": "review", "old_status": "todo", "project_id": "22222222-2222-2222-2222-222222222222", "task_title": "会場選定・予約", "change_type": "updated"}	\N	2025-08-24 07:17:38.32296+00
4f53ac9a-e977-42f2-ab89-c0183067d1d8	550e8400-e29b-41d4-a716-446655440002	task_updated	{"task_id": "11111111-1111-1111-1111-111111111111", "changed_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e", "new_status": "review", "old_status": "todo", "project_id": "22222222-2222-2222-2222-222222222222", "task_title": "会場選定・予約", "change_type": "updated"}	\N	2025-08-24 07:17:38.32296+00
4dbf43a7-9141-497a-a405-03586c883f30	550e8400-e29b-41d4-a716-446655440001	task_updated	{"task_id": "11111111-1111-1111-1111-111111111111", "changed_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e", "new_status": "completed", "old_status": "review", "project_id": "22222222-2222-2222-2222-222222222222", "task_title": "会場選定・予約", "change_type": "updated"}	\N	2025-08-24 07:18:41.966081+00
4e8b81d7-7f54-4bb8-b8fd-1bb24dfdddd2	550e8400-e29b-41d4-a716-446655440002	task_updated	{"task_id": "11111111-1111-1111-1111-111111111111", "changed_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e", "new_status": "completed", "old_status": "review", "project_id": "22222222-2222-2222-2222-222222222222", "task_title": "会場選定・予約", "change_type": "updated"}	\N	2025-08-24 07:18:41.966081+00
e1b68f9f-1c7a-4013-94de-22a9b8353c0a	550e8400-e29b-41d4-a716-446655440001	task_updated	{"task_id": "11111111-1111-1111-1111-111111111111", "changed_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e", "new_status": "todo", "old_status": "completed", "project_id": "22222222-2222-2222-2222-222222222222", "task_title": "会場選定・予約", "change_type": "updated"}	\N	2025-08-24 07:18:59.397673+00
f4612188-c11b-4777-89e5-79ff810e7c19	550e8400-e29b-41d4-a716-446655440002	task_updated	{"task_id": "11111111-1111-1111-1111-111111111111", "changed_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e", "new_status": "todo", "old_status": "completed", "project_id": "22222222-2222-2222-2222-222222222222", "task_title": "会場選定・予約", "change_type": "updated"}	\N	2025-08-24 07:18:59.397673+00
d60db7c8-e0b1-4c32-b061-7975b2ad57ca	550e8400-e29b-41d4-a716-446655440001	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "845a482c-eafc-4a19-9d77-ee4b04ff706b", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "コメント入れます。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:14.544271+00
90afb04d-1f0d-4973-bfdf-945ad8583815	550e8400-e29b-41d4-a716-446655440002	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "845a482c-eafc-4a19-9d77-ee4b04ff706b", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "コメント入れます。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:14.544271+00
349a9ea9-d0c9-421d-b578-8514b22cf531	550e8400-e29b-41d4-a716-446655440003	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "845a482c-eafc-4a19-9d77-ee4b04ff706b", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "コメント入れます。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:14.544271+00
07c17ce6-6e08-4f29-b3f8-014ea6e8a935	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "845a482c-eafc-4a19-9d77-ee4b04ff706b", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "コメント入れます。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:14.544271+00
def5aad7-f4ae-400d-a7fa-2fc1f09a5b23	550e8400-e29b-41d4-a716-446655440001	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "ab5012fc-9717-4599-8809-05eb25b82d86", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "そうそう。入れますよ。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:28.349899+00
26a3dd35-250d-4d8c-8d58-abd292e565ae	550e8400-e29b-41d4-a716-446655440002	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "ab5012fc-9717-4599-8809-05eb25b82d86", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "そうそう。入れますよ。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:28.349899+00
f711c03a-8066-4054-801d-ab3534d5db4b	550e8400-e29b-41d4-a716-446655440003	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "ab5012fc-9717-4599-8809-05eb25b82d86", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "そうそう。入れますよ。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:28.349899+00
79973d8e-b776-4389-8bdd-d13ecf4d223f	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	task_commented	{"target_id": "11111111-1111-1111-1111-111111111112", "comment_id": "ab5012fc-9717-4599-8809-05eb25b82d86", "project_id": "22222222-2222-2222-2222-222222222222", "target_type": "task", "comment_body": "そうそう。入れますよ。", "commented_by": "3cde03f2-7fd4-4f43-a268-da72b3e2b60e"}	\N	2025-08-24 07:19:28.349899+00
\.


--
-- Data for Name: organization_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_memberships (org_id, user_id, role, created_at, created_by) FROM stdin;
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440001	admin	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440002	project_manager	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440003	contributor	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111111	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	admin	2025-08-23 15:20:50.484029+00	\N
\.


--
-- Data for Name: priority_change_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.priority_change_history (id, task_id, user_id, old_priority, new_priority, changed_at, reason) FROM stdin;
\.


--
-- Data for Name: priority_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.priority_options (id, name, label, color, weight, is_active, created_at, updated_at) FROM stdin;
987db261-d6ce-4865-8fca-aee5afd8613f	low	低	#28a745	1	t	2025-08-23 15:20:50.420019+00	2025-08-23 15:20:50.501908+00
86bb0a37-225f-4d1e-afa4-8ae2387f3ec6	medium	中	#007bff	2	t	2025-08-23 15:20:50.420019+00	2025-08-23 15:20:50.501908+00
c8d92e0c-c2da-42d6-8dbc-bf999d5abc6a	high	高	#ffc107	3	t	2025-08-23 15:20:50.420019+00	2025-08-23 15:20:50.501908+00
4c8e8288-5959-4691-b1f0-b686818350f0	urgent	緊急	#dc3545	4	t	2025-08-23 15:20:50.420019+00	2025-08-23 15:20:50.501908+00
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (user_id, display_name, company, created_at, updated_at) FROM stdin;
3cde03f2-7fd4-4f43-a268-da72b3e2b60e	田中角栄	総督府	2025-08-24 07:17:29.934192+00	2025-08-24 07:19:45.552609+00
\.


--
-- Data for Name: project_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_memberships (project_id, user_id, role, created_at, created_by) FROM stdin;
22222222-2222-2222-2222-222222222222	550e8400-e29b-41d4-a716-446655440001	admin	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
22222222-2222-2222-2222-222222222222	550e8400-e29b-41d4-a716-446655440002	admin	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
22222222-2222-2222-2222-222222222222	550e8400-e29b-41d4-a716-446655440003	member	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
22222222-2222-2222-2222-222222222222	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	admin	2025-08-23 15:20:50.484029+00	\N
\.


--
-- Data for Name: role_change_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_change_history (id, user_id, old_role, new_role, changed_by, changed_at) FROM stdin;
\.


--
-- Data for Name: status_change_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status_change_history (id, task_id, user_id, old_status, new_status, changed_at, reason) FROM stdin;
152aca15-c463-4dc5-89aa-d79be66d80e3	11111111-1111-1111-1111-111111111111	3cde03f2-7fd4-4f43-a268-da72b3e2b60e	todo	review	2025-08-24 07:17:38.32296+00	Status updated via UI
30f07843-6a62-4473-8b4f-834e4067fb6a	11111111-1111-1111-1111-111111111111	3cde03f2-7fd4-4f43-a268-da72b3e2b60e	review	completed	2025-08-24 07:18:41.966081+00	Status updated via UI
4a040aaa-18b8-4e08-9695-f90747c08aea	11111111-1111-1111-1111-111111111111	3cde03f2-7fd4-4f43-a268-da72b3e2b60e	completed	todo	2025-08-24 07:18:59.397673+00	Status updated via UI
\.


--
-- Data for Name: task_assignees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_assignees (task_id, user_id, created_at, created_by) FROM stdin;
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440002	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111112	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111113	550e8400-e29b-41d4-a716-446655440003	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111114	550e8400-e29b-41d4-a716-446655440003	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111115	550e8400-e29b-41d4-a716-446655440002	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
\.


--
-- Data for Name: task_links; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_links (id, task_id, title, url, link_type, description, file_id, storage_provider, storage_key, created_at, created_by, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: task_watchers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_watchers (task_id, user_id, created_at, created_by) FROM stdin;
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111112	550e8400-e29b-41d4-a716-446655440002	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111113	550e8400-e29b-41d4-a716-446655440001	2025-08-23 15:20:50.401091+00	550e8400-e29b-41d4-a716-446655440001
\.


--
-- Data for Name: messages_2025_08_22; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_22 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_23; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_23 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_24; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_24 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_25; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_25 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_26; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_26 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_27; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_27 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-08-23 15:20:47
20211116045059	2025-08-23 15:20:47
20211116050929	2025-08-23 15:20:47
20211116051442	2025-08-23 15:20:47
20211116212300	2025-08-23 15:20:47
20211116213355	2025-08-23 15:20:47
20211116213934	2025-08-23 15:20:47
20211116214523	2025-08-23 15:20:47
20211122062447	2025-08-23 15:20:47
20211124070109	2025-08-23 15:20:47
20211202204204	2025-08-23 15:20:47
20211202204605	2025-08-23 15:20:47
20211210212804	2025-08-23 15:20:47
20211228014915	2025-08-23 15:20:47
20220107221237	2025-08-23 15:20:47
20220228202821	2025-08-23 15:20:47
20220312004840	2025-08-23 15:20:47
20220603231003	2025-08-23 15:20:47
20220603232444	2025-08-23 15:20:47
20220615214548	2025-08-23 15:20:47
20220712093339	2025-08-23 15:20:47
20220908172859	2025-08-23 15:20:47
20220916233421	2025-08-23 15:20:47
20230119133233	2025-08-23 15:20:47
20230128025114	2025-08-23 15:20:47
20230128025212	2025-08-23 15:20:47
20230227211149	2025-08-23 15:20:47
20230228184745	2025-08-23 15:20:47
20230308225145	2025-08-23 15:20:47
20230328144023	2025-08-23 15:20:47
20231018144023	2025-08-23 15:20:47
20231204144023	2025-08-23 15:20:47
20231204144024	2025-08-23 15:20:47
20231204144025	2025-08-23 15:20:47
20240108234812	2025-08-23 15:20:47
20240109165339	2025-08-23 15:20:47
20240227174441	2025-08-23 15:20:47
20240311171622	2025-08-23 15:20:47
20240321100241	2025-08-23 15:20:47
20240401105812	2025-08-23 15:20:47
20240418121054	2025-08-23 15:20:47
20240523004032	2025-08-23 15:20:47
20240618124746	2025-08-23 15:20:47
20240801235015	2025-08-23 15:20:47
20240805133720	2025-08-23 15:20:47
20240827160934	2025-08-23 15:20:47
20240919163303	2025-08-23 15:20:47
20240919163305	2025-08-23 15:20:47
20241019105805	2025-08-23 15:20:47
20241030150047	2025-08-23 15:20:47
20241108114728	2025-08-23 15:20:47
20241121104152	2025-08-23 15:20:47
20241130184212	2025-08-23 15:20:47
20241220035512	2025-08-23 15:20:47
20241220123912	2025-08-23 15:20:47
20241224161212	2025-08-23 15:20:47
20250107150512	2025-08-23 15:20:47
20250110162412	2025-08-23 15:20:47
20250123174212	2025-08-23 15:20:47
20250128220012	2025-08-23 15:20:47
20250506224012	2025-08-23 15:20:47
20250523164012	2025-08-23 15:20:47
20250714121412	2025-08-23 15:20:47
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: roles; Owner: postgres
--

COPY roles.user_roles (user_id, role_name, granted_by, granted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
files	files	\N	2025-08-23 15:20:50.443939+00	2025-08-23 15:20:50.443939+00	f	f	52428800	\N	\N	STANDARD
task-files	task-files	\N	2025-08-23 15:20:50.545728+00	2025-08-23 15:20:50.545728+00	t	f	52428800	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_analytics (id, type, format, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.iceberg_namespaces (id, bucket_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.iceberg_tables (id, namespace_id, bucket_id, name, location, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-08-23 15:20:49.629103
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-08-23 15:20:49.63093
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-08-23 15:20:49.631517
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-08-23 15:20:49.635685
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-08-23 15:20:49.638261
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-08-23 15:20:49.639166
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-08-23 15:20:49.640899
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-08-23 15:20:49.642037
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-08-23 15:20:49.642838
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-08-23 15:20:49.643687
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-08-23 15:20:49.645194
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-08-23 15:20:49.646673
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-08-23 15:20:49.647819
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-08-23 15:20:49.648666
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-08-23 15:20:49.649441
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-08-23 15:20:49.6546
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-08-23 15:20:49.655694
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-08-23 15:20:49.656604
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-08-23 15:20:49.657494
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-08-23 15:20:49.658812
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-08-23 15:20:49.659553
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-08-23 15:20:49.660771
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-08-23 15:20:49.66395
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-08-23 15:20:49.66653
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-08-23 15:20:49.667707
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-08-23 15:20:49.668763
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-08-23 15:20:49.66953
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-08-23 15:20:49.673283
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-08-23 15:20:49.690998
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-08-23 15:20:49.692786
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-08-23 15:20:49.693862
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-08-23 15:20:49.695109
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-08-23 15:20:49.696109
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-08-23 15:20:49.697166
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-08-23 15:20:49.69742
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-08-23 15:20:49.698902
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-08-23 15:20:49.699845
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-08-23 15:20:49.702121
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-08-23 15:20:49.703645
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

COPY supabase_functions.hooks (id, hook_table_id, hook_name, created_at, request_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

COPY supabase_functions.migrations (version, inserted_at) FROM stdin;
initial	2025-08-23 15:20:37.002553+00
20210809183423_update_grants	2025-08-23 15:20:37.002553+00
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.schema_migrations (version, statements, name) FROM stdin;
20250816113800	{"-- Imported from iqvia_jtb_migrations/001_schema.sql\n-- Schema for IQVIA × JTB Task Management Tool (Supabase/PostgreSQL)\ncreate extension if not exists pgcrypto","-- profiles table definition moved to 20250820200000_create_profiles_table.sql\ncreate table if not exists public.organizations (\n  id uuid primary key default gen_random_uuid(),\n  name text not null,\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  updated_at timestamptz,\n  updated_by uuid references auth.users(id)\n)","create table if not exists public.organization_memberships (\n  org_id uuid references public.organizations(id) on delete cascade,\n  user_id uuid references auth.users(id) on delete cascade,\n  role text not null check (role in ('admin','org_manager','project_manager','contributor','viewer')),\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  primary key (org_id, user_id)\n)","create table if not exists public.projects (\n  id uuid primary key default gen_random_uuid(),\n  org_id uuid not null references public.organizations(id) on delete cascade,\n  name text not null,\n  start_date date,\n  end_date date,\n  status text default 'active',\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  updated_at timestamptz,\n  updated_by uuid references auth.users(id)\n)","create table if not exists public.project_memberships (\n  project_id uuid references public.projects(id) on delete cascade,\n  user_id uuid references auth.users(id) on delete cascade,\n  role text not null check (role in ('project_manager','contributor','viewer')),\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  primary key (project_id, user_id)\n)","do $$ begin create type public.task_status as enum ('todo','doing','review','done','blocked'); exception when duplicate_object then null; end $$","do $$ begin create type public.task_priority as enum ('low','medium','high','urgent'); exception when duplicate_object then null; end $$","do $$ begin create type public.storage_provider as enum ('box','supabase'); exception when duplicate_object then null; end $$","do $$ begin create type public.comment_target as enum ('task','file'); exception when duplicate_object then null; end $$","do $$ begin create type public.notify_type as enum ('task_updated','task_commented','file_versioned','mention'); exception when duplicate_object then null; end $$","create table if not exists public.tasks (\n  id uuid primary key default gen_random_uuid(),\n  project_id uuid not null references public.projects(id) on delete cascade,\n  title text not null,\n  description text,\n  status public.task_status not null default 'todo',\n  priority public.task_priority not null default 'medium',\n  due_at timestamptz,\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  updated_at timestamptz,\n  updated_by uuid references auth.users(id)\n)","create table if not exists public.task_assignees (\n  task_id uuid references public.tasks(id) on delete cascade,\n  user_id uuid references auth.users(id) on delete cascade,\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  primary key (task_id, user_id)\n)","create table if not exists public.task_watchers (\n  task_id uuid references public.tasks(id) on delete cascade,\n  user_id uuid references auth.users(id) on delete cascade,\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  primary key (task_id, user_id)\n)","create table if not exists public.files (\n  id uuid primary key default gen_random_uuid(),\n  project_id uuid not null references public.projects(id) on delete cascade,\n  name text not null,\n  provider public.storage_provider not null,\n  external_id text,\n  external_url text,\n  current_version int default 1,\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id),\n  updated_at timestamptz,\n  updated_by uuid references auth.users(id)\n)","create table if not exists public.file_versions (\n  id uuid primary key default gen_random_uuid(),\n  file_id uuid not null references public.files(id) on delete cascade,\n  version int not null,\n  size_bytes bigint,\n  checksum text,\n  storage_key text,\n  uploaded_at timestamptz default now(),\n  uploaded_by uuid references auth.users(id)\n)","create table if not exists public.comments (\n  id uuid primary key default gen_random_uuid(),\n  target_type public.comment_target not null,\n  target_id uuid not null,\n  body text not null,\n  parent_id uuid,\n  created_at timestamptz default now(),\n  created_by uuid references auth.users(id)\n)","create table if not exists public.notifications (\n  id uuid primary key default gen_random_uuid(),\n  user_id uuid not null references auth.users(id) on delete cascade,\n  type public.notify_type not null,\n  payload jsonb not null,\n  read_at timestamptz,\n  created_at timestamptz default now()\n)","create index if not exists idx_tasks_project_status_prio on public.tasks(project_id, status, priority)","create index if not exists idx_comments_target_created on public.comments(target_type, target_id, created_at)","create index if not exists idx_notifications_user_created on public.notifications(user_id, created_at)"}	init_schema
20250816113810	{"-- Row Level Security (RLS) Policies\n-- Enable RLS on all tables\n-- profiles table RLS moved to 20250820200000_create_profiles_table.sql\nalter table public.organizations enable row level security","alter table public.organization_memberships enable row level security","alter table public.projects enable row level security","alter table public.project_memberships enable row level security","alter table public.tasks enable row level security","alter table public.task_assignees enable row level security","alter table public.task_watchers enable row level security","alter table public.files enable row level security","alter table public.file_versions enable row level security","alter table public.comments enable row level security","alter table public.notifications enable row level security","-- Helper functions for RLS\ncreate or replace function public.is_org_member(org_uuid uuid)\nreturns boolean as $$\nbegin\n  return exists (\n    select 1 from public.organization_memberships\n    where org_id = org_uuid and user_id = auth.uid()\n  );\nend;\n$$ language plpgsql security definer","create or replace function public.is_project_member(project_uuid uuid)\nreturns boolean as $$\nbegin\n  return exists (\n    select 1 from public.project_memberships\n    where project_id = project_uuid and user_id = auth.uid()\n  );\nend;\n$$ language plpgsql security definer","create or replace function public.has_project_role(project_uuid uuid, required_roles text[])\nreturns boolean as $$\nbegin\n  return exists (\n    select 1 from public.project_memberships\n    where project_id = project_uuid \n      and user_id = auth.uid()\n      and role = any(required_roles)\n  );\nend;\n$$ language plpgsql security definer","create or replace function public.get_project_id_from_task(task_uuid uuid)\nreturns uuid as $$\nbegin\n  return (select project_id from public.tasks where id = task_uuid);\nend;\n$$ language plpgsql security definer","-- Profiles policies moved to 20250820200000_create_profiles_table.sql\n\n-- Organizations: Simplified to avoid recursion\ncreate policy \\"Users can view all organizations\\" on public.organizations\n  for select using (true)","create policy \\"Users can manage organizations\\" on public.organizations\n  for all using (true)","-- Organization memberships: Simplified to avoid recursion\ncreate policy \\"Users can view all org memberships\\" on public.organization_memberships\n  for select using (true)","create policy \\"Users can manage their own membership\\" on public.organization_memberships\n  for all using (user_id = auth.uid())","-- Projects: Simplified to avoid recursion\ncreate policy \\"Users can view all projects\\" on public.projects\n  for select using (true)","create policy \\"Users can manage projects\\" on public.projects\n  for all using (true)","-- Project memberships: Simplified to avoid recursion\ncreate policy \\"Users can view all project memberships\\" on public.project_memberships\n  for select using (true)","create policy \\"Users can manage their own project membership\\" on public.project_memberships\n  for all using (user_id = auth.uid())","-- Tasks: Simplified to avoid recursion\ncreate policy \\"Users can view all tasks\\" on public.tasks\n  for select using (true)","create policy \\"Users can create tasks\\" on public.tasks\n  for insert with check (true)","create policy \\"Users can update tasks\\" on public.tasks\n  for update using (true)","create policy \\"Users can delete tasks\\" on public.tasks\n  for delete using (true)","-- Task assignees: Simplified to avoid recursion\ncreate policy \\"Users can view all task assignees\\" on public.task_assignees\n  for select using (true)","create policy \\"Users can manage task assignees\\" on public.task_assignees\n  for all using (true)","-- Task watchers: Simplified to avoid recursion\ncreate policy \\"Users can view all task watchers\\" on public.task_watchers\n  for select using (true)","create policy \\"Users can manage task watchers\\" on public.task_watchers\n  for all using (true)","-- Files: Simplified to avoid recursion\ncreate policy \\"Users can view all files\\" on public.files\n  for select using (true)","create policy \\"Users can manage files\\" on public.files\n  for all using (true)","-- File versions: Simplified to avoid recursion\ncreate policy \\"Users can view all file versions\\" on public.file_versions\n  for select using (true)","create policy \\"Users can manage file versions\\" on public.file_versions\n  for all using (true)","-- Comments: Simplified to avoid recursion\ncreate policy \\"Users can view all comments\\" on public.comments\n  for select using (true)","create policy \\"Users can create comments\\" on public.comments\n  for insert with check (true)","create policy \\"Comment authors can update their comments\\" on public.comments\n  for update using (created_by = auth.uid())","-- Notifications: Users can only see their own notifications\ncreate policy \\"Users can view own notifications\\" on public.notifications\n  for select using (user_id = auth.uid())","create policy \\"Users can update own notifications\\" on public.notifications\n  for update using (user_id = auth.uid())","-- Service role can insert notifications (for triggers)\ncreate policy \\"Service role can insert notifications\\" on public.notifications\n  for insert with check (true)"}	rls_placeholder
20250816113820	{"-- Triggers for automatic timestamp and notification handling\n\n-- Function to set updated_at and updated_by columns\ncreate or replace function public.set_updated_columns()\nreturns trigger as $$\nbegin\n  new.updated_at = now();\n  new.updated_by = auth.uid();\n  return new;\nend;\n$$ language plpgsql","-- Function to create notifications for task updates\ncreate or replace function public.notify_task_update()\nreturns trigger as $$\ndeclare\n  watcher_id uuid;\n  assignee_id uuid;\n  payload_data jsonb;\nbegin\n  -- Build notification payload\n  payload_data = jsonb_build_object(\n    'task_id', new.id,\n    'task_title', new.title,\n    'project_id', new.project_id,\n    'changed_by', auth.uid(),\n    'old_status', coalesce(old.status::text, 'new'),\n    'new_status', new.status::text,\n    'change_type', case when old is null then 'created' else 'updated' end\n  );\n\n  -- Notify task watchers\n  for watcher_id in \n    select user_id from public.task_watchers \n    where task_id = new.id and user_id != auth.uid()\n  loop\n    insert into public.notifications (user_id, type, payload)\n    values (watcher_id, 'task_updated', payload_data);\n  end loop;\n\n  -- Notify task assignees (if not already notified as watcher)\n  for assignee_id in \n    select user_id from public.task_assignees \n    where task_id = new.id \n      and user_id != auth.uid()\n      and not exists (\n        select 1 from public.task_watchers \n        where task_id = new.id and user_id = assignee_id\n      )\n  loop\n    insert into public.notifications (user_id, type, payload)\n    values (assignee_id, 'task_updated', payload_data);\n  end loop;\n\n  return new;\nend;\n$$ language plpgsql security definer","-- Function to create notifications for comments\ncreate or replace function public.notify_comment_created()\nreturns trigger as $$\ndeclare\n  target_project_id uuid;\n  member_id uuid;\n  payload_data jsonb;\nbegin\n  -- Get project ID based on comment target\n  if new.target_type = 'task' then\n    select project_id into target_project_id\n    from public.tasks where id = new.target_id;\n  elsif new.target_type = 'file' then\n    select project_id into target_project_id\n    from public.files where id = new.target_id;\n  end if;\n\n  -- Build notification payload\n  payload_data = jsonb_build_object(\n    'comment_id', new.id,\n    'target_type', new.target_type,\n    'target_id', new.target_id,\n    'project_id', target_project_id,\n    'comment_body', left(new.body, 100),\n    'commented_by', auth.uid()\n  );\n\n  -- Notify all project members except the comment author\n  for member_id in \n    select user_id from public.project_memberships \n    where project_id = target_project_id and user_id != auth.uid()\n  loop\n    insert into public.notifications (user_id, type, payload)\n    values (member_id, 'task_commented', payload_data);\n  end loop;\n\n  return new;\nend;\n$$ language plpgsql security definer","-- Apply triggers to relevant tables\n-- Updated at/by triggers\ncreate trigger set_updated_at_organizations\n  before update on public.organizations\n  for each row execute function public.set_updated_columns()","create trigger set_updated_at_projects\n  before update on public.projects\n  for each row execute function public.set_updated_columns()","create trigger set_updated_at_tasks\n  before update on public.tasks\n  for each row execute function public.set_updated_columns()","create trigger set_updated_at_files\n  before update on public.files\n  for each row execute function public.set_updated_columns()","-- profiles trigger moved to 20250820200000_create_profiles_table.sql\n\n-- Notification triggers\ncreate trigger notify_on_task_change\n  after insert or update on public.tasks\n  for each row execute function public.notify_task_update()","create trigger notify_on_comment_insert\n  after insert on public.comments\n  for each row execute function public.notify_comment_created()"}	triggers_placeholder
20250816113830	{"-- Sample data for development\n-- Note: In production, auth.users will be created via Supabase Auth\n\n-- Create sample users (mock UUIDs for dev)\n-- These would normally be created via Supabase Auth signup\ninsert into auth.users (id, email, created_at) values \n  ('550e8400-e29b-41d4-a716-446655440001', 'admin@iqvia.com', now()),\n  ('550e8400-e29b-41d4-a716-446655440002', 'pm@jtb.com', now()),\n  ('550e8400-e29b-41d4-a716-446655440003', 'dev@vendor.com', now())\non conflict (id) do nothing","-- Create profiles (moved to 20250820200000_create_profiles_table.sql)\n-- Profiles will be created through auth system instead of seed data\n\n-- Create sample organization\ninsert into public.organizations (id, name, created_by) values\n  ('11111111-1111-1111-1111-111111111111', 'IQVIA × JTB Alliance', '550e8400-e29b-41d4-a716-446655440001')\non conflict (id) do nothing","-- Create organization memberships\ninsert into public.organization_memberships (org_id, user_id, role, created_by) values\n  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', 'admin', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', 'project_manager', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440003', 'contributor', '550e8400-e29b-41d4-a716-446655440001')\non conflict (org_id, user_id) do nothing","-- Create sample project\ninsert into public.projects (id, org_id, name, start_date, end_date, created_by) values\n  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Phase 3 Clinical Trial Event', '2025-01-01', '2025-06-30', '550e8400-e29b-41d4-a716-446655440001')\non conflict (id) do nothing","-- Create project memberships\ninsert into public.project_memberships (project_id, user_id, role, created_by) values\n  ('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440001', 'project_manager', '550e8400-e29b-41d4-a716-446655440001'),\n  ('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440002', 'project_manager', '550e8400-e29b-41d4-a716-446655440001'),\n  ('22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440003', 'contributor', '550e8400-e29b-41d4-a716-446655440001')\non conflict (project_id, user_id) do nothing","-- Insert sample tasks\ninsert into public.tasks (id, title, description, status, priority, project_id, due_at, created_by, updated_by) values\n('11111111-1111-1111-1111-111111111111', '会場選定・予約', '治験イベント会場の調査と予約手配を行う', 'todo', 'high', '22222222-2222-2222-2222-222222222222', '2025-02-15T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),\n('11111111-1111-1111-1111-111111111112', '講演者調整', 'キーオピニオンリーダーおよび治験責任医師との連絡調整', 'doing', 'high', '22222222-2222-2222-2222-222222222222', '2025-02-28T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),\n('11111111-1111-1111-1111-111111111113', 'マーケティング資料作成', 'パンフレット、バナー、デジタル素材の制作', 'review', 'medium', '22222222-2222-2222-2222-222222222222', '2025-03-10T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),\n('11111111-1111-1111-1111-111111111114', '参加登録システム構築', 'オンライン参加登録システムとバッジ印刷機能の実装', 'done', 'medium', '22222222-2222-2222-2222-222222222222', '2025-01-30T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),\n('11111111-1111-1111-1111-111111111115', 'ケータリング手配', 'メニュー企画と食事制限対応の準備', 'blocked', 'low', '22222222-2222-2222-2222-222222222222', '2025-03-01T00:00:00.000Z', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001')\non conflict (id) do nothing","-- Create task assignments\ninsert into public.task_assignees (task_id, user_id, created_by) values\n  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111114', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111115', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001')\non conflict (task_id, user_id) do nothing","-- Create task watchers\ninsert into public.task_watchers (task_id, user_id, created_by) values\n  ('11111111-1111-1111-1111-111111111111', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111112', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),\n  ('11111111-1111-1111-1111-111111111113', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001')\non conflict (task_id, user_id) do nothing"}	seed_placeholder
20250817000001	{"-- Chat messages table\ncreate table if not exists public.chat_messages (\n  id uuid primary key default gen_random_uuid(),\n  project_id uuid not null references public.projects(id) on delete cascade,\n  user_id uuid not null references auth.users(id) on delete cascade,\n  content text not null,\n  created_at timestamptz default now(),\n  updated_at timestamptz default now()\n)","-- Enable RLS\nalter table public.chat_messages enable row level security","-- Create policies for chat messages\ncreate policy \\"Users can view project chat messages\\" on public.chat_messages\n  for select using (\n    exists (\n      select 1 from public.project_memberships pm\n      where pm.project_id = chat_messages.project_id\n      and pm.user_id = auth.uid()\n    )\n  )","create policy \\"Users can insert project chat messages\\" on public.chat_messages\n  for insert with check (\n    user_id = auth.uid()\n  )","create policy \\"Users can update own chat messages\\" on public.chat_messages\n  for update using (user_id = auth.uid())","create policy \\"Users can delete own chat messages\\" on public.chat_messages\n  for delete using (user_id = auth.uid())","-- Create index for better performance\ncreate index if not exists idx_chat_messages_project_created on public.chat_messages(project_id, created_at desc)","-- Enable realtime\nalter publication supabase_realtime add table public.chat_messages"}	chat_system
20250817120001	{"-- Priority options table\ncreate table if not exists public.priority_options (\n  id uuid primary key default gen_random_uuid(),\n  name varchar(50) not null unique,\n  label varchar(100) not null,\n  color varchar(7) not null,\n  weight integer not null unique,\n  is_active boolean default true,\n  created_at timestamptz default now(),\n  updated_at timestamptz default now()\n)","-- Priority change history table\ncreate table if not exists public.priority_change_history (\n  id uuid primary key default gen_random_uuid(),\n  task_id uuid not null references public.tasks(id) on delete cascade,\n  user_id uuid not null references auth.users(id),\n  old_priority varchar(50),\n  new_priority varchar(50) not null,\n  changed_at timestamptz default now(),\n  reason text\n)","-- Insert default priority options\ninsert into public.priority_options (name, label, color, weight) values\n  ('low', '低', '#28a745', 1),\n  ('medium', '中', '#ffc107', 2),\n  ('high', '高', '#fd7e14', 3),\n  ('urgent', '緊急', '#dc3545', 4)","-- Enable RLS\nalter table public.priority_options enable row level security","alter table public.priority_change_history enable row level security","-- RLS policies for priority_options (read-only for authenticated users)\ncreate policy \\"All users can view priority options\\" on public.priority_options\n  for select using (auth.role() = 'authenticated')","-- RLS policies for priority_change_history\ncreate policy \\"Users can view all priority history\\" on public.priority_change_history\n  for select using (auth.role() = 'authenticated')","create policy \\"Users can insert priority history entries\\" on public.priority_change_history\n  for insert with check (user_id = auth.uid())","-- Create indexes for better performance\ncreate index if not exists idx_priority_change_history_task_id on public.priority_change_history(task_id)","create index if not exists idx_priority_change_history_user_id on public.priority_change_history(user_id)","create index if not exists idx_priority_change_history_changed_at on public.priority_change_history(changed_at desc)","-- Update trigger for priority_options\ncreate or replace function update_priority_options_updated_at()\nreturns trigger as $$\nbegin\n  new.updated_at = now();\n  return new;\nend;\n$$ language plpgsql","create trigger trigger_update_priority_options_updated_at\n  before update on public.priority_options\n  for each row execute function update_priority_options_updated_at()","-- Function to log priority changes\ncreate or replace function log_priority_change()\nreturns trigger as $$\nbegin\n  -- Only log if priority actually changed\n  if old.priority is distinct from new.priority then\n    insert into public.priority_change_history (\n      task_id,\n      user_id,\n      old_priority,\n      new_priority,\n      reason\n    ) values (\n      new.id,\n      auth.uid(),\n      old.priority,\n      new.priority,\n      'Priority updated via UI'\n    );\n  end if;\n  return new;\nend;\n$$ language plpgsql security definer","-- Trigger to automatically log priority changes\ncreate trigger trigger_log_priority_change\n  after update on public.tasks\n  for each row execute function log_priority_change()"}	priority_management
20250817130000	{"-- ファイル管理システム強化: 既存テーブルに列追加\n-- Created: 2025-08-17\n\n-- files テーブルに追加列を追加\nALTER TABLE files ADD COLUMN IF NOT EXISTS description TEXT","ALTER TABLE files ADD COLUMN IF NOT EXISTS file_type VARCHAR(100)","-- 'document', 'image', 'video', 'other'\nALTER TABLE files ADD COLUMN IF NOT EXISTS mime_type VARCHAR(255)","ALTER TABLE files ADD COLUMN IF NOT EXISTS storage_path TEXT","-- Supabase Storage path\nALTER TABLE files ADD COLUMN IF NOT EXISTS total_versions INTEGER DEFAULT 1","ALTER TABLE files ADD COLUMN IF NOT EXISTS total_size_bytes BIGINT DEFAULT 0","-- current_version列をcurrent_version_idに変更\nALTER TABLE files ADD COLUMN IF NOT EXISTS current_version_id UUID","-- file_versionsテーブルに追加列を追加\nALTER TABLE file_versions ADD COLUMN IF NOT EXISTS name VARCHAR(255)","ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS storage_path TEXT","ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS external_id VARCHAR(255)","ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS upload_status VARCHAR(50) DEFAULT 'completed'","ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS change_notes TEXT","ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id)","ALTER TABLE file_versions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()","-- version列をversion_number列に統一\nALTER TABLE file_versions ADD COLUMN IF NOT EXISTS version_number INTEGER","-- 既存データの整合性を保つため、version_numberに既存のversionデータをコピー\nUPDATE file_versions SET version_number = version WHERE version_number IS NULL","-- インデックス作成\nCREATE INDEX IF NOT EXISTS idx_files_project_id ON files(project_id)","CREATE INDEX IF NOT EXISTS idx_files_created_by ON files(created_by)","CREATE INDEX IF NOT EXISTS idx_files_file_type ON files(file_type)","CREATE INDEX IF NOT EXISTS idx_file_versions_file_id ON file_versions(file_id)","CREATE INDEX IF NOT EXISTS idx_file_versions_created_by ON file_versions(created_by)","-- UNIQUE制約を追加（存在しない場合のみ）\nDO $$ \nBEGIN\n    BEGIN\n        ALTER TABLE file_versions ADD CONSTRAINT unique_file_version UNIQUE(file_id, version_number);\n    EXCEPTION \n        WHEN duplicate_object THEN NULL;\n    END;\nEND $$","-- current_version_id の外部キー制約を後から追加（エラーを無視）\nDO $$ \nBEGIN\n    BEGIN\n        ALTER TABLE files \n        ADD CONSTRAINT fk_files_current_version \n        FOREIGN KEY (current_version_id) REFERENCES file_versions(id);\n    EXCEPTION \n        WHEN duplicate_object THEN NULL;\n    END;\nEND $$","-- RLS (Row Level Security) 有効化\nALTER TABLE files ENABLE ROW LEVEL SECURITY","ALTER TABLE file_versions ENABLE ROW LEVEL SECURITY","-- RLSポリシー: files\n-- プロジェクトメンバーのみアクセス可能\nCREATE POLICY \\"Enable read access for project members\\" ON files\n    FOR SELECT USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable insert for project members\\" ON files\n    FOR INSERT WITH CHECK (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable update for project members\\" ON files\n    FOR UPDATE USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable delete for project members\\" ON files\n    FOR DELETE USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )","-- RLSポリシー: file_versions\n-- ファイルの親プロジェクトメンバーのみアクセス可能\nCREATE POLICY \\"Enable read access for project members\\" ON file_versions\n    FOR SELECT USING (\n        EXISTS (\n            SELECT 1 FROM files f\n            JOIN project_memberships pm ON pm.project_id = f.project_id\n            WHERE f.id = file_versions.file_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable insert for project members\\" ON file_versions\n    FOR INSERT WITH CHECK (\n        EXISTS (\n            SELECT 1 FROM files f\n            JOIN project_memberships pm ON pm.project_id = f.project_id\n            WHERE f.id = file_versions.file_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable update for project members\\" ON file_versions\n    FOR UPDATE USING (\n        EXISTS (\n            SELECT 1 FROM files f\n            JOIN project_memberships pm ON pm.project_id = f.project_id\n            WHERE f.id = file_versions.file_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable delete for project members\\" ON file_versions\n    FOR DELETE USING (\n        EXISTS (\n            SELECT 1 FROM files f\n            JOIN project_memberships pm ON pm.project_id = f.project_id\n            WHERE f.id = file_versions.file_id \n            AND pm.user_id = auth.uid()\n        )\n    )","-- トリガー: updated_at自動更新\nCREATE OR REPLACE FUNCTION update_files_updated_at()\nRETURNS TRIGGER AS $$\nBEGIN\n    NEW.updated_at = NOW();\n    RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql","CREATE TRIGGER trigger_files_updated_at\n    BEFORE UPDATE ON files\n    FOR EACH ROW\n    EXECUTE FUNCTION update_files_updated_at()","-- リアルタイム通知設定\nALTER PUBLICATION supabase_realtime ADD TABLE files","ALTER PUBLICATION supabase_realtime ADD TABLE file_versions"}	file_management
20250817130001	{"-- Supabase Storage setup for file management\n-- Created: 2025-08-17\n\n-- Create storage bucket for files\nINSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)\nVALUES (\n  'files',\n  'files', \n  false,\n  52428800, -- 50MB limit\n  NULL -- Allow all file types\n) ON CONFLICT (id) DO NOTHING","-- Storage policies for files bucket\n-- Allow authenticated users to upload files\nCREATE POLICY \\"Authenticated users can upload files\\" ON storage.objects\n  FOR INSERT WITH CHECK (\n    bucket_id = 'files' \n    AND auth.role() = 'authenticated'\n  )","-- Allow users to read files from projects they are members of\nCREATE POLICY \\"Users can read project files\\" ON storage.objects\n  FOR SELECT USING (\n    bucket_id = 'files' \n    AND auth.role() = 'authenticated'\n    AND (\n      -- Extract project_id from path (format: project_id/filename)\n      EXISTS (\n        SELECT 1 FROM project_memberships pm \n        WHERE pm.project_id = split_part(name, '/', 1)::uuid\n        AND pm.user_id = auth.uid()\n      )\n    )\n  )","-- Allow users to update files in projects they are members of\nCREATE POLICY \\"Users can update project files\\" ON storage.objects\n  FOR UPDATE USING (\n    bucket_id = 'files' \n    AND auth.role() = 'authenticated'\n    AND (\n      EXISTS (\n        SELECT 1 FROM project_memberships pm \n        WHERE pm.project_id = split_part(name, '/', 1)::uuid\n        AND pm.user_id = auth.uid()\n      )\n    )\n  )","-- Allow users to delete files in projects they are members of\nCREATE POLICY \\"Users can delete project files\\" ON storage.objects\n  FOR DELETE USING (\n    bucket_id = 'files' \n    AND auth.role() = 'authenticated'\n    AND (\n      EXISTS (\n        SELECT 1 FROM project_memberships pm \n        WHERE pm.project_id = split_part(name, '/', 1)::uuid\n        AND pm.user_id = auth.uid()\n      )\n    )\n  )"}	storage_setup
20250817140000	{"-- メンション機能: mentions テーブルとトリガー作成\n-- Created: 2025-08-17\n\n-- mentions テーブル (メンション履歴)\nCREATE TABLE IF NOT EXISTS mentions (\n    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n    message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,\n    mentioned_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,\n    mentioned_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,\n    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,\n    mention_text TEXT NOT NULL, -- @username の形式\n    read_at TIMESTAMP WITH TIME ZONE,\n    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),\n    \n    UNIQUE(message_id, mentioned_user_id)\n)","-- インデックス作成\nCREATE INDEX IF NOT EXISTS idx_mentions_mentioned_user_id ON mentions(mentioned_user_id)","CREATE INDEX IF NOT EXISTS idx_mentions_project_id ON mentions(project_id)","CREATE INDEX IF NOT EXISTS idx_mentions_read_at ON mentions(read_at)","CREATE INDEX IF NOT EXISTS idx_mentions_created_at ON mentions(created_at)","-- RLS (Row Level Security) 有効化\nALTER TABLE mentions ENABLE ROW LEVEL SECURITY","-- RLSポリシー: mentions\n-- メンションされたユーザーのみ自分のメンションを閲覧可能\nCREATE POLICY \\"Users can read their own mentions\\" ON mentions\n    FOR SELECT USING (\n        mentioned_user_id = auth.uid()\n    )","-- プロジェクトメンバーのみメンション作成可能\nCREATE POLICY \\"Project members can create mentions\\" ON mentions\n    FOR INSERT WITH CHECK (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = mentions.project_id \n            AND pm.user_id = auth.uid()\n        )\n        AND mentioned_by_user_id = auth.uid()\n    )","-- メンションされたユーザーのみ自分のメンション更新可能（既読状態更新）\nCREATE POLICY \\"Users can update their own mentions\\" ON mentions\n    FOR UPDATE USING (\n        mentioned_user_id = auth.uid()\n    )","-- メンション作成者のみ削除可能\nCREATE POLICY \\"Mention creators can delete mentions\\" ON mentions\n    FOR DELETE USING (\n        mentioned_by_user_id = auth.uid()\n    )","-- メンション検出・作成用の関数\nCREATE OR REPLACE FUNCTION extract_mentions_from_message()\nRETURNS TRIGGER AS $$\nDECLARE\n    mention_regex TEXT := '@([a-zA-Z0-9._-]+)';\n    mention_match TEXT;\n    mentioned_user_record RECORD;\n    user_email TEXT;\nBEGIN\n    -- メッセージからメンション（@username）を抽出\n    FOR mention_match IN \n        SELECT unnest(regexp_split_to_array(NEW.content, '\\\\s+'))\n        WHERE unnest(regexp_split_to_array(NEW.content, '\\\\s+')) ~ mention_regex\n    LOOP\n        -- @を除去してユーザー名を取得\n        user_email := substring(mention_match from 2);\n        \n        -- ユーザーが存在するかチェック（emailで検索）\n        SELECT au.id, p.display_name \n        INTO mentioned_user_record\n        FROM auth.users au\n        LEFT JOIN profiles p ON p.user_id = au.id\n        WHERE au.email = user_email || '@example.com' -- 仮のドメイン追加\n           OR au.email = user_email\n           OR p.display_name = user_email;\n           \n        -- ユーザーが見つかり、プロジェクトメンバーの場合、メンションを作成\n        IF mentioned_user_record.id IS NOT NULL THEN\n            -- プロジェクトメンバーかチェック\n            IF EXISTS (\n                SELECT 1 FROM project_memberships pm \n                WHERE pm.project_id = NEW.project_id \n                AND pm.user_id = mentioned_user_record.id\n            ) THEN\n                -- メンション作成（重複チェック）\n                INSERT INTO mentions (\n                    message_id,\n                    mentioned_user_id,\n                    mentioned_by_user_id,\n                    project_id,\n                    mention_text\n                ) VALUES (\n                    NEW.id,\n                    mentioned_user_record.id,\n                    NEW.user_id,\n                    NEW.project_id,\n                    mention_match\n                ) ON CONFLICT (message_id, mentioned_user_id) DO NOTHING;\n            END IF;\n        END IF;\n    END LOOP;\n    \n    RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql","-- チャットメッセージ挿入時にメンション検出トリガー\nCREATE TRIGGER trigger_extract_mentions\n    AFTER INSERT ON chat_messages\n    FOR EACH ROW\n    EXECUTE FUNCTION extract_mentions_from_message()","-- リアルタイム通知設定\nALTER PUBLICATION supabase_realtime ADD TABLE mentions"}	mentions_system
20250817170000	{"-- タスクステータスの更新\n-- doing (進行中) を削除、blocked (停止中) を resolved (対応済み) に変更\n\n-- 1. 新しいenum型を作成\nCREATE TYPE public.task_status_new AS ENUM ('todo', 'review', 'done', 'resolved')","-- 2. 新しいカラムを追加\nALTER TABLE public.tasks ADD COLUMN status_new public.task_status_new","-- 3. データを移行（マッピング処理）\nUPDATE public.tasks SET status_new = \n  CASE \n    WHEN status = 'todo' THEN 'todo'::public.task_status_new\n    WHEN status = 'doing' THEN 'todo'::public.task_status_new  -- doing -> todo\n    WHEN status = 'review' THEN 'review'::public.task_status_new\n    WHEN status = 'done' THEN 'done'::public.task_status_new\n    WHEN status = 'blocked' THEN 'resolved'::public.task_status_new  -- blocked -> resolved\n    ELSE 'todo'::public.task_status_new\n  END","-- 4. インデックスを削除\nDROP INDEX IF EXISTS idx_tasks_project_status_prio","-- 5. 古いカラムを削除\nALTER TABLE public.tasks DROP COLUMN status","-- 6. 新しいカラムをリネーム\nALTER TABLE public.tasks RENAME COLUMN status_new TO status","-- 7. NOT NULL制約とデフォルト値を設定\nALTER TABLE public.tasks ALTER COLUMN status SET NOT NULL","ALTER TABLE public.tasks ALTER COLUMN status SET DEFAULT 'todo'","-- 8. 古いenum型を削除して新しいものをリネーム\nDROP TYPE IF EXISTS public.task_status CASCADE","ALTER TYPE public.task_status_new RENAME TO task_status","-- 9. インデックスを再作成\nCREATE INDEX idx_tasks_project_status_prio ON public.tasks(project_id, status, priority)"}	update_task_status
20250817290000	{"-- 強制的にchat_messagesのRLSを完全に無効化\n\n-- すべてのポリシーを強制削除\nDO $$\nDECLARE\n    pol RECORD;\nBEGIN\n    FOR pol IN \n        SELECT schemaname, tablename, policyname \n        FROM pg_policies \n        WHERE schemaname = 'public' AND tablename = 'chat_messages'\n    LOOP\n        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', pol.policyname, pol.schemaname, pol.tablename);\n    END LOOP;\nEND $$","-- RLS完全無効化\nALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY","-- 外部キー制約も完全削除\nALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_user_id_fkey","ALTER TABLE public.chat_messages DROP CONSTRAINT IF EXISTS chat_messages_project_id_fkey","-- テーブルの権限設定\nGRANT ALL ON public.chat_messages TO anon","GRANT ALL ON public.chat_messages TO authenticated"}	force_disable_chat_rls
20250817180000	{"-- カスタムステータス機能の追加\n-- プロジェクト別にカスタムステータスを管理\n\n-- 1. カスタムステータステーブルの作成\nCREATE TABLE public.custom_statuses (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,\n  name VARCHAR(100) NOT NULL,\n  label VARCHAR(100) NOT NULL,\n  color VARCHAR(7) NOT NULL, -- hex color code (e.g., #ff0000)\n  order_index INTEGER NOT NULL DEFAULT 0,\n  is_active BOOLEAN NOT NULL DEFAULT true,\n  created_by UUID REFERENCES auth.users(id),\n  created_at TIMESTAMPTZ DEFAULT NOW(),\n  updated_by UUID REFERENCES auth.users(id),\n  updated_at TIMESTAMPTZ DEFAULT NOW(),\n  \n  -- プロジェクト内でのステータス名の一意制約\n  UNIQUE(project_id, name)\n)","-- 2. タスクテーブルにカスタムステータス参照を追加\nALTER TABLE public.tasks ADD COLUMN custom_status_id UUID REFERENCES public.custom_statuses(id)","-- 3. インデックスの作成\nCREATE INDEX idx_custom_statuses_project_id ON public.custom_statuses(project_id)","CREATE INDEX idx_custom_statuses_project_order ON public.custom_statuses(project_id, order_index)","CREATE INDEX idx_tasks_custom_status ON public.tasks(custom_status_id)","-- 4. RLS (Row Level Security) の設定\nALTER TABLE public.custom_statuses ENABLE ROW LEVEL SECURITY","-- プロジェクトメンバーのみアクセス可能\nCREATE POLICY \\"Enable read access for project members\\" ON public.custom_statuses\n  FOR SELECT USING (\n    EXISTS (\n      SELECT 1 FROM public.project_memberships pm\n      WHERE pm.project_id = custom_statuses.project_id \n      AND pm.user_id = auth.uid()\n    )\n  )","CREATE POLICY \\"Enable insert for project members\\" ON public.custom_statuses\n  FOR INSERT WITH CHECK (\n    EXISTS (\n      SELECT 1 FROM public.project_memberships pm\n      WHERE pm.project_id = custom_statuses.project_id \n      AND pm.user_id = auth.uid()\n    )\n  )","CREATE POLICY \\"Enable update for project members\\" ON public.custom_statuses\n  FOR UPDATE USING (\n    EXISTS (\n      SELECT 1 FROM public.project_memberships pm\n      WHERE pm.project_id = custom_statuses.project_id \n      AND pm.user_id = auth.uid()\n    )\n  )","CREATE POLICY \\"Enable delete for project members\\" ON public.custom_statuses\n  FOR DELETE USING (\n    EXISTS (\n      SELECT 1 FROM public.project_memberships pm\n      WHERE pm.project_id = custom_statuses.project_id \n      AND pm.user_id = auth.uid()\n    )\n  )","-- 5. 更新時刻を自動で更新するトリガー\nCREATE OR REPLACE FUNCTION update_updated_at()\nRETURNS TRIGGER AS $$\nBEGIN\n  NEW.updated_at = NOW();\n  NEW.updated_by = auth.uid();\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql","CREATE TRIGGER update_custom_statuses_updated_at\n  BEFORE UPDATE ON public.custom_statuses\n  FOR EACH ROW EXECUTE FUNCTION update_updated_at()","-- 6. リアルタイム通知の設定\nALTER PUBLICATION supabase_realtime ADD TABLE public.custom_statuses"}	custom_status
20250817190000	{"-- Chat messages RLS policy fix\n-- insertポリシーにプロジェクトメンバーシップのチェックを追加\n\n-- 既存のinsertポリシーを削除\nDROP POLICY IF EXISTS \\"Users can insert project chat messages\\" ON public.chat_messages","-- 新しいinsertポリシーを作成（プロジェクトメンバーシップをチェック）\nCREATE POLICY \\"Users can insert project chat messages\\" ON public.chat_messages\n  FOR INSERT WITH CHECK (\n    user_id = auth.uid()\n    AND EXISTS (\n      SELECT 1 FROM public.project_memberships pm\n      WHERE pm.project_id = chat_messages.project_id\n      AND pm.user_id = auth.uid()\n    )\n  )"}	fix_chat_rls
20250817200000	{"-- Fix foreign key constraint issues by making user references nullable\n-- This prevents errors when users don't exist in auth.users table after database reset\n\n-- Tasks table\nALTER TABLE public.tasks ALTER COLUMN created_by DROP NOT NULL","ALTER TABLE public.tasks ALTER COLUMN updated_by DROP NOT NULL","-- Files table  \nALTER TABLE public.files ALTER COLUMN created_by DROP NOT NULL","ALTER TABLE public.files ALTER COLUMN updated_by DROP NOT NULL","-- Projects table\nALTER TABLE public.projects ALTER COLUMN created_by DROP NOT NULL","ALTER TABLE public.projects ALTER COLUMN updated_by DROP NOT NULL","-- Organizations table\nALTER TABLE public.organizations ALTER COLUMN created_by DROP NOT NULL","ALTER TABLE public.organizations ALTER COLUMN updated_by DROP NOT NULL","-- Custom statuses table\nALTER TABLE public.custom_statuses ALTER COLUMN created_by DROP NOT NULL","ALTER TABLE public.custom_statuses ALTER COLUMN updated_by DROP NOT NULL"}	fix_user_references
20250817240000	{"-- 現在のログインユーザーをプロジェクトメンバーに確実に追加\n\n-- 1. テスト組織を確実に存在させる\nINSERT INTO public.organizations (id, name, created_at, updated_at) VALUES \n('11111111-1111-1111-1111-111111111111', 'テスト組織', NOW(), NOW())\nON CONFLICT (id) DO UPDATE SET \n    name = EXCLUDED.name,\n    updated_at = NOW()","-- 2. テストプロジェクトを確実に存在させる  \nINSERT INTO public.projects (id, name, org_id, created_at, updated_at) VALUES \n('22222222-2222-2222-2222-222222222222', 'テストプロジェクト', '11111111-1111-1111-1111-111111111111', NOW(), NOW())\nON CONFLICT (id) DO UPDATE SET \n    name = EXCLUDED.name,\n    updated_at = NOW()","-- 3. auth.usersテーブルに直接ユーザーを挿入（存在しない場合のみ）\nINSERT INTO auth.users (\n    id, \n    email, \n    encrypted_password,\n    email_confirmed_at,\n    created_at,\n    updated_at,\n    role,\n    aud\n) VALUES (\n    'ac8ded90-9943-4a1a-b917-9d8d29967a23',\n    'admin@test.com',\n    '$2a$10$dummy.encrypted.password.hash.for.test.user.only',\n    NOW(),\n    NOW(),\n    NOW(),\n    'authenticated',\n    'authenticated'\n) ON CONFLICT (id) DO NOTHING","-- 4. 組織メンバーシップを追加\nINSERT INTO public.organization_memberships (org_id, user_id, role, created_at) VALUES \n('11111111-1111-1111-1111-111111111111', 'ac8ded90-9943-4a1a-b917-9d8d29967a23', 'admin', NOW())\nON CONFLICT (org_id, user_id) DO UPDATE SET \n    role = EXCLUDED.role","-- 5. プロジェクトメンバーシップを追加\nINSERT INTO public.project_memberships (project_id, user_id, role, created_at) VALUES \n('22222222-2222-2222-2222-222222222222', 'ac8ded90-9943-4a1a-b917-9d8d29967a23', 'project_manager', NOW())\nON CONFLICT (project_id, user_id) DO UPDATE SET \n    role = EXCLUDED.role"}	add_user_membership
20250817250000	{"-- Chat messages RLS policy fix - 簡潔なポリシーに変更\n\n-- 既存のinsertポリシーを削除\nDROP POLICY IF EXISTS \\"Users can insert project chat messages\\" ON public.chat_messages","-- 新しいinsertポリシーを作成（シンプルな形式）\nCREATE POLICY \\"Users can insert project chat messages\\" ON public.chat_messages\n  FOR INSERT WITH CHECK (\n    user_id = auth.uid()\n  )","-- selectポリシーも確認・修正\nDROP POLICY IF EXISTS \\"Users can view project chat messages\\" ON public.chat_messages","CREATE POLICY \\"Users can view project chat messages\\" ON public.chat_messages\n  FOR SELECT USING (\n    user_id = auth.uid() OR\n    project_id IN (\n      SELECT pm.project_id \n      FROM public.project_memberships pm \n      WHERE pm.user_id = auth.uid()\n    )\n  )"}	fix_chat_rls_simple
20250817260000	{"-- Chat RLS policy を完全に削除して再作成\n\n-- 全てのchat_messagesのRLSポリシーを削除\nDROP POLICY IF EXISTS \\"Users can insert project chat messages\\" ON public.chat_messages","DROP POLICY IF EXISTS \\"Users can view project chat messages\\" ON public.chat_messages","DROP POLICY IF EXISTS \\"Users can select project chat messages\\" ON public.chat_messages","DROP POLICY IF EXISTS \\"chat_messages_insert_policy\\" ON public.chat_messages","DROP POLICY IF EXISTS \\"chat_messages_select_policy\\" ON public.chat_messages","-- 最もシンプルなポリシーで再作成\nCREATE POLICY \\"chat_insert_simple\\" ON public.chat_messages\n  FOR INSERT WITH CHECK (user_id = auth.uid())","CREATE POLICY \\"chat_select_simple\\" ON public.chat_messages\n  FOR SELECT USING (true)"}	fix_chat_policy_direct
20250817270000	{"-- 一時的にchat_messagesのRLSを無効化してテスト\n\n-- 既存のポリシーを全て削除\nDROP POLICY IF EXISTS \\"Users can insert project chat messages\\" ON public.chat_messages","DROP POLICY IF EXISTS \\"Users can view project chat messages\\" ON public.chat_messages","DROP POLICY IF EXISTS \\"chat_insert_simple\\" ON public.chat_messages","DROP POLICY IF EXISTS \\"chat_select_simple\\" ON public.chat_messages","-- RLS自体を無効化\nALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY"}	disable_chat_rls_temp
20250817280000	{"-- 一時的にchat_messagesの外部キー制約を削除してテスト\n\n-- chat_messagesのuser_id外部キー制約を削除\nALTER TABLE public.chat_messages \nDROP CONSTRAINT IF EXISTS chat_messages_user_id_fkey","-- project_id外部キー制約も一時的に削除（必要であれば）\nALTER TABLE public.chat_messages \nDROP CONSTRAINT IF EXISTS chat_messages_project_id_fkey"}	remove_user_fkey_temp
20250817310000	{"-- mentionsテーブルからchat_messagesへの依存を削除してチャット機能をシンプル化\n\n-- mentionsテーブルの外部キー制約を削除\nALTER TABLE public.mentions \nDROP CONSTRAINT IF EXISTS mentions_message_id_fkey","-- chat_messagesテーブルを削除して再作成\nDROP TABLE IF EXISTS public.chat_messages CASCADE","-- シンプルなchat_messagesテーブルを再作成\nCREATE TABLE public.chat_messages (\n    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,\n    content text NOT NULL,\n    user_id uuid,\n    project_id uuid,\n    created_at timestamptz DEFAULT now(),\n    updated_at timestamptz DEFAULT now()\n)","-- RLS無効化\nALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY","-- 権限付与\nGRANT ALL ON public.chat_messages TO anon","GRANT ALL ON public.chat_messages TO authenticated","GRANT ALL ON public.chat_messages TO service_role"}	remove_mentions_dependency
20250817320000	{"-- Delete existing admin@test.com user if exists\nDELETE FROM auth.users WHERE email = 'admin@test.com'","-- Create admin@test.com user\nINSERT INTO auth.users (\n  id,\n  email,\n  encrypted_password,\n  email_confirmed_at,\n  created_at,\n  updated_at,\n  raw_app_meta_data,\n  raw_user_meta_data,\n  is_super_admin,\n  role\n) VALUES (\n  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',\n  'admin@test.com',\n  crypt('password123', gen_salt('bf')),\n  now(),\n  now(),\n  now(),\n  '{\\"provider\\": \\"email\\", \\"providers\\": [\\"email\\"]}',\n  '{\\"role\\": \\"admin\\", \\"display_name\\": \\"Administrator\\", \\"company\\": \\"IQVIA\\"}',\n  false,\n  'authenticated'\n)","-- Add admin user to organization if not exists\nINSERT INTO organization_memberships (\n  user_id,\n  org_id,\n  role,\n  created_at\n) VALUES (\n  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',\n  '11111111-1111-1111-1111-111111111111',\n  'admin',\n  now()\n) ON CONFLICT (org_id, user_id) DO NOTHING","-- Add admin user to project as project_manager if not exists\nINSERT INTO project_memberships (\n  user_id,\n  project_id,\n  role,\n  created_at\n) VALUES (\n  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',\n  '22222222-2222-2222-2222-222222222222',\n  'project_manager',\n  now()\n) ON CONFLICT (project_id, user_id) DO NOTHING"}	create_admin_user
20250817330000	{"-- Add task links functionality\n-- Supports external URLs and future file storage integration\n\n-- Link type enum for extensibility\nDO $$ \nBEGIN \n  CREATE TYPE public.link_type AS ENUM ('url', 'file', 'storage'); \nEXCEPTION \n  WHEN duplicate_object THEN NULL; \nEND $$","-- Task links table\nCREATE TABLE IF NOT EXISTS public.task_links (\n  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),\n  task_id uuid NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,\n  title text NOT NULL,\n  url text NOT NULL,\n  link_type public.link_type NOT NULL DEFAULT 'url',\n  description text,\n  -- For future storage integration\n  file_id uuid REFERENCES public.files(id) ON DELETE CASCADE,\n  storage_provider text,\n  storage_key text,\n  -- Metadata\n  created_at timestamptz DEFAULT now(),\n  created_by uuid REFERENCES auth.users(id),\n  updated_at timestamptz,\n  updated_by uuid REFERENCES auth.users(id)\n)","-- Index for performance\nCREATE INDEX IF NOT EXISTS idx_task_links_task_id ON public.task_links(task_id)","CREATE INDEX IF NOT EXISTS idx_task_links_type ON public.task_links(link_type)","-- Enable RLS (Row Level Security)\nALTER TABLE public.task_links ENABLE ROW LEVEL SECURITY","-- RLS policies (disabled for now like other tables)\n-- Policies will be enabled when chat RLS is re-enabled"}	add_task_links
20250817340000	{"-- Disable RLS for task_links table temporarily\n-- Same approach as chat_messages to avoid 403 errors\n\nALTER TABLE public.task_links DISABLE ROW LEVEL SECURITY"}	disable_task_links_rls
20250817350000	{"-- Fix projects table schema to match admin dashboard expectations\n\n-- Add description column\nALTER TABLE public.projects \nADD COLUMN IF NOT EXISTS description TEXT","-- Add settings column for future use\nALTER TABLE public.projects \nADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}'","-- Rename org_id to organization_id for consistency\nALTER TABLE public.projects \nRENAME COLUMN org_id TO organization_id","-- Update foreign key constraint name\nALTER TABLE public.projects \nDROP CONSTRAINT IF EXISTS projects_org_id_fkey","ALTER TABLE public.projects \nADD CONSTRAINT projects_organization_id_fkey \nFOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE","-- Update project_memberships role values to match admin dashboard\nALTER TABLE public.project_memberships \nDROP CONSTRAINT IF EXISTS project_memberships_role_check","-- Update existing roles to new values\nUPDATE public.project_memberships \nSET role = CASE \n  WHEN role = 'project_manager' THEN 'admin'\n  WHEN role = 'contributor' THEN 'member'\n  WHEN role = 'viewer' THEN 'viewer'\n  ELSE 'member'  -- Default fallback\nEND","-- Add constraint after data is cleaned\nALTER TABLE public.project_memberships \nADD CONSTRAINT project_memberships_role_check \nCHECK (role IN ('admin', 'member', 'viewer'))"}	fix_projects_schema
20250817360000	{"-- Update priority colors to be more intuitive\n-- 緊急:赤、高:黄色、中:青、低:緑\n\n-- Update priority_options colors if they exist\nUPDATE public.priority_options \nSET color = CASE \n    WHEN name = 'low' THEN '#28a745'    -- 緑\n    WHEN name = 'medium' THEN '#007bff' -- 青  \n    WHEN name = 'high' THEN '#ffc107'   -- 黄色\n    WHEN name = 'urgent' THEN '#dc3545' -- 赤\n    ELSE color\nEND\nWHERE name IN ('low', 'medium', 'high', 'urgent')","-- Insert default priority options if they don't exist\nINSERT INTO public.priority_options (name, label, color, weight, is_active)\nVALUES \n    ('low', '低', '#28a745', 1, true),\n    ('medium', '中', '#007bff', 2, true),\n    ('high', '高', '#ffc107', 3, true),\n    ('urgent', '緊急', '#dc3545', 4, true)\nON CONFLICT (name) DO UPDATE SET\n    color = EXCLUDED.color,\n    label = EXCLUDED.label"}	update_priority_colors
20250817380000	{"-- Add storage_folder column to tasks table for file organization\n-- Each task will have its own dedicated storage folder\n\n-- Add storage_folder column\nALTER TABLE public.tasks \nADD COLUMN storage_folder TEXT"}	add_task_storage_folder
20250821030000	{"-- Redesign: Use auth.users.role directly for all role management\n\n-- Step 1: Update existing auth.users with proper roles from metadata\nUPDATE auth.users \nSET role = CASE \n    WHEN raw_user_meta_data ->> 'role' = 'admin' THEN 'admin'\n    WHEN raw_user_meta_data ->> 'role' = 'project_manager' THEN 'project_manager'\n    WHEN raw_user_meta_data ->> 'role' = 'org_manager' THEN 'project_manager'\n    ELSE 'viewer'\nEND","-- Step 2: Ensure admin user has correct role\nUPDATE auth.users \nSET role = 'admin' \nWHERE email = 'admin@test.com'","-- Step 3: Drop all complex RLS policies and functions\nDROP POLICY IF EXISTS \\"admin_full_access\\" ON public.profiles","DROP POLICY IF EXISTS \\"users_own_profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"admin_manage_orgs\\" ON public.organizations","DROP POLICY IF EXISTS \\"members_view_orgs\\" ON public.organizations","DROP POLICY IF EXISTS \\"admin_manage_projects\\" ON public.projects","DROP POLICY IF EXISTS \\"project_managers_manage\\" ON public.projects","DROP POLICY IF EXISTS \\"members_view_projects\\" ON public.projects","DROP FUNCTION IF EXISTS public.get_user_role(UUID)","-- Step 4: Create super simple RLS policies using auth.users.role directly\n\n-- Profiles: Admin can manage all, users can manage own\nCREATE POLICY \\"profiles_admin_all\\" ON public.profiles\n    FOR ALL USING (\n        (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin'\n    )","CREATE POLICY \\"profiles_user_own\\" ON public.profiles\n    FOR ALL USING (auth.uid() = user_id)","-- Organizations: Admin can manage all, others view where they're members\nCREATE POLICY \\"orgs_admin_all\\" ON public.organizations\n    FOR ALL USING (\n        (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin'\n    )","CREATE POLICY \\"orgs_members_view\\" ON public.organizations\n    FOR SELECT USING (\n        EXISTS (\n            SELECT 1 FROM organization_memberships om \n            WHERE om.org_id = id AND om.user_id = auth.uid()\n        )\n    )","-- Projects: Admin and project managers can manage, others view where they're members\nCREATE POLICY \\"projects_admin_pm_all\\" ON public.projects\n    FOR ALL USING (\n        (SELECT role FROM auth.users WHERE id = auth.uid()) IN ('admin', 'project_manager')\n    )","CREATE POLICY \\"projects_members_view\\" ON public.projects\n    FOR SELECT USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = id AND pm.user_id = auth.uid()\n        )\n    )","-- Step 5: Update trigger function to not manage roles (auth.users.role is set manually)\nCREATE OR REPLACE FUNCTION public.handle_new_user()\nRETURNS TRIGGER AS $$\nBEGIN\n    -- Only create profile with basic info (no role management)\n    INSERT INTO public.profiles (user_id, display_name, company)\n    VALUES (\n        NEW.id,\n        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),\n        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown')\n    );\n    \n    RETURN NEW;\nEND;\n$$ language 'plpgsql' SECURITY DEFINER","-- Step 6: Clean up profiles table - remove role column (already done in previous migration)\n-- Role is now managed only in auth.users.role"}	redesign_simple_auth_users_role
20250817390000	{"-- Temporarily disable sample data to resolve migration issues\n-- TODO: Re-enable after fixing type issues\n\n-- Add sample organization and project for testing  \n-- INSERT INTO organizations (id, name, created_at) VALUES \n-- ('440e8400-e29b-41d4-a716-446655440000', 'サンプル組織', NOW())\n-- ON CONFLICT (id) DO NOTHING;\n\n-- INSERT INTO projects (id, organization_id, name, created_at) VALUES \n-- ('550e8400-e29b-41d4-a716-446655440000', '440e8400-e29b-41d4-a716-446655440000', 'サンプルプロジェクト', NOW())\n-- ON CONFLICT (id) DO NOTHING;\n\n-- Add sample tasks (using proper enum values)\n-- INSERT INTO tasks (id, title, description, status, priority, project_id, storage_folder, created_at) VALUES \n-- ('660e8400-e29b-41d4-a716-446655440001', 'タスク1：要件定義', 'プロジェクトの要件を定義する', 'todo'::task_status, 'high'::task_priority, '550e8400-e29b-41d4-a716-446655440000', 'task_660e8400-e29b-41d4-a716-446655440001', NOW()),\n-- ('660e8400-e29b-41d4-a716-446655440002', 'タスク2：設計書作成', 'システム設計書を作成する', 'review'::task_status, 'medium'::task_priority, '550e8400-e29b-41d4-a716-446655440000', 'task_660e8400-e29b-41d4-a716-446655440002', NOW()),\n-- ('660e8400-e29b-41d4-a716-446655440003', 'タスク3：実装', 'フロントエンド実装を行う', 'done'::task_status, 'urgent'::task_priority, '550e8400-e29b-41d4-a716-446655440000', 'task_660e8400-e29b-41d4-a716-446655440003', NOW())\n-- ON CONFLICT (id) DO NOTHING;"}	add_sample_data
20250818000000	{"-- Storage bucket作成\nINSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)\nVALUES ('files', 'files', true, 52428800, NULL)\nON CONFLICT (id) DO NOTHING","-- Storage bucket policy設定\nCREATE POLICY \\"Public file access\\" ON storage.objects\nFOR SELECT USING (bucket_id = 'files')","CREATE POLICY \\"Public file upload\\" ON storage.objects\nFOR INSERT WITH CHECK (bucket_id = 'files')","CREATE POLICY \\"Public file delete\\" ON storage.objects\nFOR DELETE USING (bucket_id = 'files')"}	create_storage_bucket
20250820100000	{"-- Fix organizations.created_by foreign key constraint to reference auth.users\n-- This fixes the issue where organizations cannot be created due to missing public.users table\n\n-- Drop existing foreign key constraint if it exists\nALTER TABLE public.organizations \nDROP CONSTRAINT IF EXISTS organizations_created_by_fkey","-- Add new foreign key constraint referencing auth.users\nALTER TABLE public.organizations \nADD CONSTRAINT organizations_created_by_fkey \nFOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL","-- Also fix updated_by if it has similar constraint\nALTER TABLE public.organizations \nDROP CONSTRAINT IF EXISTS organizations_updated_by_fkey","ALTER TABLE public.organizations \nADD CONSTRAINT organizations_updated_by_fkey \nFOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL","-- Fix projects table as well for consistency\nALTER TABLE public.projects \nDROP CONSTRAINT IF EXISTS projects_created_by_fkey","ALTER TABLE public.projects \nADD CONSTRAINT projects_created_by_fkey \nFOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL","ALTER TABLE public.projects \nDROP CONSTRAINT IF EXISTS projects_updated_by_fkey","ALTER TABLE public.projects \nADD CONSTRAINT projects_updated_by_fkey \nFOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL","-- Fix tasks table as well for consistency\nALTER TABLE public.tasks \nDROP CONSTRAINT IF EXISTS tasks_created_by_fkey","ALTER TABLE public.tasks \nADD CONSTRAINT tasks_created_by_fkey \nFOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL","ALTER TABLE public.tasks \nDROP CONSTRAINT IF EXISTS tasks_updated_by_fkey","ALTER TABLE public.tasks \nADD CONSTRAINT tasks_updated_by_fkey \nFOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL"}	fix_organizations_foreign_key
20250820200000	{"-- Create profiles table for user information\nCREATE TABLE IF NOT EXISTS public.profiles (\n    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,\n    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,\n    display_name TEXT,\n    company TEXT,\n    role TEXT DEFAULT 'viewer',\n    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,\n    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,\n    UNIQUE(user_id)\n)","-- Enable RLS\nALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY","-- Create RLS policies (with IF NOT EXISTS equivalent)\nDO $$ BEGIN\n    CREATE POLICY \\"Users can view own profile\\" ON public.profiles\n        FOR SELECT USING (auth.uid() = user_id);\nEXCEPTION\n    WHEN duplicate_object THEN NULL;\nEND $$","DO $$ BEGIN\n    CREATE POLICY \\"Users can update own profile\\" ON public.profiles\n        FOR UPDATE USING (auth.uid() = user_id);\nEXCEPTION\n    WHEN duplicate_object THEN NULL;\nEND $$","DO $$ BEGIN\n    CREATE POLICY \\"Users can insert own profile\\" ON public.profiles\n        FOR INSERT WITH CHECK (auth.uid() = user_id);\nEXCEPTION\n    WHEN duplicate_object THEN NULL;\nEND $$","-- Create updated_at trigger\nCREATE OR REPLACE FUNCTION public.handle_updated_at()\nRETURNS TRIGGER AS $$\nBEGIN\n    NEW.updated_at = timezone('utc'::text, now());\n    RETURN NEW;\nEND;\n$$ language 'plpgsql'","DROP TRIGGER IF EXISTS handle_updated_at ON public.profiles","CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.profiles\n    FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at()","-- Function to handle new user profile creation\nCREATE OR REPLACE FUNCTION public.handle_new_user()\nRETURNS TRIGGER AS $$\nDECLARE\n    user_role text;\nBEGIN\n    -- ロールを取得\n    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'viewer');\n    \n    -- プロファイルを作成\n    INSERT INTO public.profiles (user_id, display_name, company, role)\n    VALUES (\n        NEW.id,\n        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),\n        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown'),\n        user_role\n    );\n    \n    -- auth.users.roleを更新\n    UPDATE auth.users \n    SET role = user_role\n    WHERE id = NEW.id;\n    \n    RETURN NEW;\nEND;\n$$ language 'plpgsql' SECURITY DEFINER","-- Create trigger for automatic profile creation\nDROP TRIGGER IF EXISTS on_auth_user_created ON auth.users","CREATE TRIGGER on_auth_user_created\n    AFTER INSERT ON auth.users\n    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user()"}	create_profiles_table
20250820220000	{"-- Fix auth.users role assignment on user creation\n-- Remove direct auth.users update to avoid permission errors\n\nCREATE OR REPLACE FUNCTION public.handle_new_user()\nRETURNS TRIGGER AS $$\nDECLARE\n    user_role text;\nBEGIN\n    -- ロールを取得\n    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'viewer');\n    \n    -- プロファイルを作成\n    INSERT INTO public.profiles (user_id, display_name, company, role)\n    VALUES (\n        NEW.id,\n        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),\n        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown'),\n        user_role\n    );\n    \n    -- auth.users直接更新は権限エラーを起こすため削除\n    -- 代わりにraw_user_meta_dataにロール情報を保存済み\n    \n    RETURN NEW;\nEND;\n$$ language 'plpgsql' SECURITY DEFINER"}	fix_auth_user_role
20250821010000	{"-- Simplify role management to use auth.users directly\n\n-- Step 1: Update existing auth.users with roles from profiles\nUPDATE auth.users \nSET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', p.role)\nFROM profiles p \nWHERE auth.users.id = p.user_id","-- Step 2: Create simple RLS policies using auth.users roles\n\n-- Helper function to get user role from JWT/metadata\nCREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID DEFAULT auth.uid())\nRETURNS TEXT AS $$\nBEGIN\n    RETURN COALESCE(\n        auth.jwt() ->> 'role',  -- From JWT if available\n        (SELECT raw_user_meta_data ->> 'role' FROM auth.users WHERE id = user_id), -- From metadata\n        'viewer' -- Default\n    );\nEND;\n$$ LANGUAGE plpgsql SECURITY DEFINER","-- Step 3: Simple RLS policies for profiles table\n\n-- Drop all existing policies\nDROP POLICY IF EXISTS \\"Users can view own profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"Users can update own profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"Users can insert own profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"Admins can view all profiles\\" ON public.profiles","DROP POLICY IF EXISTS \\"Admins can update all profiles\\" ON public.profiles","DROP POLICY IF EXISTS \\"Admins can insert profiles\\" ON public.profiles","-- New simple policies\nCREATE POLICY \\"admin_full_access\\" ON public.profiles\n    FOR ALL USING (public.get_user_role() = 'admin')","CREATE POLICY \\"users_own_profile\\" ON public.profiles  \n    FOR ALL USING (auth.uid() = user_id)","-- Step 4: Apply to other important tables\n\n-- Organizations (admin can manage all, others can view where they're members)\nALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"admin_manage_orgs\\" ON public.organizations\n    FOR ALL USING (public.get_user_role() = 'admin')","CREATE POLICY \\"members_view_orgs\\" ON public.organizations\n    FOR SELECT USING (\n        EXISTS (\n            SELECT 1 FROM organization_memberships om \n            WHERE om.org_id = id AND om.user_id = auth.uid()\n        )\n    )","-- Projects (similar pattern)\nALTER TABLE public.projects ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"admin_manage_projects\\" ON public.projects\n    FOR ALL USING (public.get_user_role() = 'admin')","CREATE POLICY \\"project_managers_manage\\" ON public.projects\n    FOR ALL USING (public.get_user_role() IN ('admin', 'project_manager'))","CREATE POLICY \\"members_view_projects\\" ON public.projects\n    FOR SELECT USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = id AND pm.user_id = auth.uid()\n        )\n    )","-- Step 5: Update user creation function to be simpler\nCREATE OR REPLACE FUNCTION public.handle_new_user()\nRETURNS TRIGGER AS $$\nDECLARE\n    user_role text;\nBEGIN\n    -- Get role from metadata, default to viewer\n    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'viewer');\n    \n    -- Create profile with minimal info (role now managed in auth.users)\n    INSERT INTO public.profiles (user_id, display_name, company)\n    VALUES (\n        NEW.id,\n        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),\n        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown')\n    );\n    \n    RETURN NEW;\nEND;\n$$ language 'plpgsql' SECURITY DEFINER","-- Step 6: Remove role column from profiles (for full simplification)\nALTER TABLE public.profiles DROP COLUMN IF EXISTS role"}	simplify_to_auth_users_roles
20250821040000	{"-- Implement Hybrid Admin System according to design guide\n\n-- Step 1: Create admin schema and admins table\ncreate schema if not exists admin","create table if not exists admin.admins(\n  user_id uuid primary key references auth.users(id),\n  granted_by uuid references auth.users(id),\n  granted_at timestamptz not null default now(),\n  expires_at timestamptz\n)","create index if not exists idx_admins_user_id on admin.admins(user_id)","-- Enable RLS on admin.admins\nalter table admin.admins enable row level security","-- Only authenticated users can read admin status (for RLS policies)\ncreate policy \\"authenticated_read_admins\\" on admin.admins\n  for select using (auth.role() = 'authenticated')","-- Step 2: Create function to sync admin status to app_metadata\ncreate or replace function admin.sync_admin_metadata()\nreturns void\nlanguage plpgsql\nsecurity definer\nas $$\ndeclare\n  admin_user record;\nbegin\n  -- Update all current admins to have is_admin = true\n  for admin_user in \n    select user_id from admin.admins \n    where expires_at is null or expires_at > now()\n  loop\n    update auth.users \n    set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{\\"is_admin\\": true}'::jsonb\n    where id = admin_user.user_id;\n  end loop;\n  \n  -- Update non-admins to have is_admin = false or remove the flag\n  update auth.users \n  set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{\\"is_admin\\": false}'::jsonb\n  where id not in (\n    select user_id from admin.admins \n    where expires_at is null or expires_at > now()\n  );\nend;\n$$","-- Step 3: Create function to grant admin privileges\ncreate or replace function admin.grant_admin_privileges(target_user_id uuid, granter_user_id uuid default auth.uid())\nreturns void\nlanguage plpgsql\nsecurity definer\nas $$\nbegin\n  -- Check if granter is admin (or allow if no admins exist yet for bootstrap)\n  if not exists (select 1 from admin.admins where expires_at is null or expires_at > now()) then\n    -- Bootstrap case: allow if no admins exist\n    null;\n  elsif not exists (\n    select 1 from admin.admins \n    where user_id = granter_user_id \n    and (expires_at is null or expires_at > now())\n  ) then\n    raise exception 'Only admins can grant admin privileges';\n  end if;\n  \n  -- Insert or update admin record\n  insert into admin.admins (user_id, granted_by)\n  values (target_user_id, granter_user_id)\n  on conflict (user_id) do update set\n    granted_by = excluded.granted_by,\n    granted_at = now(),\n    expires_at = null;\n    \n  -- Sync metadata\n  perform admin.sync_admin_metadata();\nend;\n$$","-- Step 4: Create function to revoke admin privileges\ncreate or replace function admin.revoke_admin_privileges(target_user_id uuid)\nreturns void\nlanguage plpgsql\nsecurity definer\nas $$\nbegin\n  -- Check if caller is admin\n  if not exists (\n    select 1 from admin.admins \n    where user_id = auth.uid() \n    and (expires_at is null or expires_at > now())\n  ) then\n    raise exception 'Only admins can revoke admin privileges';\n  end if;\n  \n  -- Remove admin record\n  delete from admin.admins where user_id = target_user_id;\n  \n  -- Sync metadata\n  perform admin.sync_admin_metadata();\nend;\n$$","-- Step 5: Update existing RLS policies to use hybrid approach\n\n-- Drop old policies\ndrop policy if exists \\"profiles_admin_all\\" on public.profiles","drop policy if exists \\"profiles_user_own\\" on public.profiles","drop policy if exists \\"orgs_admin_all\\" on public.organizations","drop policy if exists \\"orgs_members_view\\" on public.organizations","drop policy if exists \\"projects_admin_pm_all\\" on public.projects","drop policy if exists \\"projects_members_view\\" on public.projects","-- New hybrid policies for profiles\ncreate policy \\"profiles_admin_all\\" on public.profiles\n  for all using (\n    coalesce((auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, false)\n  )","create policy \\"profiles_user_own\\" on public.profiles\n  for all using (auth.uid() = user_id)","-- New hybrid policies for organizations\ncreate policy \\"orgs_admin_all\\" on public.organizations\n  for all using (\n    coalesce((auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, false)\n  )","create policy \\"orgs_members_view\\" on public.organizations\n  for select using (\n    exists (\n      select 1 from organization_memberships om \n      where om.org_id = id and om.user_id = auth.uid()\n    )\n  )","-- New hybrid policies for projects\ncreate policy \\"projects_admin_all\\" on public.projects\n  for all using (\n    coalesce((auth.jwt() -> 'app_metadata' ->> 'is_admin')::boolean, false)\n  )","create policy \\"projects_members_view\\" on public.projects\n  for select using (\n    exists (\n      select 1 from project_memberships pm \n      where pm.project_id = id and pm.user_id = auth.uid()\n    )\n  )","-- Step 6: Bootstrap initial admin user\n-- Create admin@test.com as initial admin (bootstrap)\ndo $$\nbegin\n  -- Ensure admin@test.com exists\n  if exists (select 1 from auth.users where email = 'admin@test.com') then\n    -- Grant admin privileges to admin@test.com (bootstrap case)\n    perform admin.grant_admin_privileges(\n      (select id from auth.users where email = 'admin@test.com'),\n      null -- bootstrap case\n    );\n  end if;\nend $$","-- Step 7: Grant necessary permissions\ngrant usage on schema admin to authenticated","grant select on admin.admins to authenticated","grant execute on function admin.grant_admin_privileges(uuid, uuid) to authenticated","grant execute on function admin.revoke_admin_privileges(uuid) to authenticated","grant execute on function admin.sync_admin_metadata() to authenticated"}	implement_hybrid_admin_system
20250821043000	{"-- カレンダー機能用eventsテーブル作成\n\ncreate table if not exists public.events (\n  id uuid primary key default gen_random_uuid(),\n  title text not null,\n  description text,\n  start timestamptz not null,\n  \\"end\\" timestamptz,\n  all_day boolean not null default false,\n  -- 所有者: デフォルトでログインユーザー\n  owner_user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,\n  color text,\n  location text,\n  created_at timestamptz not null default now(),\n  updated_at timestamptz not null default now()\n)","alter table public.events enable row level security","create policy \\"events_read_own\\"\non public.events for select\nusing (owner_user_id = auth.uid())","create policy \\"events_insert_own\\"\non public.events for insert\nwith check (owner_user_id = auth.uid())","create policy \\"events_update_own\\"\non public.events for update\nusing (owner_user_id = auth.uid())\nwith check (owner_user_id = auth.uid())","create policy \\"events_delete_own\\"\non public.events for delete\nusing (owner_user_id = auth.uid())","create or replace function public.set_events_updated_at()\nreturns trigger language plpgsql as $$\nbegin\n  new.updated_at = now();\n  return new;\nend $$","drop trigger if exists trg_events_updated on public.events","create trigger trg_events_updated before update on public.events\nfor each row execute function public.set_events_updated_at()","create index if not exists idx_events_owner_start_end\non public.events (owner_user_id, start, \\"end\\")"}	create_events_table
20250821050000	{"-- Fix chat_messages and profiles relationship for proper JOIN operations\n\n-- Step 1: Ensure profiles table exists for all auth.users\n-- This is already handled by existing triggers, but let's make sure\n\n-- Step 2: Update Chat.tsx query approach - use left join instead of inner join\n-- to handle cases where profiles might not exist yet\n\n-- Step 3: Add foreign key constraint for better referential integrity (optional)\n-- Only add if we want strict referential integrity\n\n-- For now, let's create a view that makes the JOIN easier and more reliable\ncreate or replace view public.chat_messages_with_profiles as\nselect \n  cm.id,\n  cm.project_id,\n  cm.user_id,\n  cm.content,\n  cm.created_at,\n  coalesce(p.display_name, 'User ' || left(cm.user_id::text, 8)) as display_name,\n  coalesce(p.company, '会社名未設定') as company\nfrom chat_messages cm\nleft join profiles p on cm.user_id = p.user_id","-- Grant necessary permissions\ngrant select on public.chat_messages_with_profiles to authenticated","-- Add RLS policy for the view (inherits from chat_messages policies)\nalter view public.chat_messages_with_profiles set (security_invoker = true)"}	fix_chat_profiles_relation
20250821060000	{"-- Add RPC functions to access admin.admins table from client\n\n-- Function to get current admin user IDs\ncreate or replace function public.get_current_admins()\nreturns table(user_id uuid)\nlanguage plpgsql\nsecurity definer\nas $$\nbegin\n  return query\n  select a.user_id\n  from admin.admins a\n  where a.expires_at is null or a.expires_at > now();\nend;\n$$","-- Function to check if a user is admin (for client-side use)\ncreate or replace function public.is_user_admin(check_user_id uuid default auth.uid())\nreturns boolean\nlanguage plpgsql\nsecurity definer\nas $$\nbegin\n  return exists (\n    select 1 \n    from admin.admins a\n    where a.user_id = check_user_id\n    and (a.expires_at is null or a.expires_at > now())\n  );\nend;\n$$","-- Grant execute permissions\ngrant execute on function public.get_current_admins() to authenticated","grant execute on function public.is_user_admin(uuid) to authenticated"}	add_admin_rpc_functions
20250821130000	{"-- Create task-files storage bucket for task-specific file storage\nINSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)\nVALUES ('task-files', 'task-files', true, 52428800, NULL)\nON CONFLICT (id) DO NOTHING","-- Storage policies for task-files bucket\nCREATE POLICY \\"Authenticated users can view task files\\" ON storage.objects\nFOR SELECT USING (\n  bucket_id = 'task-files' \n  AND auth.role() = 'authenticated'\n)","CREATE POLICY \\"Authenticated users can upload task files\\" ON storage.objects\nFOR INSERT WITH CHECK (\n  bucket_id = 'task-files' \n  AND auth.role() = 'authenticated'\n)","CREATE POLICY \\"Authenticated users can update task files\\" ON storage.objects\nFOR UPDATE USING (\n  bucket_id = 'task-files' \n  AND auth.role() = 'authenticated'\n)","CREATE POLICY \\"Authenticated users can delete task files\\" ON storage.objects\nFOR DELETE USING (\n  bucket_id = 'task-files' \n  AND auth.role() = 'authenticated'\n)"}	create_task_files_bucket
20250821140000	{"-- Add trigger to automatically generate storage_folder for tasks\n-- This ensures every task has a unique storage folder for file organization\n\n-- Function to generate storage folder for new tasks\nCREATE OR REPLACE FUNCTION generate_task_storage_folder()\nRETURNS TRIGGER AS $$\nBEGIN\n  -- Generate unique storage folder: task_{task_id}\n  NEW.storage_folder = 'task_' || NEW.id;\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql","-- Trigger to call the function before insert\nCREATE TRIGGER trg_generate_task_storage_folder\n  BEFORE INSERT ON public.tasks\n  FOR EACH ROW\n  EXECUTE FUNCTION generate_task_storage_folder()","-- Update existing tasks to have storage folders\nUPDATE public.tasks \nSET storage_folder = 'task_' || id \nWHERE storage_folder IS NULL","-- Create index on storage_folder for better performance\nCREATE INDEX IF NOT EXISTS idx_tasks_storage_folder ON public.tasks(storage_folder)"}	add_task_storage_folder_trigger
20250821150000	{"-- Add task_id column to files table for task-specific file organization\n-- This allows files to be associated with specific tasks\n\n-- Add task_id column with foreign key constraint\nALTER TABLE public.files \nADD COLUMN task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE","-- Create index for better query performance\nCREATE INDEX IF NOT EXISTS idx_files_task_id ON public.files(task_id)","-- Update RLS policies to include task-based file access\n-- Drop existing policies first\nDROP POLICY IF EXISTS \\"Enable read access for project members\\" ON files","DROP POLICY IF EXISTS \\"Enable insert for project members\\" ON files","DROP POLICY IF EXISTS \\"Enable update for project members\\" ON files","DROP POLICY IF EXISTS \\"Enable delete for project members\\" ON files","-- Recreate policies with task support\nCREATE POLICY \\"Enable read access for project members\\" ON files\n    FOR SELECT USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable insert for project members\\" ON files\n    FOR INSERT WITH CHECK (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable update for project members\\" ON files\n    FOR UPDATE USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )","CREATE POLICY \\"Enable delete for project members\\" ON files\n    FOR DELETE USING (\n        EXISTS (\n            SELECT 1 FROM project_memberships pm \n            WHERE pm.project_id = files.project_id \n            AND pm.user_id = auth.uid()\n        )\n    )"}	add_task_id_to_files
20250821160000	{"-- Fix files_updated_by foreign key constraint error\n-- The updated_by column should be nullable or have a proper default\n\n-- First, check if updated_by column exists and drop the foreign key constraint temporarily\nDO $$ \nBEGIN\n    -- Drop the foreign key constraint if it exists\n    IF EXISTS (\n        SELECT 1 FROM information_schema.table_constraints \n        WHERE constraint_name = 'files_updated_by_fkey' \n        AND table_name = 'files'\n    ) THEN\n        ALTER TABLE files DROP CONSTRAINT files_updated_by_fkey;\n    END IF;\nEND $$","-- Make updated_by nullable if it exists\nDO $$ \nBEGIN\n    IF EXISTS (\n        SELECT 1 FROM information_schema.columns \n        WHERE table_name = 'files' \n        AND column_name = 'updated_by'\n    ) THEN\n        ALTER TABLE files ALTER COLUMN updated_by DROP NOT NULL;\n    END IF;\nEND $$","-- Add back the foreign key constraint as nullable\nDO $$ \nBEGIN\n    IF EXISTS (\n        SELECT 1 FROM information_schema.columns \n        WHERE table_name = 'files' \n        AND column_name = 'updated_by'\n    ) THEN  \n        ALTER TABLE files \n        ADD CONSTRAINT files_updated_by_fkey \n        FOREIGN KEY (updated_by) REFERENCES auth.users(id);\n    END IF;\nEND $$","-- Update existing files to have proper updated_by values\nUPDATE files \nSET updated_by = created_by \nWHERE updated_by IS NULL AND created_by IS NOT NULL","-- Update the files table trigger to set updated_by on updates\nDO $$\nBEGIN\n    IF EXISTS (\n        SELECT 1 FROM information_schema.columns \n        WHERE table_name = 'files' \n        AND column_name = 'updated_by'\n    ) THEN\n        -- Create or replace the update trigger function\n        CREATE OR REPLACE FUNCTION update_files_updated_by()\n        RETURNS TRIGGER AS $func$\n        BEGIN\n            NEW.updated_by = auth.uid();\n            NEW.updated_at = NOW();\n            RETURN NEW;\n        END;\n        $func$ LANGUAGE plpgsql SECURITY DEFINER;\n\n        -- Drop existing trigger if it exists\n        DROP TRIGGER IF EXISTS files_update_trigger ON files;\n        \n        -- Create the trigger\n        CREATE TRIGGER files_update_trigger\n            BEFORE UPDATE ON files\n            FOR EACH ROW\n            EXECUTE FUNCTION update_files_updated_by();\n    END IF;\nEND $$"}	fix_files_updated_by_constraint
20250823000000	{"-- Add 'completed' status to task_status enum\n-- This allows tasks to be marked as completed\nALTER TYPE task_status ADD VALUE IF NOT EXISTS 'completed'"}	add_completed_status
20250823010000	{"-- Fix tasks_updated_by foreign key constraint error\n-- The updated_by column should be nullable and reference valid users\n\n-- First, drop the foreign key constraint if it exists\nDO $$ \nBEGIN\n    IF EXISTS (\n        SELECT 1 FROM information_schema.table_constraints \n        WHERE constraint_name = 'tasks_updated_by_fkey' \n        AND table_name = 'tasks'\n    ) THEN\n        ALTER TABLE tasks DROP CONSTRAINT tasks_updated_by_fkey;\n    END IF;\nEND $$","-- Make updated_by nullable\nALTER TABLE tasks ALTER COLUMN updated_by DROP NOT NULL","-- Update existing tasks that have invalid updated_by references\nUPDATE tasks \nSET updated_by = created_by \nWHERE updated_by IS NOT NULL \n  AND NOT EXISTS (SELECT 1 FROM auth.users WHERE id = tasks.updated_by)","-- Set updated_by to NULL for tasks where created_by is also invalid\nUPDATE tasks \nSET updated_by = NULL \nWHERE updated_by IS NOT NULL \n  AND created_by IS NOT NULL\n  AND NOT EXISTS (SELECT 1 FROM auth.users WHERE id = tasks.created_by)","-- Add back the foreign key constraint as nullable\nALTER TABLE tasks \nADD CONSTRAINT tasks_updated_by_fkey \nFOREIGN KEY (updated_by) REFERENCES auth.users(id)"}	fix_tasks_updated_by_constraint
20250823020000	{"-- Status options table (similar to priority_options)\n-- Allows dynamic management of task statuses\n\n-- 1. Create status_options table\nCREATE TABLE IF NOT EXISTS public.status_options (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  name VARCHAR(50) NOT NULL UNIQUE,\n  label VARCHAR(100) NOT NULL,\n  color VARCHAR(7) NOT NULL,\n  weight INTEGER NOT NULL UNIQUE,\n  is_active BOOLEAN DEFAULT TRUE,\n  created_at TIMESTAMPTZ DEFAULT NOW(),\n  updated_at TIMESTAMPTZ DEFAULT NOW()\n)","-- 2. Create status change history table\nCREATE TABLE IF NOT EXISTS public.status_change_history (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,\n  user_id UUID NOT NULL REFERENCES auth.users(id),\n  old_status VARCHAR(50),\n  new_status VARCHAR(50) NOT NULL,\n  changed_at TIMESTAMPTZ DEFAULT NOW(),\n  reason TEXT\n)","-- 3. Insert default status options\nINSERT INTO public.status_options (name, label, color, weight) VALUES\n  ('todo', '未着手', '#6c757d', 1),\n  ('review', 'レビュー中', '#ffc107', 2),\n  ('done', '作業完了', '#28a745', 3),\n  ('resolved', '対応済み', '#17a2b8', 4),\n  ('completed', '完了済み', '#6f42c1', 5)\nON CONFLICT (name) DO NOTHING","-- 4. Enable RLS\nALTER TABLE public.status_options ENABLE ROW LEVEL SECURITY","ALTER TABLE public.status_change_history ENABLE ROW LEVEL SECURITY","-- 5. RLS policies for status_options (read-only for authenticated users)\nCREATE POLICY \\"All users can view status options\\" ON public.status_options\n  FOR SELECT USING (auth.role() = 'authenticated')","-- 6. RLS policies for status_change_history\nCREATE POLICY \\"Users can view all status history\\" ON public.status_change_history\n  FOR SELECT USING (auth.role() = 'authenticated')","CREATE POLICY \\"Users can insert status history entries\\" ON public.status_change_history\n  FOR INSERT WITH CHECK (user_id = auth.uid())","-- 7. Create indexes for better performance\nCREATE INDEX IF NOT EXISTS idx_status_change_history_task_id ON public.status_change_history(task_id)","CREATE INDEX IF NOT EXISTS idx_status_change_history_user_id ON public.status_change_history(user_id)","CREATE INDEX IF NOT EXISTS idx_status_change_history_changed_at ON public.status_change_history(changed_at DESC)","-- 8. Update trigger for status_options\nCREATE OR REPLACE FUNCTION update_status_options_updated_at()\nRETURNS TRIGGER AS $$\nBEGIN\n  NEW.updated_at = NOW();\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql","CREATE TRIGGER trigger_update_status_options_updated_at\n  BEFORE UPDATE ON public.status_options\n  FOR EACH ROW EXECUTE FUNCTION update_status_options_updated_at()","-- 9. Function to log status changes\nCREATE OR REPLACE FUNCTION log_status_change()\nRETURNS TRIGGER AS $$\nBEGIN\n  -- Only log if status actually changed\n  IF OLD.status IS DISTINCT FROM NEW.status THEN\n    INSERT INTO public.status_change_history (\n      task_id,\n      user_id,\n      old_status,\n      new_status,\n      reason\n    ) VALUES (\n      NEW.id,\n      auth.uid(),\n      OLD.status,\n      NEW.status,\n      'Status updated via UI'\n    );\n  END IF;\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql SECURITY DEFINER","-- 10. Trigger to automatically log status changes\nCREATE TRIGGER trigger_log_status_change\n  AFTER UPDATE ON public.tasks\n  FOR EACH ROW EXECUTE FUNCTION log_status_change()"}	create_status_options_table
20250823030000	{"-- Add reference to status_options in tasks table\n-- This will allow dynamic status management\n\n-- 1. Add status_option_id column to tasks table\nALTER TABLE public.tasks ADD COLUMN status_option_id UUID REFERENCES public.status_options(id)","-- 2. Create index for better performance\nCREATE INDEX IF NOT EXISTS idx_tasks_status_option_id ON public.tasks(status_option_id)","-- 3. Update existing tasks to reference status_options\n-- Map current enum values to corresponding status_options records\nUPDATE public.tasks \nSET status_option_id = (\n  SELECT id FROM public.status_options \n  WHERE name = tasks.status::text\n)\nWHERE status_option_id IS NULL","-- 4. Function to get status info from status_options\nCREATE OR REPLACE FUNCTION get_task_status_info(task_status TEXT)\nRETURNS TABLE(\n  id UUID,\n  name TEXT,\n  label TEXT,\n  color TEXT,\n  weight INTEGER\n) AS $$\nBEGIN\n  RETURN QUERY\n  SELECT \n    so.id,\n    so.name,\n    so.label,\n    so.color,\n    so.weight\n  FROM public.status_options so\n  WHERE so.name = task_status AND so.is_active = true;\nEND;\n$$ LANGUAGE plpgsql SECURITY DEFINER","-- 5. View to get tasks with status information\nCREATE OR REPLACE VIEW public.tasks_with_status_info AS\nSELECT \n  t.*,\n  so.label as status_label,\n  so.color as status_color,\n  so.weight as status_weight\nFROM public.tasks t\nLEFT JOIN public.status_options so ON t.status_option_id = so.id","-- 6. Grant permissions for the view\nGRANT SELECT ON public.tasks_with_status_info TO authenticated","-- 7. Enable RLS for the view (inherits from tasks table)\nALTER VIEW public.tasks_with_status_info SET (security_invoker = on)"}	add_status_reference_to_tasks
20250823040000	{"-- 8-Role Permission System for Event Management\n-- 管理権限, 主催者権限, スポンサー権限, 代理店権限, 制作会社権限, 事務局権限, スタッフ権限, ビュワー権限\n\n-- 1. Role definitions table\nCREATE TABLE IF NOT EXISTS public.role_definitions (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  role_name VARCHAR(50) NOT NULL UNIQUE,\n  role_level INTEGER NOT NULL UNIQUE,\n  display_name VARCHAR(100) NOT NULL,\n  description TEXT,\n  is_active BOOLEAN DEFAULT TRUE,\n  created_at TIMESTAMPTZ DEFAULT NOW()\n)","-- 2. Permission definitions table\nCREATE TABLE IF NOT EXISTS public.permission_definitions (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  permission_name VARCHAR(50) NOT NULL UNIQUE,\n  resource VARCHAR(50) NOT NULL, -- 'organizations', 'projects', 'tasks', etc.\n  action VARCHAR(20) NOT NULL,   -- 'create', 'read', 'update', 'delete'\n  description TEXT,\n  is_active BOOLEAN DEFAULT TRUE,\n  created_at TIMESTAMPTZ DEFAULT NOW()\n)","-- 3. Role-Permission mapping table\nCREATE TABLE IF NOT EXISTS public.role_permissions (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  role_name VARCHAR(50) NOT NULL REFERENCES public.role_definitions(role_name),\n  permission_name VARCHAR(50) NOT NULL REFERENCES public.permission_definitions(permission_name),\n  is_granted BOOLEAN DEFAULT TRUE,\n  created_at TIMESTAMPTZ DEFAULT NOW(),\n  UNIQUE(role_name, permission_name)\n)","-- 4. Insert role definitions (level 8 = highest)\nINSERT INTO public.role_definitions (role_name, role_level, display_name, description) VALUES\n  ('admin', 8, '管理権限', 'システム全体管理、全権限'),\n  ('organizer', 7, '主催者権限', 'イベント企画・承認、予算管理'),\n  ('sponsor', 6, 'スポンサー権限', 'スポンサー関連情報管理'),\n  ('agency', 5, '代理店権限', '営業・顧客管理、契約関連'),\n  ('production', 4, '制作会社権限', 'コンテンツ制作、デザイン管理'),\n  ('secretariat', 3, '事務局権限', '運営業務、参加者管理'),\n  ('staff', 2, 'スタッフ権限', '当日運営、限定的操作'),\n  ('viewer', 1, 'ビュワー権限', '閲覧のみ')\nON CONFLICT (role_name) DO NOTHING","-- 5. Insert permission definitions\nINSERT INTO public.permission_definitions (permission_name, resource, action, description) VALUES\n  ('organizations_create', 'organizations', 'create', '組織作成'),\n  ('organizations_read', 'organizations', 'read', '組織閲覧'),\n  ('organizations_update', 'organizations', 'update', '組織更新'),\n  ('organizations_delete', 'organizations', 'delete', '組織削除'),\n  ('projects_create', 'projects', 'create', 'プロジェクト作成'),\n  ('projects_read', 'projects', 'read', 'プロジェクト閲覧'),\n  ('projects_update', 'projects', 'update', 'プロジェクト更新'),\n  ('projects_delete', 'projects', 'delete', 'プロジェクト削除'),\n  ('tasks_create', 'tasks', 'create', 'タスク作成'),\n  ('tasks_read', 'tasks', 'read', 'タスク閲覧'),\n  ('tasks_update', 'tasks', 'update', 'タスク更新'),\n  ('tasks_delete', 'tasks', 'delete', 'タスク削除'),\n  ('events_create', 'events', 'create', 'イベント作成'),\n  ('events_read', 'events', 'read', 'イベント閲覧'),\n  ('events_update', 'events', 'update', 'イベント更新'),\n  ('events_delete', 'events', 'delete', 'イベント削除'),\n  ('users_manage', 'users', 'manage', 'ユーザー管理'),\n  ('budget_manage', 'budget', 'manage', '予算管理'),\n  ('contracts_manage', 'contracts', 'manage', '契約管理'),\n  ('content_create', 'content', 'create', 'コンテンツ作成'),\n  ('participants_manage', 'participants', 'manage', '参加者管理')\nON CONFLICT (permission_name) DO NOTHING","-- 6. Insert role-permission mappings\n-- Admin (level 8) - All permissions\nINSERT INTO public.role_permissions (role_name, permission_name) \nSELECT 'admin', permission_name FROM public.permission_definitions\nON CONFLICT DO NOTHING","-- Organizer (level 7) - Event management, budget, high-level permissions\nINSERT INTO public.role_permissions (role_name, permission_name) VALUES\n  ('organizer', 'organizations_read'),\n  ('organizer', 'projects_create'), ('organizer', 'projects_read'), ('organizer', 'projects_update'), ('organizer', 'projects_delete'),\n  ('organizer', 'tasks_create'), ('organizer', 'tasks_read'), ('organizer', 'tasks_update'), ('organizer', 'tasks_delete'),\n  ('organizer', 'events_create'), ('organizer', 'events_read'), ('organizer', 'events_update'), ('organizer', 'events_delete'),\n  ('organizer', 'budget_manage'),\n  ('organizer', 'participants_manage')\nON CONFLICT DO NOTHING","-- Sponsor (level 6) - Sponsor-related permissions\nINSERT INTO public.role_permissions (role_name, permission_name) VALUES\n  ('sponsor', 'projects_read'),\n  ('sponsor', 'events_read'),\n  ('sponsor', 'tasks_read')\nON CONFLICT DO NOTHING","-- Agency (level 5) - Sales, customer management\nINSERT INTO public.role_permissions (role_name, permission_name) VALUES\n  ('agency', 'projects_read'), ('agency', 'projects_update'),\n  ('agency', 'events_read'),\n  ('agency', 'tasks_create'), ('agency', 'tasks_read'), ('agency', 'tasks_update'),\n  ('agency', 'contracts_manage'),\n  ('agency', 'participants_manage')\nON CONFLICT DO NOTHING","-- Production (level 4) - Content creation\nINSERT INTO public.role_permissions (role_name, permission_name) VALUES\n  ('production', 'projects_read'),\n  ('production', 'events_read'),\n  ('production', 'tasks_create'), ('production', 'tasks_read'), ('production', 'tasks_update'),\n  ('production', 'content_create')\nON CONFLICT DO NOTHING","-- Secretariat (level 3) - Operations, participant management\nINSERT INTO public.role_permissions (role_name, permission_name) VALUES\n  ('secretariat', 'projects_read'),\n  ('secretariat', 'events_read'), ('secretariat', 'events_update'),\n  ('secretariat', 'tasks_create'), ('secretariat', 'tasks_read'), ('secretariat', 'tasks_update'),\n  ('secretariat', 'participants_manage')\nON CONFLICT DO NOTHING","-- Staff (level 2) - Limited operations\nINSERT INTO public.role_permissions (role_name, permission_name) VALUES\n  ('staff', 'projects_read'),\n  ('staff', 'events_read'),\n  ('staff', 'tasks_read'), ('staff', 'tasks_update')\nON CONFLICT DO NOTHING","-- Viewer (level 1) - Read only\nINSERT INTO public.role_permissions (role_name, permission_name) VALUES\n  ('viewer', 'projects_read'),\n  ('viewer', 'events_read'),\n  ('viewer', 'tasks_read')\nON CONFLICT DO NOTHING","-- 7. Helper functions\nCREATE OR REPLACE FUNCTION public.get_user_role_level(user_id UUID DEFAULT auth.uid())\nRETURNS INTEGER AS $$\nBEGIN\n  RETURN (\n    SELECT rd.role_level \n    FROM auth.users u\n    JOIN public.role_definitions rd ON u.role = rd.role_name\n    WHERE u.id = user_id\n    LIMIT 1\n  );\nEND;\n$$ LANGUAGE plpgsql SECURITY DEFINER","CREATE OR REPLACE FUNCTION public.has_permission(user_id UUID, permission VARCHAR)\nRETURNS BOOLEAN AS $$\nBEGIN\n  RETURN EXISTS (\n    SELECT 1 \n    FROM auth.users u\n    JOIN public.role_permissions rp ON u.role = rp.role_name\n    WHERE u.id = user_id \n    AND rp.permission_name = permission \n    AND rp.is_granted = true\n  );\nEND;\n$$ LANGUAGE plpgsql SECURITY DEFINER","-- 8. Enable RLS\nALTER TABLE public.role_definitions ENABLE ROW LEVEL SECURITY","ALTER TABLE public.permission_definitions ENABLE ROW LEVEL SECURITY","ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY","-- Everyone can read role definitions (for UI dropdowns)\nCREATE POLICY \\"role_definitions_read_all\\" ON public.role_definitions FOR SELECT USING (true)","CREATE POLICY \\"permission_definitions_read_all\\" ON public.permission_definitions FOR SELECT USING (true)","CREATE POLICY \\"role_permissions_read_all\\" ON public.role_permissions FOR SELECT USING (true)"}	create_role_permissions_system
20250823050000	{"-- Update existing RLS policies to support 8-role permission system\n\n-- 1. Drop all existing role-based policies\nDROP POLICY IF EXISTS \\"profiles_admin_all\\" ON public.profiles","DROP POLICY IF EXISTS \\"profiles_user_own\\" ON public.profiles","DROP POLICY IF EXISTS \\"orgs_admin_all\\" ON public.organizations","DROP POLICY IF EXISTS \\"orgs_members_view\\" ON public.organizations","DROP POLICY IF EXISTS \\"projects_admin_pm_all\\" ON public.projects","DROP POLICY IF EXISTS \\"projects_members_view\\" ON public.projects","-- 2. Create new permission-based policies using role_permissions system\n\n-- Profiles: Users can manage their own, admins can manage all\nCREATE POLICY \\"profiles_own_manage\\" ON public.profiles\n  FOR ALL USING (auth.uid() = user_id)","CREATE POLICY \\"profiles_admin_manage\\" ON public.profiles\n  FOR ALL USING (\n    EXISTS (\n      SELECT 1 FROM auth.users u\n      WHERE u.id = auth.uid() AND u.role = 'admin'\n    )\n  )","-- Organizations: Permission-based access\nCREATE POLICY \\"organizations_create\\" ON public.organizations\n  FOR INSERT WITH CHECK (\n    public.has_permission(auth.uid(), 'organizations_create')\n  )","CREATE POLICY \\"organizations_read\\" ON public.organizations\n  FOR SELECT USING (\n    public.has_permission(auth.uid(), 'organizations_read') OR\n    EXISTS (\n      SELECT 1 FROM organization_memberships om \n      WHERE om.org_id = id AND om.user_id = auth.uid()\n    )\n  )","CREATE POLICY \\"organizations_update\\" ON public.organizations\n  FOR UPDATE USING (\n    public.has_permission(auth.uid(), 'organizations_update')\n  )","CREATE POLICY \\"organizations_delete\\" ON public.organizations\n  FOR DELETE USING (\n    public.has_permission(auth.uid(), 'organizations_delete')\n  )","-- Projects: Permission-based access\nCREATE POLICY \\"projects_create\\" ON public.projects\n  FOR INSERT WITH CHECK (\n    public.has_permission(auth.uid(), 'projects_create')\n  )","CREATE POLICY \\"projects_read\\" ON public.projects\n  FOR SELECT USING (\n    public.has_permission(auth.uid(), 'projects_read') OR\n    EXISTS (\n      SELECT 1 FROM project_memberships pm \n      WHERE pm.project_id = id AND pm.user_id = auth.uid()\n    )\n  )","CREATE POLICY \\"projects_update\\" ON public.projects\n  FOR UPDATE USING (\n    public.has_permission(auth.uid(), 'projects_update') OR\n    (created_by = auth.uid())\n  )","CREATE POLICY \\"projects_delete\\" ON public.projects\n  FOR DELETE USING (\n    public.has_permission(auth.uid(), 'projects_delete')\n  )","-- Tasks: Permission-based access\nCREATE POLICY \\"tasks_create\\" ON public.tasks\n  FOR INSERT WITH CHECK (\n    public.has_permission(auth.uid(), 'tasks_create')\n  )","CREATE POLICY \\"tasks_read\\" ON public.tasks\n  FOR SELECT USING (\n    public.has_permission(auth.uid(), 'tasks_read') OR\n    EXISTS (\n      SELECT 1 FROM project_memberships pm \n      WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid()\n    )\n  )","CREATE POLICY \\"tasks_update\\" ON public.tasks\n  FOR UPDATE USING (\n    public.has_permission(auth.uid(), 'tasks_update') OR\n    (created_by = auth.uid())\n  )","CREATE POLICY \\"tasks_delete\\" ON public.tasks\n  FOR DELETE USING (\n    public.has_permission(auth.uid(), 'tasks_delete')\n  )","-- Events: Permission-based access\nCREATE POLICY \\"events_create\\" ON public.events\n  FOR INSERT WITH CHECK (\n    public.has_permission(auth.uid(), 'events_create')\n  )","CREATE POLICY \\"events_read\\" ON public.events\n  FOR SELECT USING (\n    public.has_permission(auth.uid(), 'events_read') OR\n    owner_user_id = auth.uid()\n  )","CREATE POLICY \\"events_update\\" ON public.events\n  FOR UPDATE USING (\n    public.has_permission(auth.uid(), 'events_update') OR\n    owner_user_id = auth.uid()\n  )","CREATE POLICY \\"events_delete\\" ON public.events\n  FOR DELETE USING (\n    public.has_permission(auth.uid(), 'events_delete') OR\n    owner_user_id = auth.uid()\n  )"}	update_existing_rls_policies
20250823060000	{"-- User Management RPC Functions for 8-Role Permission System\n\n-- 1. Get all users with their role information (admin only)\nCREATE OR REPLACE FUNCTION public.get_all_users_with_roles()\nRETURNS TABLE(\n  user_id UUID,\n  email TEXT,\n  role_name TEXT,\n  role_level INTEGER,\n  role_display_name TEXT,\n  created_at TIMESTAMPTZ,\n  last_sign_in_at TIMESTAMPTZ\n)\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nBEGIN\n  -- Check if current user is admin\n  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN\n    RAISE EXCEPTION 'Access denied. Admin privileges required.';\n  END IF;\n\n  RETURN QUERY\n  SELECT \n    u.id as user_id,\n    u.email,\n    COALESCE(u.role, 'viewer') as role_name,\n    COALESCE(rd.role_level, 1) as role_level,\n    COALESCE(rd.display_name, 'ビュワー権限') as role_display_name,\n    u.created_at,\n    u.last_sign_in_at\n  FROM auth.users u\n  LEFT JOIN public.role_definitions rd ON u.role = rd.role_name\n  WHERE u.aud = 'authenticated'\n  ORDER BY u.created_at DESC;\nEND;\n$$","-- 2. Update user role (admin only)\nCREATE OR REPLACE FUNCTION public.update_user_role(\n  target_user_id UUID,\n  new_role_name TEXT\n)\nRETURNS VOID\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nBEGIN\n  -- Check if current user is admin\n  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN\n    RAISE EXCEPTION 'Access denied. Admin privileges required.';\n  END IF;\n\n  -- Validate role exists\n  IF NOT EXISTS (SELECT 1 FROM public.role_definitions WHERE role_name = new_role_name AND is_active = true) THEN\n    RAISE EXCEPTION 'Invalid role: %', new_role_name;\n  END IF;\n\n  -- Prevent removing admin role from the last admin\n  IF (SELECT role FROM auth.users WHERE id = target_user_id) = 'admin' \n     AND new_role_name != 'admin' \n     AND (SELECT COUNT(*) FROM auth.users WHERE role = 'admin') <= 1 THEN\n    RAISE EXCEPTION 'Cannot remove admin role from the last admin user';\n  END IF;\n\n  -- Update user role\n  UPDATE auth.users \n  SET \n    role = new_role_name,\n    updated_at = NOW()\n  WHERE id = target_user_id;\n\n  -- Log the role change (if you want to track changes)\n  INSERT INTO public.role_change_history (user_id, old_role, new_role, changed_by, changed_at)\n  VALUES (\n    target_user_id, \n    (SELECT role FROM auth.users WHERE id = target_user_id),\n    new_role_name,\n    auth.uid(),\n    NOW()\n  ) ON CONFLICT DO NOTHING;\nEND;\n$$","-- 3. Get user role history (admin only)\nCREATE OR REPLACE FUNCTION public.get_user_role_history(target_user_id UUID)\nRETURNS TABLE(\n  old_role TEXT,\n  new_role TEXT,\n  changed_by_email TEXT,\n  changed_at TIMESTAMPTZ\n)\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nBEGIN\n  -- Check if current user is admin\n  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN\n    RAISE EXCEPTION 'Access denied. Admin privileges required.';\n  END IF;\n\n  RETURN QUERY\n  SELECT \n    rch.old_role,\n    rch.new_role,\n    u.email as changed_by_email,\n    rch.changed_at\n  FROM public.role_change_history rch\n  LEFT JOIN auth.users u ON rch.changed_by = u.id\n  WHERE rch.user_id = target_user_id\n  ORDER BY rch.changed_at DESC;\nEND;\n$$","-- 4. Create role change history table\nCREATE TABLE IF NOT EXISTS public.role_change_history (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id UUID NOT NULL,\n  old_role TEXT,\n  new_role TEXT NOT NULL,\n  changed_by UUID,\n  changed_at TIMESTAMPTZ DEFAULT NOW()\n)","-- 5. Bulk update user roles (admin only)\nCREATE OR REPLACE FUNCTION public.bulk_update_user_roles(\n  user_role_updates JSONB\n)\nRETURNS VOID\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nDECLARE\n  update_item JSONB;\nBEGIN\n  -- Check if current user is admin\n  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN\n    RAISE EXCEPTION 'Access denied. Admin privileges required.';\n  END IF;\n\n  -- Process each update\n  FOR update_item IN SELECT * FROM jsonb_array_elements(user_role_updates)\n  LOOP\n    PERFORM public.update_user_role(\n      (update_item->>'user_id')::UUID,\n      update_item->>'role_name'\n    );\n  END LOOP;\nEND;\n$$","-- 6. Get role statistics (admin only)\nCREATE OR REPLACE FUNCTION public.get_role_statistics()\nRETURNS TABLE(\n  role_name TEXT,\n  role_display_name TEXT,\n  role_level INTEGER,\n  user_count BIGINT\n)\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nBEGIN\n  -- Check if current user is admin\n  IF NOT (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin' THEN\n    RAISE EXCEPTION 'Access denied. Admin privileges required.';\n  END IF;\n\n  RETURN QUERY\n  SELECT \n    rd.role_name,\n    rd.display_name as role_display_name,\n    rd.role_level,\n    COUNT(u.id) as user_count\n  FROM public.role_definitions rd\n  LEFT JOIN auth.users u ON rd.role_name = u.role\n  WHERE rd.is_active = true\n  GROUP BY rd.role_name, rd.display_name, rd.role_level\n  ORDER BY rd.role_level DESC;\nEND;\n$$","-- Grant execute permissions to authenticated users (RLS will handle admin check)\nGRANT EXECUTE ON FUNCTION public.get_all_users_with_roles() TO authenticated","GRANT EXECUTE ON FUNCTION public.update_user_role(UUID, TEXT) TO authenticated","GRANT EXECUTE ON FUNCTION public.get_user_role_history(UUID) TO authenticated","GRANT EXECUTE ON FUNCTION public.bulk_update_user_roles(JSONB) TO authenticated","GRANT EXECUTE ON FUNCTION public.get_role_statistics() TO authenticated","-- Enable RLS on role_change_history\nALTER TABLE public.role_change_history ENABLE ROW LEVEL SECURITY","-- Admin can manage all role history\nCREATE POLICY \\"role_history_admin_all\\" ON public.role_change_history\n  FOR ALL USING (\n    (SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin'\n  )"}	add_user_management_rpc
20250823070000	{"-- Add RPC function to get current user with role information\n\nCREATE OR REPLACE FUNCTION public.get_current_user_with_role()\nRETURNS TABLE(\n  user_id UUID,\n  email TEXT,\n  role_name TEXT,\n  role_level INTEGER,\n  role_display_name TEXT\n)\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nBEGIN\n  RETURN QUERY\n  SELECT \n    u.id as user_id,\n    u.email,\n    COALESCE(u.role, 'viewer') as role_name,\n    COALESCE(rd.role_level, 1) as role_level,\n    COALESCE(rd.display_name, 'ビュワー権限') as role_display_name\n  FROM auth.users u\n  LEFT JOIN public.role_definitions rd ON u.role = rd.role_name\n  WHERE u.id = auth.uid()\n  LIMIT 1;\nEND;\n$$","-- Grant execute permission\nGRANT EXECUTE ON FUNCTION public.get_current_user_with_role() TO authenticated"}	add_current_user_role_rpc
20250823080000	{"-- profiles テーブルのRLSポリシーの競合を解決\n\n-- 既存の全てのポリシーを削除\nDROP POLICY IF EXISTS \\"Users can view own profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"Users can update own profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"Users can insert own profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"admin_full_access\\" ON public.profiles","DROP POLICY IF EXISTS \\"users_own_profile\\" ON public.profiles","DROP POLICY IF EXISTS \\"profiles_admin_all\\" ON public.profiles","DROP POLICY IF EXISTS \\"profiles_user_own\\" ON public.profiles","DROP POLICY IF EXISTS \\"profiles_own_manage\\" ON public.profiles","DROP POLICY IF EXISTS \\"profiles_admin_manage\\" ON public.profiles","-- 新しい統合されたポリシーを作成\n-- ユーザーは自分のプロフィールを管理可能\nCREATE POLICY \\"profiles_user_own_access\\" ON public.profiles\n  FOR ALL \n  USING (auth.uid() = user_id)\n  WITH CHECK (auth.uid() = user_id)","-- 管理者は全プロフィールを管理可能\nCREATE POLICY \\"profiles_admin_full_access\\" ON public.profiles\n  FOR ALL \n  USING ((SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin')\n  WITH CHECK ((SELECT role FROM auth.users WHERE id = auth.uid()) = 'admin')","-- プロフィールは認証ユーザーによって読み取り可能（メンション機能などで必要）\nCREATE POLICY \\"profiles_authenticated_read\\" ON public.profiles\n  FOR SELECT \n  USING (auth.role() = 'authenticated')"}	fix_profiles_rls_policies
20250823210000	{"-- Implement 8-role system following the same hybrid pattern as admin.admins\n-- This matches the existing admin schema structure\n\n-- Step 1: Clean up existing complex permission system\nDROP FUNCTION IF EXISTS public.has_permission(uuid, text)","DROP FUNCTION IF EXISTS public.get_user_role(uuid)","DROP FUNCTION IF EXISTS public.get_current_user_with_role()","DROP FUNCTION IF EXISTS public.get_all_users_with_roles()","DROP FUNCTION IF EXISTS public.update_user_role(uuid, text)","DROP TABLE IF EXISTS public.role_permissions","DROP TABLE IF EXISTS public.permission_definitions","DROP TABLE IF EXISTS public.role_definitions","-- Drop complex permission policies\nDROP POLICY IF EXISTS \\"organizations_create\\" ON public.organizations","DROP POLICY IF EXISTS \\"organizations_read\\" ON public.organizations","DROP POLICY IF EXISTS \\"organizations_update\\" ON public.organizations","DROP POLICY IF EXISTS \\"organizations_delete\\" ON public.organizations","DROP POLICY IF EXISTS \\"projects_create\\" ON public.projects","DROP POLICY IF EXISTS \\"projects_read\\" ON public.projects","DROP POLICY IF EXISTS \\"projects_update\\" ON public.projects","DROP POLICY IF EXISTS \\"projects_delete\\" ON public.projects","DROP POLICY IF EXISTS \\"tasks_create\\" ON public.tasks","DROP POLICY IF EXISTS \\"tasks_read\\" ON public.tasks","DROP POLICY IF EXISTS \\"tasks_update\\" ON public.tasks","DROP POLICY IF EXISTS \\"tasks_delete\\" ON public.tasks","DROP POLICY IF EXISTS \\"events_create\\" ON public.events","DROP POLICY IF EXISTS \\"events_read\\" ON public.events","DROP POLICY IF EXISTS \\"events_update\\" ON public.events","DROP POLICY IF EXISTS \\"events_delete\\" ON public.events","DROP POLICY IF EXISTS \\"profiles_admin_manage\\" ON public.profiles","-- Step 2: Create roles schema and user_roles table\nCREATE SCHEMA IF NOT EXISTS roles","CREATE TABLE IF NOT EXISTS roles.user_roles(\n  user_id uuid PRIMARY KEY REFERENCES auth.users(id),\n  role_name text NOT NULL CHECK (role_name IN ('admin', 'organizer', 'sponsor', 'agency', 'production', 'secretariat', 'staff', 'viewer')),\n  granted_by uuid REFERENCES auth.users(id),\n  granted_at timestamptz NOT NULL DEFAULT now(),\n  updated_at timestamptz NOT NULL DEFAULT now()\n)","CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON roles.user_roles(user_id)","CREATE INDEX IF NOT EXISTS idx_user_roles_role_name ON roles.user_roles(role_name)","-- Enable RLS on roles.user_roles\nALTER TABLE roles.user_roles ENABLE ROW LEVEL SECURITY","-- Only authenticated users can read role status (for RLS policies)\nCREATE POLICY \\"authenticated_read_roles\\" ON roles.user_roles\n  FOR SELECT USING (auth.role() = 'authenticated')","-- Step 3: Create function to sync role to app_metadata\nCREATE OR REPLACE FUNCTION roles.sync_role_metadata()\nRETURNS void\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nDECLARE\n  user_record record;\nBEGIN\n  -- Update all users with their current role\n  FOR user_record IN \n    SELECT u.id, COALESCE(ur.role_name, 'viewer') as user_role\n    FROM auth.users u\n    LEFT JOIN roles.user_roles ur ON u.id = ur.user_id\n  LOOP\n    UPDATE auth.users \n    SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', user_record.user_role)\n    WHERE id = user_record.id;\n  END LOOP;\nEND;\n$$","-- Step 4: Create function to assign role\nCREATE OR REPLACE FUNCTION roles.assign_role(target_user_id uuid, new_role text, granter_user_id uuid DEFAULT auth.uid())\nRETURNS void\nLANGUAGE plpgsql\nSECURITY DEFINER\nAS $$\nBEGIN\n  -- Check if granter is admin (bootstrap case allows if no roles exist)\n  IF NOT EXISTS (SELECT 1 FROM admin.admins WHERE user_id = granter_user_id AND (expires_at IS NULL OR expires_at > now())) THEN\n    IF EXISTS (SELECT 1 FROM roles.user_roles) THEN\n      RAISE EXCEPTION 'Only admins can assign roles';\n    END IF;\n  END IF;\n  \n  -- Validate role\n  IF new_role NOT IN ('admin', 'organizer', 'sponsor', 'agency', 'production', 'secretariat', 'staff', 'viewer') THEN\n    RAISE EXCEPTION 'Invalid role: %', new_role;\n  END IF;\n  \n  -- Insert or update role record\n  INSERT INTO roles.user_roles (user_id, role_name, granted_by)\n  VALUES (target_user_id, new_role, granter_user_id)\n  ON CONFLICT (user_id) DO UPDATE SET\n    role_name = excluded.role_name,\n    granted_by = excluded.granted_by,\n    updated_at = now();\n    \n  -- Sync metadata\n  PERFORM roles.sync_role_metadata();\nEND;\n$$","-- Step 5: Update RLS policies to use JWT app_metadata (same pattern as admin)\n-- Simple role-based policies using JWT app_metadata\nCREATE POLICY \\"organizations_role_based\\" ON public.organizations\n  FOR ALL USING (\n    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'sponsor') OR\n    EXISTS (SELECT 1 FROM organization_memberships om WHERE om.org_id = id AND om.user_id = auth.uid())\n  )","CREATE POLICY \\"projects_role_based\\" ON public.projects\n  FOR ALL USING (\n    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'agency', 'production') OR\n    created_by = auth.uid() OR\n    EXISTS (SELECT 1 FROM project_memberships pm WHERE pm.project_id = id AND pm.user_id = auth.uid())\n  )","CREATE POLICY \\"tasks_role_based\\" ON public.tasks\n  FOR ALL USING (\n    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'agency', 'production', 'secretariat', 'staff') OR\n    created_by = auth.uid() OR\n    EXISTS (SELECT 1 FROM project_memberships pm WHERE pm.project_id = tasks.project_id AND pm.user_id = auth.uid())\n  )","CREATE POLICY \\"events_role_based\\" ON public.events\n  FOR ALL USING (\n    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'organizer', 'secretariat') OR\n    owner_user_id = auth.uid()\n  )","-- Step 6: Grant necessary permissions\nGRANT USAGE ON SCHEMA roles TO authenticated","GRANT SELECT ON roles.user_roles TO authenticated","GRANT EXECUTE ON FUNCTION roles.assign_role(uuid, text, uuid) TO authenticated","GRANT EXECUTE ON FUNCTION roles.sync_role_metadata() TO authenticated"}	implement_8_roles_hybrid_system
20250823220000	{"-- Fix profiles RLS policies to resolve 403 Forbidden errors\n-- Drop all existing policies on profiles table\nDROP POLICY IF EXISTS \\"profiles_admin_all\\" ON profiles","DROP POLICY IF EXISTS \\"profiles_user_own\\" ON profiles","DROP POLICY IF EXISTS \\"profiles_admin_manage\\" ON profiles","DROP POLICY IF EXISTS \\"Users can view own profile\\" ON profiles","DROP POLICY IF EXISTS \\"Users can update own profile\\" ON profiles","DROP POLICY IF EXISTS \\"Users can insert own profile\\" ON profiles","DROP POLICY IF EXISTS \\"admin_full_access\\" ON profiles","DROP POLICY IF EXISTS \\"users_own_profile\\" ON profiles","-- Ensure RLS is enabled\nALTER TABLE profiles ENABLE ROW LEVEL SECURITY","-- Create working policies for profiles access\n-- Allow all authenticated users to read profiles (needed for project members, mentions, etc.)\nCREATE POLICY \\"profiles_select_authenticated\\" ON profiles \nFOR SELECT \nTO authenticated \nUSING (true)","-- Users can insert their own profile\nCREATE POLICY \\"profiles_insert_own\\" ON profiles \nFOR INSERT \nTO authenticated \nWITH CHECK (auth.uid() = user_id)","-- Users can update their own profile\nCREATE POLICY \\"profiles_update_own\\" ON profiles \nFOR UPDATE \nTO authenticated \nUSING (auth.uid() = user_id)","-- Admins can do everything via JWT role check\nCREATE POLICY \\"profiles_admin_all\\" ON profiles \nFOR ALL \nTO authenticated \nUSING (\n  COALESCE(\n    (auth.jwt() ->> 'app_metadata')::json ->> 'role',\n    'viewer'\n  ) = 'admin'\n)"}	fix_profiles_rls_immediate
20250823230000	{"-- Create profiles table with proper RLS policies\n-- This migration ensures profiles table exists and works correctly\n\n-- Drop table if exists to start fresh\nDROP TABLE IF EXISTS profiles CASCADE","-- Create profiles table\nCREATE TABLE profiles (\n    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,\n    display_name TEXT,\n    company TEXT,\n    created_at TIMESTAMPTZ DEFAULT NOW(),\n    updated_at TIMESTAMPTZ DEFAULT NOW()\n)","-- Create updated_at trigger\nCREATE OR REPLACE FUNCTION update_updated_at_column()\nRETURNS TRIGGER AS $$\nBEGIN\n    NEW.updated_at = NOW();\n    RETURN NEW;\nEND;\n$$ language 'plpgsql'","CREATE TRIGGER profiles_updated_at\n    BEFORE UPDATE ON profiles\n    FOR EACH ROW\n    EXECUTE PROCEDURE update_updated_at_column()","-- Enable RLS\nALTER TABLE profiles ENABLE ROW LEVEL SECURITY","-- Create simple, working RLS policies\nCREATE POLICY \\"profiles_select_all\\" \nON profiles FOR SELECT \nTO authenticated \nUSING (true)","CREATE POLICY \\"profiles_insert_own\\" \nON profiles FOR INSERT \nTO authenticated \nWITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"profiles_update_own\\" \nON profiles FOR UPDATE \nTO authenticated \nUSING (auth.uid() = user_id)\nWITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"profiles_delete_own\\" \nON profiles FOR DELETE \nTO authenticated \nUSING (auth.uid() = user_id)","-- Grant necessary permissions\nGRANT ALL ON profiles TO authenticated","GRANT ALL ON profiles TO service_role"}	create_profiles_final
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 46, true);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('supabase_functions.hooks_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

