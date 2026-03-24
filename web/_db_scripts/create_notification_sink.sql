-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - EVENT-DRIVEN NOTIFICATION SINK (V3.2 - FIXED RLS)
-- ============================================================================
-- FIX: Added INSERT policy for system_notifications to allow triggers to work
-- FIX: Moved trigger condition inside function to prevent RLS violations
-- ============================================================================

-- 1. Cleanup
DROP VIEW IF EXISTS view_system_notifications;

-- 2. Define the Sink: Durable Notification Ledger
CREATE TABLE IF NOT EXISTS system_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id), -- Nullable: If set, target to user. If null, broadcast to staff.
    type TEXT NOT NULL,                     -- 'stock_low', 'chat_message', etc.
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    reference_id TEXT,                      -- Links to inventory_id, chat_room_id, etc.
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 🛡️ SECURITY: Steel Cage RLS
ALTER TABLE system_notifications ENABLE ROW LEVEL SECURITY;

-- Admins/Staff can see everything, or specific users can see their own targeted alerts
CREATE POLICY "authenticated_select_notifications" ON system_notifications
FOR SELECT TO authenticated
USING (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "user_update_read_state" ON system_notifications
FOR UPDATE TO authenticated
USING (auth.uid() = user_id OR user_id IS NULL)
WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Allow triggers to insert notifications (triggers run with elevated privileges)
CREATE POLICY "service_role_insert_notifications" ON system_notifications
FOR INSERT TO authenticated
WITH CHECK (true);

-- 🏗️ TRIGGER ENGINES: The Automated Dispatcher

-- A. 🛡️ INVENTORY TRIAGE (Low Stock Alerts)
CREATE OR REPLACE FUNCTION trg_handle_stock_alerts()
RETURNS TRIGGER AS $$
BEGIN
    -- 🚨 Threshold: Stock Low (LT 10)
    IF (OLD.stock_available >= 10 AND NEW.stock_available < 10 AND NEW.stock_available > 0) THEN
        INSERT INTO system_notifications (type, title, message, reference_id)
        VALUES ('stock_low', 'LOW STOCK ALERT', 'Resource depletion: ' || NEW.item_name || ' (Available: ' || NEW.stock_available || ')', NEW.id::TEXT);
    END IF;

    -- 🚨 Threshold: Stock Depleted (= 0)
    IF (OLD.stock_available > 0 AND NEW.stock_available = 0) THEN
        INSERT INTO system_notifications (type, title, message, reference_id)
        VALUES ('stock_out', 'RESOURCES DEPLETED', 'Supply chain break: ' || NEW.item_name || ' is out of stock.', NEW.id::TEXT);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_stock_intel ON inventory;
CREATE TRIGGER trg_stock_intel
AFTER UPDATE ON inventory
FOR EACH ROW
EXECUTE FUNCTION trg_handle_stock_alerts();


-- B. 🛡️ RECOGNITION TRIAGE (New User Pending Status)
CREATE OR REPLACE FUNCTION trg_handle_user_alerts()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'pending') THEN
        INSERT INTO system_notifications (type, title, message, reference_id)
        VALUES ('user_pending', 'NEW ACCESS REQUEST', NEW.full_name || ' is requesting system credentials.', NEW.id::TEXT);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_user_intel ON user_profiles;

-- Fire on new registrations
CREATE TRIGGER trg_user_intel_insert
AFTER INSERT ON user_profiles
FOR EACH ROW WHEN (NEW.status = 'pending')
EXECUTE FUNCTION trg_handle_user_alerts();

-- Fire ONLY when status CHANGES to pending
CREATE TRIGGER trg_user_intel_update
AFTER UPDATE ON user_profiles
FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'pending')
EXECUTE FUNCTION trg_handle_user_alerts();


-- C. 🛡️ LOGISTICS TRIAGE (New Borrow Requests)
CREATE OR REPLACE FUNCTION trg_handle_borrow_alerts()
RETURNS TRIGGER AS $$
BEGIN
    -- Only create notification for pending requests (approval workflow)
    -- Skip notifications for direct borrows (status = 'borrowed')
    IF NEW.status = 'pending' THEN
        INSERT INTO system_notifications (type, title, message, reference_id)
        VALUES ('borrow_request', 'LOGISTICS ALERT', 'New borrow request from ' || NEW.borrower_name || ' (Qty: ' || NEW.quantity || ')', NEW.id::TEXT);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_borrow_intel ON borrow_logs;
CREATE TRIGGER trg_borrow_intel
AFTER INSERT ON borrow_logs
FOR EACH ROW
EXECUTE FUNCTION trg_handle_borrow_alerts();


-- D. 🛡️ CHAT TRIAGE (New Message Alerts)
CREATE OR REPLACE FUNCTION trg_handle_chat_alerts()
RETURNS TRIGGER AS $$
DECLARE
    sender_name TEXT;
BEGIN
    -- Lookup sender's name for the notification
    SELECT full_name INTO sender_name FROM user_profiles WHERE id = NEW.sender_id;

    INSERT INTO system_notifications (user_id, type, title, message, reference_id)
    VALUES (NEW.receiver_id, 'chat_message', 'NEW MESSAGE', 'From ' || COALESCE(sender_name, 'Unknown') || ': ' || LEFT(NEW.content, 50), NEW.room_id::TEXT);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_chat_intel ON chat_messages;
CREATE TRIGGER trg_chat_intel
AFTER INSERT ON chat_messages
FOR EACH ROW
WHEN (NEW.receiver_id IS NOT NULL)
EXECUTE FUNCTION trg_handle_chat_alerts();
