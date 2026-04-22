-- ============================================================================
-- LIGTAS CDRRMO - FCM RELIABILITY BLUEPRINT (V1)
-- ============================================================================
-- Purpose:
-- 1) Canonical device-token registry RPC (single source of truth)
-- 2) Notification event queue for async dispatch
-- 3) Delivery ledger for observability + retry decisions
-- ============================================================================

-- --------------------------------------------------------------------------
-- 0. Token table hardening (backward compatible)
-- --------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.user_fcm_tokens
  ADD COLUMN IF NOT EXISTS device_id TEXT,
  ADD COLUMN IF NOT EXISTS app_version TEXT,
  ADD COLUMN IF NOT EXISTS invalidated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS invalid_reason TEXT,
  ADD COLUMN IF NOT EXISTS last_success_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id
  ON public.user_fcm_tokens (user_id);

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_last_seen_at
  ON public.user_fcm_tokens (last_seen_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_active
  ON public.user_fcm_tokens (user_id, invalidated_at)
  WHERE invalidated_at IS NULL;

-- --------------------------------------------------------------------------
-- 1. Canonical registration RPC
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.register_device_token(
  p_user_id UUID,
  p_token TEXT,
  p_platform TEXT,
  p_device_id TEXT DEFAULT NULL,
  p_app_version TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO public.user_fcm_tokens (
    user_id,
    fcm_token,
    device_platform,
    device_id,
    app_version,
    last_seen_at,
    invalidated_at,
    invalid_reason
  )
  VALUES (
    p_user_id,
    p_token,
    p_platform,
    p_device_id,
    p_app_version,
    NOW(),
    NULL,
    NULL
  )
  ON CONFLICT (fcm_token)
  DO UPDATE SET
    user_id = EXCLUDED.user_id,
    device_platform = EXCLUDED.device_platform,
    device_id = COALESCE(EXCLUDED.device_id, public.user_fcm_tokens.device_id),
    app_version = COALESCE(EXCLUDED.app_version, public.user_fcm_tokens.app_version),
    last_seen_at = NOW(),
    invalidated_at = NULL,
    invalid_reason = NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE ALL ON FUNCTION public.register_device_token(UUID, TEXT, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.register_device_token(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.register_device_token(UUID, TEXT, TEXT, TEXT, TEXT) TO service_role;

-- Backward compatibility shim for existing mobile clients.
CREATE OR REPLACE FUNCTION public.handle_device_token(
  p_user_id UUID,
  p_token TEXT,
  p_platform TEXT
)
RETURNS VOID AS $$
BEGIN
  PERFORM public.register_device_token(
    p_user_id,
    p_token,
    p_platform,
    NULL,
    NULL
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE ALL ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) TO service_role;

-- --------------------------------------------------------------------------
-- 2. Event queue (async dispatch source)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  audience JSONB NOT NULL DEFAULT '{}'::jsonb,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'sent', 'partial', 'failed', 'dead')),
  attempt_count INT NOT NULL DEFAULT 0,
  next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  idempotency_key TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_events_status_retry
  ON public.notification_events (status, next_attempt_at);

CREATE INDEX IF NOT EXISTS idx_notification_events_created
  ON public.notification_events (created_at DESC);

ALTER TABLE public.notification_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "service_role_manage_notification_events" ON public.notification_events;
CREATE POLICY "service_role_manage_notification_events"
ON public.notification_events
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- --------------------------------------------------------------------------
-- 3. Delivery ledger (per-token send outcomes)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.notification_events(id) ON DELETE CASCADE,
  user_id UUID,
  token_id UUID REFERENCES public.user_fcm_tokens(id) ON DELETE SET NULL,
  provider TEXT NOT NULL DEFAULT 'fcm',
  provider_message_id TEXT,
  attempt_no INT NOT NULL DEFAULT 1,
  result TEXT NOT NULL
    CHECK (result IN ('success', 'retryable_failure', 'permanent_failure')),
  error_code TEXT,
  error_message TEXT,
  latency_ms INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_deliveries_event_id
  ON public.notification_deliveries (event_id);

CREATE INDEX IF NOT EXISTS idx_notification_deliveries_result_time
  ON public.notification_deliveries (result, created_at DESC);

ALTER TABLE public.notification_deliveries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "service_role_manage_notification_deliveries" ON public.notification_deliveries;
CREATE POLICY "service_role_manage_notification_deliveries"
ON public.notification_deliveries
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- --------------------------------------------------------------------------
-- 4. Event enqueue RPC (idempotent)
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enqueue_notification_event(
  p_event_type TEXT,
  p_audience JSONB DEFAULT '{}'::jsonb,
  p_payload JSONB DEFAULT '{}'::jsonb,
  p_idempotency_key TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO public.notification_events (
    event_type,
    audience,
    payload,
    idempotency_key
  )
  VALUES (
    p_event_type,
    COALESCE(p_audience, '{}'::jsonb),
    COALESCE(p_payload, '{}'::jsonb),
    p_idempotency_key
  )
  ON CONFLICT (idempotency_key)
  DO UPDATE SET
    updated_at = NOW()
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE ALL ON FUNCTION public.enqueue_notification_event(TEXT, JSONB, JSONB, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.enqueue_notification_event(TEXT, JSONB, JSONB, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.enqueue_notification_event(TEXT, JSONB, JSONB, TEXT) TO service_role;

SELECT 'FCM Reliability Blueprint V1 applied' AS status;
