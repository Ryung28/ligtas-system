-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX MANAGER INVENTORY ACCESS (V5 - FINAL ALIGNMENT)
-- ============================================================================
-- PURPOSE: Fix SQL View Name Error and JSON Parsing Error (CamelCase)
-- ============================================================================

-- 1. Ensure Inventory Table has all required columns
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'qr_code') THEN 
        ALTER TABLE inventory ADD COLUMN qr_code TEXT DEFAULT '';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'item_code') THEN 
        ALTER TABLE inventory ADD COLUMN item_code TEXT DEFAULT '';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'low_stock_threshold') THEN 
        ALTER TABLE inventory ADD COLUMN low_stock_threshold INTEGER DEFAULT 10;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'unit') THEN 
        ALTER TABLE inventory ADD COLUMN unit TEXT DEFAULT 'pcs';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'image_url') THEN 
        ALTER TABLE inventory ADD COLUMN image_url TEXT;
    END IF;
END $$;

-- 2. Clean Start: Drop View to allow column name changes (Avoids ERROR: 42P16)
DROP VIEW IF EXISTS active_inventory CASCADE;

-- 3. Redefine active_inventory View with QUOTED CAMELCASE MAPPING
-- This is critical: Postgres forces lowercase unless aliases are quoted.
-- The Dart DTO _$InventoryModelImplFromJson expects these exact keys.
CREATE VIEW active_inventory AS
SELECT 
    id,
    item_name, -- @JsonKey(name: 'item_name')
    category,
    stock_total, -- @JsonKey(name: 'stock_total')
    stock_available, -- @JsonKey(name: 'stock_available')
    status,
    description,
    storage_location as location, -- expected: 'location'
    qr_code as "qrCode", -- expected: 'qrCode' (QUOTED)
    created_at, -- @JsonKey(name: 'created_at')
    updated_at, -- @JsonKey(name: 'updated_at')
    deleted_at,
    item_code as code, -- expected: 'code'
    low_stock_threshold as "minStockLevel", -- expected: 'minStockLevel' (QUOTED)
    unit,
    image_url -- @JsonKey(name: 'image_url')
FROM inventory
WHERE 
    deleted_at IS NULL
    AND (
        (SELECT role FROM user_profiles WHERE id = auth.uid()) IN ('admin', 'editor')
        OR get_user_warehouse() IS NULL 
        OR storage_location = get_user_warehouse()
    );

-- 4. Re-apply Permissions (since view was dropped)
GRANT SELECT ON active_inventory TO authenticated;

-- 5. Update RLS Policies for the base table 'inventory'
DROP POLICY IF EXISTS "warehouse_inventory_select" ON inventory;
CREATE POLICY "warehouse_inventory_select" ON inventory
FOR SELECT TO authenticated
USING (
    (SELECT role FROM user_profiles WHERE id = auth.uid()) IN ('admin', 'editor')
    OR get_user_warehouse() IS NULL
    OR storage_location = get_user_warehouse()
);

-- 6. Update RLS Policy for Borrow Logs
DROP POLICY IF EXISTS "warehouse_logs_select" ON borrow_logs;
CREATE POLICY "warehouse_logs_select" ON borrow_logs
FOR SELECT TO authenticated
USING (
    (SELECT role FROM user_profiles WHERE id = auth.uid()) IN ('admin', 'editor')
    OR get_user_warehouse() IS NULL
    OR borrowed_from_warehouse = get_user_warehouse()
);

SELECT '✅ Manager Inventory Access Fixed - DTO Alignment Complete (V5)' as status;
