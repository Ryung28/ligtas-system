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

  -- FK-safe clear must be done in one TRUNCATE statement.
  truncate table
    public.chat_messages,
    public.chat_rooms,
    public.borrow_logs,
    public.notification_reads,
    public.notification_deliveries,
    public.notification_events,
    public.system_notifications,
    public.activity_log,
    public.cctv_logs,
    public.logistics_actions,
    public.auth_debug_logs
  restart identity;

  -- Normalize operational availability after clearing borrow logs.
  -- This keeps equipment master records but removes residual "borrowed/dispensed"
  -- state that is encoded via stock_available deltas.
  update public.inventory i
  set stock_available = greatest(
    0,
    coalesce(i.stock_total, 0)
      - coalesce(i.qty_damaged, 0)
      - coalesce(i.qty_maintenance, 0)
      - coalesce(i.qty_lost, 0)
  ),
      updated_at = now()
  where coalesce(i.stock_available, 0) <> greatest(
    0,
    coalesce(i.stock_total, 0)
      - coalesce(i.qty_damaged, 0)
      - coalesce(i.qty_maintenance, 0)
      - coalesce(i.qty_lost, 0)
  );

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

  -- Restore should replay snapshot rows only. Disable user triggers that enqueue side effects.
  alter table public.borrow_logs disable trigger user;
  alter table public.chat_messages disable trigger user;

  -- Clear current logbook rows first in one FK-safe TRUNCATE statement.
  truncate table
    public.chat_messages,
    public.chat_rooms,
    public.borrow_logs,
    public.notification_reads,
    public.notification_deliveries,
    public.notification_events,
    public.system_notifications,
    public.activity_log,
    public.cctv_logs,
    public.logistics_actions,
    public.auth_debug_logs
  restart identity;

  -- Restore parent-first to satisfy FK constraints
  insert into public.borrow_logs
  select (jsonb_populate_record(null::public.borrow_logs, dedup.row_data)).*
  from (
    select row_data
    from (
      select
        sr.row_data,
        row_number() over (
          partition by coalesce(sr.row_data->>'id', md5(sr.row_data::text))
          order by
            nullif(sr.row_data->>'updated_at', '')::timestamptz desc nulls last,
            nullif(sr.row_data->>'created_at', '')::timestamptz desc nulls last
        ) as rn
      from archive.logbook_snapshot_rows sr
      where sr.snapshot_id = p_snapshot_id
        and sr.table_name = 'public.borrow_logs'
    ) ranked
    where rn = 1
  ) dedup
  on conflict do nothing;

  -- Keep all room IDs for chat_messages FK, but normalize duplicate borrow_request_id.
  -- Winner row keeps borrow_request_id; other duplicates are forced to NULL.
  insert into public.chat_rooms
  select
    (
      jsonb_populate_record(
        null::public.chat_rooms,
        case
          when dedup_borrow.rn_borrow = 1 then dedup_borrow.row_data
          else jsonb_set(dedup_borrow.row_data, '{borrow_request_id}', 'null'::jsonb, true)
        end
      )
    ).*
  from (
    with dedup_id as (
      select row_data
      from (
        select
          sr.row_data,
          row_number() over (
            partition by coalesce(sr.row_data->>'id', md5(sr.row_data::text))
            order by
              nullif(sr.row_data->>'updated_at', '')::timestamptz desc nulls last,
              nullif(sr.row_data->>'created_at', '')::timestamptz desc nulls last
          ) as rn_id
        from archive.logbook_snapshot_rows sr
        where sr.snapshot_id = p_snapshot_id
          and sr.table_name = 'public.chat_rooms'
      ) ranked_id
      where rn_id = 1
    )
    select
      d.row_data,
      row_number() over (
        partition by
          coalesce(
            case
              when nullif(trim(coalesce(d.row_data->>'borrow_request_id', '')), '') is null then null
              else (nullif(trim(d.row_data->>'borrow_request_id'), ''))::bigint::text
            end,
            '__NULL__:' || coalesce(d.row_data->>'id', md5(d.row_data::text))
          )
        order by
          nullif(d.row_data->>'updated_at', '')::timestamptz desc nulls last,
          nullif(d.row_data->>'created_at', '')::timestamptz desc nulls last,
          nullif(d.row_data->>'id', '') desc nulls last
      ) as rn_borrow
    from dedup_id d
  ) dedup_borrow
  on conflict (id) do update
  set
    borrow_request_id = excluded.borrow_request_id,
    borrower_user_id = excluded.borrower_user_id,
    created_at = excluded.created_at;

  insert into public.chat_messages
  select (jsonb_populate_record(null::public.chat_messages, dedup.row_data)).*
  from (
    select row_data
    from (
      select
        sr.row_data,
        row_number() over (
          partition by coalesce(sr.row_data->>'id', md5(sr.row_data::text))
          order by
            nullif(sr.row_data->>'created_at', '')::timestamptz desc nulls last
        ) as rn
      from archive.logbook_snapshot_rows sr
      where sr.snapshot_id = p_snapshot_id
        and sr.table_name = 'public.chat_messages'
    ) ranked
    where rn = 1
  ) dedup
  on conflict do nothing;

  insert into public.system_notifications
  select
    (jsonb_populate_record(null::public.system_notifications, dedup.row_data)).*
  from (
    select row_data
    from (
      select
        sr.row_data,
        row_number() over (
          partition by coalesce(sr.row_data->>'id', md5(sr.row_data::text))
          order by
            nullif(sr.row_data->>'created_at', '')::timestamptz desc nulls last,
            nullif(sr.row_data->>'id', '') desc nulls last
        ) as rn
      from archive.logbook_snapshot_rows sr
      where sr.snapshot_id = p_snapshot_id
        and sr.table_name = 'public.system_notifications'
    ) ranked
    where rn = 1
  ) dedup
  on conflict do nothing;

  insert into public.notification_events
  select
    (jsonb_populate_record(null::public.notification_events, dedup.row_data)).*
  from (
    select row_data
    from (
      select
        sr.row_data,
        row_number() over (
          partition by coalesce(sr.row_data->>'id', md5(sr.row_data::text))
          order by
            nullif(sr.row_data->>'created_at', '')::timestamptz desc nulls last,
            nullif(sr.row_data->>'id', '') desc nulls last
        ) as rn
      from archive.logbook_snapshot_rows sr
      where sr.snapshot_id = p_snapshot_id
        and sr.table_name = 'public.notification_events'
    ) ranked
    where rn = 1
  ) dedup
  on conflict do nothing;

  insert into public.notification_deliveries
  select nd.*
  from (
    select (jsonb_populate_record(null::public.notification_deliveries, sr.row_data)).*
    from archive.logbook_snapshot_rows sr
    where sr.snapshot_id = p_snapshot_id
      and sr.table_name = 'public.notification_deliveries'
  ) nd
  join public.notification_events ne on ne.id = nd.event_id
  on conflict do nothing;

  insert into public.notification_reads
  select nr.*
  from (
    select (jsonb_populate_record(null::public.notification_reads, ranked.row_data)).*
    from (
      select sr.row_data,
        row_number() over (
          partition by
            coalesce(sr.row_data->>'notification_id', '__NULL_NOTIFICATION__'),
            coalesce(sr.row_data->>'user_id', '__NULL_USER__')
          order by
            nullif(sr.row_data->>'read_at', '')::timestamptz desc nulls last
        ) as rn
      from archive.logbook_snapshot_rows sr
      where sr.snapshot_id = p_snapshot_id
        and sr.table_name = 'public.notification_reads'
    ) ranked
    where rn = 1
  ) nr
  join public.system_notifications sn on sn.id = nr.notification_id
  join auth.users au on au.id = nr.user_id
  on conflict do nothing;

  insert into public.activity_log
  select (jsonb_populate_record(null::public.activity_log, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.activity_log'
  on conflict do nothing;

  insert into public.cctv_logs
  select (jsonb_populate_record(null::public.cctv_logs, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.cctv_logs'
  on conflict do nothing;

  insert into public.logistics_actions
  select (jsonb_populate_record(null::public.logistics_actions, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.logistics_actions'
  on conflict do nothing;

  insert into public.auth_debug_logs
  select (jsonb_populate_record(null::public.auth_debug_logs, sr.row_data)).*
  from archive.logbook_snapshot_rows sr
  where sr.snapshot_id = p_snapshot_id
    and sr.table_name = 'public.auth_debug_logs'
  on conflict do nothing;

  alter table public.chat_messages enable trigger user;
  alter table public.borrow_logs enable trigger user;

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
    begin
      alter table public.chat_messages enable trigger user;
    exception
      when others then
        null;
    end;
    begin
      alter table public.borrow_logs enable trigger user;
    exception
      when others then
        null;
    end;
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

create or replace function public.admin_logbook_import_snapshot_v1(
  p_requested_by uuid,
  p_payload jsonb,
  p_scope_version text,
  p_reason text
)
returns uuid
language plpgsql
security definer
set search_path = public, archive
as $$
declare
  v_schema_version text;
  v_source_snapshot jsonb;
  v_scope_version text;
  v_rows jsonb;
  v_import_reason text;
  v_new_snapshot_id uuid;
  v_row jsonb;
  v_table_name text;
  v_row_data jsonb;
  v_max_rows integer := 250000;
begin
  if not pg_try_advisory_xact_lock(987654321, 1002) then
    raise exception 'Another logbook import is already running';
  end if;

  perform public.assert_admin_reset_actor(p_requested_by);

  if jsonb_typeof(p_payload) is distinct from 'object' then
    raise exception 'Import blocked: payload must be a JSON object';
  end if;

  v_schema_version := coalesce(p_payload->>'schema_version', '');
  if v_schema_version <> 'logbook-export-v1' then
    raise exception 'Unsupported export schema version';
  end if;

  v_source_snapshot := p_payload->'snapshot';
  if jsonb_typeof(v_source_snapshot) is distinct from 'object' then
    raise exception 'Import blocked: snapshot metadata missing';
  end if;

  v_scope_version := coalesce(v_source_snapshot->>'scope_version', '');
  if v_scope_version = '' then
    raise exception 'Import blocked: snapshot scope version missing';
  end if;

  if v_scope_version <> p_scope_version then
    raise exception 'Scope version mismatch';
  end if;

  v_rows := p_payload->'rows';
  if jsonb_typeof(v_rows) is distinct from 'array' then
    raise exception 'Import blocked: rows must be a JSON array';
  end if;

  if jsonb_array_length(v_rows) > v_max_rows then
    raise exception 'Import blocked: row count exceeds limit (%)', v_max_rows;
  end if;

  v_import_reason := trim(coalesce(p_reason, ''));
  if length(v_import_reason) < 10 then
    raise exception 'Import blocked: reason must be at least 10 characters';
  end if;

  insert into archive.logbook_snapshots (requested_by, reason, scope_version)
  values (
    p_requested_by,
    format(
      'Imported backup (%s): %s',
      coalesce(v_source_snapshot->>'id', 'external'),
      v_import_reason
    ),
    v_scope_version
  )
  returning id into v_new_snapshot_id;

  for v_row in
    select value
    from jsonb_array_elements(v_rows)
  loop
    v_table_name := coalesce(v_row->>'table_name', '');
    v_row_data := v_row->'row_data';

    if v_table_name not in (
      'public.chat_messages',
      'public.chat_rooms',
      'public.borrow_logs',
      'public.notification_reads',
      'public.notification_deliveries',
      'public.notification_events',
      'public.system_notifications',
      'public.activity_log',
      'public.cctv_logs',
      'public.logistics_actions',
      'public.auth_debug_logs'
    ) then
      raise exception 'Import blocked: unsupported table %', v_table_name;
    end if;

    if jsonb_typeof(v_row_data) is distinct from 'object' then
      raise exception 'Import blocked: invalid row payload for table %', v_table_name;
    end if;

    insert into archive.logbook_snapshot_rows (snapshot_id, table_name, row_data)
    values (v_new_snapshot_id, v_table_name, v_row_data);
  end loop;

  return v_new_snapshot_id;
end;
$$;

create or replace function public.admin_logbook_prune_snapshots_v1(
  p_requested_by uuid,
  p_keep_latest integer default 100,
  p_keep_days integer default 180
)
returns table(deleted_snapshots integer, deleted_rows bigint)
language plpgsql
security definer
set search_path = public, archive
as $$
declare
  v_deleted_snapshots integer := 0;
  v_deleted_rows bigint := 0;
begin
  perform public.assert_admin_reset_actor(p_requested_by);

  if p_keep_latest < 1 then
    raise exception 'Prune blocked: p_keep_latest must be >= 1';
  end if;

  if p_keep_days < 1 then
    raise exception 'Prune blocked: p_keep_days must be >= 1';
  end if;

  with referenced as (
    select snapshot_id from public.backup_jobs where snapshot_id is not null
    union
    select snapshot_id from public.reset_jobs where snapshot_id is not null
    union
    select snapshot_id from public.restore_jobs where snapshot_id is not null
  ),
  ranked as (
    select
      s.id,
      s.created_at,
      row_number() over (order by s.created_at desc, s.id desc) as rn
    from archive.logbook_snapshots s
    left join referenced r on r.snapshot_id = s.id
    where r.snapshot_id is null
  ),
  candidates as (
    select id
    from ranked
    where rn > p_keep_latest
      and created_at < now() - make_interval(days => p_keep_days)
  ),
  row_counts as (
    select count(*)::bigint as row_count
    from archive.logbook_snapshot_rows
    where snapshot_id in (select id from candidates)
  ),
  deleted as (
    delete from archive.logbook_snapshots s
    where s.id in (select id from candidates)
    returning s.id
  )
  select
    coalesce((select count(*) from deleted), 0),
    coalesce((select row_count from row_counts), 0)
  into v_deleted_snapshots, v_deleted_rows;

  return query select v_deleted_snapshots, v_deleted_rows;
end;
$$;

revoke all on function public.admin_logbook_reset_v1(uuid, text, text) from public;
revoke all on function public.admin_logbook_backup_v1(uuid, text, text) from public;
revoke all on function public.admin_logbook_restore_v1(uuid, uuid, text, text) from public;
revoke all on function public.admin_logbook_snapshot_preview_v1(uuid, uuid) from public;
revoke all on function public.admin_logbook_export_snapshot_v1(uuid, uuid) from public;
revoke all on function public.admin_logbook_import_snapshot_v1(uuid, jsonb, text, text) from public;
revoke all on function public.admin_logbook_prune_snapshots_v1(uuid, integer, integer) from public;
revoke all on function public.create_logbook_snapshot_v1(uuid, text, text) from public;
revoke all on function public.assert_admin_reset_actor(uuid) from public;
revoke all on function public.assert_no_active_logbook_job() from public;
grant execute on function public.admin_logbook_reset_v1(uuid, text, text) to authenticated;
grant execute on function public.admin_logbook_backup_v1(uuid, text, text) to authenticated;
grant execute on function public.admin_logbook_restore_v1(uuid, uuid, text, text) to authenticated;
grant execute on function public.admin_logbook_snapshot_preview_v1(uuid, uuid) to authenticated;
grant execute on function public.admin_logbook_export_snapshot_v1(uuid, uuid) to authenticated;
grant execute on function public.admin_logbook_import_snapshot_v1(uuid, jsonb, text, text) to authenticated;
grant execute on function public.admin_logbook_prune_snapshots_v1(uuid, integer, integer) to authenticated;
