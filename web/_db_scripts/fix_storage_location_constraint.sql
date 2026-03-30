-- Fix storage_location constraint issue
-- Drop the old check constraint that's blocking custom locations

-- Step 1: Drop the problematic constraint
ALTER TABLE inventory 
DROP CONSTRAINT IF EXISTS check_storage_location;

-- Step 2: Drop the constraint we added earlier (if it exists)
ALTER TABLE inventory 
DROP CONSTRAINT IF EXISTS storage_location_not_empty;

-- Step 3: Add a simpler constraint that just prevents empty strings
ALTER TABLE inventory 
ADD CONSTRAINT storage_location_not_empty 
CHECK (storage_location IS NULL OR trim(storage_location) != '');

-- Verify the change
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'inventory'::regclass 
AND conname LIKE '%storage%';
