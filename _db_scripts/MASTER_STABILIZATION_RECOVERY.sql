-- ============================================================================
-- 🛡️ LIGTAS MASTER STABILIZATION RECOVERY SCRIPT (V2 - CLEAN REPAIR)
-- ============================================================================
-- FIX: ERROR 42725: function name is not unique (Overloaded functions)
-- ============================================================================

-- ── 1. LOGISTICS SCHEMA RECOVERY ──
ALTER TABLE public.logistics_actions 
ADD COLUMN IF NOT EXISTS recipient_name TEXT,
ADD COLUMN IF NOT EXISTS recipient_office TEXT;

-- ── 2. ATOMIC LOGISTICS RPC REPAIR ──
-- 🛡️ FORCE DROP: Liquidating all previous overloaded signatures to avoid collision
DROP FUNCTION IF EXISTS public.adjust_inventory_item(BIGINT, INTEGER, INTEGER, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.adjust_inventory_item(BIGINT, INTEGER, INTEGER, TEXT, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.adjust_inventory_item(
    p_item_id BIGINT,
    p_old_quantity INTEGER,
    p_new_quantity INTEGER,
    p_action_type TEXT,
    p_forensic_note TEXT,
    p_item_name TEXT,
    p_recipient_name TEXT DEFAULT NULL,
    p_recipient_office TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_diff INTEGER;
BEGIN
    v_diff := p_new_quantity - p_old_quantity;

    -- Update inventory stock
    UPDATE public.inventory 
    SET quantity = p_new_quantity,
        updated_at = NOW()
    WHERE id = p_item_id;

    -- Record Structured Logistics Action
    INSERT INTO public.logistics_actions (
        inventory_id,
        item_name,
        action_type,
        quantity_changed,
        new_quantity,
        note,
        recipient_name,
        recipient_office,
        created_at
    ) VALUES (
        p_item_id,
        p_item_name,
        p_action_type,
        v_diff,
        p_new_quantity,
        p_forensic_note,
        p_recipient_name,
        p_recipient_office,
        NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 3. THE MASTER KEY: 100% RELIABLE ADMIN RLS BYPASS ──
DROP POLICY IF EXISTS "unified_borrow_logs_select" ON borrow_logs;

CREATE POLICY "unified_borrow_logs_select" ON borrow_logs 
  FOR SELECT 
  TO authenticated 
  USING (
    -- 🛡️ MASTER KEY: Direct JWT bypass
    (auth.jwt() ->> 'email') = 'admin@ligtas-cdrrmo.ph'
    OR 
    (auth.uid() = borrower_user_id)
  );

-- ── VERIFICATION ──
COMMENT ON FUNCTION public.adjust_inventory_item IS 'LIGTAS-v2: Multi-transaction atomic inventory sync with recipient metadata.';
SELECT '✅ STABILIZATION COMPLETE: Function overloading resolved and RLS applied.' as status;
