-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - OVERDUE DETECTION & NOTIFICATIONS
-- ============================================================================
-- PURPOSE: Detect overdue items and create notifications
-- PRIORITY 3: Automated overdue monitoring
-- ============================================================================
-- NOTE: This function should be called by a scheduled job (pg_cron or external)
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- FUNCTION: Detect and Notify Overdue Items
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION detect_overdue_items()
RETURNS TABLE(
    processed_count INTEGER,
    overdue_count INTEGER,
    notification_count INTEGER
) AS $$
DECLARE
    v_processed_count INTEGER := 0;
    v_overdue_count INTEGER := 0;
    v_notification_count INTEGER := 0;
    v_log RECORD;
BEGIN
    -- Step 1: Update status to 'overdue' for borrowed items past their return date
    UPDATE borrow_logs
    SET status = 'overdue'
    WHERE status = 'borrowed'
      AND expected_return_date < NOW()
      AND expected_return_date IS NOT NULL;
    
    GET DIAGNOSTICS v_overdue_count = ROW_COUNT;

    -- Step 2: Create notifications for newly overdue items
    -- Only create if notification doesn't already exist for this log
    FOR v_log IN 
        SELECT 
            bl.id,
            bl.item_name,
            bl.quantity,
            bl.borrower_name,
            bl.expected_return_date
        FROM borrow_logs bl
        WHERE bl.status = 'overdue'
          AND NOT EXISTS (
              SELECT 1 
              FROM system_notifications sn 
              WHERE sn.reference_id = bl.id::TEXT 
                AND sn.type = 'item_overdue'
          )
    LOOP
        INSERT INTO system_notifications (type, title, message, reference_id)
        VALUES (
            'item_overdue',
            'OVERDUE ALERT',
            v_log.borrower_name || ' has overdue ' || v_log.item_name || 
            ' (Qty: ' || v_log.quantity || ') - Due: ' || 
            TO_CHAR(v_log.expected_return_date, 'Mon DD, YYYY'),
            v_log.id::TEXT
        );
        
        v_notification_count := v_notification_count + 1;
    END LOOP;

    v_processed_count := v_overdue_count + v_notification_count;

    RETURN QUERY SELECT v_processed_count, v_overdue_count, v_notification_count;
END;
$$ LANGUAGE plpgsql;

-- ─────────────────────────────────────────────────────────────────────────────
-- GRANT PERMISSIONS
-- ─────────────────────────────────────────────────────────────────────────────

GRANT EXECUTE ON FUNCTION detect_overdue_items() TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- USAGE INSTRUCTIONS
-- ─────────────────────────────────────────────────────────────────────────────

COMMENT ON FUNCTION detect_overdue_items() IS 
'Detects overdue borrow logs and creates notifications. 
Should be called daily via pg_cron or external scheduler.
Returns: (processed_count, overdue_count, notification_count)

Example pg_cron setup:
SELECT cron.schedule(
    ''detect-overdue-daily'',
    ''0 8 * * *'',  -- Run at 8 AM daily
    $$SELECT detect_overdue_items()$$
);

Manual execution:
SELECT * FROM detect_overdue_items();
';

SELECT 'Overdue Detection Function: CREATED' as status;
SELECT 'Run manually: SELECT * FROM detect_overdue_items();' as usage;
SELECT 'Or setup pg_cron for daily automation' as automation;
