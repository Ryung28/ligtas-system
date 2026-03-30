-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - FIX MISSING ADMIN PROFILE
-- ============================================================================
-- PURPOSE: Create admin profile for auth users who don't have one
-- ROOT CAUSE: RLS policies check user_profiles for role, but some auth.users
--             don't have a corresponding profile row
-- ============================================================================

-- Step 1: Find all auth users without profiles
SELECT 
    'ORPHANED AUTH USERS' as status,
    au.id,
    au.email,
    au.created_at
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id
WHERE up.id IS NULL;

-- Step 2: Create profiles for all orphaned auth users
-- (This will make them admins by default - adjust role as needed)
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
    'admin' as role,  -- Change to 'editor' or 'responder' if needed
    'active' as status,
    NULL as assigned_warehouse  -- NULL = full access for admins
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id
WHERE up.id IS NULL
ON CONFLICT (id) DO UPDATE
SET 
    role = EXCLUDED.role,
    status = EXCLUDED.status,
    assigned_warehouse = EXCLUDED.assigned_warehouse,
    updated_at = NOW();

-- Step 3: Verify the fix
SELECT 
    'VERIFICATION' as status,
    COUNT(*) as total_auth_users,
    COUNT(up.id) as users_with_profiles,
    COUNT(*) - COUNT(up.id) as orphaned_users
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id;

-- Step 4: Show all admin users
SELECT 
    'ADMIN USERS' as status,
    up.id,
    up.email,
    up.full_name,
    up.role,
    up.status,
    up.assigned_warehouse
FROM public.user_profiles up
WHERE up.role = 'admin'
ORDER BY up.created_at DESC;
