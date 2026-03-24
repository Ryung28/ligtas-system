-- ============================================
-- ADD STORAGE LOCATION COLUMN TO INVENTORY
-- ============================================
-- Purpose: Track physical warehouse location of equipment
-- Author: LIGTAS System
-- Date: 2026-03-24

-- Step 1: Add storage_location column with default value
ALTER TABLE inventory 
ADD COLUMN IF NOT EXISTS storage_location TEXT 
DEFAULT 'lower_warehouse';

-- Step 2: Add check constraint to ensure valid values
ALTER TABLE inventory
ADD CONSTRAINT check_storage_location 
CHECK (storage_location IN ('lower_warehouse', '2nd_floor_warehouse', 'office', 'field'));

-- Step 3: Backfill existing items with default value
UPDATE inventory 
SET storage_location = 'lower_warehouse' 
WHERE storage_location IS NULL;

-- Step 4: Add index for filtering performance
CREATE INDEX IF NOT EXISTS idx_inventory_storage_location 
ON inventory(storage_location);

-- Step 5: Add comment for documentation
COMMENT ON COLUMN inventory.storage_location IS 'Physical warehouse location: lower_warehouse, 2nd_floor_warehouse, office, or field';
