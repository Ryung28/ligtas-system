-- Atomic borrow dispatch for web/mobile.
-- Ensures stock check + borrow_logs insert happen inside one transaction boundary.
-- Also updates inventory trigger behavior so variant borrows decrement the variant row.

-- 1) Make stock trigger variant-aware (single source of truth on INSERT to borrow_logs)
CREATE OR REPLACE FUNCTION public.update_inventory_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.inventory
        SET stock_available = stock_available - NEW.quantity
        WHERE id = COALESCE(NEW.inventory_variant_id, NEW.inventory_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Keep trigger as INSERT-only to avoid double add on existing web return flows.
DROP TRIGGER IF EXISTS auto_update_inventory_stock ON public.borrow_logs;
CREATE TRIGGER auto_update_inventory_stock
    AFTER INSERT ON public.borrow_logs
    FOR EACH ROW
    EXECUTE FUNCTION public.update_inventory_stock();

-- 2) Atomic borrow RPC with row lock and stock preflight
CREATE OR REPLACE FUNCTION public.dispatch_borrow_atomic(
    p_inventory_id bigint,
    p_inventory_variant_id bigint,
    p_item_name text,
    p_quantity integer,
    p_borrower_name text,
    p_borrower_contact text,
    p_borrower_organization text,
    p_purpose text DEFAULT '',
    p_approved_by_name text DEFAULT NULL,
    p_released_by_name text DEFAULT NULL,
    p_released_by_user_id uuid DEFAULT NULL,
    p_transaction_type text DEFAULT 'borrow',
    p_status text DEFAULT 'borrowed',
    p_borrow_date timestamptz DEFAULT NULL,
    p_pickup_scheduled_at timestamptz DEFAULT NULL,
    p_actual_return_date timestamptz DEFAULT NULL,
    p_expected_return_date timestamptz DEFAULT NULL,
    p_platform_origin text DEFAULT 'Web',
    p_created_origin text DEFAULT 'Web',
    p_last_updated_origin text DEFAULT 'Web',
    p_source_batch jsonb DEFAULT NULL,
    p_now timestamptz DEFAULT now()
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    v_target_inventory_id bigint;
    v_current_stock integer;
    v_log_id bigint;
BEGIN
    IF p_quantity IS NULL OR p_quantity < 1 THEN
        RAISE EXCEPTION 'Quantity must be at least 1';
    END IF;

    v_target_inventory_id := COALESCE(p_inventory_variant_id, p_inventory_id);

    -- Lock target stock row to serialize concurrent borrows on same row.
    SELECT stock_available
    INTO v_current_stock
    FROM public.inventory
    WHERE id = v_target_inventory_id
    FOR UPDATE;

    IF v_current_stock IS NULL THEN
        RAISE EXCEPTION 'Inventory item not found: %', v_target_inventory_id;
    END IF;

    IF v_current_stock < p_quantity THEN
        RAISE EXCEPTION 'check_stock_positive: insufficient stock. Requested %, available %', p_quantity, v_current_stock;
    END IF;

    INSERT INTO public.borrow_logs (
        inventory_id,
        inventory_variant_id,
        item_name,
        quantity,
        borrower_name,
        borrower_contact,
        borrower_organization,
        purpose,
        approved_by_name,
        released_by_name,
        released_by_user_id,
        transaction_type,
        status,
        borrow_date,
        pickup_scheduled_at,
        actual_return_date,
        expected_return_date,
        platform_origin,
        created_origin,
        last_updated_origin,
        source_batch,
        created_at
    ) VALUES (
        p_inventory_id,
        p_inventory_variant_id,
        p_item_name,
        p_quantity,
        p_borrower_name,
        p_borrower_contact,
        p_borrower_organization,
        COALESCE(p_purpose, ''),
        p_approved_by_name,
        p_released_by_name,
        p_released_by_user_id,
        p_transaction_type,
        p_status,
        p_borrow_date,
        p_pickup_scheduled_at,
        p_actual_return_date,
        p_expected_return_date,
        p_platform_origin,
        p_created_origin,
        p_last_updated_origin,
        p_source_batch,
        p_now
    )
    RETURNING id INTO v_log_id;

    RETURN jsonb_build_object(
        'success', true,
        'borrow_log_id', v_log_id,
        'inventory_id', p_inventory_id,
        'inventory_variant_id', p_inventory_variant_id,
        'quantity', p_quantity
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.dispatch_borrow_atomic(
    bigint,
    bigint,
    text,
    integer,
    text,
    text,
    text,
    text,
    text,
    text,
    uuid,
    text,
    text,
    timestamptz,
    timestamptz,
    timestamptz,
    timestamptz,
    text,
    text,
    text,
    jsonb,
    timestamptz
) TO authenticated;
