-- ================================================
-- LIGTAS SYSTEM - PENDING ACCESS MIGRATION
-- ================================================
-- Senior Dev: This script migrates from "Pre-Approval Whitelist" to "Post-Registration Approval"
-- This allows mobile users to sign up freely, then await admin approval
-- Run this in your Supabase SQL Editor AFTER the main auth setup

-- ================================================
-- 1. ADD USER STATUS COLUMN
-- ================================================
-- Add status enum type
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('pending', 'active', 'suspended');
    END IF;
END $$;

-- Add status column to user_profiles (default: pending for new signups)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS status user_status DEFAULT 'pending' NOT NULL;

-- Add approval tracking metadata
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES auth.users(id);

-- ================================================
-- 2. UPDATE EXISTING USERS TO "ACTIVE"
-- ================================================
-- All users who are already in the system should be marked as active
UPDATE user_profiles 
SET status = 'active', 
    approved_at = NOW()
WHERE status = 'pending';

-- ================================================
-- 3. UPDATE ROW LEVEL SECURITY POLICIES
-- ================================================

-- IMPORTANT: Pending users can ONLY read their own profile
-- They cannot see inventory, logs, or other users until approved

-- Drop and recreate the inventory read policy
DROP POLICY IF EXISTS "Allow authenticated read access" ON inventory;
CREATE POLICY "Allow authenticated read access"
ON inventory FOR SELECT
TO authenticated
USING (
    -- Only active users can read inventory
    EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid() AND status = 'active'
    )
);

-- Ensure the admin write policy still exists
DROP POLICY IF EXISTS "Allow admin write access" ON inventory;
CREATE POLICY "Allow admin write access"
ON inventory FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid() AND role = 'admin' AND status = 'active'
    )
);

-- Update borrow_logs policies (if they exist)
-- Pending users cannot see or create borrow logs
DROP POLICY IF EXISTS "Allow authenticated read borrow logs" ON borrow_logs;
CREATE POLICY "Allow authenticated read borrow logs"
ON borrow_logs FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid() AND status = 'active'
    )
);

DROP POLICY IF EXISTS "Allow authenticated create borrow logs" ON borrow_logs;
CREATE POLICY "Allow authenticated create borrow logs"
ON borrow_logs FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid() AND status = 'active'
    )
);

-- ================================================
-- 4. CREATE ACCESS REQUEST NOTIFICATION SYSTEM
-- ================================================
-- This table logs whenever a user requests access (optional, for audit)
CREATE TABLE IF NOT EXISTS access_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT,
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES auth.users,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected'))
);

ALTER TABLE access_requests ENABLE ROW LEVEL SECURITY;

-- Only admins can view access requests
DROP POLICY IF EXISTS "Admins can view access requests" ON access_requests;
CREATE POLICY "Admins can view access requests"
ON access_requests FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid() AND role = 'admin' AND status = 'active'
    )
);

-- ================================================
-- 5. CREATE FUNCTION TO LOG ACCESS REQUESTS
-- ================================================
CREATE OR REPLACE FUNCTION public.log_access_request()
RETURNS TRIGGER AS $$
BEGIN
    -- When a new user profile is created, log the access request
    IF NEW.status = 'pending' THEN
        INSERT INTO access_requests (user_id, email, full_name, status)
        VALUES (NEW.id, NEW.email, NEW.full_name, 'pending')
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to log access requests
DROP TRIGGER IF EXISTS on_user_profile_created ON user_profiles;
CREATE TRIGGER on_user_profile_created
    AFTER INSERT ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.log_access_request();

-- ================================================
-- 6. UPDATE THE AUTO-PROFILE CREATION FUNCTION
-- ================================================
-- IMPORTANT: New signups default to 'pending' status
-- This was already handled by the DEFAULT value in the ALTER TABLE above

-- ================================================
-- 7. ADD HELPER FUNCTION FOR ADMIN APPROVAL
-- ================================================
CREATE OR REPLACE FUNCTION public.approve_user(target_user_id UUID, target_role TEXT DEFAULT 'viewer')
RETURNS BOOLEAN AS $$
DECLARE
    is_admin BOOLEAN;
BEGIN
    -- Check if the calling user is an admin
    SELECT (role = 'admin' AND status = 'active')
    INTO is_admin
    FROM user_profiles
    WHERE id = auth.uid();

    IF NOT is_admin THEN
        RAISE EXCEPTION 'Unauthorized: Only active admins can approve users';
    END IF;

    -- Validate role
    IF target_role NOT IN ('admin', 'editor', 'viewer') THEN
        RAISE EXCEPTION 'Invalid role: Must be admin, editor, or viewer';
    END IF;

    -- Update the user profile
    UPDATE user_profiles
    SET 
        status = 'active',
        role = target_role,
        approved_at = NOW(),
        approved_by = auth.uid()
    WHERE id = target_user_id;

    -- Update the access request
    UPDATE access_requests
    SET 
        status = 'approved',
        approved_at = NOW(),
        approved_by = auth.uid()
    WHERE user_id = target_user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================
-- 8. ADD HELPER FUNCTION FOR ADMIN REJECTION
-- ================================================
CREATE OR REPLACE FUNCTION public.reject_user(target_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    is_admin BOOLEAN;
BEGIN
    -- Check if the calling user is an admin
    SELECT (role = 'admin' AND status = 'active')
    INTO is_admin
    FROM user_profiles
    WHERE id = auth.uid();

    IF NOT is_admin THEN
        RAISE EXCEPTION 'Unauthorized: Only active admins can reject users';
    END IF;

    -- Update the user to suspended
    UPDATE user_profiles
    SET 
        status = 'suspended',
        approved_at = NOW(),
        approved_by = auth.uid()
    WHERE id = target_user_id;

    -- Update the access request
    UPDATE access_requests
    SET 
        status = 'rejected',
        approved_at = NOW(),
        approved_by = auth.uid()
    WHERE user_id = target_user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================
-- VERIFICATION QUERIES
-- ================================================

-- Check the updated user_profiles schema
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
ORDER BY ordinal_position;

-- View all users with their status
SELECT id, email, full_name, role, status, approved_at 
FROM user_profiles 
ORDER BY created_at DESC;

-- View pending access requests
SELECT ar.*, up.email, up.full_name 
FROM access_requests ar
JOIN user_profiles up ON ar.user_id = up.id
WHERE ar.status = 'pending'
ORDER BY ar.requested_at DESC;

-- ================================================
-- MIGRATION COMPLETE!
-- ================================================
-- Next Steps:
-- 1. Run this script in Supabase SQL Editor
-- 2. Update the web dashboard to show "Access Requests" tab
-- 3. Update the mobile app to handle "pending" status gracefully
-- 4. Test the approval workflow
--
-- Key Changes:
-- ✅ New users default to "pending" status
-- ✅ Pending users can only view their own profile
-- ✅ Admins can approve/reject users via web dashboard
-- ✅ All existing users are marked as "active"
-- ✅ Audit trail via access_requests table
-- ================================================
