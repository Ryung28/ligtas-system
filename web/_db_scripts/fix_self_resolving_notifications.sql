-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - SELF-RESOLVING STOCK NOTIFICATIONS (V4.2)
-- PURPOSE: Automatically delete 'Low Stock' alerts when stock recovers.
-- BENEFIT: Prevents stale notification cards after restocking.
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_handle_stock_alerts()
RETURNS TRIGGER AS $$
BEGIN
    -- 🚨 BRANCH A: THE ALARM (When stock drops below thresholds)
    
    -- 1. Threshold: Low Stock (Below 10)
    IF (OLD.stock_available >= 10 AND NEW.stock_available < 10 AND NEW.stock_available > 0) THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'stock_low', 
            'LOW STOCK ALERT', 
            'Resource depletion: ' || NEW.item_name || ' (Available: ' || NEW.stock_available || ')', 
            NEW.id::TEXT, 
            jsonb_build_object('search_query', NEW.item_name, 'item_name', NEW.item_name)
        );
    END IF;

    -- 2. Threshold: Stock Depleted (= 0)
    IF (OLD.stock_available > 0 AND NEW.stock_available = 0) THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'stock_out', 
            'RESOURCES DEPLETED', 
            'Supply chain break: ' || NEW.item_name || ' is out of stock.', 
            NEW.id::TEXT, 
            jsonb_build_object('search_query', NEW.item_name, 'item_name', NEW.item_name)
        );
    END IF;

    -- ✨ BRANCH B: THE RESOLUTION (The "Healing" Logic)
    
    -- If stock was in an alert state (< 10) and is now recovered (>= 10), 
    -- we purge the alerts from the system_notifications table.
    IF (OLD.stock_available < 10 AND NEW.stock_available >= 10) THEN
        DELETE FROM public.system_notifications 
        WHERE reference_id = NEW.id::TEXT 
        AND type IN ('stock_low', 'stock_out');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Ensure the trigger is attached (Re-running this is idempotent)
DROP TRIGGER IF EXISTS trg_stock_intel ON inventory;
CREATE TRIGGER trg_stock_intel
AFTER UPDATE ON inventory
FOR EACH ROW
EXECUTE FUNCTION trg_handle_stock_alerts();

SELECT 'Stock Alerts: REFACTORED to Self-Resolving.' as status;
