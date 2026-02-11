-- ================================================
-- CDRRMO AUTHENTICATION SETUP
-- ================================================
-- This script sets up user authentication for the CDRRMO Inventory System
-- Run this in your Supabase SQL Editor after running supabase_setup.sql

-- ================================================
-- 1. CREATE DEMO USER
-- ================================================
-- Note: In Supabase, users are managed in the auth.users table
-- You can create users through the Supabase dashboard or using the auth API

-- For testing, use the Supabase Authentication console to create a user with:
-- Email: admin@cdrrmo.gov.ph
-- Password: cdrrmo2024

-- Or use this SQL to manually insert (password will be hashed by Supabase):
-- This is typically done through the Supabase UI or Auth API, not raw SQL

-- ================================================
-- 2. CREATE USER PROFILES TABLE (Optional but recommended)
-- ================================================
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'viewer' CHECK (role IN ('admin', 'editor', 'viewer')),
    department TEXT DEFAULT 'CDRRMO',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own profile
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
CREATE POLICY "Users can view own profile"
ON user_profiles FOR SELECT
USING (auth.uid() = id);

-- Policy: Users can update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
USING (auth.uid() = id);

-- Policy: Admins can view all profiles (Required for Access Control page)
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
CREATE POLICY "Admins can view all profiles"
ON user_profiles FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- ================================================
-- 3. CREATE FUNCTION TO AUTO-CREATE PROFILE ON SIGNUP
-- ================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ================================================
-- 4. UPDATE INVENTORY TABLE RLS FOR AUTHENTICATED USERS
-- ================================================
-- Drop existing public policy
DROP POLICY IF EXISTS "Enable read access for all users" ON inventory;

-- Allow authenticated users to read inventory
DROP POLICY IF EXISTS "Allow authenticated read access" ON inventory;
CREATE POLICY "Allow authenticated read access"
ON inventory FOR SELECT
TO authenticated
USING (true);

-- Allow admins to insert/update/delete
DROP POLICY IF EXISTS "Allow admin write access" ON inventory;
CREATE POLICY "Allow admin write access"
ON inventory FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid() AND role = 'admin'
    )
);

-- ================================================
-- 5. CREATE ACTIVITY LOG TABLE (Optional - for audit trail)
-- ================================================
CREATE TABLE IF NOT EXISTS activity_log (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id BIGINT,
    changes JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- Only authenticated users can view logs
DROP POLICY IF EXISTS "Authenticated users can view logs" ON activity_log;
CREATE POLICY "Authenticated users can view logs"
ON activity_log FOR SELECT
TO authenticated
USING (true);

-- ================================================
-- 6. VERIFICATION QUERIES
-- ================================================
-- Check if user_profiles table exists
SELECT * FROM user_profiles LIMIT 5;

-- Check current authenticated user (run this when logged in)
SELECT auth.uid(), auth.email();

-- Check RLS policies
SELECT schemaname, tablename, policyname, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('inventory', 'user_profiles', 'activity_log');

-- ================================================
-- SETUP COMPLETE!
-- ================================================
-- Next steps:
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Add User" → "Create new user"
-- 3. Enter:
--    Email: admin@cdrrmo.gov.ph
--    Password: cdrrmo2024
--    Auto Confirm User: YES
-- 4. The user profile will be automatically created via the trigger
-- 5. You can now log in with these credentials!
-- 
-- IMPORTANT NOTES:
-- - For production, use stronger passwords and enable email confirmation
-- - Consider adding two-factor authentication
-- - Set up password policies in Supabase Auth settings
-- - Regularly audit the activity_log table
-- ================================================
