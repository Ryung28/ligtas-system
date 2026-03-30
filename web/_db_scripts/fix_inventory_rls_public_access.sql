-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX INVENTORY RLS PUBLIC ACCESS
-- ============================================================================
-- ISSUE: "Allow public full access" policy overrides warehouse filtering
-- CAUSE: Multiple PERMISSIVE policies use OR logic, so "true" allows everything
-- FIX: Remove the overly permissive public policy
-- ============================================================================

-- Drop the problematic policy
DROP POLICY IF EXISTS "Allow public full access" ON inventory;

-- Verify remaining policies
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'inventory'
ORDER BY policyname;

SELECT '✅ Removed overly permissive public access policy' as status;
SELECT '🛡️ Warehouse filtering now enforced correctly' as result;
