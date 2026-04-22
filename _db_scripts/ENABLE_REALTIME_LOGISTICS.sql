-- 🏛️ SENIOR ARCHITECT IDEMPOTENT REALTIME SETUP
-- This script enables Supabase Realtime for the three pillars of LIGTAS Logistics.
-- Designed to be run multiple times without causing "Relation already exists" errors.

DO $$
BEGIN
    -- 1. Ensure the publication exists
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        CREATE PUBLICATION supabase_realtime;
    END IF;

    -- 2. Add 'inventory' if not already present
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'inventory'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE inventory;
    END IF;

    -- 3. Add 'borrow_logs' if not already present
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'borrow_logs'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE borrow_logs;
    END IF;

    -- 4. Add 'storage_locations' if not already present
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'storage_locations'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE storage_locations;
    END IF;

END $$;

-- 🏛️ PERFORMANCE: Set 'Full' replica identity for accurate delta tracking.
-- This allows the stream to send the PREVIOUS state of an item during updates.
ALTER TABLE inventory REPLICA IDENTITY FULL;
ALTER TABLE borrow_logs REPLICA IDENTITY FULL;
ALTER TABLE storage_locations REPLICA IDENTITY FULL;

