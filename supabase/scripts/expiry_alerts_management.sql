-- ============================================================================
-- EXPIRY ALERTS MANAGEMENT SCRIPT
-- ============================================================================
-- Helpful queries for managing and testing the expiry alert system
-- ============================================================================

-- ─── 1. MANUAL TRIGGER ──────────────────────────────────────────────────────
-- Run the expiry check immediately (useful for testing)

SELECT public.check_expiry_alerts();

-- ─── 2. VIEW ALL SCHEDULED JOBS ─────────────────────────────────────────────

SELECT 
    jobid,
    jobname,
    schedule,
    command,
    active,
    database
FROM cron.job
ORDER BY jobname;

-- ─── 3. VIEW EXPIRY ALERT JOB STATUS ────────────────────────────────────────

SELECT 
    j.jobname,
    j.schedule,
    j.active,
    r.start_time,
    r.end_time,
    r.status,
    r.return_message
FROM cron.job j
LEFT JOIN cron.job_run_details r ON j.jobid = r.jobid
WHERE j.jobname = 'daily-expiry-alert-check'
ORDER BY r.start_time DESC
LIMIT 10;

-- ─── 4. VIEW ALL EXPIRY NOTIFICATIONS ───────────────────────────────────────

SELECT 
    id,
    type,
    title,
    message,
    reference_id,
    created_at,
    metadata->>'item_name' as item_name,
    metadata->>'days_remaining' as days_remaining,
    metadata->>'alert_threshold' as alert_threshold
FROM system_notifications
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
ORDER BY created_at DESC;

-- ─── 5. VIEW ITEMS THAT SHOULD TRIGGER ALERTS ──────────────────────────────

SELECT 
    id,
    item_name,
    expiry_date,
    COALESCE(expiry_alert_days, 15) as alert_threshold,
    stock_available,
    (expiry_date::date - CURRENT_DATE) as days_remaining,
    CASE 
        WHEN (expiry_date::date - CURRENT_DATE) < 0 THEN 'EXPIRED'
        WHEN (expiry_date::date - CURRENT_DATE) = 0 THEN 'EXPIRES TODAY'
        WHEN (expiry_date::date - CURRENT_DATE) <= 7 THEN 'CRITICAL'
        WHEN (expiry_date::date - CURRENT_DATE) <= COALESCE(expiry_alert_days, 15) THEN 'WARNING'
        ELSE 'OK'
    END as status
FROM inventory
WHERE expiry_date IS NOT NULL
  AND stock_available > 0
  AND deleted_at IS NULL
  AND (expiry_date::date - CURRENT_DATE) <= COALESCE(expiry_alert_days, 15)
ORDER BY days_remaining ASC;

-- ─── 6. COUNT NOTIFICATIONS BY TYPE ─────────────────────────────────────────

SELECT 
    type,
    COUNT(*) as count,
    MIN(created_at) as oldest,
    MAX(created_at) as newest
FROM system_notifications
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
GROUP BY type
ORDER BY type;

-- ─── 7. FIND DUPLICATE NOTIFICATIONS ────────────────────────────────────────

SELECT 
    reference_id,
    type,
    COUNT(*) as notification_count,
    MAX(created_at) as latest_notification
FROM system_notifications
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
  AND created_at > NOW() - INTERVAL '24 hours'
GROUP BY reference_id, type
HAVING COUNT(*) > 1
ORDER BY notification_count DESC;

-- ─── 8. CLEAN UP OLD NOTIFICATIONS (MANUAL) ────────────────────────────────

-- Preview what would be deleted
SELECT 
    id,
    type,
    title,
    created_at,
    AGE(NOW(), created_at) as age
FROM system_notifications
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
  AND created_at < NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;

-- Actually delete (uncomment to execute)
/*
DELETE FROM system_notifications
WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
  AND created_at < NOW() - INTERVAL '7 days';
*/

-- ─── 9. CREATE TEST DATA ────────────────────────────────────────────────────

-- Insert test items with various expiry dates
/*
INSERT INTO inventory (
    item_name,
    category,
    item_type,
    expiry_date,
    expiry_alert_days,
    stock_available,
    stock_total,
    description
)
VALUES 
    -- Expired item
    ('Test Item - Expired', 'Medical', 'consumable', CURRENT_DATE - INTERVAL '5 days', 15, 5, 10, 'Test item for expired notification'),
    
    -- Expires today
    ('Test Item - Today', 'Medical', 'consumable', CURRENT_DATE, 15, 8, 10, 'Test item expiring today'),
    
    -- Critical (5 days)
    ('Test Item - Critical', 'Medical', 'consumable', CURRENT_DATE + INTERVAL '5 days', 15, 12, 15, 'Test item in critical zone'),
    
    -- Warning (10 days)
    ('Test Item - Warning', 'Medical', 'consumable', CURRENT_DATE + INTERVAL '10 days', 15, 20, 25, 'Test item in warning zone'),
    
    -- OK (30 days)
    ('Test Item - OK', 'Medical', 'consumable', CURRENT_DATE + INTERVAL '30 days', 15, 15, 20, 'Test item still good');
*/

-- ─── 10. DELETE TEST DATA ───────────────────────────────────────────────────

-- Remove test items (uncomment to execute)
/*
DELETE FROM inventory
WHERE item_name LIKE 'Test Item -%';

DELETE FROM system_notifications
WHERE metadata->>'item_name' LIKE 'Test Item -%';
*/

-- ─── 11. RESCHEDULE JOB (CHANGE FREQUENCY) ─────────────────────────────────

-- Unschedule existing job
/*
SELECT cron.unschedule('daily-expiry-alert-check');
*/

-- Schedule with new frequency (e.g., every 6 hours)
/*
SELECT cron.schedule(
    'daily-expiry-alert-check',
    '0 */6 * * *',  -- Every 6 hours
    $$SELECT public.check_expiry_alerts();$$
);
*/

-- ─── 12. DISABLE/ENABLE JOB ─────────────────────────────────────────────────

-- Disable the job (keeps it scheduled but won't run)
/*
UPDATE cron.job
SET active = false
WHERE jobname = 'daily-expiry-alert-check';
*/

-- Enable the job
/*
UPDATE cron.job
SET active = true
WHERE jobname = 'daily-expiry-alert-check';
*/

-- ─── 13. VIEW NOTIFICATION READS ────────────────────────────────────────────

-- See which users have read expiry notifications
SELECT 
    sn.id,
    sn.type,
    sn.title,
    sn.metadata->>'item_name' as item_name,
    nr.user_id,
    up.full_name,
    nr.read_at
FROM system_notifications sn
LEFT JOIN notification_reads nr ON sn.id = nr.notification_id
LEFT JOIN user_profiles up ON nr.user_id = up.id
WHERE sn.type IN ('expiry', 'expiry_critical', 'expiry_warning')
ORDER BY sn.created_at DESC, nr.read_at DESC;

-- ─── 14. STATISTICS ─────────────────────────────────────────────────────────

-- Overall expiry alert statistics
SELECT 
    COUNT(DISTINCT ii.id) as total_items_with_expiry,
    COUNT(DISTINCT CASE WHEN (ii.expiry_date::date - CURRENT_DATE) < 0 THEN ii.id END) as expired_items,
    COUNT(DISTINCT CASE WHEN (ii.expiry_date::date - CURRENT_DATE) BETWEEN 0 AND 7 THEN ii.id END) as critical_items,
    COUNT(DISTINCT CASE WHEN (ii.expiry_date::date - CURRENT_DATE) BETWEEN 8 AND COALESCE(ii.expiry_alert_days, 15) THEN ii.id END) as warning_items,
    COUNT(DISTINCT sn.id) as total_notifications,
    COUNT(DISTINCT CASE WHEN sn.type = 'expiry' THEN sn.id END) as expired_notifications,
    COUNT(DISTINCT CASE WHEN sn.type = 'expiry_critical' THEN sn.id END) as critical_notifications,
    COUNT(DISTINCT CASE WHEN sn.type = 'expiry_warning' THEN sn.id END) as warning_notifications
FROM inventory ii
LEFT JOIN system_notifications sn ON sn.reference_id = ii.id::TEXT 
    AND sn.type IN ('expiry', 'expiry_critical', 'expiry_warning')
    AND sn.created_at > NOW() - INTERVAL '7 days'
WHERE ii.expiry_date IS NOT NULL
  AND ii.stock_available > 0
  AND ii.deleted_at IS NULL;
