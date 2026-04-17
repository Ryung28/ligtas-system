-- 🎯 SUPER SENIOR RPC PATCH: BROADCAST RECOVERY (V2: TYPE-SAFETY FIX)
-- This script redeclares get_user_inbox with correct TEXT type for polymorphic reference_id
-- to avoid Postgres 42804 "cannot change return type of existing function" errors.

-- 1. DROP EXISTING TO PURGE OLD TYPE SIGNATURE
DROP FUNCTION IF EXISTS public.get_user_inbox(INT);

-- 2. CREATE PATCHED FUNCTION WITH TEXT REFERENCE_ID
CREATE OR REPLACE FUNCTION public.get_user_inbox(p_limit INT DEFAULT 20)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    reference_id TEXT, -- 🛡️ POLYMORPHIC: Align with sn.reference_id (TEXT)
    title TEXT,
    message TEXT,
    type TEXT,
    metadata JSONB, -- 🛡️ CONTEXTUAL PAYLOAD: Added for precision deep-linking
    created_at TIMESTAMPTZ,
    is_read BOOLEAN
) AS $$
DECLARE
    v_role TEXT;
    v_audience TEXT;
BEGIN
    SELECT up.role
    INTO v_role
    FROM public.user_profiles up
    WHERE up.id = auth.uid();

    v_audience := CASE
        WHEN COALESCE(LOWER(v_role), 'viewer') IN ('admin', 'editor', 'manager', 'inventory_manager', 'inventory manager')
            THEN 'manager'
        ELSE 'user'
    END;

    RETURN QUERY
    SELECT 
        sn.id,
        sn.user_id,
        sn.reference_id, -- Already a TEXT column in system_notifications
        sn.title,
        sn.message,
        sn.type,
        sn.metadata, -- 🛡️ DYNAMIC INTEL: Pass-through from system_notifications
        sn.created_at,
        (nr.notification_id IS NOT NULL) AS is_read
    FROM public.system_notifications sn
    -- 🛡️ TACTICAL SILO: Left join only on the CURRENT user's read receipts
    LEFT JOIN public.notification_reads nr 
        ON sn.id = nr.notification_id AND nr.user_id = auth.uid()
    -- 🛡️ ROLE-AWARE BROADCAST: users only see their lane
    WHERE
        sn.user_id = auth.uid()
        OR (
            sn.user_id IS NULL
            AND COALESCE(sn.metadata->>'audience_role', 'manager') IN ('all', v_audience)
        )
    ORDER BY sn.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 🛡️ SECURITY AUDIT: Ensure the function is accessible by authenticated users
GRANT EXECUTE ON FUNCTION public.get_user_inbox(INT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_inbox(INT) TO service_role;
