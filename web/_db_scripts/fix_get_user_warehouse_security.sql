-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX GET_USER_WAREHOUSE SECURITY CONTEXT
-- ============================================================================
-- ISSUE: Function is SECURITY DEFINER, causing auth.uid() to return NULL
-- FIX: Change to SECURITY INVOKER to use caller's authentication context
-- ============================================================================

-- Drop and recreate with correct security context
DROP FUNCTION IF EXISTS get_user_warehouse();

CREATE OR REPLACE FUNCTION get_user_warehouse()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY INVOKER  -- Use caller's auth context, not function owner's
STABLE
AS $$
DECLARE
    v_warehouse TEXT;
BEGIN
    SELECT assigned_warehouse INTO v_warehouse
    FROM user_profiles
    WHERE id = auth.uid();
    
    RETURN v_warehouse;
END;
$$;

-- Verify the fix
SELECT proname, prosecdef FROM pg_proc WHERE proname = 'get_user_warehouse';

SELECT '✅ Changed get_user_warehouse to SECURITY INVOKER' as status;
