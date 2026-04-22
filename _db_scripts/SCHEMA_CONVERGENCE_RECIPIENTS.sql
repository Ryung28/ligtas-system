-- 🛡️ SCHEMA CONVERGENCE: Adding Structured Recipient Data
-- This migration ensures that field actions (mobile) align with the Web's reporting requirements.

-- 1. ADD STRUCTURED COLUMNS
ALTER TABLE public.logistics_actions 
ADD COLUMN IF NOT EXISTS recipient_name TEXT,
ADD COLUMN IF NOT EXISTS recipient_office TEXT;

-- 2. UPDATE THE ATOMIC ENGINE
-- We replace the previous version with one that accepts structured metadata.
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
BEGIN
    -- A. Update the primary stock level
    UPDATE public.inventory
    SET stock_available = p_new_quantity,
        updated_at = now()
    WHERE id = p_item_id;

    -- B. Record the forensic signature (The Receipt)
    INSERT INTO public.logistics_actions (
        item_id,
        item_name,
        type,
        status,
        quantity,
        forensic_note,
        recipient_name,
        recipient_office,
        created_at
    ) VALUES (
        p_item_id,
        p_item_name,
        p_action_type,
        'completed',
        ABS(p_new_quantity - p_old_quantity),
        p_forensic_note,
        p_recipient_name,
        p_recipient_office,
        now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
