-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - TACTICAL MIRROR (VIEW ALIGNMENT V2)
-- ============================================================================
-- 1. Updates 'active_inventory' to include AGGREGATE stock logic.
-- 2. Restores 'restock_alert_enabled' and 'low_stock_threshold' mapping.
-- 3. ENSURES PERFECT 1:1 PARITY with the Web Dashboard.
-- ============================================================================

DROP VIEW IF EXISTS active_inventory;

CREATE OR REPLACE VIEW active_inventory AS
WITH variant_summary AS (
    SELECT 
        parent_id,
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
    i.stock_total, 
    i.stock_available, 
    (i.stock_available + COALESCE(vs.sum_available, 0)) as aggregate_available,
    (i.stock_total + COALESCE(vs.sum_total, 0)) as aggregate_total,
    i.status, 
    i.description, 
    i.storage_location as location, 
    i.qr_code as "qrCode", 
    i.item_code as code, 
    i.low_stock_threshold,
    i.restock_alert_enabled,
    i.unit, 
    i.image_url, 
    i.created_at, 
    i.updated_at
FROM inventory i
LEFT JOIN variant_summary vs ON i.id = vs.parent_id
WHERE i.deleted_at IS NULL 
  AND i.parent_id IS NULL; -- 🛡️ MIRROR: Only show Master SKUs on the main grid

GRANT SELECT ON active_inventory TO authenticated;
GRANT SELECT ON active_inventory TO anon;
GRANT SELECT ON active_inventory TO service_role;

SELECT '✅ active_inventory View Patched: AGGREGATE PARITY ENABLED' as status;
