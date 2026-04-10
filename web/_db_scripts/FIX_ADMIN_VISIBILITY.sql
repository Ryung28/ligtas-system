-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX ADMIN VISIBILITY (RLS BYPASS)
-- ============================================================================
-- ISSUE: The previous RLS policy was hide-only: it only showed 'admin' rows.
-- FIX: Create a SECURITY DEFINER function to check the current user's role
-- WITHOUT triggering recursion, allowing admins to see 'responders'.
-- ============================================================================

-- Step 1: Create a non-recursive role checker
CREATE OR REPLACE FUNCTION public.is_admin_or_editor()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'editor')
    AND status = 'active'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Step 2: Grant permissions
GRANT EXECUTE ON FUNCTION public.is_admin_or_editor() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_or_editor() TO service_role;

-- Step 3: Apply the Sovereign Admin policy
-- This allows Admins/Editors to see ALL rows, regardless of row role.
DROP POLICY IF EXISTS "Unified Dashboard Access" ON user_profiles;

CREATE POLICY "Unified Dashboard Access" ON user_profiles
    FOR SELECT
    TO authenticated
    USING (
        id = auth.uid() -- Everyone can see themselves
        OR
        public.is_admin_or_editor() -- Admins/Editors see EVERYTHING
    );

-- Verify
SELECT '✅ Admin Visibility Restored - Responders should now be visible' as status;
