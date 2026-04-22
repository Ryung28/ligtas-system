-- ============================================================================
-- LIGTAS SYSTEM - DATABASE INTEGRITY FIX
-- ============================================================================
-- 1. PREVENT NEGATIVE STOCK
-- This ensures stock can never go below 0, preventing concurrency bugs.
ALTER TABLE inventory ADD CONSTRAINT check_stock_positive CHECK (stock_available >= 0);

-- 2. ENSURE AUTOMATION TRIGGERS EXIST
-- This function handles the math atomically inside the database.
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

-- Re-create the trigger to be sure
DROP TRIGGER IF EXISTS auto_update_inventory_stock ON borrow_logs;
CREATE TRIGGER auto_update_inventory_stock
    AFTER INSERT ON borrow_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_stock();

-- 3. CONFIRMATION
SELECT 'Database Integrity Secured: Negative Stock Prevented & Auto-Calculation Active' as status;
