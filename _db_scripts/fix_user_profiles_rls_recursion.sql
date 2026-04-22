-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX USER_PROFILES RLS RECURSION
-- ============================================================================
-- ISSUE: user_profiles policy calls get_my_role() which queries user_profiles
-- CAUSE: Circular dependency - get_my_role() → user_profiles → get_my_role()
-- FIX: Remove get_my_role() from user_profiles policy, use direct role check
-- ============================================================================

-- Drop the problematic policy
DROP POLICY IF EXISTS "Unified Dashboard Access" ON user_profiles;

-- Create fixed policy without recursion
CREATE POLICY "Unified Dashboard Access" ON user_profiles
    FOR SELECT
    TO authenticated
    USING (
        -- Users can see their own profile
        id = auth.uid()
        OR
        -- Admins and editors can see all profiles (direct check, no function call)
        role = ANY (ARRAY['admin'::text, 'editor'::text])
    );

-- Verify the fix
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'user_profiles' AND policyname = 'Unified Dashboard Access';

SELECT '✅ Fixed user_profiles RLS - removed recursion' as status;
