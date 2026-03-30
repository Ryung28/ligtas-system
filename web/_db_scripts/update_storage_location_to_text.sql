-- Update storage_location column to accept custom text values
-- This allows admins to specify any location, not just predefined ones

-- Step 1: Drop the dependent view
DROP VIEW IF EXISTS inventory_availability;

-- Step 2: Change column type from enum to text
ALTER TABLE inventory 
ALTER COLUMN storage_location TYPE TEXT;

-- Step 3: Add a check constraint to prevent empty strings
ALTER TABLE inventory 
ADD CONSTRAINT storage_location_not_empty 
CHECK (storage_location IS NULL OR length(trim(storage_location)) > 0);

-- Step 4: Update existing NULL values to default
UPDATE inventory 
SET storage_location = 'lower_warehouse' 
WHERE storage_location IS NULL;

-- Step 5: Add comment for documentation
COMMENT ON COLUMN inventory.storage_location IS 
'Storage location of the item. Can be predefined (lower_warehouse, 2nd_floor_warehouse, office, field) or custom text for scattered items.';

-- Step 6: Recreate the inventory_availability view
CREATE VIEW inventory_availability AS
SELECT 
  i.id,
  i.item_name,
  i.description,
  i.category,
  i.stock_total,
  i.stock_available,
  i.status,
  i.image_url,
  i.serial_number,
  i.equipment_type,
  i.item_type,
  i.storage_location,
  i.brand,
  i.expiry_date,
  i.expiry_alert_days,
  i.created_at,
  i.updated_at,
  i.deleted_at,
  
  -- Calculate borrowed quantity (status = 'borrowed')
  COALESCE(borrowed.qty, 0) as stock_borrowed,
  
  -- Calculate pending quantity (status = 'pending')
  COALESCE(pending.qty, 0) as stock_pending,
  
  -- Calculate truly available stock (excluding pending reservations)
  (i.stock_available - COALESCE(pending.qty, 0)) as stock_truly_available
  
FROM inventory i

-- Join borrowed items
LEFT JOIN (
  SELECT 
    inventory_id, 
    SUM(quantity) as qty 
  FROM borrow_logs 
  WHERE status = 'borrowed' 
  GROUP BY inventory_id
) borrowed ON i.id = borrowed.inventory_id

-- Join pending items
LEFT JOIN (
  SELECT 
    inventory_id, 
    SUM(quantity) as qty 
  FROM borrow_logs 
  WHERE status = 'pending' 
  GROUP BY inventory_id
) pending ON i.id = pending.inventory_id;

-- Step 7: Grant permissions
GRANT SELECT ON inventory_availability TO authenticated;
