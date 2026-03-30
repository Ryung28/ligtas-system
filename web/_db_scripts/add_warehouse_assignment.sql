-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - WAREHOUSE ASSIGNMENT & ISOLATION
-- ============================================================================
-- PURPOSE: Implement single-warehouse assignment per user
-- APPROACH: Option B - Filter by warehouse at time of borrow (accountability)
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 1: Add assigned_warehouse to user_profiles
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS assigned_warehouse TEXT;

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_assigned_warehouse 
ON user_profiles(assigned_warehouse);

COMMENT ON COLUMN user_profiles.assigned_warehouse IS 
'Warehouse assignment for equipment managers. NULL = admin (full access), TEXT = specific warehouse';

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 2: Add borrowed_from_warehouse to borrow_logs (accountability)
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE borrow_logs 
ADD COLUMN IF NOT EXISTS borrowed_from_warehouse TEXT;

-- Index for filtering
CREATE INDEX IF NOT EXISTS idx_borrow_logs_borrowed_from_warehouse 
ON borrow_logs(borrowed_from_warehouse);

COMMENT ON COLUMN borrow_logs.borrowed_from_warehouse IS 
'Warehouse location at time of borrow. Used for manager accountability and log filtering.';

-- Backfill existing logs with current inventory location
UPDATE borrow_logs bl
SET borrowed_from_warehouse = (
    SELECT storage_location 
    FROM inventory i 
    WHERE i.id = bl.inventory_id
)
WHERE borrowed_from_warehouse IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 3: Create helper function for user warehouse (performance)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_user_warehouse()
RETURNS TEXT AS $$
DECLARE
    v_warehouse TEXT;
BEGIN
    SELECT assigned_warehouse INTO v_warehouse
    FROM user_profiles
    WHERE id = auth.uid();
    
    RETURN v_warehouse;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION get_user_warehouse() TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 4: Update inventory RLS policies (warehouse isolation)
-- ─────────────────────────────────────────────────────────────────────────────

-- Drop existing policies
DROP POLICY IF EXISTS "Allow authenticated read access" ON inventory;
DROP POLICY IF EXISTS "Allow authenticated write access" ON inventory;

-- New SELECT policy: Admins see all, managers see only their warehouse
CREATE POLICY "warehouse_inventory_select" ON inventory
FOR SELECT TO authenticated
USING (
    get_user_warehouse() IS NULL  -- Admin: full access
    OR storage_location = get_user_warehouse()  -- Manager: only their warehouse
);

-- New INSERT policy: Admins can insert anywhere, managers only their warehouse
CREATE POLICY "warehouse_inventory_insert" ON inventory
FOR INSERT TO authenticated
WITH CHECK (
    get_user_warehouse() IS NULL  -- Admin: full access
    OR storage_location = get_user_warehouse()  -- Manager: only their warehouse
);

-- New UPDATE policy: Admins can update all, managers only their warehouse
CREATE POLICY "warehouse_inventory_update" ON inventory
FOR UPDATE TO authenticated
USING (
    get_user_warehouse() IS NULL
    OR storage_location = get_user_warehouse()
)
WITH CHECK (
    get_user_warehouse() IS NULL
    OR storage_location = get_user_warehouse()
);

-- New DELETE policy: Admins only
CREATE POLICY "warehouse_inventory_delete" ON inventory
FOR DELETE TO authenticated
USING (get_user_warehouse() IS NULL);

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 5: Update borrow_logs RLS policies (accountability-based filtering)
-- ─────────────────────────────────────────────────────────────────────────────

-- Drop existing policies
DROP POLICY IF EXISTS "Allow authenticated read access" ON borrow_logs;
DROP POLICY IF EXISTS "Allow authenticated write access" ON borrow_logs;

-- New SELECT policy: Filter by warehouse at time of borrow
CREATE POLICY "warehouse_logs_select" ON borrow_logs
FOR SELECT TO authenticated
USING (
    get_user_warehouse() IS NULL  -- Admin: see all logs
    OR borrowed_from_warehouse = get_user_warehouse()  -- Manager: only their warehouse logs
);

-- New INSERT policy: Auto-populate borrowed_from_warehouse
CREATE POLICY "warehouse_logs_insert" ON borrow_logs
FOR INSERT TO authenticated
WITH CHECK (
    get_user_warehouse() IS NULL  -- Admin: can create logs for any warehouse
    OR borrowed_from_warehouse = get_user_warehouse()  -- Manager: only their warehouse
);

-- New UPDATE policy: Can only update logs from their warehouse
CREATE POLICY "warehouse_logs_update" ON borrow_logs
FOR UPDATE TO authenticated
USING (
    get_user_warehouse() IS NULL
    OR borrowed_from_warehouse = get_user_warehouse()
)
WITH CHECK (
    get_user_warehouse() IS NULL
    OR borrowed_from_warehouse = get_user_warehouse()
);

-- New DELETE policy: Admins only
CREATE POLICY "warehouse_logs_delete" ON borrow_logs
FOR DELETE TO authenticated
USING (get_user_warehouse() IS NULL);

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 6: Update borrow transaction to auto-populate warehouse
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION auto_populate_borrowed_warehouse()
RETURNS TRIGGER AS $$
BEGIN
    -- Auto-populate borrowed_from_warehouse from inventory.storage_location
    IF NEW.borrowed_from_warehouse IS NULL THEN
        SELECT storage_location INTO NEW.borrowed_from_warehouse
        FROM inventory
        WHERE id = NEW.inventory_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_populate_borrowed_warehouse ON borrow_logs;

CREATE TRIGGER trg_auto_populate_borrowed_warehouse
BEFORE INSERT ON borrow_logs
FOR EACH ROW
EXECUTE FUNCTION auto_populate_borrowed_warehouse();

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 7: Backfill existing users (admins = NULL, others = NULL until assigned)
-- ─────────────────────────────────────────────────────────────────────────────

-- Set all admins to NULL (full access)
UPDATE user_profiles
SET assigned_warehouse = NULL
WHERE role = 'admin';

-- Leave non-admins as NULL (no access until admin assigns them)
-- This is intentional - forces explicit assignment

SELECT 'Warehouse Assignment System: ENABLED' as status;
SELECT 'Admins have full access. Non-admins need warehouse assignment.' as note;
