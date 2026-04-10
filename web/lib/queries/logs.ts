import { createSupabaseServer } from '@/lib/supabase-server'
import { BorrowLog } from '@/lib/types/inventory'

/**
 * Server-side log fetcher
 * Runs on the server during route navigation - faster than client fetch
 */
export async function getInitialLogs() {
    try {
        const supabase = await createSupabaseServer()

        const { data, error } = await supabase
            .from('borrow_logs')
            .select(`
                *,
                pickup_scheduled_at,
                inventory:inventory_id (
                    item_name
                )
            `)
            .order('created_at', { ascending: false })
        .limit(50)

        if (error) throw error

        // Resolution Logic: Priority = Log Name > Inventory Name > Fallback
        const logs = (data as any[]).map(log => ({
            ...log,
            item_name: (log.item_name && log.item_name !== 'Unknown Item')
                ? log.item_name
                : (log.inventory?.item_name || log.item_name || 'Unknown Item')
        })) as BorrowLog[]

        return logs
    } catch (error) {
        console.error('Failed to fetch logs:', error)
        return []
    }
}
