-- ================================================
-- LIGTAS BORROW/RETURN LOGS TABLE
-- ================================================
-- This table tracks all borrowing and returning transactions

CREATE TABLE IF NOT EXISTS borrow_logs (
    id BIGSERIAL PRIMARY KEY,
    
    -- Item Information
    inventory_id BIGINT REFERENCES inventory(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    
    -- Borrower Information
    borrower_name TEXT NOT NULL,
    borrower_contact TEXT,
    borrower_organization TEXT,
    purpose TEXT,
    
    -- Transaction Details
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('borrow', 'return')),
    borrow_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expected_return_date TIMESTAMPTZ,
    actual_return_date TIMESTAMPTZ,
    
    -- Status
    status TEXT NOT NULL DEFAULT 'borrowed' CHECK (status IN ('borrowed', 'returned', 'overdue')),
    
    -- Additional Info
    notes TEXT,
    processed_by TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE borrow_logs ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all logs
CREATE POLICY "Allow authenticated read access"
ON borrow_logs FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to insert/update logs
CREATE POLICY "Allow authenticated write access"
ON borrow_logs FOR ALL
TO authenticated
USING (true);

-- Create indexes for performance
CREATE INDEX idx_borrow_logs_inventory_id ON borrow_logs(inventory_id);
CREATE INDEX idx_borrow_logs_status ON borrow_logs(status);
CREATE INDEX idx_borrow_logs_borrow_date ON borrow_logs(borrow_date DESC);
CREATE INDEX idx_borrow_logs_transaction_type ON borrow_logs(transaction_type);

-- Function to auto-update timestamp
CREATE OR REPLACE FUNCTION update_borrow_logs_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for auto-updating timestamp
CREATE TRIGGER update_borrow_logs_timestamp
    BEFORE UPDATE ON borrow_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_borrow_logs_timestamp();

-- Function to update inventory stock on borrow/return
CREATE OR REPLACE FUNCTION update_inventory_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_type = 'borrow' THEN
        -- Decrease stock when borrowing
        UPDATE inventory
        SET stock_available = stock_available - NEW.quantity
        WHERE id = NEW.inventory_id;
    ELSIF NEW.transaction_type = 'return' THEN
        -- Increase stock when returning
        UPDATE inventory
        SET stock_available = stock_available + NEW.quantity
        WHERE id = NEW.inventory_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update inventory stock
CREATE TRIGGER auto_update_inventory_stock
    AFTER INSERT ON borrow_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_inventory_stock();

-- Insert sample data
INSERT INTO borrow_logs (inventory_id, item_name, quantity, borrower_name, borrower_contact, borrower_organization, purpose, transaction_type, expected_return_date, status) VALUES
(1, 'First Aid Kit', 2, 'Juan Dela Cruz', '09171234567', 'Barangay San Jose', 'Emergency Response Training', 'borrow', NOW() + INTERVAL '7 days', 'borrowed'),
(2, 'Flashlight', 5, 'Maria Santos', '09187654321', 'CDRRMO Team Alpha', 'Night Patrol', 'borrow', NOW() + INTERVAL '3 days', 'borrowed'),
(3, 'Safety Helmet', 3, 'Pedro Reyes', '09198765432', 'Construction Site 1', 'Infrastructure Inspection', 'borrow', NOW() + INTERVAL '14 days', 'borrowed');

-- Sample returned items
INSERT INTO borrow_logs (inventory_id, item_name, quantity, borrower_name, borrower_organization, purpose, transaction_type, borrow_date, expected_return_date, actual_return_date, status) VALUES
(1, 'First Aid Kit', 1, 'Ana Lopez', 'Barangay Sta. Maria', 'Community Health Drive', 'return', NOW() - INTERVAL '10 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', 'returned'),
(4, 'Fire Extinguisher', 2, 'Carlos Garcia', 'Local Fire Brigade', 'Fire Safety Seminar', 'return', NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day', NOW(), 'returned');

-- Verify data
SELECT * FROM borrow_logs ORDER BY created_at DESC;
