-- Fix NULL borrow_date in borrow_logs
-- This updates all records where borrow_date is NULL to use created_at value

UPDATE borrow_logs 
SET borrow_date = created_at 
WHERE borrow_date IS NULL;

-- Verify the fix
SELECT id, item_name, borrow_date, created_at 
FROM borrow_logs 
WHERE borrow_date IS NULL;
