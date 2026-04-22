-- Add variant support to inventory table
-- This enables parent-child relationships for item variants (e.g., Dummy (Child), Dummy (Adult))

-- Step 1: Add new columns (without constraints first)
ALTER TABLE inventory
ADD COLUMN IF NOT EXISTS parent_id BIGINT,
ADD COLUMN IF NOT EXISTS variant_label TEXT,
ADD COLUMN IF NOT EXISTS base_name TEXT;

-- Step 2: Backfill base_name for ALL existing items
-- This handles existing items like "Dummy (Child)" -> base_name: "Dummy", variant_label: "Child"
UPDATE inventory
SET base_name = CASE
  WHEN item_name ~ '\([^)]+\)$' THEN TRIM(REGEXP_REPLACE(item_name, '\s*\([^)]+\)$', ''))
  ELSE item_name
END
WHERE base_name IS NULL;

-- Step 3: Now add the foreign key constraint
ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_parent
FOREIGN KEY (parent_id) REFERENCES inventory(id) ON DELETE CASCADE;

-- Step 4: Create index for parent_id lookups
CREATE INDEX IF NOT EXISTS idx_inventory_parent_id ON inventory(parent_id);

-- Step 5: Create helper function to get full item name (for display)
CREATE OR REPLACE FUNCTION get_full_item_name(item_row inventory)
RETURNS TEXT AS $$
BEGIN
  IF item_row.variant_label IS NOT NULL THEN
    RETURN item_row.base_name || ' (' || item_row.variant_label || ')';
  ELSE
    RETURN item_row.base_name;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Step 6: Create view for easier querying with computed full names
CREATE OR REPLACE VIEW inventory_items_with_variants AS
SELECT 
  i.*,
  get_full_item_name(i) AS full_name,
  CASE 
    WHEN i.parent_id IS NULL THEN (
      SELECT COUNT(*) 
      FROM inventory children 
      WHERE children.parent_id = i.id
    )
    ELSE 0
  END AS variant_count,
  CASE
    WHEN i.parent_id IS NULL THEN (
      SELECT COALESCE(SUM(children.stock_total), 0) + i.stock_total
      FROM inventory children
      WHERE children.parent_id = i.id
    )
    ELSE i.stock_total
  END AS total_stock
FROM inventory i;

-- Step 7: RLS policies already exist on inventory table, no changes needed
-- The existing policies will work with the new parent_id column

-- Step 8: Add comment for documentation
COMMENT ON COLUMN inventory.parent_id IS 'References parent item for variants. NULL for parent items.';
COMMENT ON COLUMN inventory.variant_label IS 'Variant type (e.g., Child, Adult, Small, Large). NULL for parent items.';
COMMENT ON COLUMN inventory.base_name IS 'Base item name without variant (e.g., Dummy). Used for grouping.';
