-- ============================================================================
-- FIX: Borrow Logs Status Constraint
-- ============================================================================
-- PROBLEM: Cannot approve requests - "borrow_logs_status_check" constraint violation
-- CAUSE: Missing 'staged' and 'rejected' status values in CHECK constraint
-- SOLUTION: Update constraint to include all workflow statuses
-- ============================================================================

-- Drop existing constraint
ALTER TABLE borrow_logs DROP CONSTRAINT IF EXISTS borrow_logs_status_check;

-- Add updated constraint with ALL workflow statuses
ALTER TABLE borrow_logs
ADD CONSTRAINT borrow_logs_status_check 
CHECK (status IN (
    'pending',      -- Initial request state
    'staged',       -- Approved, awaiting handoff
    'borrowed',     -- Active borrow
    'returned',     -- Completed return
    'overdue',      -- Past expected return date
    'dispensed',    -- Consumable item dispensed
    'cancelled',    -- User cancelled
    'rejected'      -- Admin rejected
));

-- Verification
SELECT 'Borrow Logs Status Constraint: UPDATED' as status;
SELECT 'Allowed statuses: pending, staged, borrowed, returned, overdue, dispensed, cancelled, rejected' as note;
