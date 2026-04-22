-- ============================================================================
-- Add long-term phone field for profile completeness checks
-- ============================================================================

ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS phone_number TEXT;

-- Backfill from auth metadata when available.
UPDATE public.user_profiles up
SET phone_number = NULLIF(BTRIM(au.raw_user_meta_data ->> 'phone_number'), '')
FROM auth.users au
WHERE au.id = up.id
  AND (up.phone_number IS NULL OR BTRIM(up.phone_number) = '')
  AND NULLIF(BTRIM(au.raw_user_meta_data ->> 'phone_number'), '') IS NOT NULL;
