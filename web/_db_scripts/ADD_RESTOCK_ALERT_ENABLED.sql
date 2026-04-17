-- ============================================================================
-- Add explicit per-item low-stock alert toggle
-- ============================================================================
ALTER TABLE public.inventory
ADD COLUMN IF NOT EXISTS restock_alert_enabled BOOLEAN NOT NULL DEFAULT true;

UPDATE public.inventory
SET restock_alert_enabled = true
WHERE restock_alert_enabled IS NULL;
