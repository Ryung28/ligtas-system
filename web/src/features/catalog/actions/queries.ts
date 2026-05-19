'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { ActionResult } from '@/src/shared/types'

export async function getInventoryAlerts(): Promise<ActionResult<any>> {
    try {
        const supabase = await createSupabaseServer()
        const { data, error } = await supabase.from('v_inventory_actionable_alerts').select('*').eq('needs_action', true)
        if (error) throw error
        
        const alerts = data || []
        const summary = {
            out_of_stock: alerts.filter(i => i.is_out_of_stock).length,
            low_stock: alerts.filter(i => i.is_low_stock).length,
            expiring_soon: alerts.filter(i => i.is_expiring).length,
            expired: alerts.filter(i => i.is_expired).length,
            damaged: alerts.filter(i => i.is_damaged).length,
            maintenance: alerts.filter(i => i.is_maintenance).length,
            missing: alerts.filter(i => i.is_missing).length,
            total_active_alerts: alerts.length
        }
        return { data: { summary, items: alerts.slice(0, 10) }, error: null }
    } catch (error: any) {
        return { data: null, error: error.message || 'An unexpected error occurred.' }
    }
}
