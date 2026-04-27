-- Logbook Reset v1 foundation (apply manually in Supabase SQL editor or migration tool)
-- Scope: reset logbook data only while preserving equipment and storage objects.

create schema if not exists archive;

create table if not exists archive.logbook_snapshots (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  requested_by uuid not null,
  reason text not null,
  scope_version text not null
);

create table if not exists archive.logbook_snapshot_rows (
  snapshot_id uuid not null references archive.logbook_snapshots(id) on delete cascade,
  table_name text not null,
  row_data jsonb not null
);

create table if not exists public.reset_jobs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  status text not null check (status in ('started', 'completed', 'failed')),
  requested_by uuid not null references auth.users(id),
  reason text not null,
  scope_version text not null,
  snapshot_id uuid references archive.logbook_snapshots(id),
  error_message text
);

create table if not exists public.backup_jobs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  status text not null check (status in ('started', 'completed', 'failed')),
  requested_by uuid not null references auth.users(id),
  reason text not null,
  scope_version text not null,
  snapshot_id uuid references archive.logbook_snapshots(id),
  error_message text
);

create table if not exists public.restore_jobs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  status text not null check (status in ('started', 'completed', 'failed')),
  requested_by uuid not null references auth.users(id),
  reason text not null,
  scope_version text not null,
  snapshot_id uuid not null references archive.logbook_snapshots(id),
  error_message text
);

create or replace function public.assert_no_active_logbook_job()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_has_active boolean;
begin
  select exists (
    select 1
    from public.reset_jobs
    where status = 'started'
      and created_at > now() - interval '30 minutes'
  ) or exists (
    select 1
    from public.backup_jobs
    where status = 'started'
      and created_at > now() - interval '30 minutes'
  ) or exists (
    select 1
    from public.restore_jobs
    where status = 'started'
      and created_at > now() - interval '30 minutes'
  )
  into v_has_active;

  if v_has_active then
    raise exception 'Another logbook backup/reset job is already running';
  end if;
end;
$$;

create or replace function public.assert_admin_reset_actor(p_requested_by uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role text;
  v_status text;
begin
  if auth.uid() is null then
    raise exception 'Unauthorized: no active session';
  end if;

  if auth.uid() <> p_requested_by then
    raise exception 'Unauthorized: actor mismatch';
  end if;

  select role, status
  into v_role, v_status
  from public.user_profiles
  where id = p_requested_by;

  if v_role is distinct from 'admin' or v_status is distinct from 'active' then
    raise exception 'Forbidden: admin role required';
  end if;
end;
$$;

create or replace function public.create_logbook_snapshot_v1(
  p_requested_by uuid,
  p_reason text,
  p_scope_version text
)
returns uuid
language plpgsql
security definer
set search_path = public, archive
as $$
declare
  v_snapshot_id uuid;
begin
  perform public.assert_admin_reset_actor(p_requested_by);

  insert into archive.logbook_snapshots (requested_by, reason, scope_version)
  values (p_requested_by, p_reason, p_scope_version)
  returning id into v_snapshot_id;

  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.chat_messages', to_jsonb(t) from public.chat_messages t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.chat_rooms', to_jsonb(t) from public.chat_rooms t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.borrow_logs', to_jsonb(t) from public.borrow_logs t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.notification_reads', to_jsonb(t) from public.notification_reads t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.notification_deliveries', to_jsonb(t) from public.notification_deliveries t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.notification_events', to_jsonb(t) from public.notification_events t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.system_notifications', to_jsonb(t) from public.system_notifications t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.activity_log', to_jsonb(t) from public.activity_log t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.cctv_logs', to_jsonb(t) from public.cctv_logs t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.logistics_actions', to_jsonb(t) from public.logistics_actions t;
  insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
  select v_snapshot_id, 'public.auth_debug_logs', to_jsonb(t) from public.auth_debug_logs t;

  return v_snapshot_id;
end;
$$;

create or replace function public.admin_logbook_backup_v1(
  p_requested_by uuid,
  p_reason text,
  p_scope_version text
)
returns table(job_id uuid, snapshot_id uuid)
language plpgsql
security definer
set search_path = public, archive
as $$
declare
  v_job_id uuid;
  v_snapshot_id uuid;
begin
  if not pg_try_advisory_xact_lock(987654321, 1001) then
    raise exception 'Another logbook backup/reset job is already running';
  end if;

  perform public.assert_admin_reset_actor(p_requested_by);
  perform public.assert_no_active_logbook_job();

  insert into public.backup_jobs (status, requested_by, reason, scope_version)
  values ('started', p_requested_by, p_reason, p_scope_version)
  returning id into v_job_id;

  v_snapshot_id := public.create_logbook_snapshot_v1(
    p_requested_by,
    p_reason,
    p_scope_version
  );

  update public.backup_jobs
  set status = 'completed',
      completed_at = now(),
      snapshot_id = v_snapshot_id
  where id = v_job_id;

  return query select v_job_id, v_snapshot_id;
exception
  when others then
    update public.backup_jobs
    set status = 'failed',
        completed_at = now(),
        error_message = sqlerrm
    where id = v_job_id;
    raise;
end;
$$;

create or replace function public.admin_logbook_reset_v1(
  p_requested_by uuid,
  p_reason text,
  p_scope_version text
)
returns table(job_id uuid, snapshot_id uuid)
language plpgsql
security definer
set search_path = public, archive
as $$
declare
  v_job_id uuid;
  v_snapshot_id uuid;
  v_latest_backup_at timestamptz;
begin
  if not pg_try_advisory_xact_lock(987654321, 1001) then
    raise exception 'Another logbook backup/reset job is already running';
  end if;

  perform public.assert_admin_reset_actor(p_requested_by);
  perform public.assert_no_active_logbook_job();

  select created_at
  into v_latest_backup_at
  from public.backup_jobs
  where status = 'completed'
  order by created_at desc
  limit 1;

  if v_latest_backup_at is null then
    raise exception 'Reset blocked: no completed backup found';
  end if;

  if v_latest_backup_at < now() - interval '24 hours' then
    raise exception 'Reset blocked: latest completed backup is older than 24 hours';
  end if;

  insert into public.reset_jobs (status, requested_by, reason, scope_version)
  values ('started', p_requested_by, p_reason, p_scope_version)
  returning id into v_job_id;

  v_snapshot_id := public.create_logbook_snapshot_v1(
    p_requested_by,
    p_reason,
    p_scope_version
  );

  -- FK-safe reset order (child tables first)
  truncate table public.chat_messages restart identity;
  truncate table public.chat_rooms restart identity;
  truncate table public.borrow_logs restart identity;
  truncate table public.notification_reads restart identity;
  truncate table public.notification_deliveries restart identity;
  truncate table public.notification_events restart identity;
  truncate table public.system_notifications restart identity;
  truncate table public.activity_log restart identity;
  truncate table public.cctv_logs restart identity;
  truncate table public.logistics_actions restart identity;
  truncate table public.auth_debug_logs restart identity;

  update public.reset_jobs
  set status = 'completed',
      completed_at = now(),
      snapshot_id = v_snapshot_id
  where id = v_job_id;

  return query select v_job_id, v_snapshot_id;
exception
  when others then
    update public.reset_jobs
    set status = 'failed',
        completed_at = now(),
        error_message = sqlerrm
    where id = v_job_id;
    raise;
end;
$$;

create or replace function public.admin_logbook_restore_v1(
  p_requested_by uuid,
  p_snapshot_id uuid,
  p_reason text,
  p_scope_version text
)
returns table(job_id uuid, snapshot_id uuid)
language plpgsql
security definer
set search_path = public, archive
as $$
declare
  v_job_id uuid;
  v_snapshot_exists boolean;
begin
  if not pg_try_advisory_xact_lock(987654321, 1001) then
    raise exception 'Another logbook backup/reset job is already running';
  end if;

  perform public.assert_admin_reset_actor(p_requested_by);
  perform public.assert_no_active_logbook_job();

  select exists (
    select 1
    from archive.logbook_snapshots
    where id = p_snapshot_id
  )
  into v_snapshot_exists;

  if not v_snapshot_exists then
    raise exception 'Restore blocked: snapshot not found';
  end if;

  insert into public.restore_jobs (status, requested_by, reason, scope_version, snapshot_id)
  values ('started', p_requested_by, p_reason, p_scope_version, p_snapshot_id)
  returning id into v_job_id;

  -- Clear current logbook rows first (same FK-safe clear order as reset)
  truncate table public.chat_messages restart identity;
  truncate table public.chat_rooms restart identity;
  truncate table public.borrow_logs restart identity;
  truncate table public.notification_reads restart identity;
  truncate table public.notification_deliveries restart identity;
  truncate table public.notification_events restart identity;
  truncate table public.system_notifications restart identity;
  truncate table public.activity_log restart identity;
  truncate table public.cctv_logs restart identity;
  truncate table public.logistics_actions restart identity;
  truncate table public.auth_debug_logs restart identity;

  -- Restore parent-first to satisfy FK constraints
  insert into public.borrow_logs
  select (jsonb_populate_record(null::public.borrow_logs, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.borrow_logs';

  insert into public.chat_rooms
  select (jsonb_populate_record(null::public.chat_rooms, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.chat_rooms';

  insert into public.chat_messages
  select (jsonb_populate_record(null::public.chat_messages, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.chat_messages';

  insert into public.system_notifications
  select (jsonb_populate_record(null::public.system_notifications, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.system_notifications';

  insert into public.notification_events
  select (jsonb_populate_record(null::public.notification_events, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.notification_events';

  insert into public.notification_deliveries
  select (jsonb_populate_record(null::public.notification_deliveries, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.notification_deliveries';

  insert into public.notification_reads
  select (jsonb_populate_record(null::public.notification_reads, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.notification_reads';

  insert into public.activity_log
  select (jsonb_populate_record(null::public.activity_log, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.activity_log';

  insert into public.cctv_logs
  select (jsonb_populate_record(null::public.cctv_logs, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.cctv_logs';

  insert into public.logistics_actions
  select (jsonb_populate_record(null::public.logistics_actions, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.logistics_actions';

  insert into public.auth_debug_logs
  select (jsonb_populate_record(null::public.auth_debug_logs, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.auth_debug_logs';

  -- Re-align sequences for bigint identity/serial tables
  perform setval('public.borrow_logs_id_seq', greatest(coalesce((select max(id) from public.borrow_logs), 0), 1), true);
  perform setval('public.activity_log_id_seq', greatest(coalesce((select max(id) from public.activity_log), 0), 1), true);

  update public.restore_jobs
  set status = 'completed',
      completed_at = now()
  where id = v_job_id;

  return query select v_job_id, p_snapshot_id;
exception
  when others then
    update public.restore_jobs
    set status = 'failed',
        completed_at = now(),
        error_message = sqlerrm
    where id = v_job_id;
    raise;
end;
$$;

create or replace function public.admin_logbook_snapshot_preview_v1(
  p_requested_by uuid,
  p_snapshot_id uuid
)
returns table(
  snapshot_id uuid,
  created_at timestamptz,
  requested_by uuid,
  reason text,
  scope_version text,
  table_name text,
  row_count bigint
)
language plpgsql
security definer
set search_path = public, archive
as $$
begin
  perform public.assert_admin_reset_actor(p_requested_by);

  return query
  select
    s.id as snapshot_id,
    s.created_at,
    s.requested_by,
    s.reason,
    s.scope_version,
    r.table_name,
    count(*)::bigint as row_count
  from archive.logbook_snapshots s
  join archive.logbook_snapshot_rows r
    on r.snapshot_id = s.id
  where s.id = p_snapshot_id
  group by s.id, s.created_at, s.requested_by, s.reason, s.scope_version, r.table_name
  order by r.table_name;
end;
$$;

create or replace function public.admin_logbook_export_snapshot_v1(
  p_requested_by uuid,
  p_snapshot_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, archive
as $$
declare
  v_snapshot archive.logbook_snapshots%rowtype;
  v_rows jsonb;
begin
  perform public.assert_admin_reset_actor(p_requested_by);

  select *
  into v_snapshot
  from archive.logbook_snapshots
  where id = p_snapshot_id;

  if not found then
    raise exception 'Export blocked: snapshot not found';
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'table_name', r.table_name,
        'row_data', r.row_data
      )
      order by r.table_name
    ),
    '[]'::jsonb
  )
  into v_rows
  from archive.logbook_snapshot_rows r
  where r.snapshot_id = p_snapshot_id;

  return jsonb_build_object(
    'schema_version', 'logbook-export-v1',
    'snapshot', jsonb_build_object(
      'id', v_snapshot.id,
      'created_at', v_snapshot.created_at,
      'requested_by', v_snapshot.requested_by,
      'reason', v_snapshot.reason,
      'scope_version', v_snapshot.scope_version
    ),
    'rows', v_rows
  );
end;
$$;

revoke all on function public.admin_logbook_reset_v1(uuid, text, text) from public;
revoke all on function public.admin_logbook_backup_v1(uuid, text, text) from public;
revoke all on function public.admin_logbook_restore_v1(uuid, uuid, text, text) from public;
revoke all on function public.admin_logbook_snapshot_preview_v1(uuid, uuid) from public;
revoke all on function public.admin_logbook_export_snapshot_v1(uuid, uuid) from public;
revoke all on function public.create_logbook_snapshot_v1(uuid, text, text) from public;
revoke all on function public.assert_admin_reset_actor(uuid) from public;
revoke all on function public.assert_no_active_logbook_job() from public;
grant execute on function public.admin_logbook_reset_v1(uuid, text, text) to authenticated;
grant execute on function public.admin_logbook_backup_v1(uuid, text, text) to authenticated;
grant execute on function public.admin_logbook_restore_v1(uuid, uuid, text, text) to authenticated;
grant execute on function public.admin_logbook_snapshot_preview_v1(uuid, uuid) to authenticated;
grant execute on function public.admin_logbook_export_snapshot_v1(uuid, uuid) to authenticated;
