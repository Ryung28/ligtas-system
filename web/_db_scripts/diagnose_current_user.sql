-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - DIAGNOSE CURRENT USER
-- ============================================================================
-- PURPOSE: Find out which account you're logged in as and if it has a profile
-- INSTRUCTIONS: Run this while logged into the web dashboard
-- ============================================================================

-- Check 1: Who am I in the auth system?
SELECT 
    'AUTH IDENTITY' as check_type,
    auth.uid() as my_user_id,
    auth.role() as my_auth_role,
    (auth.jwt() ->> 'email') as my_email;

-- Check 2: Do I have a profile?
SELECT 
    'PROFILE CHECK' as check_type,
    id,
    email,
    full_name,
    role,
    status,
    assigned_warehouse
FROM user_profiles
WHERE id = auth.uid();

-- Check 3: What does is_admin() return for me?
SELECT 
    'ADMIN CHECK' as check_type,
    public.is_admin() as am_i_admin,
    public.is_editor() as am_i_editor,
    public.get_my_role() as my_role,
    public.get_user_warehouse() as my_warehouse;

-- Check 4: Can I see any borrow logs?
SELECT 
    'LOGS VISIBILITY' as check_type,
    COUNT(*) as logs_i_can_see
FROM borrow_logs;

-- ============================================================================
-- DIAGNOSIS RESULTS INTERPRETATION
-- ============================================================================
-- 
-- If Check 2 shows "No rows returned":
--   → You have NO profile in user_profiles table
--   → This is the "Ghost Admin" issue
--   → FIX: Run QUICK_FIX_admin_profile.sql
--
-- If Check 3 shows am_i_admin = FALSE:
--   → Your profile exists but role is not 'admin'
--   → FIX: Update your role manually or ask another admin
--
-- If Check 4 shows logs_i_can_see = 0:
--   → Either no logs exist, or RLS is blocking you
--   → If you're admin and logs exist, run QUICK_FIX_admin_profile.sql
--
-- ============================================================================

-- QUICK FIX (if Check 2 returned no rows):
-- Run this to create your admin profile immediately:
/*
INSERT INTO public.user_profiles (id, full_name, email, role, status, assigned_warehouse)
SELECT 
    id,
    COALESCE(raw_user_meta_data->>'full_name', email),
    email,
    'admin',
    'active',
    NULL
FROM auth.users
WHERE id = auth.uid()
ON CONFLICT (id) DO UPDATE
SET role = 'admin', status = 'active', assigned_warehouse = NULL;
*/
