-- ============================================================================
-- LIGTAS CDRRMO - NOTIFICATION EVENT ROUTING (V1)
-- ============================================================================
-- Goal:
-- Route existing in-app notification sources into the new
-- public.notification_events queue so the mobile push pipeline is unified.
--
-- Sources covered:
--   1) chat_messages (receiver-directed)
--   2) system_notifications (targeted + manager broadcast)
--
-- Notes:
-- - We intentionally disable direct chat HTTP push trigger to avoid duplicates.
-- - This migration is additive and compatible with FCM_RELIABILITY_BLUEPRINT_V1.sql.
-- ============================================================================

-- --------------------------------------------------------------------------
-- 0) Disable legacy direct chat push trigger (if present)
-- --------------------------------------------------------------------------
DROP TRIGGER IF EXISTS dispatch_chat_notification ON public.chat_messages;

-- --------------------------------------------------------------------------
-- 1) Chat -> notification_events
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_enqueue_chat_notification_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_sender_name TEXT;
  v_title TEXT;
  v_body TEXT;
  v_room_id TEXT;
BEGIN
  -- Only route if a direct receiver exists.
  IF NEW.receiver_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(full_name, 'ResQTrack Dispatch')
    INTO v_sender_name
  FROM public.user_profiles
  WHERE id = NEW.sender_id;

  v_title := v_sender_name;
  v_body := LEFT(COALESCE(NEW.content, 'New message'), 200);
  v_room_id := NEW.room_id::TEXT;

  INSERT INTO public.notification_events (
    event_type,
    audience,
    payload,
    idempotency_key
  ) VALUES (
    'chat_message',
    jsonb_build_object('user_ids', jsonb_build_array(NEW.receiver_id::TEXT)),
    jsonb_build_object(
      'title', v_title,
      'body', v_body,
      'path', '/chat/' || v_room_id,
      'channel_id', 'emergency_coordination_v7',
      'sound', 'critical_alarm',
      'priority', 'high',
      'ttl_seconds', 300,
      'collapse_id', 'chat:' || v_room_id,
      'metadata', jsonb_build_object(
        'room_id', v_room_id,
        'sender_id', NEW.sender_id::TEXT,
        'receiver_id', NEW.receiver_id::TEXT
      )
    ),
    'chat:' || NEW.id::TEXT
  )
  ON CONFLICT (idempotency_key) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enqueue_chat_notification_event ON public.chat_messages;
CREATE TRIGGER trg_enqueue_chat_notification_event
AFTER INSERT ON public.chat_messages
FOR EACH ROW
EXECUTE FUNCTION public.trg_enqueue_chat_notification_event();

-- --------------------------------------------------------------------------
-- 2) system_notifications -> notification_events
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_enqueue_system_notification_event()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_ids TEXT[];
  v_type TEXT := COALESCE(NEW.type, 'system_alert');
  v_path TEXT := '/dashboard';
  v_priority TEXT := 'normal';
  v_sound TEXT := 'notification';
  v_ttl INT := 3600;
  v_collapse_id TEXT := 'sys:' || COALESCE(NEW.type, 'system') || ':' || COALESCE(NEW.reference_id, NEW.id::TEXT);
BEGIN
  -- Audience resolution:
  -- - If user_id exists, target that user only.
  -- - Else broadcast to manager roles.
  IF NEW.user_id IS NOT NULL THEN
    v_user_ids := ARRAY[NEW.user_id::TEXT];
  ELSE
    SELECT COALESCE(array_agg(id::TEXT), ARRAY[]::TEXT[])
      INTO v_user_ids
    FROM public.user_profiles
    WHERE role IN ('admin', 'staff', 'editor', 'viewer')
      AND status = 'active';
  END IF;

  IF COALESCE(array_length(v_user_ids, 1), 0) = 0 THEN
    RETURN NEW;
  END IF;

  -- Tactical mapping by notification type
  IF v_type = 'chat_message' THEN
    v_path := '/chat/' || COALESCE(NEW.reference_id, '');
    v_priority := 'high';
    v_sound := 'critical_alarm';
    v_ttl := 300;
    v_collapse_id := 'chat:' || COALESCE(NEW.reference_id, NEW.id::TEXT);
  ELSIF v_type IN ('borrow_request', 'borrow_approved', 'borrow_rejected', 'item_returned') THEN
    v_path := '/requests';
    v_priority := CASE WHEN v_type = 'borrow_request' THEN 'high' ELSE 'normal' END;
    v_sound := CASE WHEN v_type = 'borrow_request' THEN 'critical_alarm' ELSE 'notification' END;
    v_ttl := 1800;
    v_collapse_id := 'borrow:' || COALESCE(NEW.reference_id, NEW.id::TEXT);
  ELSIF v_type IN ('stock_low', 'stock_out') THEN
    v_path := '/inventory';
    v_priority := 'high';
    v_sound := 'critical_alarm';
    v_ttl := 7200;
    v_collapse_id := 'stock:' || COALESCE(NEW.reference_id, NEW.id::TEXT);
  ELSIF v_type IN ('user_approved', 'user_reactivated') THEN
    v_path := '/dashboard';
    v_priority := 'normal';
    v_sound := 'notification';
    v_ttl := 86400;
    v_collapse_id := 'account:' || COALESCE(NEW.reference_id, NEW.id::TEXT);
  ELSIF v_type = 'user_suspended' THEN
    v_path := '/login';
    v_priority := 'high';
    v_sound := 'critical_alarm';
    v_ttl := 86400;
    v_collapse_id := 'account:' || COALESCE(NEW.reference_id, NEW.id::TEXT);
  END IF;

  INSERT INTO public.notification_events (
    event_type,
    audience,
    payload,
    idempotency_key
  ) VALUES (
    v_type,
    jsonb_build_object('user_ids', to_jsonb(v_user_ids)),
    jsonb_build_object(
      'title', COALESCE(NEW.title, 'ResQTrack Alert'),
      'body', COALESCE(NEW.message, 'Check your dashboard for updates.'),
      'path', v_path,
      'channel_id', 'emergency_coordination_v7',
      'sound', v_sound,
      'priority', v_priority,
      'ttl_seconds', v_ttl,
      'collapse_id', v_collapse_id,
      'metadata', COALESCE(NEW.metadata, '{}'::jsonb)
    ),
    'sys:' || NEW.id::TEXT
  )
  ON CONFLICT (idempotency_key) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enqueue_system_notification_event ON public.system_notifications;
CREATE TRIGGER trg_enqueue_system_notification_event
AFTER INSERT ON public.system_notifications
FOR EACH ROW
EXECUTE FUNCTION public.trg_enqueue_system_notification_event();

SELECT 'Notification event routing V1 applied' AS status;
