-- ============================================================================
-- LIGTAS SYSTEM - IDEMPOTENT DEVICE REGISTRATION
-- ============================================================================
-- 🛠️ 1. HANDLE DEVICE TOKEN RPC
-- Resolves 'Unique Constraint' errors by using an UPSERT pattern.

CREATE OR REPLACE FUNCTION public.handle_device_token(
    p_user_id UUID, 
    p_token TEXT, 
    p_platform TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.user_fcm_tokens (
        user_id, 
        fcm_token, 
        device_platform, 
        last_seen_at
    )
    VALUES (
        p_user_id, 
        p_token, 
        p_platform, 
        NOW()
    )
    ON CONFLICT (fcm_token) 
    DO UPDATE SET 
        user_id = EXCLUDED.user_id,
        last_seen_at = NOW(),
        device_platform = EXCLUDED.device_platform;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 🛡️ 2. PERMISSIONS
GRANT EXECUTE ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.handle_device_token(UUID, TEXT, TEXT) TO service_role;
