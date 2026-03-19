-- ============================================================================
-- LIGTAS SYSTEM - RLS RECURSION FIX & UNLOCK
-- ============================================================================
-- 🛡️ Step 1: Secure Role Fetcher (Security Definer)
-- This function runs with the privileges of the 'postgres' user, 
-- allowing it to read the user_profiles table even when RLS is active.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT AS $$
DECLARE
  v_role text;
BEGIN
  -- We query the public table specifically
  SELECT role INTO v_role 
  FROM public.user_profiles 
  WHERE id = auth.uid();
  
  RETURN v_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 🛡️ Step 2: Unified Access Policy Replacement
-- Consolidated policy to prevent "RLS Collision" and recursion loops.
-- ============================================================================

-- Drop old, potentially conflicting policies
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Universal Profile Visibility" ON user_profiles;
DROP POLICY IF EXISTS "Unified Dashboard Access" ON user_profiles;

CREATE POLICY "Unified Dashboard Access"
ON user_profiles FOR SELECT
TO authenticated
USING (
  -- Permissive condition 1: Owner access
  id = auth.uid() 
  OR 
  -- Permissive condition 2: Staff access (via SECURITY DEFINER function)
  public.get_my_role() IN ('admin', 'editor')
);

-- 🛡️ Step 3: Emergency Unlock Sequence
-- Force the current administrator to 'active' status to ensure bypass of 
-- any status-locking logic in the dashboard.
-- ============================================================================

UPDATE user_profiles
SET status = 'active'
WHERE id = auth.uid();

-- Audit Log
SELECT 'RLS RECURSION FIXED: Unified Dashboard Access active' as result;
