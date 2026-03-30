-- ============================================
-- ADD EXPIRY TRACKING FOR CONSUMABLES
-- ============================================
-- Purpose: Track expiry dates for consumable goods (canned goods, water, etc.)
-- Author: LIGTAS System
-- Date: 2026-03-24

-- Step 1: Add brand column
ALTER TABLE inventory 
ADD COLUMN IF NOT EXISTS brand TEXT;

-- Step 2: Add expiry_date column (nullable, only for consumables)
ALTER TABLE inventory 
ADD COLUMN IF NOT EXISTS expiry_date DATE;

-- Step 3: Add expiry_alert_days column (default 30 days warning)
ALTER TABLE inventory 
ADD COLUMN IF NOT EXISTS expiry_alert_days INTEGER DEFAULT 30;

-- Step 4: Add check constraint (alert days must be positive)
ALTER TABLE inventory
ADD CONSTRAINT check_expiry_alert_days 
CHECK (expiry_alert_days IS NULL OR expiry_alert_days > 0);

-- Step 5: Add index for expiry queries
CREATE INDEX IF NOT EXISTS idx_inventory_expiry_date 
ON inventory(expiry_date) 
WHERE expiry_date IS NOT NULL;

-- Step 6: Add comments for documentation
COMMENT ON COLUMN inventory.brand IS 'Brand name for consumables (e.g., Del Monte, Nestle)';
COMMENT ON COLUMN inventory.expiry_date IS 'Expiry date for consumable goods';
COMMENT ON COLUMN inventory.expiry_alert_days IS 'Days before expiry to trigger alert (default 30)';
