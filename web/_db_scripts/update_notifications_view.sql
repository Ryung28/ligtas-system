-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - POLYMORPHIC INTEL MATRIX (V2)
-- ============================================================================
-- Refactored for end-to-end alignment with Tactical Premium UI Matrix.
-- Aggregates: User Approvals, Inventory Alerts, Borrow Requests, Incidents.
-- ============================================================================

DROP VIEW IF EXISTS view_system_notifications;

CREATE VIEW view_system_notifications AS

-- 🛡️ 1. USER_PENDING: Registration Approvals
-- Source: user_profiles (Tactical Authentication)
SELECT 
    up.id::TEXT as id,
    up.id::TEXT as reference_id,
    'user_pending' as type,
    'ACCESS REQUEST' as title,
    up.full_name || ' is awaiting verification.' as message,
    up.created_at as time,
    false as is_read
FROM user_profiles up
WHERE up.status = 'pending'

UNION ALL

-- 🛡️ 2. BORROW_REQUEST: Equipment Logistics
-- Source: borrow_logs (Equipment Flow)
SELECT 
    bl.id::TEXT as id,
    bl.id::TEXT as reference_id,
    'borrow_request' as type,
    'LOGISTICS: BORROW' as title,
    bl.borrower_name || ' requested ' || COALESCE(i.item_name, 'Unknown Item') as message,
    bl.created_at as time,
    false as is_read
FROM borrow_logs bl
LEFT JOIN inventory i ON bl.inventory_id = i.id
WHERE bl.status = 'pending'

UNION ALL

-- 🛡️ 3. STOCK_LOW & STOCK_OUT: Inventory Intelligence
-- Source: inventory (Resource Management)
SELECT 
    'stock_' || i.id::TEXT as id,
    i.id::TEXT as reference_id,
    CASE 
        WHEN i.stock_available = 0 THEN 'stock_out' 
        ELSE 'stock_low' 
    END as type,
    CASE 
        WHEN i.stock_available = 0 THEN 'STOCK DEPLETED' 
        ELSE 'LOW STOCK ALERT' 
    END as title,
    i.item_name || ' (Available: ' || i.stock_available || ')' as message,
    i.updated_at as time,
    false as is_read
FROM inventory i
WHERE i.stock_available < 10 -- Threshold aligned for Disaster Prep

UNION ALL

-- 🛡️ 4. OVERDUE_ALERT: Accountability Layer
-- Source: borrow_logs (Tactical Compliance)
SELECT 
    'overdue_' || bl.id::TEXT as id,
    bl.id::TEXT as reference_id,
    'overdue_alert' as type,
    'OVERDUE EQUIPMENT' as title,
    bl.borrower_name || ' has unreturned ' || COALESCE(i.item_name, 'Item') as message,
    bl.expected_return_date as time,
    false as is_read
FROM borrow_logs bl
LEFT JOIN inventory i ON bl.inventory_id = i.id
WHERE bl.status = 'borrowed' 
  AND bl.expected_return_date < NOW()

UNION ALL

-- 🛡️ 5. INCIDENT_REPORT: Emergency Operations
-- Source: cctv_logs (Monitoring & Response)
-- Note: Mapping from cctv_logs until a dedicated incident table is deployed.
SELECT 
    cl.id::TEXT as id,
    cl.id::TEXT as reference_id,
    'incident_report' as type,
    'TACTICAL ALERT' as title,
    'New ' || COALESCE(cl.classification, 'incident') || ' at ' || COALESCE(cl.camera_name, 'Unknown Location') as message,
    cl.created_at as time,
    false as is_read
FROM cctv_logs cl
WHERE cl.created_at > (NOW() - INTERVAL '24 hours')

ORDER BY time DESC;

-- 🛡️ SECURITY: Lockdown access to authenticated operators only
GRANT SELECT ON view_system_notifications TO authenticated;
