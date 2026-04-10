-- ============================================================================
-- 🏗️ LIGTAS ARCHITECT: NOTIFICATION PIPELINE REFACTOR (V4.1 - NATIVE)
-- Goal: Aggressive Simplification. Remove fragile pg_net/Vault logic.
-- Pattern: Supabase Native Database Webhooks.
-- ============================================================================

-- 1. CLEANUP: Remove the "Rube Goldberg" manual HTTP dispatch
-- 🛡️ CASCADE: This will automatically drop ANY triggers depending on this function
-- (Handles 'tr_notify_on_new_chat_message', 'on_chat_message_inserted', etc.)

DROP TRIGGER IF EXISTS tr_notify_on_new_chat_message ON public.chat_messages;
DROP TRIGGER IF EXISTS on_chat_message_inserted ON public.chat_messages;
DROP FUNCTION IF EXISTS public.handle_new_chat_message() CASCADE;

-- 2. VERIFY: Ensure the Device Token Registry is intact
-- This table and RPC are the "Source of Truth" for the mobile app's signal.
-- They do NOT need to be changed as they are already stable.

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'user_fcm_tokens') THEN
        RAISE NOTICE 'Note: user_fcm_tokens table not found. Ensure SETUP_NOTIFICATION_PIPELINE.sql was run.';
    END IF;
END $$;

-- ============================================================================
-- 🛡️ MANUAL ACTION REQUIRED (THE "STEEL CAGE" STEP)
-- ============================================================================
-- Native Webhooks are managed by the Supabase platform infrastructure. 
-- To ensure this never breaks when your project ID or keys change:
--
-- 1. Go to: Supabase Dashboard -> Database -> Webhooks.
-- 2. Click "Create a new Webhook".
-- 3. Configuration:
--    - Name: dispatch_chat_push
--    - Table: chat_messages
--    - Events: INSERT (Check this box)
-- 4. Webhook Destination:
--    - Type: Supabase Edge Function
--    - Function: push-notification (Select from dropdown)
--    - Method: POST
--    - Timeout: 5000
-- 5. Click "Save".
-- ============================================================================

SELECT 'Notification Pipeline: Legacy logic PURGED. Native Webhook READY for manual activation.' as status;
