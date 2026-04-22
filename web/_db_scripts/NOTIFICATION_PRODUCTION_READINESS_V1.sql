-- ============================================================================
-- LIGTAS CDRRMO - NOTIFICATION PRODUCTION READINESS (V1)
-- ============================================================================
-- Purpose:
-- 1) Run notification dispatcher every minute via pg_cron.
-- 2) Add operational SQL views for dead-letter and queue monitoring.
-- 3) Add stale-token invalidation + old-delivery cleanup routines.
-- 4) Add weekly health reporting view for reliability tracking.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS ops;

-- --------------------------------------------------------------------------
-- 1) Dispatcher invoker + cron cadence
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.invoke_notification_dispatcher()
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_request_id bigint;
BEGIN
  SELECT net.http_post(
    url := 'https://knarlvwnuvedyfvvaota.supabase.co/functions/v1/notification-dispatcher',
    body := '{}'::jsonb,
    params := '{}'::jsonb,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuYXJsdndudXZlZHlmdnZhb3RhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MjQxMzQsImV4cCI6MjA4NTMwMDEzNH0.ychlatdBNWPWvwoeT4NzKHS5HNv1ZytKQ31E1RvXvrA',
      'apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtuYXJsdndudXZlZHlmdnZhb3RhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MjQxMzQsImV4cCI6MjA4NTMwMDEzNH0.ychlatdBNWPWvwoeT4NzKHS5HNv1ZytKQ31E1RvXvrA'
    ),
    timeout_milliseconds := 15000
  ) INTO v_request_id;

  RETURN v_request_id;
END;
$$;

REVOKE ALL ON FUNCTION public.invoke_notification_dispatcher() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.invoke_notification_dispatcher() TO service_role;

-- Ensure a single active scheduler job for the dispatcher.
DO $do$
DECLARE
  v_job record;
BEGIN
  FOR v_job IN
    SELECT jobid
    FROM cron.job
    WHERE jobname = 'notification-dispatcher-every-minute'
  LOOP
    PERFORM cron.unschedule(v_job.jobid);
  END LOOP;

  PERFORM cron.schedule(
    'notification-dispatcher-every-minute',
    '* * * * *',
    $cron$SELECT public.invoke_notification_dispatcher();$cron$
  );
END
$do$;

-- --------------------------------------------------------------------------
-- 2) Dead-letter + queue monitoring views
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW ops.notification_dead_letters AS
SELECT
  e.id,
  e.event_type,
  e.status,
  e.attempt_count,
  e.idempotency_key,
  e.audience,
  e.payload,
  e.created_at,
  e.updated_at
FROM public.notification_events e
WHERE e.status IN ('failed', 'dead')
ORDER BY e.updated_at DESC;

CREATE OR REPLACE VIEW ops.notification_dispatch_backlog AS
SELECT
  e.id,
  e.event_type,
  e.status,
  e.attempt_count,
  e.next_attempt_at,
  e.created_at,
  e.updated_at
FROM public.notification_events e
WHERE e.status = 'pending'
  AND e.next_attempt_at <= NOW()
ORDER BY e.next_attempt_at ASC, e.created_at ASC;

-- --------------------------------------------------------------------------
-- 3) Stale-token invalidation + delivery retention cleanup
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ops.invalidate_stale_tokens(
  p_min_permanent_failures int DEFAULT 2,
  p_lookback interval DEFAULT interval '14 days',
  p_recent_success_grace interval DEFAULT interval '3 days'
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_count integer;
BEGIN
  WITH candidate_tokens AS (
    SELECT
      d.token_id
    FROM public.notification_deliveries d
    WHERE d.token_id IS NOT NULL
      AND d.result = 'permanent_failure'
      AND d.created_at >= NOW() - p_lookback
    GROUP BY d.token_id
    HAVING COUNT(*) >= p_min_permanent_failures
  ),
  updated AS (
    UPDATE public.user_fcm_tokens t
    SET
      invalidated_at = NOW(),
      invalid_reason = COALESCE(t.invalid_reason, 'repeated_permanent_failure')
    WHERE t.id IN (SELECT token_id FROM candidate_tokens)
      AND t.invalidated_at IS NULL
      AND (t.last_success_at IS NULL OR t.last_success_at < NOW() - p_recent_success_grace)
    RETURNING 1
  )
  SELECT COUNT(*) INTO v_count FROM updated;

  RETURN COALESCE(v_count, 0);
END;
$$;

REVOKE ALL ON FUNCTION ops.invalidate_stale_tokens(int, interval, interval) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION ops.invalidate_stale_tokens(int, interval, interval) TO service_role;

CREATE OR REPLACE FUNCTION ops.cleanup_old_notification_deliveries(
  p_retention_days int DEFAULT 90
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_count integer;
BEGIN
  DELETE FROM public.notification_deliveries
  WHERE created_at < NOW() - make_interval(days => p_retention_days);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN COALESCE(v_count, 0);
END;
$$;

REVOKE ALL ON FUNCTION ops.cleanup_old_notification_deliveries(int) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION ops.cleanup_old_notification_deliveries(int) TO service_role;

-- Daily maintenance at 03:20 UTC.
DO $do$
DECLARE
  v_job record;
BEGIN
  FOR v_job IN
    SELECT jobid
    FROM cron.job
    WHERE jobname = 'notification-maintenance-daily'
  LOOP
    PERFORM cron.unschedule(v_job.jobid);
  END LOOP;

  PERFORM cron.schedule(
    'notification-maintenance-daily',
    '20 3 * * *',
    $cron$SELECT ops.invalidate_stale_tokens(); SELECT ops.cleanup_old_notification_deliveries(90);$cron$
  );
END
$do$;

-- --------------------------------------------------------------------------
-- 4) Weekly health view
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW ops.notification_weekly_health AS
WITH weekly AS (
  SELECT
    e.event_type,
    COUNT(*) AS events_total,
    COUNT(*) FILTER (WHERE e.status = 'sent') AS events_sent,
    COUNT(*) FILTER (WHERE e.status = 'partial') AS events_partial,
    COUNT(*) FILTER (WHERE e.status = 'failed') AS events_failed,
    COUNT(*) FILTER (WHERE e.status = 'dead') AS events_dead
  FROM public.notification_events e
  WHERE e.created_at >= NOW() - interval '7 days'
  GROUP BY e.event_type
),
delivery AS (
  SELECT
    e.event_type,
    COUNT(*) AS delivery_total,
    COUNT(*) FILTER (WHERE d.result = 'success') AS delivery_success,
    COUNT(*) FILTER (WHERE d.result = 'retryable_failure') AS delivery_retryable_failure,
    COUNT(*) FILTER (WHERE d.result = 'permanent_failure') AS delivery_permanent_failure
  FROM public.notification_deliveries d
  JOIN public.notification_events e ON e.id = d.event_id
  WHERE d.created_at >= NOW() - interval '7 days'
  GROUP BY e.event_type
)
SELECT
  COALESCE(w.event_type, d.event_type) AS event_type,
  COALESCE(w.events_total, 0) AS events_total,
  COALESCE(w.events_sent, 0) AS events_sent,
  COALESCE(w.events_partial, 0) AS events_partial,
  COALESCE(w.events_failed, 0) AS events_failed,
  COALESCE(w.events_dead, 0) AS events_dead,
  COALESCE(d.delivery_total, 0) AS delivery_total,
  COALESCE(d.delivery_success, 0) AS delivery_success,
  COALESCE(d.delivery_retryable_failure, 0) AS delivery_retryable_failure,
  COALESCE(d.delivery_permanent_failure, 0) AS delivery_permanent_failure,
  CASE
    WHEN COALESCE(d.delivery_total, 0) = 0 THEN 0
    ELSE ROUND((COALESCE(d.delivery_success, 0)::numeric / d.delivery_total::numeric) * 100, 2)
  END AS delivery_success_pct
FROM weekly w
FULL OUTER JOIN delivery d
  ON d.event_type = w.event_type
ORDER BY delivery_success_pct ASC, events_total DESC;

SELECT 'Notification production readiness V1 applied' AS status;
