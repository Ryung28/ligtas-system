-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - ADD MISSING COLUMNS TO BORROW_LOGS
-- ============================================================================
-- Fixes "column borrow_logs.borrower_user_id does not exist" and other mismatches.
-- ============================================================================

DO $$ 
BEGIN 
    -- 1. Add borrower_user_id (Crucial for filtering "My Items")
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'borrower_user_id') THEN 
        ALTER TABLE borrow_logs ADD COLUMN borrower_user_id UUID REFERENCES auth.users(id);
        CREATE INDEX IF NOT EXISTS idx_borrow_logs_borrower_user_id ON borrow_logs(borrower_user_id);
    END IF;

    -- 2. Add borrowed_by (Standard field in repository)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'borrowed_by') THEN 
        ALTER TABLE borrow_logs ADD COLUMN borrowed_by UUID REFERENCES auth.users(id);
    END IF;

    -- 3. Add inventory_item_id (Mobile repository uses this name)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'inventory_item_id') THEN 
        ALTER TABLE borrow_logs ADD COLUMN inventory_item_id TEXT;
        -- Sync with existing inventory_id if present
        UPDATE borrow_logs SET inventory_item_id = inventory_id::TEXT WHERE inventory_id IS NOT NULL;
    END IF;

    -- 4. Add item_code
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'item_code') THEN 
        ALTER TABLE borrow_logs ADD COLUMN item_code TEXT;
    END IF;

    -- 5. Add borrower_email
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'borrower_email') THEN 
        ALTER TABLE borrow_logs ADD COLUMN borrower_email TEXT;
    END IF;

    -- 6. Add quantity_borrowed (Repository uses this name)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'quantity_borrowed') THEN 
        ALTER TABLE borrow_logs ADD COLUMN quantity_borrowed INTEGER;
        -- Sync with existing quantity if present
        UPDATE borrow_logs SET quantity_borrowed = quantity WHERE quantity IS NOT NULL;
    END IF;

    -- 7. Add returned_by
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'returned_by') THEN 
        ALTER TABLE borrow_logs ADD COLUMN returned_by UUID REFERENCES auth.users(id);
    END IF;

    -- 8. Add return_notes
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'borrow_logs' AND column_name = 'return_notes') THEN 
        ALTER TABLE borrow_logs ADD COLUMN return_notes TEXT;
    END IF;

END $$;

-- Update RLS Policies to allow users to see THEIR OWN logs
-- Aggressive matching: ID, Email, or Name to bridge Web/Mobile gap
DROP POLICY IF EXISTS "Users can view their own borrow logs" ON borrow_logs;
CREATE POLICY "Users can view their own borrow logs" 
ON borrow_logs FOR SELECT 
USING (
    auth.uid() = borrower_user_id 
    OR auth.uid() = borrowed_by
    OR borrower_email = (auth.jwt()->>'email')
);

-- Allow users to update their own logs for returns
DROP POLICY IF EXISTS "Users can update their own borrow logs" ON borrow_logs;
CREATE POLICY "Users can update their own borrow logs"
ON borrow_logs FOR UPDATE
USING (
    auth.uid() = borrower_user_id 
    OR borrower_email = (auth.jwt()->>'email')
);

-- Allow users to insert logs (needed for mobile app)
DROP POLICY IF EXISTS "Users can insert their own borrow logs" ON borrow_logs;
CREATE POLICY "Users can insert their own borrow logs" 
ON borrow_logs FOR INSERT 
WITH CHECK (auth.uid() = borrower_user_id OR borrower_user_id IS NULL);

SELECT 'Table borrow_logs updated successfully' as status;
