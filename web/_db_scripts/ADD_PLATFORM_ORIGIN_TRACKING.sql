-- ADD_PLATFORM_ORIGIN_TRACKING.sql
-- LIGTAS Inventory System - Forensic Traceability Upgrade
-- This script adds the ability to distinguish between Web Dashboard and Mobile Terminal transactions.

-- 1. ADD ORIGIN COLUMN
-- We use 'Web' as a default for existing records to maintain historical continuity.
ALTER TABLE public.borrow_logs 
ADD COLUMN IF NOT EXISTS platform_origin TEXT DEFAULT 'Web' CHECK (platform_origin IN ('Web', 'Mobile'));

-- 2. PERFORMANCE INDEXING
-- Enables fast filtering for "Field Only" or "Office Only" audit reports.
CREATE INDEX IF NOT EXISTS idx_borrow_logs_platform_origin ON public.borrow_logs(platform_origin);

-- 3. SCHEMA DOCUMENTATION
COMMENT ON COLUMN public.borrow_logs.platform_origin IS 'The system source of the transaction: Web (Command Center) or Mobile (Field Analyst).';

-- 4. HISTORICAL DATA SYNC
-- Ensure any NULLs from previous partial migrations are normalized to 'Web'.
UPDATE public.borrow_logs 
SET platform_origin = 'Web' 
WHERE platform_origin IS NULL;

-- 5. UNIFICATION NOTE
-- Note: Both platforms should now write to 'released_by_name' for handoffs.
-- Mobile 'handed_by' is being deprecated in favor of 'released_by_name' to match Web SSOT.

SELECT 'SUCCESS: platform_origin tracking enabled on borrow_logs table.' as status;
