-- Align SELECT RLS with get_user_inbox audience rules so manager broadcasts
-- (user_id IS NULL) are not visible to viewer sessions over Realtime.
DROP POLICY IF EXISTS authenticated_select_notifications ON public.system_notifications;

CREATE POLICY authenticated_select_notifications
ON public.system_notifications
FOR SELECT
TO authenticated
USING (
  (user_id = auth.uid())
  OR (
    user_id IS NULL
    AND COALESCE(metadata->>'audience_role', 'manager') IN (
      'all',
      COALESCE(
        (
          SELECT CASE
            WHEN COALESCE(LOWER(up.role), 'viewer') IN (
              'admin',
              'editor',
              'manager',
              'inventory_manager',
              'inventory manager'
            ) THEN 'manager'::text
            ELSE 'user'::text
          END
          FROM public.user_profiles AS up
          WHERE up.id = auth.uid()
        ),
        'user'::text
      )
    )
  )
);
