import { createSupabaseServer } from '@/lib/supabase-server'

/**
 * Server-side borrower data fetcher
 * Fetches user profiles and active borrow logs
 */
export async function getInitialBorrowers() {
    try {
        const supabase = await createSupabaseServer()

        // Fetch registered staff
        const { data: profiles } = await supabase
            .from('user_profiles')
            .select('full_name, email')

        const registeredStaff = new Set(
            (profiles || []).map(u => 
                u.full_name?.toLowerCase() || u.email.split('@')[0].toLowerCase()
            )
        )

        // Fetch active borrow logs
        const { data: logs, error } = await supabase
            .from('borrow_logs')
            .select('*')
            .eq('status', 'borrowed')
            .order('created_at', { ascending: false })

        if (error) throw error

        // Group by borrower
        const staffTracking: Record<string, { count: number, items: any[] }> = {}
        
        ;(logs || []).forEach(log => {
            if (!staffTracking[log.borrower_name]) {
                staffTracking[log.borrower_name] = { count: 0, items: [] }
            }
            staffTracking[log.borrower_name].count += log.quantity
            staffTracking[log.borrower_name].items.push(log)
        })

        // Convert to array with staff flag
        const allBorrowers = Object.entries(staffTracking).map(([name, data]) => ({
            name,
            isStaff: registeredStaff.has(name.toLowerCase()),
            count: data.count,
            items: data.items
        }))

        // Calculate stats
        const totalInField = allBorrowers.reduce((acc, b) => acc + b.count, 0)
        const activeBorrowersCount = allBorrowers.filter(b => b.count > 0).length
        const staffCount = allBorrowers.filter(b => b.isStaff).length
        const guestCount = allBorrowers.filter(b => !b.isStaff).length

        return {
            allBorrowers,
            stats: {
                totalInField,
                activeBorrowersCount,
                staffCount,
                guestCount
            }
        }
    } catch (error) {
        console.error('Failed to fetch borrowers:', error)
        return {
            allBorrowers: [],
            stats: {
                totalInField: 0,
                activeBorrowersCount: 0,
                staffCount: 0,
                guestCount: 0
            }
        }
    }
}
