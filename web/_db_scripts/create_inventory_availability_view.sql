-- ============================================
-- INVENTORY AVAILABILITY VIEW
-- ============================================
-- Purpose: Calculate real-time available stock accounting for:
--   - Physical stock (stock_available)
--   - Reserved by pending approvals (stock_pending)
--   - Currently borrowed (stock_borrowed)
-- 
-- Usage: Use this view instead of direct inventory table queries
--        to get accurate availability for borrow operations
-- ============================================

-- Drop existing view first to allow column reordering
DROP VIEW IF EXISTS inventory_availability;

-- Recreate view with storage_location column
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

-- ============================================
-- GRANT PERMISSIONS
-- ============================================
-- Ensure authenticated users can read from this view
GRANT SELECT ON inventory_availability TO authenticated;

-- ============================================
-- USAGE EXAMPLE
-- ============================================
-- SELECT * FROM inventory_availability 
-- WHERE stock_truly_available > 0 
--   AND status != 'archived'
-- ORDER BY item_name;
