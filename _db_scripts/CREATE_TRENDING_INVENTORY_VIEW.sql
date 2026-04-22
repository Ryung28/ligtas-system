-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - ANALYTICS ENGINE (TRENDING INVENTORY)
-- ============================================================================
-- PURPOSE: Pre-computed view for most borrowed equipment over trailing 30 days.
-- SILO INTEGRITY: Scaled by warehouse_id (borrowed_from_warehouse).
-- PERFORMANCE: Materialized View used to avoid recursive log scans.
-- ============================================================================

-- 1. CREATE MATERIALIZED VIEW
CREATE MATERIALIZED VIEW IF NOT EXISTS trending_inventory_view AS
SELECT 
    i.id as inventory_id,
    i.item_name,
    i.category,
    bl.borrowed_from_warehouse as warehouse_id,
    COUNT(bl.id) as borrow_count,
    MAX(bl.borrow_date) as last_borrowed_at
FROM borrow_logs bl
JOIN inventory i ON bl.inventory_id = i.id
WHERE bl.transaction_type = 'borrow'
  AND bl.status != 'cancelled'
  AND bl.borrow_date > NOW() - INTERVAL '30 days'
GROUP BY i.id, i.item_name, i.category, bl.borrowed_from_warehouse
ORDER BY borrow_count DESC;

-- 2. CREATE UNIQUE INDEX (Required for CONCURRENT REFRESH)
CREATE UNIQUE INDEX IF NOT EXISTS idx_trending_inventory_composite 
ON trending_inventory_view (inventory_id, warehouse_id);

-- 3. REFRESH FUNCTION (To be called via Cron or Trigger)
CREATE OR REPLACE FUNCTION refresh_trending_inventory_view()
RETURNS void AS $$
BEGIN
  -- Concurrent refresh prevents locking the view during reads
  REFRESH MATERIALIZED VIEW CONCURRENTLY trending_inventory_view;
END;
$$ LANGUAGE plpgsql;

COMMENT ON MATERIALIZED VIEW trending_inventory_view IS 'Pre-computed trending equipment data for the analytics dashboard.';
