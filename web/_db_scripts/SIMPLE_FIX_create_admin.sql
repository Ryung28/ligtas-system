-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - SIMPLE ADMIN PROFILE FIX
-- ============================================================================
-- INSTRUCTIONS:
-- 1. Replace 'YOUR_EMAIL_HERE' with your actual login email (2 places)
-- 2. Copy this entire script
-- 3. Paste into Supabase SQL Editor
-- 4. Click RUN
-- 5. Hard refresh your web dashboard (Ctrl+Shift+R)
-- ============================================================================

-- Step 1: Find your auth ID
DO $$
DECLARE
    user_id UUID;
    user_email TEXT := 'YOUR_EMAIL_HERE'; -- ← CHANGE THIS
BEGIN
    -- Get your ID from auth.users
    SELECT id INTO user_id
    FROM auth.users
    WHERE email = user_email;

    -- Check if we found the user
    IF user_id IS NULL THEN
        RAISE EXCEPTION 'No user found with email: %. Check your email and try again.', user_email;
    END IF;

    -- Show what we found
    RAISE NOTICE 'Found user ID: %', user_id;

    -- Step 2: Create your admin profile
    INSERT INTO public.user_profiles (
        id,
        full_name,
        email,
        role,
        status,
        assigned_warehouse
    )
    VALUES (
        user_id,
        'System Administrator',
        user_email,
        'admin',
        'active',
        NULL  -- NULL = full access to all warehouses
    )
    ON CONFLICT (id) DO UPDATE
    SET 
        role = 'admin',
        status = 'active',
        assigned_warehouse = NULL,
        updated_at = NOW();

    RAISE NOTICE 'Admin profile created successfully!';
END $$;

-- Step 3: Verify the fix
SELECT 
    '✓ VERIFICATION' as status,
    id,
    email,
    role,
    status,
    CASE 
        WHEN assigned_warehouse IS NULL THEN 'Full Access (All Warehouses)'
        ELSE assigned_warehouse
    END as warehouse_access
FROM public.user_profiles
WHERE email = 'YOUR_EMAIL_HERE'; -- ← CHANGE THIS

-- Step 4: Check if you can see logs now
SELECT 
    '✓ LOGS CHECK' as status,
    COUNT(*) as total_logs_visible
FROM borrow_logs;

-- ============================================================================
-- EXPECTED OUTPUT:
-- - Notice: "Admin profile created successfully!"
-- - Verification row showing: role = 'admin', status = 'active'
-- - Logs check showing: total_logs_visible = 10 (or however many exist)
-- ============================================================================
