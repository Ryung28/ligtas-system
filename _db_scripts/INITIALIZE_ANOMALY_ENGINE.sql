-- 🏛️ LIGTAS MASTER ANOMALY VIEW (V1.2 - ENTERPRISE CALIBRATED)
-- Aggregates inventory depletion, operational failures, and logistical bottlenecks.

-- 1. RE-CREATE THE VIEW
CREATE OR REPLACE VIEW public.view_system_anomalies AS
-- A. 🔴 CRITICAL: Asset Failures (Quantity-Based)
SELECT 
    id::text as id,
    item_name as title,
    CASE 
        WHEN qty_damaged > 0 THEN 'OPERATIONAL FAILURE: ' || qty_damaged || ' Units Damaged'
        WHEN qty_lost > 0 THEN 'SECURITY BREACH: ' || qty_lost || ' Units Lost'
        WHEN qty_maintenance > 0 THEN 'MAINTENANCE REQUIRED: ' || qty_maintenance || ' Units in Repair'
        ELSE 'ASSET FAILURE: ' || status
    END as reason,
    'operational' as category,
    'critical' as severity,
    (qty_damaged + qty_lost + qty_maintenance) as current_value,
    0 as threshold_value,
    updated_at as detected_at,
    storage_location as warehouse_id
FROM public.inventory 
WHERE qty_damaged > 0 OR qty_lost > 0 OR qty_maintenance > 0 OR status = 'Damaged'

UNION ALL

-- B. 🟡 WARNING: Stock Depletion (Dynamic Threshold)
SELECT 
    id::text as id,
    item_name as title,
    'CRITICAL DEPLETION: ' || qty_good || ' Units Remaining' as reason,
    'depletion' as category,
    'warning' as severity,
    qty_good as current_value,
    COALESCE(low_stock_threshold, 10) as threshold_value,
    updated_at as detected_at,
    storage_location as warehouse_id
FROM public.inventory 
WHERE qty_good <= COALESCE(low_stock_threshold, 10) 
  AND status NOT IN ('damaged', 'lost', 'deleted')

UNION ALL

-- C. 🔴 CRITICAL: Overdue Logistics
SELECT 
    id::text as id,
    item_name as title,
    'LOGISTICAL BREACH: Overdue Return' as reason,
    'logistics' as category,
    'critical' as severity,
    1 as current_value,
    0 as threshold_value,
    updated_at as detected_at,
    warehouse_id
FROM public.borrow_logs 
WHERE status = 'overdue';

-- 2. GRANT PERMISSIONS
GRANT SELECT ON public.view_system_anomalies TO authenticated;
GRANT SELECT ON public.view_system_anomalies TO anon;
GRANT SELECT ON public.view_system_anomalies TO service_role;

-- 3. FORCE SCHEMA RELOAD
NOTIFY pgrst, 'reload schema';
