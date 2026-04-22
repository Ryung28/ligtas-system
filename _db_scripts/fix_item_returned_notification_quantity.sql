-- ============================================================================
-- Ensure returned-item notifications carry quantity (message + metadata)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.trg_handle_borrow_status_notifications()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
BEGIN
    -- CASE 1: Request APPROVED (pending/staged -> approved/borrowed)
    IF OLD.status IN ('pending', 'staged') AND NEW.status IN ('approved', 'borrowed') THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'borrow_approved',
            'REQUEST APPROVED',
            NEW.borrower_name || '''s request for ' || NEW.item_name || ' (Qty: ' || NEW.quantity || ') has been approved.',
            NEW.id::TEXT,
            jsonb_build_object(
              'borrower_name', NEW.borrower_name,
              'item_name', NEW.item_name,
              'search_query', NEW.borrower_name,
              'borrow_id', NEW.id,
              'quantity', NEW.quantity
            )
        )
        ON CONFLICT (reference_id, type)
        DO UPDATE SET
            message = EXCLUDED.message,
            metadata = EXCLUDED.metadata,
            created_at = NOW();
    END IF;

    -- CASE 2: Request REJECTED (pending -> cancelled)
    IF OLD.status = 'pending' AND NEW.status = 'cancelled' THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'borrow_rejected',
            'REQUEST DECLINED',
            NEW.borrower_name || '''s request for ' || NEW.item_name || ' (Qty: ' || NEW.quantity || ') was declined.',
            NEW.id::TEXT,
            jsonb_build_object(
              'borrower_name', NEW.borrower_name,
              'item_name', NEW.item_name,
              'search_query', NEW.borrower_name,
              'borrow_id', NEW.id,
              'quantity', NEW.quantity
            )
        )
        ON CONFLICT (reference_id, type)
        DO UPDATE SET
            message = EXCLUDED.message,
            metadata = EXCLUDED.metadata,
            created_at = NOW();
    END IF;

    -- CASE 3: Item RETURNED (borrowed -> returned)
    IF OLD.status = 'borrowed' AND NEW.status = 'returned' THEN
        INSERT INTO system_notifications (type, title, message, reference_id, metadata)
        VALUES (
            'item_returned',
            'ITEM RETURNED',
            NEW.borrower_name || ' returned ' || NEW.item_name || ' (Qty: ' || NEW.quantity || ')',
            NEW.id::TEXT,
            jsonb_build_object(
              'borrower_name', NEW.borrower_name,
              'item_name', NEW.item_name,
              'search_query', NEW.borrower_name,
              'borrow_id', NEW.id,
              'quantity', NEW.quantity
            )
        )
        ON CONFLICT (reference_id, type)
        DO UPDATE SET
            message = EXCLUDED.message,
            metadata = EXCLUDED.metadata,
            created_at = NOW();
    END IF;

    RETURN NEW;
END;
$function$;

-- One-time backfill for existing return rows missing quantity.
UPDATE public.system_notifications sn
SET
  metadata = COALESCE(sn.metadata, '{}'::jsonb) || jsonb_build_object('quantity', bl.quantity),
  message = CASE
    WHEN sn.message ~* '\(Qty:\s*\d+\)' THEN sn.message
    ELSE COALESCE(sn.message, '') || ' (Qty: ' || bl.quantity || ')'
  END
FROM public.borrow_logs bl
WHERE sn.type = 'item_returned'
  AND sn.reference_id = bl.id::TEXT
  AND (
    COALESCE((sn.metadata ->> 'quantity')::INT, NULL) IS NULL
    OR sn.message !~* '\(Qty:\s*\d+\)'
  );
