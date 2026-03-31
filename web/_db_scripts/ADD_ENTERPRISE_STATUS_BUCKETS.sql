-- ADD STATUS BUCKETS TO INVENTORY (THE ENTERPRISE WAY)
-- This enables "Sub-Bucket" management within a single row.
-- RUN THIS IN YOUR SUPABASE SQL EDITOR FIRST.

ALTER TABLE IF EXISTS public.inventory 
ADD COLUMN IF NOT EXISTS qty_good INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS qty_damaged INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS qty_maintenance INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS qty_lost INTEGER DEFAULT 0;

-- Migrate existing data based on current status
UPDATE public.inventory 
SET qty_good = stock_total 
WHERE status = 'Good' OR status IS NULL OR status = '';

UPDATE public.inventory 
SET qty_damaged = stock_total 
WHERE status = 'Damaged';

UPDATE public.inventory 
SET qty_maintenance = stock_total 
WHERE status = 'Maintenance';

-- Synchronize stock_available with the 'Good' bucket
UPDATE public.inventory 
SET stock_available = qty_good;

COMMENT ON COLUMN public.inventory.qty_good IS 'Ready for deployment';
COMMENT ON COLUMN public.inventory.qty_damaged IS 'Awaiting or undergoing repair';
COMMENT ON COLUMN public.inventory.qty_maintenance IS 'Scheduled service/calibration';
COMMENT ON COLUMN public.inventory.qty_lost IS 'Missing or unaccounted for';
