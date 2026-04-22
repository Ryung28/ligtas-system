-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - SYSTEM NOTIFICATIONS VIEW
-- ============================================================================
-- Creates a unified view for all system notifications
-- Aggregates: Access Requests, Borrow Requests, Low Stock, Overdue Items
-- ============================================================================

-- Drop existing view first
DROP VIEW IF EXISTS view_system_notifications;

-- Create new view
CREATE VIEW view_system_notifications AS

-- 1. Access Requests (User Registration Approvals)
SELECT 
    up.id::TEXT as id,
    up.id::TEXT as reference_id,
    'user_request' as type,
    'ACCESS REQUEST' as title,
    up.full_name || ' is requesting access.' as message,
    up.created_at as time,
    false as is_read
FROM user_profiles up
WHERE up.status = 'pending'

UNION ALL

-- 2. Pending Borrow Requests
SELECT 
    bl.id::TEXT as id,
    bl.id::TEXT as reference_id,
    'borrow' as type,
    'BORROW REQUEST' as title,
    bl.borrower_name || ' requested ' || COALESCE(i.item_name, 'Unknown Item') || ' (Qty: ' || bl.quantity || ')' as message,
    bl.created_at as time,
    false as is_read
FROM borrow_logs bl
LEFT JOIN inventory i ON bl.inventory_id = i.id
WHERE bl.status = 'pending'

UNION ALL

-- 3. Low Stock Alerts
SELECT 
    'stock_' || i.id::TEXT as id,
    i.id::TEXT as reference_id,
    'stock' as type,
    'LOW STOCK ALERT' as title,
    i.item_name || ' is running low (Available: ' || i.stock_available || ')' as message,
    i.updated_at as time,
    false as is_read
FROM inventory i
WHERE i.stock_available < 5 AND i.stock_available > 0

UNION ALL

-- 4. Overdue Items
SELECT 
    'overdue_' || bl.id::TEXT as id,
    bl.id::TEXT as reference_id,
    'overdue' as type,
    'OVERDUE ITEM' as title,
    bl.borrower_name || ' has overdue ' || COALESCE(i.item_name, 'Unknown Item') || ' (Due: ' || TO_CHAR(bl.expected_return_date, 'MM/DD/YYYY') || ')' as message,
    bl.expected_return_date as time,
    false as is_read
FROM borrow_logs bl
LEFT JOIN inventory i ON bl.inventory_id = i.id
WHERE bl.status = 'borrowed' 
  AND bl.expected_return_date < NOW()

ORDER BY time DESC;

-- Grant access to authenticated users
GRANT SELECT ON view_system_notifications TO authenticated;

SELECT 'System Notifications View: CREATED' as status;
