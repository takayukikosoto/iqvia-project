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
-- Name: admin; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA admin;


ALTER SCHEMA admin OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: comment_target; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.comment_target AS ENUM (
    'task',
    'file'
);


ALTER TYPE public.comment_target OWNER TO postgres;

--
-- Name: link_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.link_type AS ENUM (
    'url',
    'file',
    'storage'
);


ALTER TYPE public.link_type OWNER TO postgres;

--
-- Name: notify_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.notify_type AS ENUM (
    'task_updated',
    'task_commented',
    'file_versioned',
    'mention'
);


ALTER TYPE public.notify_type OWNER TO postgres;

--
-- Name: storage_provider; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.storage_provider AS ENUM (
    'box',
    'supabase'
);


ALTER TYPE public.storage_provider OWNER TO postgres;

--
-- Name: task_priority; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.task_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);


ALTER TYPE public.task_priority OWNER TO postgres;

--
-- Name: task_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.task_status AS ENUM (
    'todo',
    'review',
    'done',
    'resolved'
);


ALTER TYPE public.task_status OWNER TO postgres;

--
-- Name: grant_admin_privileges(uuid, uuid); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.grant_admin_privileges(target_user_id uuid, granter_user_id uuid DEFAULT auth.uid()) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  -- Check if granter is admin (or allow if no admins exist yet for bootstrap)
  if not exists (select 1 from admin.admins where expires_at is null or expires_at > now()) then
    -- Bootstrap case: allow if no admins exist
    null;
  elsif not exists (
    select 1 from admin.admins 
    where user_id = granter_user_id 
    and (expires_at is null or expires_at > now())
  ) then
    raise exception 'Only admins can grant admin privileges';
  end if;
  
  -- Insert or update admin record
  insert into admin.admins (user_id, granted_by)
  values (target_user_id, granter_user_id)
  on conflict (user_id) do update set
    granted_by = excluded.granted_by,
    granted_at = now(),
    expires_at = null;
    
  -- Sync metadata
  perform admin.sync_admin_metadata();
end;
$$;


ALTER FUNCTION admin.grant_admin_privileges(target_user_id uuid, granter_user_id uuid) OWNER TO postgres;

--
-- Name: revoke_admin_privileges(uuid); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.revoke_admin_privileges(target_user_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  -- Check if caller is admin
  if not exists (
    select 1 from admin.admins 
    where user_id = auth.uid() 
    and (expires_at is null or expires_at > now())
  ) then
    raise exception 'Only admins can revoke admin privileges';
  end if;
  
  -- Remove admin record
  delete from admin.admins where user_id = target_user_id;
  
  -- Sync metadata
  perform admin.sync_admin_metadata();
end;
$$;


ALTER FUNCTION admin.revoke_admin_privileges(target_user_id uuid) OWNER TO postgres;

--
-- Name: sync_admin_metadata(); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.sync_admin_metadata() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  admin_user record;
begin
  -- Update all current admins to have is_admin = true
  for admin_user in 
    select user_id from admin.admins 
    where expires_at is null or expires_at > now()
  loop
    update auth.users 
    set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"is_admin": true}'::jsonb
    where id = admin_user.user_id;
  end loop;
  
  -- Update non-admins to have is_admin = false or remove the flag
  update auth.users 
  set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"is_admin": false}'::jsonb
  where id not in (
    select user_id from admin.admins 
    where expires_at is null or expires_at > now()
  );
end;
$$;


ALTER FUNCTION admin.sync_admin_metadata() OWNER TO postgres;

--
-- Name: extract_mentions_from_message(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.extract_mentions_from_message() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.extract_mentions_from_message() OWNER TO postgres;

--
-- Name: get_current_admins(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_current_admins() RETURNS TABLE(user_id uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return query
  select a.user_id
  from admin.admins a
  where a.expires_at is null or a.expires_at > now();
end;
$$;


ALTER FUNCTION public.get_current_admins() OWNER TO postgres;

--
-- Name: get_project_id_from_task(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_project_id_from_task(task_uuid uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return (select project_id from public.tasks where id = task_uuid);
end;
$$;


ALTER FUNCTION public.get_project_id_from_task(task_uuid uuid) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Only create profile with basic info (no role management)
    INSERT INTO public.profiles (user_id, display_name, company)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'company', 'Unknown')
    );
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: handle_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_updated_at() OWNER TO postgres;

--
-- Name: has_project_role(uuid, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.has_project_role(project_uuid uuid, required_roles text[]) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return exists (
    select 1 from public.project_memberships
    where project_id = project_uuid 
      and user_id = auth.uid()
      and role = any(required_roles)
  );
end;
$$;


ALTER FUNCTION public.has_project_role(project_uuid uuid, required_roles text[]) OWNER TO postgres;

--
-- Name: is_org_member(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_org_member(org_uuid uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return exists (
    select 1 from public.organization_memberships
    where org_id = org_uuid and user_id = auth.uid()
  );
end;
$$;


ALTER FUNCTION public.is_org_member(org_uuid uuid) OWNER TO postgres;

--
-- Name: is_project_member(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_project_member(project_uuid uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return exists (
    select 1 from public.project_memberships
    where project_id = project_uuid and user_id = auth.uid()
  );
end;
$$;


ALTER FUNCTION public.is_project_member(project_uuid uuid) OWNER TO postgres;

--
-- Name: is_user_admin(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_user_admin(check_user_id uuid DEFAULT auth.uid()) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return exists (
    select 1 
    from admin.admins a
    where a.user_id = check_user_id
    and (a.expires_at is null or a.expires_at > now())
  );
end;
$$;


ALTER FUNCTION public.is_user_admin(check_user_id uuid) OWNER TO postgres;

--
-- Name: log_priority_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_priority_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  -- Only log if priority actually changed
  if old.priority is distinct from new.priority then
    insert into public.priority_change_history (
      task_id,
      user_id,
      old_priority,
      new_priority,
      reason
    ) values (
      new.id,
      auth.uid(),
      old.priority,
      new.priority,
      'Priority updated via UI'
    );
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.log_priority_change() OWNER TO postgres;

--
-- Name: notify_comment_created(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_comment_created() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  target_project_id uuid;
  member_id uuid;
  payload_data jsonb;
begin
  -- Get project ID based on comment target
  if new.target_type = 'task' then
    select project_id into target_project_id
    from public.tasks where id = new.target_id;
  elsif new.target_type = 'file' then
    select project_id into target_project_id
    from public.files where id = new.target_id;
  end if;

  -- Build notification payload
  payload_data = jsonb_build_object(
    'comment_id', new.id,
    'target_type', new.target_type,
    'target_id', new.target_id,
    'project_id', target_project_id,
    'comment_body', left(new.body, 100),
    'commented_by', auth.uid()
  );

  -- Notify all project members except the comment author
  for member_id in 
    select user_id from public.project_memberships 
    where project_id = target_project_id and user_id != auth.uid()
  loop
    insert into public.notifications (user_id, type, payload)
    values (member_id, 'task_commented', payload_data);
  end loop;

  return new;
end;
$$;


ALTER FUNCTION public.notify_comment_created() OWNER TO postgres;

--
-- Name: notify_task_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_task_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  watcher_id uuid;
  assignee_id uuid;
  payload_data jsonb;
begin
  -- Build notification payload
  payload_data = jsonb_build_object(
    'task_id', new.id,
    'task_title', new.title,
    'project_id', new.project_id,
    'changed_by', auth.uid(),
    'old_status', coalesce(old.status::text, 'new'),
    'new_status', new.status::text,
    'change_type', case when old is null then 'created' else 'updated' end
  );

  -- Notify task watchers
  for watcher_id in 
    select user_id from public.task_watchers 
    where task_id = new.id and user_id != auth.uid()
  loop
    insert into public.notifications (user_id, type, payload)
    values (watcher_id, 'task_updated', payload_data);
  end loop;

  -- Notify task assignees (if not already notified as watcher)
  for assignee_id in 
    select user_id from public.task_assignees 
    where task_id = new.id 
      and user_id != auth.uid()
      and not exists (
        select 1 from public.task_watchers 
        where task_id = new.id and user_id = assignee_id
      )
  loop
    insert into public.notifications (user_id, type, payload)
    values (assignee_id, 'task_updated', payload_data);
  end loop;

  return new;
end;
$$;


ALTER FUNCTION public.notify_task_update() OWNER TO postgres;

--
-- Name: set_updated_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_columns() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  new.updated_by = auth.uid();
  return new;
end;
$$;


ALTER FUNCTION public.set_updated_columns() OWNER TO postgres;

--
-- Name: update_files_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_files_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_files_updated_at() OWNER TO postgres;

--
-- Name: update_priority_options_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_priority_options_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION public.update_priority_options_updated_at() OWNER TO postgres;

--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: admin; Owner: postgres
--

CREATE TABLE admin.admins (
    user_id uuid NOT NULL,
    granted_by uuid,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone
);


ALTER TABLE admin.admins OWNER TO postgres;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content text NOT NULL,
    user_id uuid,
    project_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    display_name text,
    company text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: chat_messages_with_profiles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.chat_messages_with_profiles WITH (security_invoker='true') AS
 SELECT cm.id,
    cm.project_id,
    cm.user_id,
    cm.content,
    cm.created_at,
    COALESCE(p.display_name, ('User '::text || "left"((cm.user_id)::text, 8))) AS display_name,
    COALESCE(p.company, '会社名未設定'::text) AS company
   FROM (public.chat_messages cm
     LEFT JOIN public.profiles p ON ((cm.user_id = p.user_id)));


ALTER VIEW public.chat_messages_with_profiles OWNER TO postgres;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    target_type public.comment_target NOT NULL,
    target_id uuid NOT NULL,
    body text NOT NULL,
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: custom_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_statuses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    label character varying(100) NOT NULL,
    color character varying(7) NOT NULL,
    order_index integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_by uuid,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.custom_statuses OWNER TO postgres;

--
-- Name: file_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.file_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    file_id uuid NOT NULL,
    version integer NOT NULL,
    size_bytes bigint,
    checksum text,
    storage_key text,
    uploaded_at timestamp with time zone DEFAULT now(),
    uploaded_by uuid,
    name character varying(255),
    storage_path text,
    external_id character varying(255),
    upload_status character varying(50) DEFAULT 'completed'::character varying,
    change_notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    version_number integer
);


ALTER TABLE public.file_versions OWNER TO postgres;

--
-- Name: files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.files (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    name text NOT NULL,
    provider public.storage_provider NOT NULL,
    external_id text,
    external_url text,
    current_version integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    description text,
    file_type character varying(100),
    mime_type character varying(255),
    storage_path text,
    total_versions integer DEFAULT 1,
    total_size_bytes bigint DEFAULT 0,
    current_version_id uuid
);


ALTER TABLE public.files OWNER TO postgres;

--
-- Name: mentions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mentions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    message_id uuid NOT NULL,
    mentioned_user_id uuid NOT NULL,
    mentioned_by_user_id uuid NOT NULL,
    project_id uuid NOT NULL,
    mention_text text NOT NULL,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.mentions OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type public.notify_type NOT NULL,
    payload jsonb NOT NULL,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: organization_memberships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_memberships (
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT organization_memberships_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'org_manager'::text, 'project_manager'::text, 'contributor'::text, 'viewer'::text])))
);


ALTER TABLE public.organization_memberships OWNER TO postgres;

--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: priority_change_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.priority_change_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    user_id uuid NOT NULL,
    old_priority character varying(50),
    new_priority character varying(50) NOT NULL,
    changed_at timestamp with time zone DEFAULT now(),
    reason text
);


ALTER TABLE public.priority_change_history OWNER TO postgres;

--
-- Name: priority_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.priority_options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(50) NOT NULL,
    label character varying(100) NOT NULL,
    color character varying(7) NOT NULL,
    weight integer NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.priority_options OWNER TO postgres;

--
-- Name: project_memberships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_memberships (
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT project_memberships_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'member'::text, 'viewer'::text])))
);


ALTER TABLE public.project_memberships OWNER TO postgres;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    name text NOT NULL,
    start_date date,
    end_date date,
    status text DEFAULT 'active'::text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    description text,
    settings jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: task_assignees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_assignees (
    task_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid
);


ALTER TABLE public.task_assignees OWNER TO postgres;

--
-- Name: task_links; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    title text NOT NULL,
    url text NOT NULL,
    link_type public.link_type DEFAULT 'url'::public.link_type NOT NULL,
    description text,
    file_id uuid,
    storage_provider text,
    storage_key text,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid
);


ALTER TABLE public.task_links OWNER TO postgres;

--
-- Name: task_watchers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_watchers (
    task_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid
);


ALTER TABLE public.task_watchers OWNER TO postgres;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    priority public.task_priority DEFAULT 'medium'::public.task_priority NOT NULL,
    due_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    status public.task_status DEFAULT 'todo'::public.task_status NOT NULL,
    custom_status_id uuid,
    storage_folder text
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Data for Name: admins; Type: TABLE DATA; Schema: admin; Owner: postgres
--

COPY admin.admins (user_id, granted_by, granted_at, expires_at) FROM stdin;
bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	\N	2025-08-21 01:31:43.622373+00	\N
0a403252-cfaf-4ac1-94ca-1c5ae0b5449f	\N	2025-08-21 02:02:45.717626+00	\N
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
\.


--
-- Data for Name: custom_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_statuses (id, project_id, name, label, color, order_index, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: file_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.file_versions (id, file_id, version, size_bytes, checksum, storage_key, uploaded_at, uploaded_by, name, storage_path, external_id, upload_status, change_notes, created_by, created_at, version_number) FROM stdin;
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.files (id, project_id, name, provider, external_id, external_url, current_version, created_at, created_by, updated_at, updated_by, description, file_type, mime_type, storage_path, total_versions, total_size_bytes, current_version_id) FROM stdin;
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
\.


--
-- Data for Name: organization_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_memberships (org_id, user_id, role, created_at, created_by) FROM stdin;
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440001	admin	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440002	project_manager	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440003	contributor	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111111	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	admin	2025-08-21 01:31:43.581061+00	\N
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, created_at, created_by, updated_at, updated_by) FROM stdin;
11111111-1111-1111-1111-111111111111	テスト組織	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.565154+00	\N
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
6756b05a-e325-421e-a65a-7c9e79c51810	low	低	#28a745	1	t	2025-08-21 01:31:43.530181+00	2025-08-21 01:31:43.597217+00
134d5022-3765-4636-9683-3399279d16d9	medium	中	#007bff	2	t	2025-08-21 01:31:43.530181+00	2025-08-21 01:31:43.597217+00
79a543c1-9b01-4caf-8a63-656d8e08a52d	high	高	#ffc107	3	t	2025-08-21 01:31:43.530181+00	2025-08-21 01:31:43.597217+00
8ea12884-b81a-40f0-b8ad-cc048628bc83	urgent	緊急	#dc3545	4	t	2025-08-21 01:31:43.530181+00	2025-08-21 01:31:43.597217+00
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (id, user_id, display_name, company, created_at, updated_at) FROM stdin;
8efe8f74-195c-4163-bd8f-631a35b66ab8	0a403252-cfaf-4ac1-94ca-1c5ae0b5449f	kosoto	Unknown	2025-08-21 01:40:27.488034+00	2025-08-21 01:40:27.488034+00
\.


--
-- Data for Name: project_memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_memberships (project_id, user_id, role, created_at, created_by) FROM stdin;
22222222-2222-2222-2222-222222222222	550e8400-e29b-41d4-a716-446655440001	admin	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
22222222-2222-2222-2222-222222222222	550e8400-e29b-41d4-a716-446655440002	admin	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
22222222-2222-2222-2222-222222222222	550e8400-e29b-41d4-a716-446655440003	member	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
22222222-2222-2222-2222-222222222222	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	admin	2025-08-21 01:31:43.581061+00	\N
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, organization_id, name, start_date, end_date, status, created_at, created_by, updated_at, updated_by, description, settings) FROM stdin;
22222222-2222-2222-2222-222222222222	11111111-1111-1111-1111-111111111111	テストプロジェクト	2025-01-01	2025-06-30	active	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.565154+00	\N	\N	{}
\.


--
-- Data for Name: task_assignees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_assignees (task_id, user_id, created_at, created_by) FROM stdin;
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440002	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111112	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111113	550e8400-e29b-41d4-a716-446655440003	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111114	550e8400-e29b-41d4-a716-446655440003	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111115	550e8400-e29b-41d4-a716-446655440002	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
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
11111111-1111-1111-1111-111111111111	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111112	550e8400-e29b-41d4-a716-446655440002	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
11111111-1111-1111-1111-111111111113	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, project_id, title, description, priority, due_at, created_at, created_by, updated_at, updated_by, status, custom_status_id, storage_folder) FROM stdin;
11111111-1111-1111-1111-111111111111	22222222-2222-2222-2222-222222222222	会場選定・予約	治験イベント会場の調査と予約手配を行う	high	2025-02-15 00:00:00+00	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.552646+00	\N	todo	\N	\N
11111111-1111-1111-1111-111111111112	22222222-2222-2222-2222-222222222222	講演者調整	キーオピニオンリーダーおよび治験責任医師との連絡調整	high	2025-02-28 00:00:00+00	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.552646+00	\N	todo	\N	\N
11111111-1111-1111-1111-111111111113	22222222-2222-2222-2222-222222222222	マーケティング資料作成	パンフレット、バナー、デジタル素材の制作	medium	2025-03-10 00:00:00+00	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.552646+00	\N	review	\N	\N
11111111-1111-1111-1111-111111111114	22222222-2222-2222-2222-222222222222	参加登録システム構築	オンライン参加登録システムとバッジ印刷機能の実装	medium	2025-01-30 00:00:00+00	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.552646+00	\N	done	\N	\N
11111111-1111-1111-1111-111111111115	22222222-2222-2222-2222-222222222222	ケータリング手配	メニュー企画と食事制限対応の準備	low	2025-03-01 00:00:00+00	2025-08-21 01:31:43.522277+00	550e8400-e29b-41d4-a716-446655440001	2025-08-21 01:31:43.552646+00	\N	resolved	\N	\N
\.


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (user_id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: custom_statuses custom_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_statuses
    ADD CONSTRAINT custom_statuses_pkey PRIMARY KEY (id);


--
-- Name: custom_statuses custom_statuses_project_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_statuses
    ADD CONSTRAINT custom_statuses_project_id_name_key UNIQUE (project_id, name);


--
-- Name: file_versions file_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: mentions mentions_message_id_mentioned_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_message_id_mentioned_user_id_key UNIQUE (message_id, mentioned_user_id);


--
-- Name: mentions mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: organization_memberships organization_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_pkey PRIMARY KEY (org_id, user_id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: priority_change_history priority_change_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priority_change_history
    ADD CONSTRAINT priority_change_history_pkey PRIMARY KEY (id);


--
-- Name: priority_options priority_options_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priority_options
    ADD CONSTRAINT priority_options_name_key UNIQUE (name);


--
-- Name: priority_options priority_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priority_options
    ADD CONSTRAINT priority_options_pkey PRIMARY KEY (id);


--
-- Name: priority_options priority_options_weight_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priority_options
    ADD CONSTRAINT priority_options_weight_key UNIQUE (weight);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);


--
-- Name: project_memberships project_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_memberships
    ADD CONSTRAINT project_memberships_pkey PRIMARY KEY (project_id, user_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: task_assignees task_assignees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assignees
    ADD CONSTRAINT task_assignees_pkey PRIMARY KEY (task_id, user_id);


--
-- Name: task_links task_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_links
    ADD CONSTRAINT task_links_pkey PRIMARY KEY (id);


--
-- Name: task_watchers task_watchers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_watchers
    ADD CONSTRAINT task_watchers_pkey PRIMARY KEY (task_id, user_id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: file_versions unique_file_version; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT unique_file_version UNIQUE (file_id, version_number);


--
-- Name: idx_admins_user_id; Type: INDEX; Schema: admin; Owner: postgres
--

CREATE INDEX idx_admins_user_id ON admin.admins USING btree (user_id);


--
-- Name: idx_comments_target_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_target_created ON public.comments USING btree (target_type, target_id, created_at);


--
-- Name: idx_custom_statuses_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_custom_statuses_project_id ON public.custom_statuses USING btree (project_id);


--
-- Name: idx_custom_statuses_project_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_custom_statuses_project_order ON public.custom_statuses USING btree (project_id, order_index);


--
-- Name: idx_file_versions_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_file_versions_created_by ON public.file_versions USING btree (created_by);


--
-- Name: idx_file_versions_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_file_versions_file_id ON public.file_versions USING btree (file_id);


--
-- Name: idx_files_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_created_by ON public.files USING btree (created_by);


--
-- Name: idx_files_file_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_file_type ON public.files USING btree (file_type);


--
-- Name: idx_files_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_files_project_id ON public.files USING btree (project_id);


--
-- Name: idx_mentions_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mentions_created_at ON public.mentions USING btree (created_at);


--
-- Name: idx_mentions_mentioned_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mentions_mentioned_user_id ON public.mentions USING btree (mentioned_user_id);


--
-- Name: idx_mentions_project_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mentions_project_id ON public.mentions USING btree (project_id);


--
-- Name: idx_mentions_read_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mentions_read_at ON public.mentions USING btree (read_at);


--
-- Name: idx_notifications_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user_created ON public.notifications USING btree (user_id, created_at);


--
-- Name: idx_priority_change_history_changed_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_priority_change_history_changed_at ON public.priority_change_history USING btree (changed_at DESC);


--
-- Name: idx_priority_change_history_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_priority_change_history_task_id ON public.priority_change_history USING btree (task_id);


--
-- Name: idx_priority_change_history_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_priority_change_history_user_id ON public.priority_change_history USING btree (user_id);


--
-- Name: idx_task_links_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_links_task_id ON public.task_links USING btree (task_id);


--
-- Name: idx_task_links_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_links_type ON public.task_links USING btree (link_type);


--
-- Name: idx_tasks_custom_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_custom_status ON public.tasks USING btree (custom_status_id);


--
-- Name: idx_tasks_project_status_prio; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_project_status_prio ON public.tasks USING btree (project_id, status, priority);


--
-- Name: profiles handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


--
-- Name: comments notify_on_comment_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER notify_on_comment_insert AFTER INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION public.notify_comment_created();


--
-- Name: tasks notify_on_task_change; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER notify_on_task_change AFTER INSERT OR UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.notify_task_update();


--
-- Name: files set_updated_at_files; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_files BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION public.set_updated_columns();


--
-- Name: organizations set_updated_at_organizations; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_organizations BEFORE UPDATE ON public.organizations FOR EACH ROW EXECUTE FUNCTION public.set_updated_columns();


--
-- Name: projects set_updated_at_projects; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_projects BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.set_updated_columns();


--
-- Name: tasks set_updated_at_tasks; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_tasks BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.set_updated_columns();


--
-- Name: files trigger_files_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_files_updated_at BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION public.update_files_updated_at();


--
-- Name: tasks trigger_log_priority_change; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_log_priority_change AFTER UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.log_priority_change();


--
-- Name: priority_options trigger_update_priority_options_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_priority_options_updated_at BEFORE UPDATE ON public.priority_options FOR EACH ROW EXECUTE FUNCTION public.update_priority_options_updated_at();


--
-- Name: custom_statuses update_custom_statuses_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_custom_statuses_updated_at BEFORE UPDATE ON public.custom_statuses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: admins admins_granted_by_fkey; Type: FK CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.admins
    ADD CONSTRAINT admins_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES auth.users(id);


--
-- Name: admins admins_user_id_fkey; Type: FK CONSTRAINT; Schema: admin; Owner: postgres
--

ALTER TABLE ONLY admin.admins
    ADD CONSTRAINT admins_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: comments comments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: custom_statuses custom_statuses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_statuses
    ADD CONSTRAINT custom_statuses_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: custom_statuses custom_statuses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_statuses
    ADD CONSTRAINT custom_statuses_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: custom_statuses custom_statuses_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_statuses
    ADD CONSTRAINT custom_statuses_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
-- Name: file_versions file_versions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: file_versions file_versions_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: file_versions file_versions_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_versions
    ADD CONSTRAINT file_versions_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth.users(id);


--
-- Name: files files_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: files files_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: files files_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
-- Name: files fk_files_current_version; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT fk_files_current_version FOREIGN KEY (current_version_id) REFERENCES public.file_versions(id);


--
-- Name: mentions mentions_mentioned_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_mentioned_by_user_id_fkey FOREIGN KEY (mentioned_by_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mentions mentions_mentioned_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_mentioned_user_id_fkey FOREIGN KEY (mentioned_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mentions mentions_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: organization_memberships organization_memberships_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: organization_memberships organization_memberships_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_memberships organization_memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: organizations organizations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: organizations organizations_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: priority_change_history priority_change_history_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priority_change_history
    ADD CONSTRAINT priority_change_history_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: priority_change_history priority_change_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.priority_change_history
    ADD CONSTRAINT priority_change_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: project_memberships project_memberships_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_memberships
    ADD CONSTRAINT project_memberships_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: project_memberships project_memberships_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_memberships
    ADD CONSTRAINT project_memberships_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_memberships project_memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_memberships
    ADD CONSTRAINT project_memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: projects projects_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: projects projects_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: projects projects_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: task_assignees task_assignees_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assignees
    ADD CONSTRAINT task_assignees_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: task_assignees task_assignees_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assignees
    ADD CONSTRAINT task_assignees_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_assignees task_assignees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assignees
    ADD CONSTRAINT task_assignees_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: task_links task_links_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_links
    ADD CONSTRAINT task_links_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: task_links task_links_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_links
    ADD CONSTRAINT task_links_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: task_links task_links_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_links
    ADD CONSTRAINT task_links_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_links task_links_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_links
    ADD CONSTRAINT task_links_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
-- Name: task_watchers task_watchers_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_watchers
    ADD CONSTRAINT task_watchers_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: task_watchers task_watchers_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_watchers
    ADD CONSTRAINT task_watchers_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_watchers task_watchers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_watchers
    ADD CONSTRAINT task_watchers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: tasks tasks_custom_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_custom_status_id_fkey FOREIGN KEY (custom_status_id) REFERENCES public.custom_statuses(id);


--
-- Name: tasks tasks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: admins; Type: ROW SECURITY; Schema: admin; Owner: postgres
--

ALTER TABLE admin.admins ENABLE ROW LEVEL SECURITY;

--
-- Name: admins authenticated_read_admins; Type: POLICY; Schema: admin; Owner: postgres
--

CREATE POLICY authenticated_read_admins ON admin.admins FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: priority_options All users can view priority options; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "All users can view priority options" ON public.priority_options FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: comments Comment authors can update their comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Comment authors can update their comments" ON public.comments FOR UPDATE USING ((created_by = auth.uid()));


--
-- Name: custom_statuses Enable delete for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for project members" ON public.custom_statuses FOR DELETE USING ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = custom_statuses.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: file_versions Enable delete for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for project members" ON public.file_versions FOR DELETE USING ((EXISTS ( SELECT 1
   FROM (public.files f
     JOIN public.project_memberships pm ON ((pm.project_id = f.project_id)))
  WHERE ((f.id = file_versions.file_id) AND (pm.user_id = auth.uid())))));


--
-- Name: files Enable delete for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for project members" ON public.files FOR DELETE USING ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = files.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: custom_statuses Enable insert for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for project members" ON public.custom_statuses FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = custom_statuses.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: file_versions Enable insert for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for project members" ON public.file_versions FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM (public.files f
     JOIN public.project_memberships pm ON ((pm.project_id = f.project_id)))
  WHERE ((f.id = file_versions.file_id) AND (pm.user_id = auth.uid())))));


--
-- Name: files Enable insert for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for project members" ON public.files FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = files.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: custom_statuses Enable read access for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for project members" ON public.custom_statuses FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = custom_statuses.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: file_versions Enable read access for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for project members" ON public.file_versions FOR SELECT USING ((EXISTS ( SELECT 1
   FROM (public.files f
     JOIN public.project_memberships pm ON ((pm.project_id = f.project_id)))
  WHERE ((f.id = file_versions.file_id) AND (pm.user_id = auth.uid())))));


--
-- Name: files Enable read access for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for project members" ON public.files FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = files.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: custom_statuses Enable update for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for project members" ON public.custom_statuses FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = custom_statuses.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: file_versions Enable update for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for project members" ON public.file_versions FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM (public.files f
     JOIN public.project_memberships pm ON ((pm.project_id = f.project_id)))
  WHERE ((f.id = file_versions.file_id) AND (pm.user_id = auth.uid())))));


--
-- Name: files Enable update for project members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for project members" ON public.files FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = files.project_id) AND (pm.user_id = auth.uid())))));


--
-- Name: mentions Mention creators can delete mentions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Mention creators can delete mentions" ON public.mentions FOR DELETE USING ((mentioned_by_user_id = auth.uid()));


--
-- Name: mentions Project members can create mentions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Project members can create mentions" ON public.mentions FOR INSERT WITH CHECK (((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = mentions.project_id) AND (pm.user_id = auth.uid())))) AND (mentioned_by_user_id = auth.uid())));


--
-- Name: notifications Service role can insert notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Service role can insert notifications" ON public.notifications FOR INSERT WITH CHECK (true);


--
-- Name: comments Users can create comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create comments" ON public.comments FOR INSERT WITH CHECK (true);


--
-- Name: tasks Users can create tasks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create tasks" ON public.tasks FOR INSERT WITH CHECK (true);


--
-- Name: tasks Users can delete tasks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete tasks" ON public.tasks FOR DELETE USING (true);


--
-- Name: priority_change_history Users can insert priority history entries; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert priority history entries" ON public.priority_change_history FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: file_versions Users can manage file versions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage file versions" ON public.file_versions USING (true);


--
-- Name: files Users can manage files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage files" ON public.files USING (true);


--
-- Name: organizations Users can manage organizations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage organizations" ON public.organizations USING (true);


--
-- Name: projects Users can manage projects; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage projects" ON public.projects USING (true);


--
-- Name: task_assignees Users can manage task assignees; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage task assignees" ON public.task_assignees USING (true);


--
-- Name: task_watchers Users can manage task watchers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage task watchers" ON public.task_watchers USING (true);


--
-- Name: organization_memberships Users can manage their own membership; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own membership" ON public.organization_memberships USING ((user_id = auth.uid()));


--
-- Name: project_memberships Users can manage their own project membership; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own project membership" ON public.project_memberships USING ((user_id = auth.uid()));


--
-- Name: mentions Users can read their own mentions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read their own mentions" ON public.mentions FOR SELECT USING ((mentioned_user_id = auth.uid()));


--
-- Name: notifications Users can update own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: tasks Users can update tasks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update tasks" ON public.tasks FOR UPDATE USING (true);


--
-- Name: mentions Users can update their own mentions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own mentions" ON public.mentions FOR UPDATE USING ((mentioned_user_id = auth.uid()));


--
-- Name: comments Users can view all comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all comments" ON public.comments FOR SELECT USING (true);


--
-- Name: file_versions Users can view all file versions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all file versions" ON public.file_versions FOR SELECT USING (true);


--
-- Name: files Users can view all files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all files" ON public.files FOR SELECT USING (true);


--
-- Name: organization_memberships Users can view all org memberships; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all org memberships" ON public.organization_memberships FOR SELECT USING (true);


--
-- Name: organizations Users can view all organizations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all organizations" ON public.organizations FOR SELECT USING (true);


--
-- Name: priority_change_history Users can view all priority history; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all priority history" ON public.priority_change_history FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: project_memberships Users can view all project memberships; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all project memberships" ON public.project_memberships FOR SELECT USING (true);


--
-- Name: projects Users can view all projects; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all projects" ON public.projects FOR SELECT USING (true);


--
-- Name: task_assignees Users can view all task assignees; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all task assignees" ON public.task_assignees FOR SELECT USING (true);


--
-- Name: task_watchers Users can view all task watchers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all task watchers" ON public.task_watchers FOR SELECT USING (true);


--
-- Name: tasks Users can view all tasks; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view all tasks" ON public.tasks FOR SELECT USING (true);


--
-- Name: notifications Users can view own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: comments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

--
-- Name: custom_statuses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.custom_statuses ENABLE ROW LEVEL SECURITY;

--
-- Name: file_versions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.file_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: files; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

--
-- Name: mentions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mentions ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_memberships; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.organization_memberships ENABLE ROW LEVEL SECURITY;

--
-- Name: organizations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

--
-- Name: organizations orgs_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY orgs_admin_all ON public.organizations USING (COALESCE((((auth.jwt() -> 'app_metadata'::text) ->> 'is_admin'::text))::boolean, false));


--
-- Name: organizations orgs_members_view; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY orgs_members_view ON public.organizations FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.organization_memberships om
  WHERE ((om.org_id = organizations.id) AND (om.user_id = auth.uid())))));


--
-- Name: priority_change_history; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.priority_change_history ENABLE ROW LEVEL SECURITY;

--
-- Name: priority_options; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.priority_options ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_admin_all ON public.profiles USING (COALESCE((((auth.jwt() -> 'app_metadata'::text) ->> 'is_admin'::text))::boolean, false));


--
-- Name: profiles profiles_user_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_user_own ON public.profiles USING ((auth.uid() = user_id));


--
-- Name: project_memberships; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.project_memberships ENABLE ROW LEVEL SECURITY;

--
-- Name: projects; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

--
-- Name: projects projects_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY projects_admin_all ON public.projects USING (COALESCE((((auth.jwt() -> 'app_metadata'::text) ->> 'is_admin'::text))::boolean, false));


--
-- Name: projects projects_members_view; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY projects_members_view ON public.projects FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.project_memberships pm
  WHERE ((pm.project_id = projects.id) AND (pm.user_id = auth.uid())))));


--
-- Name: task_assignees; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.task_assignees ENABLE ROW LEVEL SECURITY;

--
-- Name: task_watchers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.task_watchers ENABLE ROW LEVEL SECURITY;

--
-- Name: tasks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA admin; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA admin TO authenticated;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION grant_admin_privileges(target_user_id uuid, granter_user_id uuid); Type: ACL; Schema: admin; Owner: postgres
--

GRANT ALL ON FUNCTION admin.grant_admin_privileges(target_user_id uuid, granter_user_id uuid) TO authenticated;


--
-- Name: FUNCTION revoke_admin_privileges(target_user_id uuid); Type: ACL; Schema: admin; Owner: postgres
--

GRANT ALL ON FUNCTION admin.revoke_admin_privileges(target_user_id uuid) TO authenticated;


--
-- Name: FUNCTION sync_admin_metadata(); Type: ACL; Schema: admin; Owner: postgres
--

GRANT ALL ON FUNCTION admin.sync_admin_metadata() TO authenticated;


--
-- Name: FUNCTION extract_mentions_from_message(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.extract_mentions_from_message() TO anon;
GRANT ALL ON FUNCTION public.extract_mentions_from_message() TO authenticated;
GRANT ALL ON FUNCTION public.extract_mentions_from_message() TO service_role;


--
-- Name: FUNCTION get_current_admins(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_current_admins() TO anon;
GRANT ALL ON FUNCTION public.get_current_admins() TO authenticated;
GRANT ALL ON FUNCTION public.get_current_admins() TO service_role;


--
-- Name: FUNCTION get_project_id_from_task(task_uuid uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_project_id_from_task(task_uuid uuid) TO anon;
GRANT ALL ON FUNCTION public.get_project_id_from_task(task_uuid uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_project_id_from_task(task_uuid uuid) TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION handle_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_updated_at() TO anon;
GRANT ALL ON FUNCTION public.handle_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.handle_updated_at() TO service_role;


--
-- Name: FUNCTION has_project_role(project_uuid uuid, required_roles text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.has_project_role(project_uuid uuid, required_roles text[]) TO anon;
GRANT ALL ON FUNCTION public.has_project_role(project_uuid uuid, required_roles text[]) TO authenticated;
GRANT ALL ON FUNCTION public.has_project_role(project_uuid uuid, required_roles text[]) TO service_role;


--
-- Name: FUNCTION is_org_member(org_uuid uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_org_member(org_uuid uuid) TO anon;
GRANT ALL ON FUNCTION public.is_org_member(org_uuid uuid) TO authenticated;
GRANT ALL ON FUNCTION public.is_org_member(org_uuid uuid) TO service_role;


--
-- Name: FUNCTION is_project_member(project_uuid uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_project_member(project_uuid uuid) TO anon;
GRANT ALL ON FUNCTION public.is_project_member(project_uuid uuid) TO authenticated;
GRANT ALL ON FUNCTION public.is_project_member(project_uuid uuid) TO service_role;


--
-- Name: FUNCTION is_user_admin(check_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_user_admin(check_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.is_user_admin(check_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.is_user_admin(check_user_id uuid) TO service_role;


--
-- Name: FUNCTION log_priority_change(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.log_priority_change() TO anon;
GRANT ALL ON FUNCTION public.log_priority_change() TO authenticated;
GRANT ALL ON FUNCTION public.log_priority_change() TO service_role;


--
-- Name: FUNCTION notify_comment_created(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.notify_comment_created() TO anon;
GRANT ALL ON FUNCTION public.notify_comment_created() TO authenticated;
GRANT ALL ON FUNCTION public.notify_comment_created() TO service_role;


--
-- Name: FUNCTION notify_task_update(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.notify_task_update() TO anon;
GRANT ALL ON FUNCTION public.notify_task_update() TO authenticated;
GRANT ALL ON FUNCTION public.notify_task_update() TO service_role;


--
-- Name: FUNCTION set_updated_columns(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_updated_columns() TO anon;
GRANT ALL ON FUNCTION public.set_updated_columns() TO authenticated;
GRANT ALL ON FUNCTION public.set_updated_columns() TO service_role;


--
-- Name: FUNCTION update_files_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_files_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_files_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_files_updated_at() TO service_role;


--
-- Name: FUNCTION update_priority_options_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_priority_options_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_priority_options_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_priority_options_updated_at() TO service_role;


--
-- Name: FUNCTION update_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at() TO service_role;


--
-- Name: TABLE admins; Type: ACL; Schema: admin; Owner: postgres
--

GRANT SELECT ON TABLE admin.admins TO authenticated;


--
-- Name: TABLE chat_messages; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.chat_messages TO anon;
GRANT ALL ON TABLE public.chat_messages TO authenticated;
GRANT ALL ON TABLE public.chat_messages TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE chat_messages_with_profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.chat_messages_with_profiles TO anon;
GRANT ALL ON TABLE public.chat_messages_with_profiles TO authenticated;
GRANT ALL ON TABLE public.chat_messages_with_profiles TO service_role;


--
-- Name: TABLE comments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.comments TO anon;
GRANT ALL ON TABLE public.comments TO authenticated;
GRANT ALL ON TABLE public.comments TO service_role;


--
-- Name: TABLE custom_statuses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.custom_statuses TO anon;
GRANT ALL ON TABLE public.custom_statuses TO authenticated;
GRANT ALL ON TABLE public.custom_statuses TO service_role;


--
-- Name: TABLE file_versions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.file_versions TO anon;
GRANT ALL ON TABLE public.file_versions TO authenticated;
GRANT ALL ON TABLE public.file_versions TO service_role;


--
-- Name: TABLE files; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.files TO anon;
GRANT ALL ON TABLE public.files TO authenticated;
GRANT ALL ON TABLE public.files TO service_role;


--
-- Name: TABLE mentions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.mentions TO anon;
GRANT ALL ON TABLE public.mentions TO authenticated;
GRANT ALL ON TABLE public.mentions TO service_role;


--
-- Name: TABLE notifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.notifications TO anon;
GRANT ALL ON TABLE public.notifications TO authenticated;
GRANT ALL ON TABLE public.notifications TO service_role;


--
-- Name: TABLE organization_memberships; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.organization_memberships TO anon;
GRANT ALL ON TABLE public.organization_memberships TO authenticated;
GRANT ALL ON TABLE public.organization_memberships TO service_role;


--
-- Name: TABLE organizations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.organizations TO anon;
GRANT ALL ON TABLE public.organizations TO authenticated;
GRANT ALL ON TABLE public.organizations TO service_role;


--
-- Name: TABLE priority_change_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.priority_change_history TO anon;
GRANT ALL ON TABLE public.priority_change_history TO authenticated;
GRANT ALL ON TABLE public.priority_change_history TO service_role;


--
-- Name: TABLE priority_options; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.priority_options TO anon;
GRANT ALL ON TABLE public.priority_options TO authenticated;
GRANT ALL ON TABLE public.priority_options TO service_role;


--
-- Name: TABLE project_memberships; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.project_memberships TO anon;
GRANT ALL ON TABLE public.project_memberships TO authenticated;
GRANT ALL ON TABLE public.project_memberships TO service_role;


--
-- Name: TABLE projects; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.projects TO anon;
GRANT ALL ON TABLE public.projects TO authenticated;
GRANT ALL ON TABLE public.projects TO service_role;


--
-- Name: TABLE task_assignees; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.task_assignees TO anon;
GRANT ALL ON TABLE public.task_assignees TO authenticated;
GRANT ALL ON TABLE public.task_assignees TO service_role;


--
-- Name: TABLE task_links; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.task_links TO anon;
GRANT ALL ON TABLE public.task_links TO authenticated;
GRANT ALL ON TABLE public.task_links TO service_role;


--
-- Name: TABLE task_watchers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.task_watchers TO anon;
GRANT ALL ON TABLE public.task_watchers TO authenticated;
GRANT ALL ON TABLE public.task_watchers TO service_role;


--
-- Name: TABLE tasks; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tasks TO anon;
GRANT ALL ON TABLE public.tasks TO authenticated;
GRANT ALL ON TABLE public.tasks TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

