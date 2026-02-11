-- ============================================================================
-- UPGRADE: ADD DESCRIPTION COLUMN
-- ============================================================================

-- 1. Add the column safely
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS description TEXT;

-- 2. Confirmation
SELECT 'Description column added successfully' as status;
