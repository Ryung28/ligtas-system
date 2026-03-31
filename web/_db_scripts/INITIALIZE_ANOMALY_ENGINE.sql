-- 🏛️ LIGTAS MASTER ANOMALY VIEW (V1.1 - CORRECTED)
-- Aggregates inventory depletion, operational failures, and logistical bottlenecks.

-- 1. RE-CREATE THE VIEW
CREATE OR REPLACE VIEW public.view_system_anomalies AS
-- A. 🔴 CRITICAL: Damaged or Lost Equipment (from inventory)
SELECT 
    id::text as id,
    item_name as title,
    'OPERATIONAL FAILURE: Asset ' || status as reason,
    'operational' as category,
    'critical' as severity,
    stock_available as current_value,
    0 as threshold_value,
    updated_at as detected_at,
    storage_location as warehouse_id 
FROM public.inventory 
WHERE status IN ('damaged', 'lost', 'missing')

UNION ALL

-- B. 🟡 WARNING: Low Stock Depletion (from inventory)
SELECT 
    id::text as id,
    item_name as title,
    'CRITICAL DEPLETION: Low Stock' as reason,
    'depletion' as category,
    'warning' as severity,
    stock_available as current_value,
    10 as threshold_value,
    updated_at as detected_at,
    storage_location as warehouse_id
FROM public.inventory 
WHERE stock_available < 10 AND status = 'available'

UNION ALL

-- C. 🔴 CRITICAL: Overdue Logistics (from borrow_logs)
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
