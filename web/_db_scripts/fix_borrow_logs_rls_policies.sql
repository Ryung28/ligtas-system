-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX BORROW LOGS RLS POLICIES
-- ============================================================================
-- ISSUE: Multiple PERMISSIVE SELECT policies use OR logic, bypassing warehouse filter
-- CAUSE: "Allow public full access" and "Allow authenticated read" bypass warehouse
-- FIX: Consolidate into single policy with proper warehouse filtering
-- ============================================================================

-- Drop conflicting policies
DROP POLICY IF EXISTS "Allow public full access" ON borrow_logs;
DROP POLICY IF EXISTS "Allow authenticated read borrow logs" ON borrow_logs;
DROP POLICY IF EXISTS "Users can view their own borrow logs" ON borrow_logs;
DROP POLICY IF EXISTS "warehouse_logs_select" ON borrow_logs;
DROP POLICY IF EXISTS "unified_borrow_logs_select" ON borrow_logs;
DROP POLICY IF EXISTS "public_own_logs_select" ON borrow_logs;

-- Create unified SELECT policy with proper Role-Based Access (RBAC)
-- 🛡️ RECURSION FIX: Use get_my_role() to avoid RLS circular dependency
-- 1. Admins see all logs (Global Visibility)
-- 2. Equipment managers (editors) see logs from their warehouse
-- 3. Borrowers see only their own logs
CREATE POLICY "unified_borrow_logs_select" ON borrow_logs
    FOR SELECT
    TO authenticated
    USING (
        -- 🛡️ GLOBAL COMMANDER: Use Security Definer function to bypass RLS recursion
        public.get_my_role() = 'admin'
        OR 
        -- 🛡️ WAREHOUSE SILO: Equipment manager access (warehouse-filtered)
        (
            public.get_my_role() = 'editor'
            AND (borrowed_from_warehouse = get_user_warehouse() OR borrowed_from_warehouse IS NULL)
        )
        OR
        -- 🛡️ FIELD OPERATOR: Borrower access (own logs only)
        (
            public.get_my_role() NOT IN ('admin', 'editor')
            AND (
                auth.uid() = borrower_user_id 
                OR auth.uid() = borrowed_by 
                OR borrower_email = (auth.jwt() ->> 'email'::text)
            )
        )
    );

-- Also create public SELECT policy for unauthenticated borrowers
CREATE POLICY "public_own_logs_select" ON borrow_logs
    FOR SELECT
    TO public
    USING (
        auth.uid() = borrower_user_id 
        OR auth.uid() = borrowed_by 
        OR borrower_email = (auth.jwt() ->> 'email'::text)
    );

-- Verify the fix
SELECT 
    policyname,
    cmd,
    roles
FROM pg_policies 
WHERE tablename = 'borrow_logs' AND cmd = 'SELECT'
ORDER BY policyname;

SELECT '✅ Consolidated borrow_logs SELECT policies with warehouse filtering' as status;
