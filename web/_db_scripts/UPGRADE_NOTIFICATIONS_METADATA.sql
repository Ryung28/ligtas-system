-- ============================================================================
-- 🚀 SUPER SENIOR MISSION: METADATA EXPANSION (V5)
-- Upgrades persistent notification sink to support precision identity-based triage.
-- ============================================================================

-- 1. Extend the physical table structure
ALTER TABLE public.system_notifications 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- 2. Upgrade the TRIGGER ENGINES to capture identity context

-- A. 🛡️ RECOGNITION TRIAGE (Capture Username)
CREATE OR REPLACE FUNCTION trg_handle_user_alerts()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'pending') THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'user_pending', 
            'NEW ACCESS REQUEST', 
            NEW.full_name || ' is requesting system credentials.', 
            NEW.id::TEXT,
            jsonb_build_object(
                'borrower_name', NEW.full_name,
                'search_query', NEW.full_name,
                'user_id', NEW.id
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- B. 🛡️ LOGISTICS TRIAGE (Capture Borrower Name)
CREATE OR REPLACE FUNCTION trg_handle_borrow_alerts()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'pending' THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'borrow_request', 
            'LOGISTICS ALERT', 
            'New borrow request from ' || NEW.borrower_name || ' (Qty: ' || NEW.quantity || ')', 
            NEW.id::TEXT,
            jsonb_build_object(
                'borrower_name', NEW.borrower_name,
                'search_query', NEW.borrower_name,
                'item_name', NEW.item_name,
                'quantity', NEW.quantity
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- C. 🛡️ INVENTORY TRIAGE (Capture Item Name)
CREATE OR REPLACE FUNCTION trg_handle_stock_alerts()
RETURNS TRIGGER AS $$
BEGIN
    -- Low Stock Alert
    IF (OLD.stock_available >= 10 AND NEW.stock_available < 10 AND NEW.stock_available > 0) THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'stock_low', 
            'LOW STOCK ALERT', 
            'Resource depletion: ' || NEW.item_name || ' (Available: ' || NEW.stock_available || ')', 
            NEW.id::TEXT,
            jsonb_build_object(
                'item_name', NEW.item_name,
                'search_query', NEW.item_name,
                'stock_available', NEW.stock_available
            )
        );
    END IF;

    -- Out of Stock
    IF (OLD.stock_available > 0 AND NEW.stock_available = 0) THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'stock_out', 
            'RESOURCES DEPLETED', 
            'Supply chain break: ' || NEW.item_name || ' is out of stock.', 
            NEW.id::TEXT,
            jsonb_build_object(
                'item_name', NEW.item_name,
                'search_query', NEW.item_name,
                'stock_available', 0
            )
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Re-Apply grants to ensure the background triggers can write
GRANT ALL ON public.system_notifications TO postgres;
GRANT ALL ON public.system_notifications TO service_role;
GRANT ALL ON public.system_notifications TO authenticated;
