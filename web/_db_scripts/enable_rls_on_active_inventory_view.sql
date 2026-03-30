-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - ENABLE RLS ON ACTIVE_INVENTORY VIEW
-- ============================================================================
-- ISSUE: active_inventory view has no RLS policies, bypassing warehouse filtering
-- FIX: Enable RLS on view and add warehouse filtering policy
-- ============================================================================

-- Enable RLS on the view
ALTER TABLE active_inventory ENABLE ROW LEVEL SECURITY;

-- Add warehouse filtering policy to the view
CREATE POLICY "warehouse_filtered_view_select" ON active_inventory
    FOR SELECT
    TO authenticated
    USING (
        (
            SELECT assigned_warehouse 
            FROM user_profiles 
            WHERE id = auth.uid()
        ) IS NULL 
        OR storage_location = (
            SELECT assigned_warehouse 
            FROM user_profiles 
            WHERE id = auth.uid()
        )
    );

-- Verify the policy was created
SELECT 
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'active_inventory';

SELECT '✅ RLS enabled on active_inventory view with warehouse filtering' as status;
