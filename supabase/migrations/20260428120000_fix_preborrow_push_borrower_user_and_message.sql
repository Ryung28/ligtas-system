-- Applied via Supabase MCP to project knarlvwnuvedyfvvaota (mobile pre-borrow push trace fix).
-- Issue: notify_borrow_log_change used only borrower_user_id; auto_populate_borrower_user_id
-- never copied borrowed_by, so many pending inserts skipped notification_events entirely.

CREATE OR REPLACE FUNCTION public.auto_populate_borrower_user_id()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.borrower_email IS NOT NULL AND NEW.borrower_email != '' THEN
        SELECT id INTO NEW.borrower_user_id
        FROM user_profiles
        WHERE LOWER(email) = LOWER(NEW.borrower_email)
        LIMIT 1;
    END IF;

    IF NEW.borrower_user_id IS NULL AND NEW.borrower_name IS NOT NULL THEN
        SELECT id INTO NEW.borrower_user_id
        FROM user_profiles
        WHERE LOWER(full_name) = LOWER(NEW.borrower_name)
        LIMIT 1;
    END IF;

    IF NEW.borrower_user_id IS NULL AND NEW.borrowed_by IS NOT NULL THEN
        NEW.borrower_user_id := NEW.borrowed_by;
    END IF;

    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.notify_borrow_log_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  user_id UUID;
  v_title TEXT := 'LIGTAS Alert';
  v_body TEXT;
BEGIN
  user_id := COALESCE(NEW.borrower_user_id, NEW.borrowed_by);

  IF user_id IS NULL THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.status = NEW.status THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'pending' THEN
      v_body := 'Your borrow request is waiting for approval: ' || NEW.item_name;
    ELSE
      v_body := 'New borrow request: ' || NEW.item_name;
    END IF;
  ELSIF NEW.status = 'approved' THEN
    v_body := 'Your request for ' || NEW.item_name || ' has been approved';
  ELSIF NEW.status = 'overdue' THEN
    v_body := 'URGENT: ' || NEW.item_name || ' is overdue!';
  ELSIF NEW.status = 'returned' THEN
    v_body := 'Successfully returned: ' || NEW.item_name;
  ELSIF NEW.status = 'cancelled' THEN
    v_body := 'Your request for ' || NEW.item_name || ' was declined';
  ELSE
    RETURN NEW;
  END IF;

  INSERT INTO notification_events (
    event_type,
    audience,
    payload,
    status
  ) VALUES (
    'borrow_log_update',
    jsonb_build_object('user_ids', ARRAY[user_id]),
    jsonb_build_object(
      'title', v_title,
      'body', v_body,
      'path', '/m/logs',
      'item_name', NEW.item_name,
      'status', NEW.status
    ),
    'pending'
  );

  RETURN NEW;
END;
$function$;
