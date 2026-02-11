-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - ROBUST DATABASE SETUP (FIXED)
-- ============================================================================
-- Run this script in Supabase SQL Editor.
-- It will safely update existing tables or create new ones if missing.
-- ============================================================================

-- 1. ENABLE UUID EXTENSION
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PART A: INVENTORY SYSTEM (Safe Update)
-- ============================================================================

-- 2. CREATE INVENTORY TABLE (If not exists)
CREATE TABLE IF NOT EXISTS inventory (
    id BIGSERIAL PRIMARY KEY,
    item_name TEXT NOT NULL,
    category TEXT NOT NULL,
    stock_available INTEGER NOT NULL DEFAULT 0,
    status TEXT DEFAULT 'Good',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ADD MISSING COLUMNS (Fix for "column does not exist" error)
DO $$ 
BEGIN 
    -- Add stock_total if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'stock_total') THEN 
        ALTER TABLE inventory ADD COLUMN stock_total INTEGER NOT NULL DEFAULT 0;
        -- Sync total with available for existing records
        UPDATE inventory SET stock_total = stock_available;
    END IF;
END $$;

-- 4. INVENTORY INDEXES
CREATE INDEX IF NOT EXISTS idx_inventory_item_name ON inventory(item_name);
CREATE INDEX IF NOT EXISTS idx_inventory_category ON inventory(category);
CREATE INDEX IF NOT EXISTS idx_inventory_stock ON inventory(stock_available);

-- 5. INSERT SAMPLE DATA (Upsert to avoid duplicates)
INSERT INTO inventory (item_name, category, stock_total, stock_available, status) VALUES
  ('Orange Rescue Boat', 'Vehicles', 2, 2, 'Good'),
  ('Life Vest (Adult)', 'Rescue', 50, 50, 'Good'),
  ('Life Vest (Child)', 'Rescue', 30, 30, 'Good'),
  ('Megaphone', 'Comms', 10, 10, 'Good'),
  ('Two-Way Radio', 'Comms', 20, 20, 'Good'),
  ('Spine Board', 'Medical', 5, 5, 'Good'),
  ('First Aid Kit (Trauma)', 'Medical', 15, 15, 'Good'),
  ('Flashlight (Rechargeable)', 'Rescue', 25, 25, 'Good'),
  ('Hard Hat (Safety)', 'Rescue', 40, 40, 'Good'),
  ('Chainsaw', 'Rescue', 3, 3, 'Serviceable')
ON CONFLICT DO NOTHING;
-- Note: If you want to force reset data, run: TRUNCATE TABLE inventory CASCADE; before this script.

-- ============================================================================
-- PART B: BORROWING & LOGS SYSTEM
-- ============================================================================

-- 6. CREATE BORROW LOGS TABLE
CREATE TABLE IF NOT EXISTS borrow_logs (
    id BIGSERIAL PRIMARY KEY,
    inventory_id BIGINT REFERENCES inventory(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    borrower_name TEXT NOT NULL,
    borrower_contact TEXT,
    borrower_organization TEXT,
    purpose TEXT,
    transaction_type TEXT NOT NULL, -- 'borrow' or 'return'
    borrow_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expected_return_date TIMESTAMPTZ,
    actual_return_date TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'borrowed',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. LOGS INDEXES
CREATE INDEX IF NOT EXISTS idx_borrow_logs_inventory_id ON borrow_logs(inventory_id);
CREATE INDEX IF NOT EXISTS idx_borrow_logs_borrow_date ON borrow_logs(borrow_date DESC);
CREATE INDEX IF NOT EXISTS idx_borrow_logs_status ON borrow_logs(status);

-- ============================================================================
-- PART C: AUTOMATION & TRIGGERS
-- ============================================================================

-- 8. FUNCTION: update_updated_at_column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_inventory_updated_at ON inventory;
CREATE TRIGGER update_inventory_updated_at 
    BEFORE UPDATE ON inventory 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 9. FUNCTION: update_inventory_stock
CREATE OR REPLACE FUNCTION update_inventory_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_type = 'borrow' THEN
        -- Decrease stock
        UPDATE inventory
        SET stock_available = stock_available - NEW.quantity
        WHERE id = NEW.inventory_id;
    ELSIF NEW.transaction_type = 'return' THEN
        -- Increase stock
        UPDATE inventory
        SET stock_available = stock_available + NEW.quantity
        WHERE id = NEW.inventory_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS auto_update_inventory_stock ON borrow_logs;
CREATE TRIGGER auto_update_inventory_stock
    AFTER INSERT ON borrow_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_stock();

-- ============================================================================
-- PART D: SECURITY (RLS)
-- ============================================================================

-- 10. ENABLE RLS & POLICIES
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE borrow_logs ENABLE ROW LEVEL SECURITY;

-- Reset policies to avoid conflicts
DROP POLICY IF EXISTS "Public read access" ON inventory;
DROP POLICY IF EXISTS "Authenticated write access" ON inventory;
DROP POLICY IF EXISTS "Allow public full access" ON inventory;

-- Allow FULL ACCESS to inventory for this demo (Select, Insert, Update, Delete)
CREATE POLICY "Allow public full access" ON inventory FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public read access logs" ON borrow_logs;
DROP POLICY IF EXISTS "Authenticated write access logs" ON borrow_logs;
DROP POLICY IF EXISTS "Allow public full access" ON borrow_logs;

-- Allow FULL ACCESS to logs for this demo
CREATE POLICY "Allow public full access" ON borrow_logs FOR ALL USING (true) WITH CHECK (true);

SELECT 'Database Permissions Updated: Write Access Enabled' as status;
