-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - SIMPLIFY BORROW LOGS RLS
-- ============================================================================
-- ISSUE: Complex policy with subqueries may fail if user not in user_profiles
-- FIX: Simplify using get_user_warehouse() which handles NULL gracefully
-- ============================================================================

-- Drop existing policy
DROP POLICY IF EXISTS "unified_borrow_logs_select" ON borrow_logs;

-- Create simplified policy
-- NULL warehouse = admin (sees all)
-- Non-NULL warehouse = equipment manager (sees only their warehouse)
-- Borrowers handled by public policy
CREATE POLICY "unified_borrow_logs_select" ON borrow_logs
    FOR SELECT
    TO authenticated
    USING (
        -- Admin or equipment manager with warehouse filter
        get_user_warehouse() IS NULL 
        OR borrowed_from_warehouse = get_user_warehouse()
        OR borrowed_from_warehouse IS NULL
        -- Also allow users to see their own logs
        OR auth.uid() = borrower_user_id 
        OR auth.uid() = borrowed_by
    );

-- Verify
SELECT policyname, cmd, roles FROM pg_policies 
WHERE tablename = 'borrow_logs' AND cmd = 'SELECT'
ORDER BY policyname;

SELECT '✅ Simplified borrow_logs RLS policy' as status;
