-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - OMEGA RECOVERY SCRIPT (FORCE ALIGNMENT)
-- ============================================================================
-- PURPOSE: 
-- 1. Fix "Column does not exist" errors in inventory views.
-- 2. Restore get_user_warehouse() with proper SECURITY DEFINER access.
-- 3. Synchronize inventory_catalog with the React Borrowing Dialog.
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 1: HARDEN INVENTORY SCHEMA (Add all missing columns)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS item_type TEXT DEFAULT 'equipment';
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS parent_id BIGINT REFERENCES inventory(id);
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS storage_location TEXT;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS brand TEXT;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS unit TEXT DEFAULT 'unit';
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS qr_code TEXT;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS item_code TEXT;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS low_stock_threshold INTEGER DEFAULT 0;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS target_stock INTEGER;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Add Audit Buckets if missing
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS qty_good INTEGER DEFAULT 0;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS qty_damaged INTEGER DEFAULT 0;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS qty_maintenance INTEGER DEFAULT 0;
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS qty_lost INTEGER DEFAULT 0;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 2: INSTALL SECURITY HELPERS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_user_warehouse()
RETURNS TEXT AS $$
DECLARE
    v_warehouse TEXT;
BEGIN
    SELECT assigned_warehouse INTO v_warehouse
    FROM public.user_profiles
    WHERE id = auth.uid();
    RETURN v_warehouse;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = public, pg_temp;

GRANT EXECUTE ON FUNCTION get_user_warehouse() TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 3: REBUILD CORE VIEWS
-- ─────────────────────────────────────────────────────────────────────────────
DROP VIEW IF EXISTS active_inventory CASCADE;
DROP VIEW IF EXISTS inventory_catalog CASCADE;

-- A. The "Gold Standard" view for Mobile
CREATE OR REPLACE VIEW active_inventory AS
SELECT 
    id, item_name, category, stock_total, stock_available, status, description, 
    storage_location as location, qr_code as "qrCode", item_code as code, 
    low_stock_threshold as "minStockLevel", unit, image_url, created_at, updated_at
FROM inventory
WHERE deleted_at IS NULL
AND (
    get_user_warehouse() IS NULL 
    OR storage_location = get_user_warehouse()
);

-- B. The Logistics Dispatch Engine (The fix for the Borrow Dialog)
CREATE OR REPLACE VIEW inventory_catalog AS
WITH variant_summary AS (
    SELECT 
        parent_id,
        jsonb_agg(jsonb_build_object(
            'id', id,
            'location', storage_location,
            'stock_available', stock_available,
            'stock_total', stock_total,
            'status', status
        )) as variant_list,
        SUM(stock_available) as sum_available,
        SUM(stock_total) as sum_total
    FROM inventory
    WHERE parent_id IS NOT NULL AND deleted_at IS NULL
    GROUP BY parent_id
)
SELECT 
    i.id,
    i.item_name,
    i.category,
    i.description,
    i.image_url,
    i.item_type,
    i.storage_location as primary_location,
    i.stock_available as primary_stock_available,
    i.stock_total as primary_stock_total,
    (i.stock_available + COALESCE(vs.sum_available, 0)) as aggregate_available,
    (i.stock_total + COALESCE(vs.sum_total, 0)) as aggregate_total,
    COALESCE(vs.variant_list, '[]'::jsonb) as variants,
    i.status,
    (
        SELECT COALESCE(SUM(quantity), 0) FROM borrow_logs 
        WHERE inventory_id = i.id AND status IN ('pending', 'staged')
    ) as stock_pending
FROM inventory i
LEFT JOIN variant_summary vs ON i.id = vs.parent_id
WHERE i.parent_id IS NULL AND i.deleted_at IS NULL
AND (
    get_user_warehouse() IS NULL 
    OR i.storage_location = get_user_warehouse()
    OR EXISTS (
        SELECT 1 FROM inventory v 
        WHERE v.parent_id = i.id 
        AND v.storage_location = get_user_warehouse()
    )
);

-- Permissions
GRANT SELECT ON active_inventory TO authenticated;
GRANT SELECT ON inventory_catalog TO authenticated;

SELECT '✅ LIGTAS OMEGA RECOVERY: SYSTEM ALIGNED' as status;
