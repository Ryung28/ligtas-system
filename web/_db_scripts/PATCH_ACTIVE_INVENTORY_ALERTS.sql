-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - TACTICAL PATCH (VIEW ALIGNMENT)
-- ============================================================================
-- Adds 'restock_alert_enabled' and restores 'low_stock_threshold' name
-- for consistency between web, mobile, and raw database queries.
-- ============================================================================

DROP VIEW IF EXISTS active_inventory;

CREATE OR REPLACE VIEW active_inventory AS
SELECT 
    id, 
    item_name, 
    category, 
    stock_total, 
    stock_available, 
    status, 
    description, 
    storage_location as location, 
    qr_code as "qrCode", 
    item_code as code, 
    low_stock_threshold, -- NO RENAME: Keep same as raw table
    restock_alert_enabled, -- ADD: Missing on mobile
    unit, 
    image_url, 
    created_at, 
    updated_at
FROM inventory
WHERE deleted_at IS NULL
AND (
    get_user_warehouse() IS NULL 
    OR storage_location = get_user_warehouse()
);

GRANT SELECT ON active_inventory TO authenticated;
GRANT SELECT ON active_inventory TO anon;
GRANT SELECT ON active_inventory TO service_role;

SELECT '✅ active_inventory View Patched: restock_alert_enabled enabled' as status;
