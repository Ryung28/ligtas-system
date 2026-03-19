-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - POLYMORPHIC READ RECEIPTS (V4.1)
-- ============================================================================
-- PROBLEM: Shared 'is_read' on broadcasts clears alerts for entire organization.
-- SOLUTION: Isolate read state in Junction Table 'notification_reads'.
-- ============================================================================

BEGIN;

-- 1. Drop existing column (Clean slate for Sink V4)
ALTER TABLE "public"."system_notifications" DROP COLUMN IF EXISTS "is_read";

-- 2. Create the Sink-State Junction
CREATE TABLE IF NOT EXISTS "public"."notification_reads" (
    "notification_id" UUID NOT NULL REFERENCES "public"."system_notifications"("id") ON DELETE CASCADE,
    "user_id" UUID NOT NULL REFERENCES "auth"."users"("id") ON DELETE CASCADE,
    "read_at" TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY ("notification_id", "user_id")
);

-- Optimization: Fast lookup for current user's unread status
CREATE INDEX IF NOT EXISTS "idx_notification_reads_user_mapping" ON "public"."notification_reads"("user_id", "notification_id");

-- 🛡️ SECURITY: STEEL CAGE RLS
ALTER TABLE "public"."notification_reads" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notification_reads_select_own" ON "public"."notification_reads"
FOR SELECT TO authenticated
USING (auth.uid() = "user_id");

CREATE POLICY "notification_reads_insert_own" ON "public"."notification_reads"
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = "user_id");

-- 3. Create RPC for the Unified Inbox (The Frontend Interface)
-- Handles the join internally for a computed 'is_read' boolean.
CREATE OR REPLACE FUNCTION "public"."get_user_inbox"(p_limit INT DEFAULT 20)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    type TEXT,
    title TEXT,
    message TEXT,
    reference_id TEXT,
    created_at TIMESTAMPTZ,
    is_read BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sn.id,
        sn.user_id,
        sn.type,
        sn.title,
        sn.message,
        sn.reference_id,
        sn.created_at,
        EXISTS (
            SELECT 1 FROM "public"."notification_reads" nr 
            WHERE nr.notification_id = sn.id 
            AND nr.user_id = auth.uid()
        ) AS is_read
    FROM public.system_notifications sn
    WHERE 
        sn.user_id IS NULL -- broadcasts
        OR sn.user_id = auth.uid() -- targeted personal alerts
    ORDER BY sn.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMIT;
