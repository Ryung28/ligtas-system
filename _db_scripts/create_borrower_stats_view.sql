-- ============================================================================
-- LIGTAS CDRRMO SYSTEM - UNIFIED IDENTITY HUB (borrower_stats)
-- ============================================================================
-- VERSION: 4.0 (Production Hardened)
-- PURPOSE: Unified forensic projection of all system identities.
-- LOGIC: Normalizes identities via LOWER(TRIM()) and partitions metrics.
-- ============================================================================

DROP VIEW IF EXISTS borrower_stats;

CREATE VIEW borrower_stats AS
WITH normalized_identities AS (
    -- 1. All Registered User Profiles (Primary Authority)
    SELECT 
        id as borrower_user_id,
        LOWER(TRIM(full_name)) as norm_name,
        full_name as display_name,
        email as borrower_email,
        role as user_role,
        status as user_status,
        true as is_verified_user
    FROM user_profiles
    
    UNION
    
    -- 2. Guest Borrowers (Forensic Authority)
    -- We only take names that don't match a verified profile to avoid duplicates
    SELECT 
        NULL as borrower_user_id,
        LOWER(TRIM(borrower_name)) as norm_name,
        borrower_name as display_name,
        borrower_email,
        NULL as user_role,
        NULL as user_status,
        false as is_verified_user
    FROM borrow_logs
    WHERE borrower_user_id IS NULL 
    AND LOWER(TRIM(borrower_name)) NOT IN (SELECT LOWER(TRIM(full_name)) FROM user_profiles)
),
identity_base AS (
    -- Deduplicate name-based identities
    SELECT DISTINCT ON (norm_name) * FROM normalized_identities
)
SELECT 
    i.borrower_user_id,
    i.display_name as borrower_name,
    MAX(i.borrower_email) as borrower_email,
    MAX(i.user_role) as user_role,
    MAX(i.user_status) as user_status,
    
    -- 📊 CORE METRICS (The Senior Dev Way)
    COUNT(bl.id) as total_borrows, -- Total Transactions (Events)
    COALESCE(SUM(bl.quantity), 0) as total_items_handled, -- Total Volume
    
    -- 🛡️ LIABILITY (Equipment expected back)
    COALESCE(SUM(bl.quantity) FILTER (WHERE bl.status = 'borrowed'), 0) as active_items,
    COUNT(bl.id) FILTER (WHERE bl.status = 'borrowed') as active_borrows,
    
    -- 🍎 SUPPORT (Consumables issued and gone)
    COALESCE(SUM(bl.quantity) FILTER (WHERE bl.status = 'dispensed'), 0) as total_consumables_issued,
    
    -- 🏁 AUDIT CLOSURE (Returned)
    COUNT(bl.id) FILTER (WHERE bl.status = 'returned') as returned_count,
    COUNT(bl.id) FILTER (WHERE bl.status = 'overdue') as overdue_count,
    
    -- 📈 RETURN RATE (Excludes consumables from penalty)
    CASE 
        WHEN COUNT(bl.id) FILTER (WHERE bl.status IN ('returned', 'overdue')) > 0
        THEN ROUND(
            (COUNT(bl.id) FILTER (WHERE bl.status = 'returned')::NUMERIC / 
             COUNT(bl.id) FILTER (WHERE bl.status IN ('returned', 'overdue'))::NUMERIC) * 100, 
            1
        )
        ELSE 100.0
    END as return_rate_percent,
    
    i.is_verified_user
    
FROM identity_base i
LEFT JOIN borrow_logs bl 
    ON (i.borrower_user_id IS NOT NULL AND i.borrower_user_id = bl.borrower_user_id)
    OR (i.borrower_user_id IS NULL AND LOWER(TRIM(i.display_name)) = LOWER(TRIM(bl.borrower_name)))
GROUP BY 
    i.borrower_user_id,
    i.display_name,
    i.is_verified_user;

GRANT SELECT ON borrower_stats TO authenticated;

COMMENT ON VIEW borrower_stats IS 
'LIGTAS v4: Identity-unified stats distinguishing between Equipment Liability and Consumable Support.';
