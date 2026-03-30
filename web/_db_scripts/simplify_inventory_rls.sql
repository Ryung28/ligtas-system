-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - SIMPLIFY INVENTORY RLS
-- ============================================================================
-- PURPOSE: Simplify RLS policies to give admins full access
-- ISSUE: Current policies are too strict and blocking admin access
-- ============================================================================

-- Step 1: Drop all existing SELECT policies on inventory
DROP POLICY IF EXISTS "warehouse_filtered_select" ON inventory;
DROP POLICY IF EXISTS "Allow public full access" ON inventory;

-- Step 2: Create a simple, clear SELECT policy
CREATE POLICY "inventory_select_policy" ON inventory
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL
        AND (
            -- Admins see everything
            (SELECT role FROM user_profiles WHERE id = auth.uid()) = 'admin'
            OR
            -- Editors see their warehouse only
            (
                (SELECT role FROM user_profiles WHERE id = auth.uid()) = 'editor'
                AND (
                    (SELECT assigned_warehouse FROM user_profiles WHERE id = auth.uid()) IS NULL
                    OR storage_location = (SELECT assigned_warehouse FROM user_profiles WHERE id = auth.uid())
                )
            )
            OR
            -- Responders see their warehouse only
            (
                (SELECT role FROM user_profiles WHERE id = auth.uid()) = 'responder'
                AND (
                    (SELECT assigned_warehouse FROM user_profiles WHERE id = auth.uid()) IS NULL
                    OR storage_location = (SELECT assigned_warehouse FROM user_profiles WHERE id = auth.uid())
                )
            )
        )
    );

-- Step 3: Verify the policy was created
SELECT 
    'POLICY CREATED' as status,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'inventory' AND cmd = 'SELECT';

-- Step 4: Test if admin can see inventory
SELECT 
    'TEST QUERY' as status,
    COUNT(*) as total_items
FROM inventory
WHERE deleted_at IS NULL;
