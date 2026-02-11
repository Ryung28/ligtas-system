-- ================================================
-- LIGTAS INVENTORY DASHBOARD - SUPABASE SQL SETUP
-- ================================================
-- Run this entire script in your Supabase SQL Editor
-- ================================================

-- 1. CREATE THE INVENTORY TABLE
CREATE TABLE IF NOT EXISTS inventory (
  id BIGSERIAL PRIMARY KEY,
  item_name TEXT NOT NULL,
  category TEXT NOT NULL,
  stock_available INTEGER NOT NULL DEFAULT 0,
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CREATE INDEX FOR BETTER PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_inventory_item_name ON inventory(item_name);
CREATE INDEX IF NOT EXISTS idx_inventory_category ON inventory(category);
CREATE INDEX IF NOT EXISTS idx_inventory_stock ON inventory(stock_available);

-- 3. INSERT SAMPLE DATA FOR TESTING
INSERT INTO inventory (item_name, category, stock_available, status) VALUES
  ('Laptop Dell XPS 13', 'Electronics', 15, 'In Stock'),
  ('Laptop HP Pavilion', 'Electronics', 8, 'In Stock'),
  ('Desktop PC Gaming', 'Electronics', 4, 'Low Stock'),
  ('iMac 24"', 'Electronics', 12, 'In Stock'),
  
  ('Office Chair Pro', 'Furniture', 3, 'Low Stock'),
  ('Standing Desk', 'Furniture', 8, 'In Stock'),
  ('Conference Table', 'Furniture', 2, 'Low Stock'),
  ('Filing Cabinet', 'Furniture', 20, 'In Stock'),
  
  ('Wireless Mouse', 'Electronics', 0, 'Out of Stock'),
  ('Keyboard Mechanical', 'Electronics', 1, 'Low Stock'),
  ('USB-C Cable', 'Accessories', 2, 'Low Stock'),
  ('HDMI Cable 6ft', 'Accessories', 25, 'In Stock'),
  
  ('Monitor 27" 4K', 'Electronics', 25, 'In Stock'),
  ('Monitor Stand', 'Accessories', 18, 'In Stock'),
  ('Webcam HD', 'Electronics', 0, 'Out of Stock'),
  
  ('Desk Lamp LED', 'Accessories', 12, 'In Stock'),
  ('Ergonomic Mat', 'Accessories', 0, 'Out of Stock'),
  ('Whiteboard', 'Office Supplies', 6, 'In Stock'),
  ('Markers Set', 'Office Supplies', 45, 'In Stock'),
  ('Sticky Notes', 'Office Supplies', 100, 'In Stock'),
  
  ('Printer Laser', 'Electronics', 3, 'Low Stock'),
  ('Scanner Document', 'Electronics', 7, 'In Stock'),
  ('Paper Shredder', 'Office Supplies', 4, 'Low Stock'),
  
  ('Headset Wireless', 'Electronics', 15, 'In Stock'),
  ('Microphone USB', 'Electronics', 8, 'In Stock'),
  ('Speakers Bluetooth', 'Electronics', 22, 'In Stock'),
  
  ('Docking Station', 'Accessories', 1, 'Low Stock'),
  ('Laptop Bag', 'Accessories', 30, 'In Stock'),
  ('Power Bank 20000mAh', 'Accessories', 0, 'Out of Stock'),
  ('Surge Protector', 'Accessories', 14, 'In Stock');

-- 4. ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;

-- 5. CREATE POLICY TO ALLOW PUBLIC READ ACCESS
-- (For production, you should add authentication)
CREATE POLICY "Enable read access for all users" 
ON inventory FOR SELECT 
USING (true);

-- Optional: Allow insert/update/delete for authenticated users
-- Uncomment if needed:
-- CREATE POLICY "Enable insert for authenticated users" 
-- ON inventory FOR INSERT 
-- WITH CHECK (auth.role() = 'authenticated');
-- 
-- CREATE POLICY "Enable update for authenticated users" 
-- ON inventory FOR UPDATE 
-- USING (auth.role() = 'authenticated');
-- 
-- CREATE POLICY "Enable delete for authenticated users" 
-- ON inventory FOR DELETE 
-- USING (auth.role() = 'authenticated');

-- 6. CREATE FUNCTION TO UPDATE 'updated_at' TIMESTAMP
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 7. CREATE TRIGGER TO AUTO-UPDATE TIMESTAMP
CREATE TRIGGER update_inventory_updated_at 
BEFORE UPDATE ON inventory 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- VERIFICATION QUERIES
-- ================================================

-- Check total records
SELECT COUNT(*) as total_items FROM inventory;

-- Check inventory by status
SELECT 
  CASE 
    WHEN stock_available = 0 THEN 'Out of Stock'
    WHEN stock_available < 5 THEN 'Low Stock'
    ELSE 'In Stock'
  END as stock_status,
  COUNT(*) as count
FROM inventory
GROUP BY stock_status;

-- Show low stock items
SELECT item_name, category, stock_available 
FROM inventory 
WHERE stock_available < 5 
ORDER BY stock_available ASC;

-- Show all items ordered by name
SELECT * FROM inventory ORDER BY item_name;

