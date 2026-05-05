-- ============================================================================
-- EXPIRY ALERT NOTIFICATION SYSTEM
-- ============================================================================
-- Automatically creates system notifications when inventory items are 
-- approaching their expiry date based on the expiry_alert_days threshold.
--
-- Notification Types:
--   - 'expiry_warning': Item is within alert threshold (amber)
--   - 'expiry_critical': Item has 7 days or less (red)
--   - 'expiry': Item has expired (red)
-- ============================================================================

-- ─── FUNCTION: Check and Create Expiry Notifications ───────────────────────

CREATE OR REPLACE FUNCTION public.check_expiry_alerts()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    item_record RECORD;
    days_remaining INTEGER;
    alert_threshold INTEGER;
    notification_type TEXT;
    notification_title TEXT;
    notification_message TEXT;
    existing_notification_id TEXT;
BEGIN
    -- Loop through all items with expiry dates
    FOR item_record IN
        SELECT 
            id,
            item_name,
            expiry_date,
            COALESCE(expiry_alert_days, 15) as alert_days,
            stock_available
        FROM public.inventory
        WHERE expiry_date IS NOT NULL
          AND stock_available > 0  -- Only alert for items in stock
          AND deleted_at IS NULL  -- Only active items (soft delete check)
    LOOP
        -- Calculate days remaining
        days_remaining := (item_record.expiry_date::date - CURRENT_DATE);
        alert_threshold := item_record.alert_days;
        
        -- Determine notification type and message
        IF days_remaining < 0 THEN
            notification_type := 'expiry';
            notification_title := 'ITEM EXPIRED';
            notification_message := item_record.item_name || ' has expired ' || ABS(days_remaining) || ' day(s) ago. Remove from inventory.';
        ELSIF days_remaining = 0 THEN
            notification_type := 'expiry_critical';
            notification_title := 'EXPIRES TODAY';
            notification_message := item_record.item_name || ' expires today. Immediate action required.';
        ELSIF days_remaining <= 7 THEN
            notification_type := 'expiry_critical';
            notification_title := 'CRITICAL EXPIRY ALERT';
            notification_message := item_record.item_name || ' expires in ' || days_remaining || ' day(s). Urgent attention needed.';
        ELSIF days_remaining <= alert_threshold THEN
            notification_type := 'expiry_warning';
            notification_title := 'EXPIRY WARNING';
            notification_message := item_record.item_name || ' expires in ' || days_remaining || ' day(s). Plan for replacement or disposal.';
        ELSE
            -- Item is not within alert threshold, skip
            CONTINUE;
        END IF;
        
        -- Check if a notification already exists for this item (within last 24 hours)
        SELECT id INTO existing_notification_id
        FROM public.system_notifications
        WHERE reference_id = item_record.id::TEXT
          AND type IN ('expiry', 'expiry_critical', 'expiry_warning')
          AND created_at > NOW() - INTERVAL '24 hours'
        LIMIT 1;
        
        -- Only create notification if one doesn't exist recently
        IF existing_notification_id IS NULL THEN
            INSERT INTO public.system_notifications (
                type,
                title,
                message,
                reference_id,
                user_id,  -- NULL = broadcast to all managers
                metadata
            )
            VALUES (
                notification_type,
                notification_title,
                notification_message,
                item_record.id::TEXT,
                NULL,  -- Broadcast to all managers/admins
                jsonb_build_object(
                    'item_id', item_record.id,
                    'item_name', item_record.item_name,
                    'expiry_date', item_record.expiry_date,
                    'days_remaining', days_remaining,
                    'alert_threshold', alert_threshold,
                    'stock_available', item_record.stock_available,
                    'audience_role', 'manager',
                    'search_query', item_record.item_name
                )
            );
            
            RAISE NOTICE 'Created % notification for item: %', notification_type, item_record.item_name;
        END IF;
    END LOOP;
    
    -- Clean up old expiry notifications (older than 7 days)
    DELETE FROM public.system_notifications
    WHERE type IN ('expiry', 'expiry_critical', 'expiry_warning')
      AND created_at < NOW() - INTERVAL '7 days';
      
    RAISE NOTICE 'Expiry alert check completed';
END;
$$;

-- ─── COMMENT ────────────────────────────────────────────────────────────────

COMMENT ON FUNCTION public.check_expiry_alerts() IS 
'Scans inventory for items approaching expiry and creates system notifications. 
Runs via pg_cron daily. Prevents duplicate notifications within 24 hours.';

-- ─── GRANT PERMISSIONS ──────────────────────────────────────────────────────

-- Allow authenticated users to execute (for manual testing)
GRANT EXECUTE ON FUNCTION public.check_expiry_alerts() TO authenticated;

-- ─── SCHEDULE: Daily Expiry Check (pg_cron) ────────────────────────────────
-- NOTE: pg_cron must be enabled in Supabase dashboard
-- This runs every day at 6:00 AM UTC

-- First, ensure pg_cron extension is available
-- (This must be enabled in Supabase Dashboard > Database > Extensions)

-- Schedule the job (uncomment after enabling pg_cron)
/*
SELECT cron.schedule(
    'daily-expiry-alert-check',
    '0 6 * * *',  -- Every day at 6:00 AM UTC
    $$SELECT public.check_expiry_alerts();$$
);
*/

-- ─── MANUAL EXECUTION ───────────────────────────────────────────────────────
-- To manually trigger the check (for testing):
-- SELECT public.check_expiry_alerts();

-- ─── VERIFY SCHEDULED JOBS ──────────────────────────────────────────────────
-- To view scheduled jobs:
-- SELECT * FROM cron.job;

-- To unschedule (if needed):
-- SELECT cron.unschedule('daily-expiry-alert-check');
