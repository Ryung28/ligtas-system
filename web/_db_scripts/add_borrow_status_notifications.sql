-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - BORROW STATUS CHANGE NOTIFICATIONS
-- ============================================================================
-- PURPOSE: Add notifications for borrow approval, rejection, and returns
-- PRIORITY 1: Critical workflow completion notifications
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER: Borrow Status Change Notifications
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION trg_handle_borrow_status_notifications()
RETURNS TRIGGER AS $$
BEGIN
    -- Only fire if status actually changed
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        
        -- CASE 1: Borrow Request APPROVED (pending → borrowed)
        IF OLD.status = 'pending' AND NEW.status = 'borrowed' THEN
            INSERT INTO system_notifications (type, title, message, reference_id, metadata)
            VALUES (
                'borrow_approved',
                'REQUEST APPROVED',
                'Your request for ' || NEW.item_name || ' (Qty: ' || NEW.quantity || ') has been approved.',
                NEW.id::TEXT,
                jsonb_build_object('search_query', NEW.borrower_name, 'borrower_name', NEW.borrower_name, 'item_name', NEW.item_name)
            );
        END IF;

        -- CASE 2: Borrow Request REJECTED (pending → cancelled)
        IF OLD.status = 'pending' AND NEW.status = 'cancelled' THEN
            INSERT INTO system_notifications (type, title, message, reference_id, metadata)
            VALUES (
                'borrow_rejected',
                'REQUEST DECLINED',
                'Your request for ' || NEW.item_name || ' (Qty: ' || NEW.quantity || ') was not approved.',
                NEW.id::TEXT,
                jsonb_build_object('search_query', NEW.borrower_name, 'borrower_name', NEW.borrower_name, 'item_name', NEW.item_name)
            );
        END IF;

        -- CASE 3: Item RETURNED (borrowed → returned)
        IF OLD.status = 'borrowed' AND NEW.status = 'returned' THEN
            INSERT INTO system_notifications (type, title, message, reference_id, metadata)
            VALUES (
                'item_returned',
                'ITEM RETURNED',
                NEW.borrower_name || ' returned ' || NEW.item_name || ' (Qty: ' || NEW.quantity || ')' ||
                CASE 
                    WHEN NEW.return_condition IS NOT NULL THEN ' - Condition: ' || NEW.return_condition
                    ELSE ''
                END,
                NEW.id::TEXT,
                jsonb_build_object('search_query', NEW.borrower_name, 'borrower_name', NEW.borrower_name, 'item_name', NEW.item_name)
            );
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trg_borrow_status_notifications ON borrow_logs;

-- Create trigger on borrow_logs UPDATE
CREATE TRIGGER trg_borrow_status_notifications
AFTER UPDATE ON borrow_logs
FOR EACH ROW
EXECUTE FUNCTION trg_handle_borrow_status_notifications();

SELECT 'Borrow Status Notifications: ENABLED' as status;
