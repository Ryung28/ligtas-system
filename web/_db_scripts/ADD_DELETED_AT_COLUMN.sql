-- ============================================================================
-- LIGTAS SYSTEM - ADD DELETED_AT FOR SOFT DELETE
-- ============================================================================
-- This script adds the deleted_at column to the inventory table
-- to support the "Steel Cage" archiving protocol.

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'deleted_at') THEN 
        ALTER TABLE inventory ADD COLUMN deleted_at TIMESTAMPTZ;
    END IF;
END $$;

SELECT 'Inventory Schema Updated: deleted_at column ensured' as status;
