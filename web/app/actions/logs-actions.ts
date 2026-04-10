'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { BorrowLog } from '@/lib/types/inventory'

/**
 * 🛡️ THE SERVER BRIDGE: Secured Log Fetcher
 * 
 * This action runs on the server using secure cookies.
 * It bypasses the client-side identity leaks that cause "Multiple GoTrueClient" 
 * conflicts and empty log results.
 */
export async function getBorrowLogsAction() {
    try {
        const supabase = await createSupabaseServer()
        
        const { data, error } = await supabase
            .from('borrow_logs')
            .select(`
                *,
                inventory:inventory_id (
                    item_name
                )
            `)
            .order('created_at', { ascending: false })
            .limit(100)

        if (error) {
            console.error('📡 SERVER BRIDGE ERROR (getBorrowLogsAction):', error)
            return { success: false, error: error.message }
        }

        // Resolution Logic: Priority = Log Name > Inventory Name > Fallback
        // This ensures mission-critical data integrity even if mobile syncs were partial.
        const logs = (data as any[]).map(log => ({
            ...log,
            item_name: (log.item_name && log.item_name !== 'Unknown Item')
                ? log.item_name
                : (log.inventory?.item_name || log.item_name || 'Unknown Item')
        })) as BorrowLog[]

        return { success: true, data: logs }
    } catch (e) {
        console.error('📡 UNEXPECTED SERVER ERROR:', e)
        return { success: false, error: 'Internal Server Error' }
    }
}
