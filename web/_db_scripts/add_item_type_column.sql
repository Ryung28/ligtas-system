-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - ADD ITEM TYPE FOR CONSUMABLES
-- ============================================================================
-- PURPOSE: Distinguish between returnable equipment and one-time consumables
-- AUTHOR: Senior Dev
-- DATE: 2026-03-23
-- ============================================================================

-- Step 1: Add item_type column to inventory table
ALTER TABLE inventory 
ADD COLUMN IF NOT EXISTS item_type TEXT DEFAULT 'equipment';

-- Step 2: Add check constraint to ensure valid values
ALTER TABLE inventory
ADD CONSTRAINT check_item_type 
CHECK (item_type IN ('equipment', 'consumable'));

-- Step 3: Create index for filtering by item type
CREATE INDEX IF NOT EXISTS idx_inventory_item_type ON inventory(item_type);

-- Step 4: Update existing items (all default to equipment)
UPDATE inventory 
SET item_type = 'equipment' 
WHERE item_type IS NULL;

-- Step 5: Add comment for documentation
COMMENT ON COLUMN inventory.item_type IS 'Type of inventory item: equipment (returnable) or consumable (one-time use)';
