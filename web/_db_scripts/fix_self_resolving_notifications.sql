-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - SELF-RESOLVING STOCK NOTIFICATIONS (V5.0)
-- PURPOSE: Align stock notifications with percent-based threshold math.
-- FORMULA: effective_units = ceil(target_stock * low_stock_threshold / 100)
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_handle_stock_alerts()
RETURNS TRIGGER AS $$
DECLARE
    old_in_alert BOOLEAN;
    new_in_alert BOOLEAN;
    new_effective_threshold INTEGER;
BEGIN
    new_effective_threshold := CASE
        WHEN COALESCE(NEW.target_stock, 0) > 0 AND COALESCE(NEW.low_stock_threshold, 0) > 0
            THEN CEIL((NEW.target_stock::NUMERIC * NEW.low_stock_threshold::NUMERIC) / 100.0)::INT
        ELSE NULL
    END;

    old_in_alert :=
        COALESCE(OLD.restock_alert_enabled, true) = true
        AND LOWER(COALESCE(OLD.status, '')) NOT IN ('damaged', 'lost', 'deleted')
        AND (
            OLD.stock_available < 5
            OR (
                COALESCE(OLD.target_stock, 0) > 0
                AND COALESCE(OLD.low_stock_threshold, 0) > 0
                AND OLD.stock_available <= CEIL((OLD.target_stock::NUMERIC * OLD.low_stock_threshold::NUMERIC) / 100.0)
            )
        );

    new_in_alert :=
        COALESCE(NEW.restock_alert_enabled, true) = true
        AND LOWER(COALESCE(NEW.status, '')) NOT IN ('damaged', 'lost', 'deleted')
        AND (
            NEW.stock_available < 5
            OR (
                COALESCE(NEW.target_stock, 0) > 0
                AND COALESCE(NEW.low_stock_threshold, 0) > 0
                AND NEW.stock_available <= CEIL((NEW.target_stock::NUMERIC * NEW.low_stock_threshold::NUMERIC) / 100.0)
            )
        );

    IF new_in_alert THEN
        DELETE FROM public.system_notifications
        WHERE reference_id = NEW.id::TEXT
          AND type IN ('stock_low', 'stock_out');

        IF NEW.stock_available = 0 THEN
            INSERT INTO system_notifications (type, title, message, reference_id, metadata)
            VALUES (
                'stock_out',
                'RESOURCES DEPLETED',
                'Supply chain break: ' || NEW.item_name || ' is out of stock.',
                NEW.id::TEXT,
                jsonb_build_object(
                    'search_query', NEW.item_name,
                    'item_name', NEW.item_name,
                    'stock_available', NEW.stock_available,
                    'target_stock', NEW.target_stock,
                    'low_stock_threshold', NEW.low_stock_threshold,
                    'effective_threshold_units', new_effective_threshold
                )
            );
        ELSE
            INSERT INTO system_notifications (type, title, message, reference_id, metadata)
            VALUES (
                'stock_low',
                'LOW STOCK ALERT',
                'Resource depletion: ' || NEW.item_name || ' (Available: ' || NEW.stock_available || ')',
                NEW.id::TEXT,
                jsonb_build_object(
                    'search_query', NEW.item_name,
                    'item_name', NEW.item_name,
                    'stock_available', NEW.stock_available,
                    'target_stock', NEW.target_stock,
                    'low_stock_threshold', NEW.low_stock_threshold,
                    'effective_threshold_units', new_effective_threshold
                )
            );
        END IF;
    ELSIF old_in_alert AND NOT new_in_alert THEN
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

SELECT 'Stock Alerts: aligned to percent-based threshold + self-resolving.' as status;
