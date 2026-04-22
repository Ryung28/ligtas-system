-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX HELPER FUNCTIONS SEARCH PATH
-- ============================================================================
-- ISSUE: Functions missing SET search_path causing schema resolution failures
-- FIX: Add explicit search_path to ensure functions find tables correctly
-- ============================================================================

-- Fix get_user_warehouse with explicit search path
CREATE OR REPLACE FUNCTION get_user_warehouse()
RETURNS TEXT AS $$
DECLARE
    v_warehouse TEXT;
BEGIN
    SELECT assigned_warehouse INTO v_warehouse
    FROM public.user_profiles
    WHERE id = auth.uid();
    RETURN v_warehouse;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER STABLE SET search_path = public, pg_temp;

-- Fix get_my_role with explicit search path
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
DECLARE
    v_role TEXT;
BEGIN
    SELECT role INTO v_role
    FROM public.user_profiles
    WHERE id = auth.uid();
    RETURN v_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = public, pg_temp;

-- Verify the functions
SELECT 
    proname,
    prosecdef,
    proconfig
FROM pg_proc 
WHERE proname IN ('get_user_warehouse', 'get_my_role');

SELECT '✅ Fixed helper functions with explicit search_path' as status;
