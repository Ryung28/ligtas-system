-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - BORROWER STATISTICS VIEW
-- ============================================================================
-- PURPOSE: Aggregate borrowing metrics per user for person-centric tracking
-- USAGE: Powers Borrower Registry page with full history and metrics
-- ============================================================================

-- Drop existing view if any
DROP VIEW IF EXISTS borrower_stats;

-- Create comprehensive borrower statistics view
CREATE VIEW borrower_stats AS
SELECT 
    bl.borrower_user_id,
    bl.borrower_name,
    bl.borrower_email,
    up.full_name as user_full_name,
    up.email as user_email,
    up.role as user_role,
    up.status as user_status,
    
    -- Borrowing metrics
    COUNT(*) as total_borrows,
    SUM(bl.quantity) as total_items_borrowed,
    
    -- Status breakdown
    COUNT(*) FILTER (WHERE bl.status = 'borrowed') as active_borrows,
    SUM(bl.quantity) FILTER (WHERE bl.status = 'borrowed') as active_items,
    
    COUNT(*) FILTER (WHERE bl.status = 'returned') as returned_count,
    SUM(bl.quantity) FILTER (WHERE bl.status = 'returned') as returned_items,
    
    COUNT(*) FILTER (WHERE bl.status = 'overdue') as overdue_count,
    SUM(bl.quantity) FILTER (WHERE bl.status = 'overdue') as overdue_items,
    
    COUNT(*) FILTER (WHERE bl.status = 'cancelled') as cancelled_count,
    
    -- Timing metrics
    MAX(bl.created_at) as last_borrow_date,
    MIN(bl.created_at) as first_borrow_date,
    
    -- Return rate calculation (returned / (returned + overdue + cancelled))
    CASE 
        WHEN COUNT(*) FILTER (WHERE bl.status IN ('returned', 'overdue', 'cancelled')) > 0
        THEN ROUND(
            (COUNT(*) FILTER (WHERE bl.status = 'returned')::NUMERIC / 
             COUNT(*) FILTER (WHERE bl.status IN ('returned', 'overdue', 'cancelled'))::NUMERIC) * 100, 
            1
        )
        ELSE 100.0
    END as return_rate_percent,
    
    -- Verification flag
    CASE 
        WHEN up.id IS NOT NULL THEN true
        ELSE false
    END as is_verified_user
    
FROM borrow_logs bl
LEFT JOIN user_profiles up ON bl.borrower_user_id = up.id
GROUP BY 
    bl.borrower_user_id, 
    bl.borrower_name, 
    bl.borrower_email,
    up.id,
    up.full_name,
    up.email,
    up.role,
    up.status;

-- Grant access
GRANT SELECT ON borrower_stats TO authenticated;

-- Add helpful comment
COMMENT ON VIEW borrower_stats IS 
'Aggregated borrowing statistics per user. Shows total borrows, active items, return rate, and verification status.';

-- Create index on underlying table for performance
CREATE INDEX IF NOT EXISTS idx_borrow_logs_created_at 
ON borrow_logs(created_at DESC);

SELECT 'Borrower Stats View: CREATED' as status;
SELECT COUNT(*) as total_borrowers FROM borrower_stats;
SELECT COUNT(*) as verified_borrowers FROM borrower_stats WHERE is_verified_user = true;
