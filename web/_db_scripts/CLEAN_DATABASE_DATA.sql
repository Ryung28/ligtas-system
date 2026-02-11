-- ============================================================================
-- LIGTAS SYSTEM - CLEAN DATA SCRIPT
-- ============================================================================
-- DESCRIPTION:
-- This script clears ALL data from the system tables but keeps the table structure.
-- Run this when you are ready to start encoding REAL CDRRMO inventory data.
-- ============================================================================

-- 1. Clears specific tables (CASCADE ensures linked logs are also cleared)
TRUNCATE TABLE borrow_logs, inventory RESTART IDENTITY CASCADE;

-- 2. (Optional) If you have specific sequences to reset manually, though RESTART IDENTITY handles most.

-- ============================================================================
-- CONFIRMATION
-- ============================================================================
-- After running this, your "Inventory" and "Logs" pages will be completely empty.
-- You can then use the "Add Item" button in the Dashboard to encode real items.
