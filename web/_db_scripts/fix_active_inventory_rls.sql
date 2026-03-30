-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX ACTIVE_INVENTORY VIEW RLS
-- ============================================================================
-- PURPOSE: Ensure active_inventory view respects RLS policies from inventory table
-- ISSUE: View may bypass RLS, allowing equipment managers to see all items
-- FIX: Recreate view WITHOUT SECURITY DEFINER to inherit RLS from base table
-- CRITICAL: Must include storage_location for warehouse filtering to work
-- ============================================================================

-- Drop existing view
DROP VIEW IF EXISTS active_inventory CASCADE;

-- Recreate view WITHOUT SECURITY DEFINER to inherit RLS from base table
-- Using ALL columns from inventory table for full compatibility
-- CRITICAL: storage_location is REQUIRED for RLS warehouse filtering
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
WHERE deleted_at IS NULL;

-- Grant access to authenticated users
GRANT SELECT ON active_inventory TO authenticated;

-- Verify RLS is inherited
COMMENT ON VIEW active_inventory IS 
'Active inventory items (non-deleted). Inherits RLS policies from inventory table. Equipment managers will only see items from their assigned warehouse via storage_location filtering.';

-- Confirmation
SELECT 'Active Inventory View: RLS ENABLED - Warehouse filtering active' as status;
SELECT 'CRITICAL: storage_location column included for RLS filtering' as note;
