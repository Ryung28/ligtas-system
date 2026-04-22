-- Add physically_returned_by field to borrow_logs table
-- This allows tracking the specific person who handed back the equipment
-- which may be different from the original borrower.

ALTER TABLE borrow_logs 
ADD COLUMN IF NOT EXISTS returned_by_name TEXT;

-- Add documentation comment
COMMENT ON COLUMN borrow_logs.returned_by_name IS 'Name of the person who physically returned the equipment to the warehouse';

-- Senior Dev Tip: No index needed for now as we don't filter by this specific field yet,
-- but adding the column ensures the audit trail is preserved.
