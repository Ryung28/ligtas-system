-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - USER STATUS CHANGE NOTIFICATIONS
-- ============================================================================
-- PURPOSE: Add notifications for user approval, rejection, and suspension
-- PRIORITY 2: User lifecycle notifications
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER: User Status Change Notifications
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION trg_handle_user_status_notifications()
RETURNS TRIGGER AS $$
BEGIN
    -- Only fire if status actually changed
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        
        -- CASE 1: User APPROVED (pending → active)
        IF OLD.status = 'pending' AND NEW.status = 'active' THEN
            INSERT INTO system_notifications (user_id, type, title, message, reference_id)
            VALUES (
                NEW.id,
                'user_approved',
                'ACCESS GRANTED',
                'Welcome to LIGTAS! Your account has been approved. You can now access the system.',
                NEW.id::TEXT
            );
        END IF;

        -- CASE 2: User SUSPENDED (active → suspended OR pending → suspended)
        IF NEW.status = 'suspended' AND OLD.status != 'suspended' THEN
            INSERT INTO system_notifications (user_id, type, title, message, reference_id)
            VALUES (
                NEW.id,
                'user_suspended',
                'ACCESS SUSPENDED',
                'Your account access has been suspended. Contact your administrator for details.',
                NEW.id::TEXT
            );
        END IF;

        -- CASE 3: User REACTIVATED (suspended → active)
        IF OLD.status = 'suspended' AND NEW.status = 'active' THEN
            INSERT INTO system_notifications (user_id, type, title, message, reference_id)
            VALUES (
                NEW.id,
                'user_reactivated',
                'ACCESS RESTORED',
                'Your account has been reactivated. Welcome back to LIGTAS!',
                NEW.id::TEXT
            );
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trg_user_status_notifications ON user_profiles;

-- Create trigger on user_profiles UPDATE
CREATE TRIGGER trg_user_status_notifications
AFTER UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION trg_handle_user_status_notifications();

SELECT 'User Status Notifications: ENABLED' as status;
