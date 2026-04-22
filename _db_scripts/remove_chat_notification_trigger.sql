-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - REMOVE CHAT NOTIFICATION TRIGGER
-- ============================================================================
-- PURPOSE: Disable chat notifications in notification bell
-- REASON: Chat already handled by sidebar badge system
-- BENEFIT: Reduces database writes and storage usage
-- ============================================================================

-- Drop the chat notification trigger
DROP TRIGGER IF EXISTS trg_chat_intel ON chat_messages;

-- Drop the trigger function
DROP FUNCTION IF EXISTS trg_handle_chat_alerts();

-- Clean up existing chat notifications from system_notifications table
DELETE FROM system_notifications WHERE type = 'chat_message';

SELECT 'Chat notification trigger: REMOVED' as status;
SELECT 'Chat notifications now handled exclusively by sidebar badge' as note;
