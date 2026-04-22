-- Add audit trail fields for equipment returns
-- This creates a complete chain of custody for accountability

-- Add new columns to borrow_logs table
ALTER TABLE borrow_logs 
ADD COLUMN IF NOT EXISTS received_by_name TEXT,
ADD COLUMN IF NOT EXISTS received_by_user_id UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS return_condition TEXT CHECK (return_condition IN ('good', 'fair', 'damaged')),
ADD COLUMN IF NOT EXISTS return_notes TEXT;

-- Add comments for documentation
COMMENT ON COLUMN borrow_logs.received_by_name IS 'Name of staff member who physically received the returned item';
COMMENT ON COLUMN borrow_logs.received_by_user_id IS 'User ID of staff member who processed the return (for audit trail)';
COMMENT ON COLUMN borrow_logs.return_condition IS 'Condition of item upon return: good, fair, or damaged';
COMMENT ON COLUMN borrow_logs.return_notes IS 'Optional notes about the return (e.g., damage details, missing parts)';

-- Create index for faster queries on received_by_user_id
CREATE INDEX IF NOT EXISTS idx_borrow_logs_received_by_user_id ON borrow_logs(received_by_user_id);
