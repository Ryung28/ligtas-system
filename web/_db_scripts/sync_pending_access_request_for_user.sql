-- ============================================================================
-- Sync access_requests when user_profiles becomes active outside approve_user
-- (e.g. auth callback whitelist promotion, reactivate, authorize whitelist).
-- Prevents stale ACCESS rows in public.system_intel (pending access_requests).
-- ============================================================================

CREATE OR REPLACE FUNCTION public.sync_pending_access_request_for_user(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  ok boolean;
BEGIN
  ok := (auth.uid() = p_user_id)
    OR EXISTS (
      SELECT 1
      FROM public.user_profiles up
      WHERE up.id = auth.uid()
        AND up.role = 'admin'
        AND up.status = 'active'::user_status
    );
  IF NOT ok THEN
    RAISE EXCEPTION 'sync_pending_access_request_for_user: not allowed';
  END IF;

  UPDATE public.access_requests
  SET
    status = 'approved',
    approved_at = COALESCE(approved_at, NOW()),
    approved_by = COALESCE(approved_by, auth.uid())
  WHERE user_id = p_user_id
    AND status = 'pending';
END;
$$;

GRANT EXECUTE ON FUNCTION public.sync_pending_access_request_for_user(uuid) TO authenticated;

-- One-time repair (run manually on environments that already have drift):
-- UPDATE public.access_requests ar
-- SET status = 'approved', approved_at = COALESCE(ar.approved_at, NOW())
-- FROM public.user_profiles up
-- WHERE ar.user_id = up.id AND ar.status = 'pending' AND up.status::text = 'active';
