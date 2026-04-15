'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { getInventory } from '@/lib/queries/inventory'
import { ReportStats } from '@/components/reports/types'

/**
 * ⚡ TACTICAL REPORT AGGREGATOR
 * Fetches cross-domain metrics for the dashboard shell.
 */
export async function getReportStatsAction(): Promise<{ success: boolean; data?: ReportStats; error?: string }> {
    try {
        const supabase = await createSupabaseServer()
        const [inventory, logsResult] = await Promise.all([
            getInventory(),
            supabase.from('borrow_logs').select('status, expected_return_date')
        ])

        const totalItems = inventory.length
        const lowStock = inventory.filter(i => (i.stock_available || 0) < 5).length
        const borrowed = logsResult.data?.filter(l => l.status === 'borrowed').length || 0
        const overdue = logsResult.data?.filter(l => 
            l.status === 'borrowed' && l.expected_return_date && new Date(l.expected_return_date) < new Date()
        ).length || 0
        
        const expiringSoon = inventory.filter(i => {
            if (!i.expiry_date) return false
            const daysUntilExpiry = Math.floor((new Date(i.expiry_date).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
            return daysUntilExpiry <= 30 && daysUntilExpiry >= 0
        }).length || 0

        return { 
            success: true, 
            data: { totalItems, lowStock, borrowed, overdue, expiringSoon } 
        }
    } catch (error: any) {
        console.error('Failed to aggregate report stats:', error)
        return { success: false, error: 'Database aggregation failed' }
    }
}
