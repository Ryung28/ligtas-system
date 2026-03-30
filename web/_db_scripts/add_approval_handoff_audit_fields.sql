-- Add approval and handoff audit trail fields to borrow_logs
-- This enables tracking WHO approved and WHO handed out equipment at each warehouse location

ALTER TABLE borrow_logs 
ADD COLUMN IF NOT EXISTS approved_by TEXT,
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS handed_by TEXT,
ADD COLUMN IF NOT EXISTS handed_at TIMESTAMPTZ;

-- Add indexes for performance on audit queries
CREATE INDEX IF NOT EXISTS idx_borrow_logs_approved_by ON borrow_logs(approved_by);
CREATE INDEX IF NOT EXISTS idx_borrow_logs_handed_by ON borrow_logs(handed_by);

COMMENT ON COLUMN borrow_logs.approved_by IS 'Name of staff member who approved the request';
COMMENT ON COLUMN borrow_logs.approved_at IS 'Timestamp when request was approved';
COMMENT ON COLUMN borrow_logs.handed_by IS 'Name of staff member who physically handed out the equipment';
COMMENT ON COLUMN borrow_logs.handed_at IS 'Timestamp when equipment was physically handed out';
