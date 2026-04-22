-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - ADD BORROWER USER ID TRACKING
-- ============================================================================
-- PURPOSE: Link borrow logs to user profiles for person-centric tracking
-- BENEFIT: Enable full borrowing history per user, metrics, and accountability
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 1: Add borrower_user_id column to borrow_logs
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE borrow_logs 
ADD COLUMN IF NOT EXISTS borrower_user_id UUID REFERENCES user_profiles(id);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_borrow_logs_borrower_user_id 
ON borrow_logs(borrower_user_id);

COMMENT ON COLUMN borrow_logs.borrower_user_id IS 
'Links borrow log to user profile. Enables person-centric tracking and full history.';

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 2: Backfill existing logs (match by email or name)
-- ─────────────────────────────────────────────────────────────────────────────

-- Match by email first (most reliable)
UPDATE borrow_logs bl
SET borrower_user_id = (
    SELECT id 
    FROM user_profiles up
    WHERE LOWER(up.email) = LOWER(bl.borrower_email)
    LIMIT 1
)
WHERE borrower_user_id IS NULL 
AND borrower_email IS NOT NULL
AND borrower_email != '';

-- Match by full name (fallback)
UPDATE borrow_logs bl
SET borrower_user_id = (
    SELECT id 
    FROM user_profiles up
    WHERE LOWER(up.full_name) = LOWER(bl.borrower_name)
    LIMIT 1
)
WHERE borrower_user_id IS NULL 
AND borrower_name IS NOT NULL
AND borrower_name != '';

-- ─────────────────────────────────────────────────────────────────────────────
-- STEP 3: Create trigger to auto-populate borrower_user_id on new borrows
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION auto_populate_borrower_user_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Try to match by email first
    IF NEW.borrower_email IS NOT NULL AND NEW.borrower_email != '' THEN
        SELECT id INTO NEW.borrower_user_id
        FROM user_profiles
        WHERE LOWER(email) = LOWER(NEW.borrower_email)
        LIMIT 1;
    END IF;
    
    -- Fallback to name match if email didn't work
    IF NEW.borrower_user_id IS NULL AND NEW.borrower_name IS NOT NULL THEN
        SELECT id INTO NEW.borrower_user_id
        FROM user_profiles
        WHERE LOWER(full_name) = LOWER(NEW.borrower_name)
        LIMIT 1;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_populate_borrower_user_id ON borrow_logs;

CREATE TRIGGER trg_auto_populate_borrower_user_id
BEFORE INSERT ON borrow_logs
FOR EACH ROW
EXECUTE FUNCTION auto_populate_borrower_user_id();

SELECT 'Borrower User ID Tracking: ENABLED' as status;
SELECT COUNT(*) as linked_logs FROM borrow_logs WHERE borrower_user_id IS NOT NULL;
SELECT COUNT(*) as unlinked_logs FROM borrow_logs WHERE borrower_user_id IS NULL;
