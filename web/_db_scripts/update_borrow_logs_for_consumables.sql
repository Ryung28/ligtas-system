-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - UPDATE BORROW LOGS FOR CONSUMABLES
-- ============================================================================
-- PURPOSE: Add 'dispensed' status and 'dispense' transaction type
-- ============================================================================

-- Step 1: Check and fix any invalid status values in existing data
UPDATE borrow_logs 
SET status = 'returned' 
WHERE status NOT IN ('borrowed', 'returned', 'overdue', 'dispensed', 'cancelled', 'pending');

-- Step 2: Check and fix any invalid transaction_type values
UPDATE borrow_logs 
SET transaction_type = 'borrow' 
WHERE transaction_type NOT IN ('borrow', 'return', 'dispense');

-- Step 3: Drop existing constraints
ALTER TABLE borrow_logs DROP CONSTRAINT IF EXISTS borrow_logs_status_check;
ALTER TABLE borrow_logs DROP CONSTRAINT IF EXISTS borrow_logs_transaction_type_check;

-- Step 4: Add updated constraints with new values
ALTER TABLE borrow_logs
ADD CONSTRAINT borrow_logs_status_check 
CHECK (status IN ('borrowed', 'returned', 'overdue', 'dispensed', 'cancelled', 'pending'));

ALTER TABLE borrow_logs
ADD CONSTRAINT borrow_logs_transaction_type_check 
CHECK (transaction_type IN ('borrow', 'return', 'dispense'));

-- Step 5: Add comments
COMMENT ON COLUMN borrow_logs.status IS 'Status: pending (awaiting approval), borrowed (active loan), returned (completed), overdue (past due), dispensed (consumable used), cancelled (voided)';
COMMENT ON COLUMN borrow_logs.transaction_type IS 'Type: borrow (returnable equipment), return (equipment returned), dispense (consumable used)';
