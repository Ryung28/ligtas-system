-- LIGTAS ENTERPRISE LOGISTICS
-- MIGRATION: ADD 'RESERVED' STATUS

-- 1. Drop the legacy check constraint
ALTER TABLE borrow_logs DROP CONSTRAINT IF EXISTS borrow_logs_status_check;

-- 2. Add the hardened constraint including the new 'reserved' state
ALTER TABLE borrow_logs
ADD CONSTRAINT borrow_logs_status_check 
CHECK (status IN ('borrowed', 'returned', 'overdue', 'pending', 'rejected', 'cancelled', 'staged', 'dispensed', 'reserved', 'mixed'));

-- 3. Document the architecture update
COMMENT ON COLUMN borrow_logs.status IS 'Status: pending (awaiting approval), reserved (approved but future pickup), staged (ready for pickup now), borrowed (active loan), returned (completed), overdue (past due), dispensed (consumable used), cancelled (voided)';

SELECT 'Table borrow_logs updated successfully' as status;
