-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX INVENTORY SELECT RLS POLICIES
-- ============================================================================
-- ISSUE: Two PERMISSIVE SELECT policies use OR logic, allowing all items
-- CAUSE: "Active users see active items only" bypasses warehouse filtering
-- FIX: Combine both policies into one with AND logic
-- ============================================================================

-- Drop the conflicting policies
DROP POLICY IF EXISTS "Active users see active items only" ON inventory;
DROP POLICY IF EXISTS "warehouse_inventory_select" ON inventory;

-- Create single unified SELECT policy with both conditions
CREATE POLICY "warehouse_filtered_select" ON inventory
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL 
        AND (
            get_user_warehouse() IS NULL 
            OR storage_location = get_user_warehouse()
        )
    );

-- Verify the fix
SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'inventory' AND cmd = 'SELECT'
ORDER BY policyname;

SELECT '✅ Combined SELECT policies into single warehouse-filtered policy' as status;
