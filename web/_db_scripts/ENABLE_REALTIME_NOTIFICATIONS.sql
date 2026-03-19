-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - REALTIME NOTIFICATIONS ENROLLMENT
-- ============================================================================
-- Run this in the Supabase SQL Editor.
-- Enables Realtime for tables used by notification system.
-- ============================================================================

-- Add tables to the supabase_realtime publication
-- This enables Realtime for these tables
-- Note: user_profiles is already enabled, so we skip it

ALTER PUBLICATION supabase_realtime ADD TABLE borrow_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE inventory;
ALTER PUBLICATION supabase_realtime ADD TABLE access_requests;

-- Verify Realtime status
SELECT 
    t.tablename,
    CASE 
        WHEN p.pubname IS NOT NULL THEN 'Realtime ENABLED'
        ELSE 'Realtime DISABLED'
    END as realtime_status
FROM pg_tables t
LEFT JOIN pg_publication_tables p 
    ON t.tablename = p.tablename AND t.schemaname = p.schemaname AND p.pubname = 'supabase_realtime'
WHERE t.schemaname = 'public' 
AND t.tablename IN ('borrow_logs', 'inventory', 'access_requests', 'user_profiles')
ORDER BY t.tablename;

SELECT 'Realtime Notifications Enrollment: COMPLETED' as status;
