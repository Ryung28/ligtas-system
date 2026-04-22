-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - QUICK FIX FOR MISSING ADMIN PROFILE
-- ============================================================================
-- INSTRUCTIONS: 
-- 1. Copy this entire script
-- 2. Go to Supabase Dashboard > SQL Editor
-- 3. Paste and run it
-- 4. Refresh your web dashboard (hard refresh: Ctrl+Shift+R)
-- ============================================================================

-- Create profiles for ALL auth users who don't have one
-- This fixes the "ghost admin" issue immediately
INSERT INTO public.user_profiles (
    id, 
    full_name, 
    email, 
    role, 
    status, 
    assigned_warehouse
)
SELECT 
    au.id,
    COALESCE(
        au.raw_user_meta_data->>'full_name',
        au.raw_user_meta_data->>'name',
        SPLIT_PART(au.email, '@', 1)
    ) as full_name,
    au.email,
    'admin' as role,
    'active' as status,
    NULL as assigned_warehouse
FROM auth.users au
WHERE NOT EXISTS (
    SELECT 1 FROM public.user_profiles up WHERE up.id = au.id
)
ON CONFLICT (id) DO UPDATE
SET 
    role = 'admin',
    status = 'active',
    assigned_warehouse = NULL,
    updated_at = NOW();

-- Verify the fix worked
SELECT 
    'FIXED ✓' as status,
    up.email,
    up.role,
    up.status,
    CASE 
        WHEN up.assigned_warehouse IS NULL THEN 'Full Access (All Warehouses)'
        ELSE up.assigned_warehouse
    END as warehouse_access
FROM public.user_profiles up
WHERE up.id = auth.uid();

-- Check if you can now see borrow logs
SELECT 
    'LOGS VISIBLE ✓' as status,
    COUNT(*) as total_logs_you_can_see
FROM borrow_logs;
