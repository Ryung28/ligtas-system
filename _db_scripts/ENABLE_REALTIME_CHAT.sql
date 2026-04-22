-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - REALTIME CHAT ENROLLMENT (ROBUST VERSION)
-- ============================================================================
-- Run this in the Supabase SQL Editor.
-- This version uses DO blocks for idempotency to avoid syntax errors on different PG versions.
-- ================================================

-- 1. ENABLE REALTIME FOR CHAT TABLES
DO $$
BEGIN
    -- Ensure publication exists
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        CREATE PUBLICATION supabase_realtime;
    END IF;

    -- Add chat_messages if not already present
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'chat_messages'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
    END IF;

    -- Add chat_rooms if not already present
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'chat_rooms'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms;
    END IF;
END $$;

-- 2. OPTIMIZE RLS POLICIES WITH INDEXES
-- This ensures the Socket Authorization doesn't time out during heavy load.

-- Ensure indexes exist for RLS lookups
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON chat_messages(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_borrower_id ON chat_rooms(borrower_user_id);

-- Example RLS Policy for chat_messages (Verify current user has access to room)
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view messages in their rooms" ON chat_messages;
CREATE POLICY "Users can view messages in their rooms" 
ON chat_messages FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM chat_rooms 
    WHERE chat_rooms.id = chat_messages.room_id 
    AND (
      chat_rooms.borrower_user_id = auth.uid() 
      OR EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND (role = 'admin' OR role = 'staff')
      )
    )
  )
);

-- RLS Policy for sending messages
DROP POLICY IF EXISTS "Users can insert messages in their rooms" ON chat_messages;
CREATE POLICY "Users can insert messages in their rooms" 
ON chat_messages FOR INSERT 
TO authenticated 
WITH CHECK (
  auth.uid() = sender_id 
  AND EXISTS (
    SELECT 1 FROM chat_rooms 
    WHERE chat_rooms.id = room_id 
    AND (
      chat_rooms.borrower_user_id = auth.uid() 
      OR EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND (role = 'admin' OR role = 'staff')
      )
    )
  )
);

SELECT 'Realtime Enrollment & RLS Optimization: COMPLETED (Robust Mode)' as status;
