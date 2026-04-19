'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { ReportStats } from '@/components/reports/types'

/**
 * ⚡ TACTICAL REPORT AGGREGATOR
 * Uses DB-level COUNT queries — zero row data downloaded to the server.
 */
export async function getReportStatsAction(): Promise<{ success: boolean; data?: ReportStats; error?: string }> {
    try {
        const supabase = await createSupabaseServer()
        const now = new Date().toISOString()

        const [
            totalItemsRes,
            borrowedRes,
            overdueRes,
            expiringSoonRes,
        ] = await Promise.all([
            supabase.from('inventory').select('*', { count: 'exact', head: true }),
            supabase.from('borrow_logs').select('*', { count: 'exact', head: true }).eq('status', 'borrowed'),
            supabase.from('borrow_logs').select('*', { count: 'exact', head: true })
                .eq('status', 'borrowed')
                .lt('expected_return_date', now),
            supabase.from('inventory').select('*', { count: 'exact', head: true })
                .not('expiry_date', 'is', null)
                .lte('expiry_date', new Date(Date.now() + 15 * 24 * 60 * 60 * 1000).toISOString()),
        ])

        // Low stock requires the threshold field — count in JS from a minimal projection
        const { data: stockRows } = await supabase
            .from('inventory')
            .select('stock_available, low_stock_threshold, target_stock, restock_alert_enabled')

        const { isLowStock } = await import('@/lib/inventory-utils')
        const lowStock = (stockRows || []).filter(i => isLowStock(i as any)).length

        return {
            success: true,
            data: {
                totalItems: totalItemsRes.count ?? 0,
                lowStock,
                borrowed: borrowedRes.count ?? 0,
                overdue: overdueRes.count ?? 0,
                expiringSoon: expiringSoonRes.count ?? 0,
            }
        }
    } catch (error: any) {
        console.error('Failed to aggregate report stats:', error)
        return { success: false, error: 'Database aggregation failed' }
    }
}

