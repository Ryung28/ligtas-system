-- 🏗️ LIGTAS: ATOMIC INVENTORY TRANSFER ENGINE
-- This function handles the direct movement of stock between two inventory records (e.g., Main Hub to Branch).
-- It ensures that stock is neither lost nor duplicated during the transfer.

CREATE OR REPLACE FUNCTION public.transfer_inventory_stock(
    p_source_id BIGINT,
    p_dest_id BIGINT,
    p_quantity INTEGER,
    p_user_id UUID,
    p_item_name TEXT
)
RETURNS VOID AS $$
DECLARE
    v_source_available INTEGER;
BEGIN
    -- 1. Check Source Availability
    SELECT stock_available INTO v_source_available
    FROM public.inventory
    WHERE id = p_source_id;

    IF v_source_available < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock at source: requested %, available %', p_quantity, v_source_available;
    END IF;

    -- 2. Decrement Source
    UPDATE public.inventory
    SET 
        stock_available = stock_available - p_quantity,
        stock_total = stock_total - p_quantity,
        updated_at = now()
    WHERE id = p_source_id;

    -- 3. Increment Destination
    UPDATE public.inventory
    SET 
        stock_available = stock_available + p_quantity,
        stock_total = stock_total + p_quantity,
        updated_at = now()
    WHERE id = p_dest_id;

    -- 4. Record Audit Log
    INSERT INTO public.inventory_audit_logs (
        item_id,
        action,
        details,
        user_id,
        created_at
    ) VALUES (
        p_source_id,
        'INTERNAL_TRANSFER',
        format('Moved %s units of %s from source %s to destination %s', p_quantity, p_item_name, p_source_id, p_dest_id),
        p_user_id,
        now()
    );

    -- 5. Record Logistics Action (Optional but good for forensic)
    INSERT INTO public.logistics_actions (
        item_id,
        item_name,
        type,
        status,
        quantity,
        forensic_note,
        created_at
    ) VALUES (
        p_source_id,
        p_item_name,
        'adjustment',
        'completed',
        p_quantity,
        format('Stock Transfer Out: %s units moved to site %s', p_quantity, p_dest_id),
        now()
    );

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
