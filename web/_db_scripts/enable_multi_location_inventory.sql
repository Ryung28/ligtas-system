-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - MULTI-LOCATION & ENTERPRISE INVENTORY SCHEMA (FIXED)
-- ============================================================================
-- This migration ensures the inventory table is robust, enables hierarchical 
-- multi-location tracking, and BRIDGES legacy column names to prevent 0-stock UI.
-- ============================================================================

-- 1. SELF-HEALING: Ensure all required columns exist in the inventory table
DO $$ 
BEGIN 
    -- Relational Link
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'parent_id') THEN 
        ALTER TABLE inventory ADD COLUMN parent_id INTEGER REFERENCES public.inventory(id);
    END IF;

    -- Enterprise Metadata
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'unit') THEN 
        ALTER TABLE inventory ADD COLUMN unit TEXT DEFAULT 'pcs';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'brand') THEN 
        ALTER TABLE inventory ADD COLUMN brand TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'item_type') THEN 
        ALTER TABLE inventory ADD COLUMN item_type TEXT DEFAULT 'equipment';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'description') THEN 
        ALTER TABLE inventory ADD COLUMN description TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'image_url') THEN 
        ALTER TABLE inventory ADD COLUMN image_url TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'storage_location') THEN 
        ALTER TABLE inventory ADD COLUMN storage_location TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'deleted_at') THEN 
        ALTER TABLE inventory ADD COLUMN deleted_at TIMESTAMPTZ;
    END IF;

    -- Enterprise Status Buckets (Quantity Partitioning)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'qty_good') THEN 
        ALTER TABLE inventory ADD COLUMN qty_good INTEGER NOT NULL DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'qty_damaged') THEN 
        ALTER TABLE inventory ADD COLUMN qty_damaged INTEGER NOT NULL DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'qty_maintenance') THEN 
        ALTER TABLE inventory ADD COLUMN qty_maintenance INTEGER NOT NULL DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'qty_lost') THEN 
        ALTER TABLE inventory ADD COLUMN qty_lost INTEGER NOT NULL DEFAULT 0;
    END IF;
END $$;

-- 2. DATA SYNCHRONIZATION: Fix the "0 Stock" bug by migrating existing data to buckets
-- If buckets are all 0 but stock_available exists, assume it is 'Good' stock.
UPDATE public.inventory 
SET qty_good = stock_available 
WHERE qty_good = 0 AND qty_damaged = 0 AND qty_maintenance = 0 AND qty_lost = 0 AND stock_available > 0;

-- 3. Add index for relational performance
CREATE INDEX IF NOT EXISTS idx_inventory_parent_id ON public.inventory(parent_id);

-- 4. Create the Aggregated Catalog View (WITH LEGACY BRIDGING)
-- Consolidates variants into a single Master row with JSON location details.
DROP VIEW IF EXISTS inventory_catalog CASCADE;

CREATE VIEW inventory_catalog AS
WITH variant_summary AS (
    SELECT 
        parent_id,
        json_agg(json_build_object(
            'id', id,
            'location', storage_location,
            'stock_available', (stock_available - COALESCE((
                SELECT SUM(quantity) FROM borrow_logs WHERE inventory_id = inventory.id AND status = 'pending'
            ), 0)),
            'stock_total', stock_total,
            'status', status,
            'qty_good', qty_good,
            'qty_damaged', qty_damaged,
            'qty_maintenance', qty_maintenance,
            'qty_lost', qty_lost
        ) ORDER BY created_at) as variant_list,
        SUM(stock_available - COALESCE((
            SELECT SUM(quantity) FROM borrow_logs WHERE inventory_id = inventory.id AND status = 'pending'
        ), 0)) as variant_stock_available,
        SUM(stock_total) as variant_stock_total,
        SUM(qty_good) as variant_qty_good,
        SUM(qty_damaged) as variant_qty_damaged,
        SUM(qty_maintenance) as variant_qty_maintenance,
        SUM(qty_lost) as variant_qty_lost
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
    i.brand,
    i.unit,
    i.storage_location as primary_location,
    -- 🛡️ LEGACY BRIDGE: Mapping new aggregate values back to original names
    (i.stock_available - COALESCE((
        SELECT SUM(quantity) FROM borrow_logs WHERE inventory_id = i.id AND status = 'pending'
    ), 0)) + COALESCE(vs.variant_stock_available, 0) as stock_available,
    i.stock_total + COALESCE(vs.variant_stock_total, 0) as stock_total,
    -- Hierarchical Specifics
    (i.stock_available - COALESCE((
        SELECT SUM(quantity) FROM borrow_logs WHERE inventory_id = i.id AND status = 'pending'
    ), 0)) as primary_stock_available,
    i.stock_total as primary_stock_total,
    (i.stock_available - COALESCE((
        SELECT SUM(quantity) FROM borrow_logs WHERE inventory_id = i.id AND status = 'pending'
    ), 0)) + COALESCE(vs.variant_stock_available, 0) as aggregate_available,
    i.stock_total + COALESCE(vs.variant_stock_total, 0) as aggregate_total,
    -- Aggregated Buckets
    i.qty_good + COALESCE(vs.variant_qty_good, 0) as qty_good,
    i.qty_damaged + COALESCE(vs.variant_qty_damaged, 0) as qty_damaged,
    i.qty_maintenance + COALESCE(vs.variant_qty_maintenance, 0) as qty_maintenance,
    i.qty_lost + COALESCE(vs.variant_qty_lost, 0) as qty_lost,
    COALESCE(vs.variant_list, '[]'::json) as variants,
    i.status,
    i.created_at,
    i.updated_at
FROM inventory i
LEFT JOIN variant_summary vs ON i.id = vs.parent_id
WHERE i.parent_id IS NULL AND i.deleted_at IS NULL
-- 🛡️ SILO INTEGRITY: Restore Multi-Tenant Security Filter
AND (
    (SELECT role FROM user_profiles WHERE id = auth.uid()) IN ('admin', 'editor')
    OR get_user_warehouse() IS NULL 
    OR i.storage_location = get_user_warehouse()
    OR EXISTS (
        SELECT 1 FROM inventory v 
        WHERE v.parent_id = i.id 
        AND v.storage_location = get_user_warehouse()
    )
);

-- 5. Re-apply Permissions
GRANT SELECT ON inventory_catalog TO authenticated;
GRANT SELECT ON inventory_catalog TO anon;

SELECT '✅ Multi-location inventory fixed: Legacy names bridged and buckets initialized' as status;
