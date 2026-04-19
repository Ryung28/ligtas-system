'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { BorrowLog } from '@/lib/types/inventory'
import { getInventoryImageUrl } from '@/lib/supabase'

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
                    item_name,
                    image_url,
                    item_type
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
                : (log.inventory?.item_name || log.item_name || 'Unknown Item'),
            image_url: getInventoryImageUrl((Array.isArray(log.inventory) ? log.inventory[0]?.image_url : log.inventory?.image_url) || null)
        })) as BorrowLog[]

        return { success: true, data: logs }
    } catch (e) {
        console.error('📡 UNEXPECTED SERVER ERROR:', e)
        return { success: false, error: 'Internal Server Error' }
    }
}

/**
 * 🎯 ATOMIC RESOLUTION: Precision Point-Query
 * 
 * Fetches a single borrow log with its inventory context.
 * Bypasses the 100-limit for standard history browsing.
 */
export async function getBorrowLogByIdAction(id: string) {
    try {
        const supabase = await createSupabaseServer()

        const { data, error } = await supabase
            .from('borrow_logs')
            .select(`
                *,
                inventory:inventory_id (
                    item_name,
                    image_url,
                    item_type,
                    category,
                    serial_number,
                    model_number,
                    brand,
                    expiry_date,
                    storage_location
                )
            `)
            .eq('id', id)
            .single()

        if (error) {
            console.error('📡 POINT QUERY ERROR:', error)
            return { success: false, error: error.message }
        }

        const log = {
            ...data,
            item_name: (data.item_name && data.item_name !== 'Unknown Item')
                ? data.item_name
                : (Array.isArray(data.inventory) ? data.inventory[0]?.item_name : data.inventory?.item_name) || data.item_name || 'Unknown Item',
            image_url: getInventoryImageUrl((Array.isArray(data.inventory) ? data.inventory[0]?.image_url : data.inventory?.image_url) || null)
        } as BorrowLog

        return { success: true, data: log }
    } catch (e) {
        console.error('📡 UNEXPECTED POINT ERROR:', e)
        return { success: false, error: 'Internal Server Error' }
    }
}
