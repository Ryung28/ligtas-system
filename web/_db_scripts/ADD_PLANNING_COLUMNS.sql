-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - PLANNING & LOGISTICS COLUMNS
-- ============================================================================
-- Adds 'target_stock' and 'low_stock_threshold' to the inventory table.
-- These are used for administrative stock goals and automated alerting.
-- ============================================================================

DO $$ 
BEGIN 
    -- 1. Administrative Stock Goal (Max Stock)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'target_stock') THEN 
        ALTER TABLE inventory ADD COLUMN target_stock INTEGER NOT NULL DEFAULT 0;
    END IF;

    -- 2. Low Stock Alert Threshold (%)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'inventory' AND column_name = 'low_stock_threshold') THEN 
        ALTER TABLE inventory ADD COLUMN low_stock_threshold INTEGER NOT NULL DEFAULT 20;
    END IF;
END $$;

SELECT '✅ Planning columns added to inventory table' as status;
