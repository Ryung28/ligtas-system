-- LOGISTICAL COMMAND CENTER: Forensic Audit Table
-- This table handles manager-level triage for dispense, disposal, and return handovers.

CREATE TABLE IF NOT EXISTS public.logistics_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_name TEXT NOT NULL,
    item_id UUID NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('dispense', 'dispose', 'audit', 'return')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'flagged')),
    quantity INTEGER NOT NULL DEFAULT 1,
    requester_id UUID,
    requester_name TEXT,
    warehouse_id TEXT,
    bin_location TEXT,
    forensic_note TEXT,
    forensic_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 🛡️ THE STEEL CAGE: Row Level Security
ALTER TABLE public.logistics_actions ENABLE ROW LEVEL SECURITY;

-- Policy: Only authenticated users can see the queue (typically analysts/managers)
-- In a more strict setup, we'd check JWT metadata or a users table for role='staff'
CREATE POLICY "Managers can view logistics queue" 
ON public.logistics_actions FOR SELECT 
TO authenticated 
USING (true); 

-- Policy: Authenticated users can update status (resolution)
CREATE POLICY "Managers can resolve logistics actions" 
ON public.logistics_actions FOR UPDATE 
TO authenticated 
USING (status = 'pending')
WITH CHECK (true);

-- Enable Realtime for the dashboard pulse
ALTER PUBLICATION supabase_realtime ADD TABLE public.logistics_actions;

-- Forensic Indexing for performance at scale
CREATE INDEX IF NOT EXISTS idx_logistics_actions_status ON public.logistics_actions(status);
CREATE INDEX IF NOT EXISTS idx_logistics_actions_type ON public.logistics_actions(type);
CREATE INDEX IF NOT EXISTS idx_logistics_actions_created_at ON public.logistics_actions(created_at DESC);

COMMENT ON TABLE public.logistics_actions IS 'Manager triage center for consumables and asset life-cycle management.';
