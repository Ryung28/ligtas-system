-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - NOTIFICATION PIPELINE SETUP
-- ============================================================================
-- 1. FCM TOKEN REGISTRY
-- This dedicated table allows one user to have multiple devices (phone, tablet).
-- ================================================

CREATE TABLE IF NOT EXISTS user_fcm_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    fcm_token TEXT UNIQUE NOT NULL,
    device_platform TEXT CHECK (device_platform IN ('ios', 'android', 'web')),
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast token lookups during dispatch
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user_id ON user_fcm_tokens(user_id);

-- 2. SECURITY (RLS)
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own tokens" ON user_fcm_tokens;
CREATE POLICY "Users can manage their own tokens" 
ON user_fcm_tokens FOR ALL 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 3. NOTIFICATION TRIGGER LOGIC
-- Automatically triggers the Edge Function when a new chat_message is inserted.

-- Note: pg_net enables asynchronous HTTP dispatch without blocking the transaction.
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ============================================================================
-- 🛡️ HARDENED DISPATCHER: No hardcoded secrets.
-- The Service Role Key is retrieved from Supabase Vault at runtime.
-- Steps to configure:
--   1. Go to Dashboard → Vault → New Secret
--   2. Name it: 'service_role_key'
--   3. Paste your Service Role Key as the value
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_chat_message()
RETURNS TRIGGER AS $$
DECLARE
  project_ref      TEXT := 'knarlvwnuvedyfvvaota';
  service_role_key TEXT;
BEGIN
  -- 🔑 Retrieve key from Vault (zero hardcoded secrets)
  SELECT decrypted_secret INTO service_role_key
  FROM vault.decrypted_secrets
  WHERE name = 'service_role_key'
  LIMIT 1;

  -- 🛡️ HARDENED LOGGING: Alert via Dashboard if Vault is misconfigured
  IF service_role_key IS NULL THEN
    RAISE WARNING '[LIGTAS-Dispatcher] 🛑 MISSION_BLOCK: service_role_key not found in Vault. Notifications deferred.';
    RETURN NEW;
  END IF;

  -- 📡 DISPATCH: Coordinated Broadcast via Edge Function
  -- X-Payload-Version: 2 triggers the Omni-Directional routing in index.ts
  PERFORM net.http_post(
    url     := 'https://' || project_ref || '.supabase.co/functions/v1/push-notification',
    headers := jsonb_build_object(
      'Content-Type',      'application/json',
      'Authorization',     'Bearer ' || service_role_key,
      'X-Payload-Version', '2'
    ),
    body    := jsonb_build_object('record', row_to_json(NEW))
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. TRIGGER DEPLOYMENT (Targeting correct schema)
DROP TRIGGER IF EXISTS tr_notify_on_new_chat_message ON public.chat_messages;
CREATE TRIGGER tr_notify_on_new_chat_message
AFTER INSERT ON public.chat_messages
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_chat_message();

-- ============================================================================
-- 5. DEVICE TOKEN REGISTRY RPC (The Missing Link)
-- ============================================================================
-- This RPC allows the mobile app to register its FCM token on app startup.
-- 🛡️ SECURITY DEFINER: Bypasses RLS so the client can write its own token.
-- 🛡️ ON CONFLICT: Ensures tokens stay unique and last_seen_at stays fresh.
-- Callable from the mobile client via: supabase.rpc('handle_device_token', {...})
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_device_token(
  p_user_id UUID,
  p_token TEXT,
  p_platform TEXT
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_fcm_tokens (user_id, fcm_token, device_platform, last_seen_at)
  VALUES (p_user_id, p_token, p_platform, NOW())
  ON CONFLICT (fcm_token) DO UPDATE SET
    user_id     = p_user_id,
    last_seen_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to authenticated users only
REVOKE ALL ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) TO authenticated;

SELECT 'Notification Pipeline Infrastructure: READY (v2 — Token RPC Added)' as status;
