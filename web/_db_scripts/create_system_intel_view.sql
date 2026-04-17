-- ============================================================================
-- THE UNIFIED INTEL COMMAND CENTER (V3.2 - LOW STOCK SSOT)
-- Creates a "Single Pane of Glass" view for all system anomalies.
-- INVENTORY branch: aligns with mobile + web "low stock" (absolute < 5 OR at/below
-- effective threshold). Removed stock_available < stock_total so 1/1 and 2/2
-- caps still surface when units are critically low.
-- ============================================================================

-- Drop the view if it exists so we can safely recreate it
DROP VIEW IF EXISTS public.system_intel;

CREATE OR REPLACE VIEW public.system_intel AS

-- 1. INVENTORY ALERTS (High-Signal Subject: Item Name)
SELECT 
    'inv-' || i.id::TEXT as id,
    'stock_low' as type,
    'INVENTORY' as category,
    CASE WHEN i.stock_available = 0 THEN 'CRITICAL' ELSE 'WARNING' END as priority,
    i.item_name as title,
    CASE 
        WHEN i.stock_available = 0 THEN 'OUT OF STOCK: Critical depletion detected.' 
        ELSE 'LOW STOCK: Only ' || i.stock_available || ' units remaining.' 
    END as message,
    jsonb_build_object(
        'item_id', i.id, 
        'item_name', i.item_name, 
        'stock_available', i.stock_available,
        'stock_total', i.stock_total,
        'low_stock_threshold', i.low_stock_threshold,
        'restock_alert_enabled', i.restock_alert_enabled,
        'search_query', i.item_name
    ) as metadata,
    i.updated_at as created_at,
    i.storage_location as warehouse_id
FROM public.inventory i
WHERE i.deleted_at IS NULL
  AND COALESCE(i.restock_alert_enabled, true) = true
  AND LOWER(COALESCE(i.status, '')) NOT IN ('damaged', 'lost', 'deleted')
  AND (
    i.stock_available < 5
    OR i.stock_available <= COALESCE(NULLIF(i.low_stock_threshold, 0), 10)
  )

UNION ALL

-- 2. LOGISTICS ACTIONS (High-Signal Subject: Item Name)
SELECT 
    'log-' || id::TEXT as id,
    'borrow_request' as type,
    'LOGISTICS' as category,
    'WARNING' as priority,
    item_name || ' (Qty: ' || quantity || ')' as title,
    CASE 
        WHEN type = 'dispense' THEN 'PENDING DISPENSE: Review request from ' || COALESCE(requester_name, 'Responder')
        WHEN type = 'dispose' THEN 'PENDING DISPOSAL: Items marked for decommissioning.'
        WHEN type = 'return' THEN 'PENDING RETURN: Verification required for check-in.'
        ELSE 'LOGISTICS TRIAGE: Manager review required.'
    END as message,
    jsonb_build_object(
        'item_id', item_id, 
        'item_name', item_name, 
        'action_id', id, 
        'type', type,
        'borrower_name', requester_name,
        'borrower_user_id', requester_id,
        'search_query', requester_name
    ) as metadata,
    created_at,
    warehouse_id
FROM public.logistics_actions
WHERE status = 'pending'

UNION ALL

-- 3. OVERDUE BORROWS (High-Signal Subject: Item Name)
SELECT 
    'bor-' || id::TEXT as id,
    'item_overdue' as type,
    'OVERDUE' as category,
    'CRITICAL' as priority,
    item_name as title,
    'OVERDUE: Borrowed by ' || borrower_name || '. Return was expected ' || expected_return_date::DATE || '.' as message,
    jsonb_build_object(
        'borrow_id', id, 
        'item_id', inventory_id, 
        'item_name', item_name,
        'borrower_name', borrower_name,
        'borrower_user_id', borrower_user_id,
        'search_query', borrower_name
    ) as metadata,
    expected_return_date as created_at,
    warehouse_id
FROM public.borrow_logs
WHERE status = 'borrowed' AND expected_return_date < NOW()

UNION ALL

-- 4. PENDING ACCESS REQUESTS (High-Signal Subject: User Name)
SELECT 
    'acc-' || id::TEXT as id,
    'user_pending' as type,
    'ACCESS' as category,
    'INFO' as priority,
    COALESCE(full_name, email) as title,
    'NEW ACCESS REQUEST: System authorization pending review.' as message,
    jsonb_build_object(
        'request_id', id, 
        'borrower_user_id', user_id, 
        'borrower_name', COALESCE(full_name, email),
        'email', email,
        'search_query', COALESCE(full_name, email)
    ) as metadata,
    requested_at as created_at,
    NULL as warehouse_id
FROM public.access_requests
WHERE status = 'pending';

-- Grant permissions
GRANT SELECT ON public.system_intel TO authenticated;
GRANT SELECT ON public.system_intel TO anon;
GRANT SELECT ON public.system_intel TO service_role;
