-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - AUTO-CREATE USER PROFILE TRIGGER
-- ============================================================================
-- PURPOSE: Automatically create user_profiles row when new auth.users created
-- PREVENTS: "Ghost admin" issue where auth exists but profile doesn't
-- ============================================================================

-- Step 1: Create the trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Create a profile with 'pending' status for new users
    -- Admins will need to approve and assign role/warehouse
    INSERT INTO public.user_profiles (
        id,
        email,
        full_name,
        role,
        status,
        assigned_warehouse
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            SPLIT_PART(NEW.email, '@', 1)
        ),
        'responder',  -- Default role
        'pending',    -- Requires admin approval
        NULL          -- No warehouse until approved
    )
    ON CONFLICT (id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Step 2: Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Step 3: Create the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Step 4: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO postgres, service_role;

-- Verification: Check if trigger exists
SELECT 
    'TRIGGER STATUS' as status,
    tgname as trigger_name,
    tgenabled as enabled
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';
