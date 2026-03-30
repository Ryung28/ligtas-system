-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - RECREATE ACTIVE_INVENTORY WITH WAREHOUSE FILTER
-- ============================================================================
-- ISSUE: Views don't support RLS, so active_inventory bypasses warehouse filtering
-- FIX: Recreate view with warehouse filter built into the query
-- ============================================================================

-- Drop existing view
DROP VIEW IF EXISTS active_inventory;

-- Recreate with warehouse filtering built-in
CREATE VIEW active_inventory AS
SELECT 
    id,
    item_name,
    category,
    stock_total,
    stock_available,
    status,
    description,
    storage_location,
    created_at,
    updated_at,
    deleted_at
FROM inventory
WHERE 
    deleted_at IS NULL
    AND (
        get_user_warehouse() IS NULL 
        OR storage_location = get_user_warehouse()
    );

-- Grant access
GRANT SELECT ON active_inventory TO authenticated;

-- Verify the view
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views 
WHERE viewname = 'active_inventory';

SELECT '✅ Recreated active_inventory view with warehouse filtering' as status;
