-- ============================================================================
-- ENABLE EXPIRY ALERT CRON JOB
-- ============================================================================
-- This migration schedules the daily expiry alert check.
-- 
-- PREREQUISITES:
-- 1. pg_cron extension must be enabled in Supabase Dashboard
-- 2. Previous migration (20260505000000) must be applied
--
-- To enable pg_cron:
-- Supabase Dashboard > Database > Extensions > Search "pg_cron" > Enable
-- ============================================================================

-- ─── VERIFY pg_cron IS ENABLED ──────────────────────────────────────────────

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'pg_cron'
    ) THEN
        RAISE EXCEPTION 'pg_cron extension is not enabled. Please enable it in Supabase Dashboard > Database > Extensions';
    END IF;
END $$;

-- ─── UNSCHEDULE EXISTING JOB (IF ANY) ──────────────────────────────────────

SELECT cron.unschedule('daily-expiry-alert-check')
WHERE EXISTS (
    SELECT 1 FROM cron.job WHERE jobname = 'daily-expiry-alert-check'
);

-- ─── SCHEDULE THE DAILY EXPIRY CHECK ────────────────────────────────────────

SELECT cron.schedule(
    'daily-expiry-alert-check',           -- Job name
    '0 6 * * *',                          -- Every day at 6:00 AM UTC
    $$SELECT public.check_expiry_alerts();$$  -- Command to execute
);

-- ─── VERIFY JOB WAS SCHEDULED ───────────────────────────────────────────────

DO $$
DECLARE
    job_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO job_count
    FROM cron.job
    WHERE jobname = 'daily-expiry-alert-check';
    
    IF job_count = 0 THEN
        RAISE EXCEPTION 'Failed to schedule expiry alert job';
    ELSE
        RAISE NOTICE 'Successfully scheduled daily expiry alert check at 6:00 AM UTC';
    END IF;
END $$;

-- ─── INITIAL RUN (OPTIONAL) ─────────────────────────────────────────────────
-- Uncomment to run the check immediately after migration

-- SELECT public.check_expiry_alerts();
