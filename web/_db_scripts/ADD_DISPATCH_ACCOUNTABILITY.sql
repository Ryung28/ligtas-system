-- ADD_DISPATCH_ACCOUNTABILITY.sql
-- LIGTAS Inventory System - Accountability Refactor
-- Finalizing the "Chain of Custody" for equipment dispatch.

-- 1. Update borrow_logs to support internal and guest accountability
ALTER TABLE public.borrow_logs 
ADD COLUMN IF NOT EXISTS approved_by_name TEXT,
ADD COLUMN IF NOT EXISTS released_by_name TEXT,
ADD COLUMN IF NOT EXISTS released_by_user_id UUID REFERENCES auth.users(id);

-- 2. Backfill existing records with a placeholder if needed (optional)
-- COMMENTED OUT: Update only if you want consistency for old data.
-- UPDATE public.borrow_logs SET released_by_name = 'System (Legacy)' WHERE released_by_name IS NULL;

-- 3. Create a view or function for "Borrower History" to power Smart Autocomplete
CREATE OR REPLACE VIEW public.borrower_registry AS
SELECT DISTINCT borrower_name, borrower_contact, borrower_organization
FROM public.borrow_logs
WHERE borrower_name IS NOT NULL
ORDER BY borrower_name ASC;

-- 4. Enable RLS permissions for the new columns
-- Assuming existing RLS allows insert/update for managers.
GRANT ALL ON TABLE public.borrow_logs TO authenticated;
GRANT SELECT ON public.borrower_registry TO authenticated;

COMMENT ON COLUMN public.borrow_logs.approved_by_name IS 'The authorizing officer (Manager/Guest) who signed off the dispatch.';
COMMENT ON COLUMN public.borrow_logs.released_by_name IS 'The logistics staff who physically handed over the items (Session-based).';
