-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - NUCLEAR FIX FOR BORROW LOGS RLS
-- ============================================================================
-- ISSUE: Complex recursion in RLS policies causing silent failures
-- FIX: Create simple SECURITY DEFINER function that bypasses all RLS
-- ============================================================================

-- Step 1: Create trusted admin checker (bypasses RLS entirely)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Step 2: Create trusted editor checker
CREATE OR REPLACE FUNCTION public.is_editor()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND role = 'editor'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Step 3: Drop ALL existing SELECT policies on borrow_logs
DROP POLICY IF EXISTS "unified_borrow_logs_select" ON borrow_logs;
DROP POLICY IF EXISTS "public_own_logs_select" ON borrow_logs;

-- Step 4: Create the SIMPLEST possible policy
CREATE POLICY "admin_sees_all" ON borrow_logs
    FOR SELECT
    TO authenticated
    USING (
        -- 🛡️ MASTER KEY: Admins see everything (stops here, no other checks)
        public.is_admin()
        OR
        -- 🛡️ WAREHOUSE FILTER: Editors see their warehouse
        (
            public.is_editor()
            AND (borrowed_from_warehouse = get_user_warehouse() OR borrowed_from_warehouse IS NULL)
        )
        OR
        -- 🛡️ SELF SERVICE: Users see their own logs
        (
            auth.uid() = borrower_user_id
            OR auth.uid() = borrowed_by
        )
    );

-- Step 5: Re-add public policy for unauthenticated borrowers
CREATE POLICY "public_own_logs" ON borrow_logs
    FOR SELECT
    TO public
    USING (
        auth.uid() = borrower_user_id
        OR auth.uid() = borrowed_by
        OR borrower_email = (auth.jwt() ->> 'email'::text)
    );

-- Verify
SELECT policyname, cmd, roles FROM pg_policies 
WHERE tablename = 'borrow_logs' AND cmd = 'SELECT';

SELECT '✅ NUCLEAR FIX APPLIED - Admin access restored' as status;
