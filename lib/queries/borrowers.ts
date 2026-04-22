import { createSupabaseServer } from '@/lib/supabase-server'

/**
 * Server-side borrower data fetcher
 * Fetches borrower statistics from borrower_stats view
 */
export async function getInitialBorrowers() {
    try {
        const supabase = await createSupabaseServer()

        // Fetch borrower stats from view
        const { data: borrowers, error } = await supabase
            .from('borrower_stats')
            .select('*')
            .order('total_borrows', { ascending: false })

        if (error) throw error

        // Calculate aggregate stats
        const stats = {
            totalBorrowers: borrowers?.length || 0,
            activeBorrowersCount: borrowers?.filter(b => b.active_borrows > 0).length || 0,
            totalInField: borrowers?.reduce((acc, b) => acc + (b.active_items || 0), 0) || 0,
            staffCount: borrowers?.filter(b => b.is_verified_user && b.user_role !== 'viewer').length || 0,
            guestCount: borrowers?.filter(b => !b.is_verified_user || b.user_role === 'viewer').length || 0,
            verifiedCount: borrowers?.filter(b => b.is_verified_user).length || 0,
        }

        return {
            borrowers: borrowers || [],
            stats
        }
    } catch (error) {
        console.error('Failed to fetch borrowers:', error)
        return {
            borrowers: [],
            stats: {
                totalBorrowers: 0,
                activeBorrowersCount: 0,
                totalInField: 0,
                staffCount: 0,
                guestCount: 0,
                verifiedCount: 0,
            }
        }
    }
}

/**
 * Fetch full borrowing history for a specific borrower
 */
export async function getBorrowerHistory(borrowerUserId: string) {
    try {
        const supabase = await createSupabaseServer()

        const { data: logs, error } = await supabase
            .from('borrow_logs')
            .select(`
                *,
                inventory:inventory_id (
                    item_name,
                    category,
                    image_url
                )
            `)
            .eq('borrower_user_id', borrowerUserId)
            .order('created_at', { ascending: false })

        if (error) throw error

        return logs || []
    } catch (error) {
        console.error('Failed to fetch borrower history:', error)
        return []
    }
}
