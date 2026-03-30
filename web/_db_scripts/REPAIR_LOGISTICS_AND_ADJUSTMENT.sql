-- REPAIRING LOGISTICS SYSTEM: Fixing ID mismatches and adding manual adjustment support

-- 1. FIX LOGISTICS ACTIONS SCHEMA
-- Change item_id from UUID to BIGINT to match our inventory table
ALTER TABLE public.logistics_actions 
ALTER COLUMN item_id TYPE BIGINT USING (NULL); -- We wipe old test data to ensure clean migration

-- 2. EXPAND PERMITTED TYPES
-- Add 'adjustment' to the check constraint
ALTER TABLE public.logistics_actions 
DROP CONSTRAINT IF EXISTS logistics_actions_type_check;

ALTER TABLE public.logistics_actions 
ADD CONSTRAINT logistics_actions_type_check 
CHECK (type IN ('dispense', 'dispose', 'audit', 'return', 'adjustment'));

-- 3. THE ATOMIC ENGINE: RPC for Safe Stock Adjustments
-- This function ensures we update the stock and record the log in a single transaction.
CREATE OR REPLACE FUNCTION public.adjust_inventory_item(
    p_item_id BIGINT,
    p_old_quantity INTEGER,
    p_new_quantity INTEGER,
    p_action_type TEXT,
    p_forensic_note TEXT,
    p_item_name TEXT
)
RETURNS VOID AS $$
BEGIN
    -- A. Update the primary stock level
    UPDATE public.inventory
    SET stock_available = p_new_quantity,
        updated_at = now()
    WHERE id = p_item_id;

    -- B. Record the forensic signature
    INSERT INTO public.logistics_actions (
        item_id,
        item_name,
        type,
        status,
        quantity,
        forensic_note,
        created_at
    ) VALUES (
        p_item_id,
        p_item_name,
        p_action_type,
        'completed',
        ABS(p_new_quantity - p_old_quantity),
        p_forensic_note,
        now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
