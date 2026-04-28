-- Borrower-targeted system_notifications row when status = pending pre-borrow,
-- so get_user_inbox (user_id = auth.uid()) drives bell badge + notification cards.

CREATE OR REPLACE FUNCTION public.trg_handle_borrow_alerts()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.status = 'pending' THEN
        INSERT INTO system_notifications (
            type,
            title,
            message,
            reference_id,
            metadata
        )
        VALUES (
            'borrow_request',
            'PRE-BORROW REQUEST',
            NEW.borrower_name || ' is requesting ' || NEW.quantity || ' x ' || NEW.item_name,
            NEW.id::TEXT,
            jsonb_build_object(
                'search_query', NEW.borrower_name,
                'borrower_name', NEW.borrower_name,
                'item_name', NEW.item_name,
                'quantity', NEW.quantity,
                'borrow_id', NEW.id,
                'audience_role', 'manager'
            )
        );

        IF COALESCE(NEW.borrower_user_id, NEW.borrowed_by) IS NOT NULL THEN
            INSERT INTO system_notifications (
                user_id,
                type,
                title,
                message,
                reference_id,
                metadata
            )
            VALUES (
                COALESCE(NEW.borrower_user_id, NEW.borrowed_by),
                'borrow_request_submitted',
                'REQUEST SUBMITTED',
                'Your request for ' || NEW.quantity || ' × ' || NEW.item_name || ' is waiting for approval.',
                NEW.id::TEXT,
                jsonb_build_object(
                    'borrow_id', NEW.id,
                    'item_name', NEW.item_name,
                    'quantity', NEW.quantity,
                    'status', NEW.status,
                    'search_query', NEW.item_name
                )
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$function$;
