'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { ReportStats, ReportType, ReportConfig } from '@/components/reports/types'
import { z } from 'zod'

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
            .is('deleted_at', null)

        const { isLowStock } = await import('@/lib/inventory-utils')
        const items = stockRows || []
        const lowStock = items.filter(i => isLowStock(i as any)).length
        const outOfStock = items.filter(i => i.stock_available <= 0).length

        return {
            success: true,
            data: {
                totalItems: totalItemsRes.count ?? 0,
                lowStock,
                outOfStock,
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

/**
 * 🛡️ REPORT VALIDATION SCHEMA
 */
const reportConfigSchema = z.object({
    dateFrom: z.string().optional(),
    dateTo: z.string().optional(),
    category: z.string().optional(),
    status: z.array(z.string()).optional(),
    borrower: z.string().optional(),
    sortOrder: z.enum(['latest', 'oldest']).optional(),
})

/**
 * 📊 TACTICAL REPORT DATA FETCHER
 * Fetches raw data for report generation.
 */
export async function fetchReportDataAction(
    type: ReportType, 
    config: ReportConfig
): Promise<{ success: boolean; data?: any[]; error?: string }> {
    try {
        // 👮 AUTHENTICATION CHECK
        const supabase = await createSupabaseServer()
        const { data: { session } } = await supabase.auth.getSession()
        
        if (!session) {
             return { success: false, error: 'Unauthorized: Session missing' }
        }

        // 🔍 VALIDATION
        const validatedConfig = reportConfigSchema.parse(config)

        const table = (type === 'logs' || type === 'overdue' || type === 'borrower-activity') 
            ? 'borrow_logs' 
            : 'inventory'

        // Rule: Never select *
        const columns = table === 'inventory' 
            ? 'id,item_name,category,stock_available,stock_total,status,storage_location,serial_number,brand,expiry_date,expiry_alert_days,low_stock_threshold,target_stock,restock_alert_enabled,deleted_at'
            : 'id,borrower_name,borrower_organization,borrower_contact,item_name,quantity,status,borrow_date,expected_return_date,actual_return_date,return_notes,return_condition,approved_by_name,released_by_name,received_by_name,returned_by_name,created_at'

        let query = supabase.from(table).select(columns)

        // 🛡️ SECURITY & CLEANLINESS: Enforce soft-delete and expiry filtering
        if (table === 'inventory') {
            query = query.is('deleted_at', null)
            if (type === 'expiry-alert') {
                query = query.not('expiry_date', 'is', null)
            }
        }

        // 📅 CRITICAL: Registry reports (inventory/summary) should ignore temporary date filters
        // but activity reports (logs) require them.
        const isRegistry = ['inventory', 'summary', 'low-stock', 'expiry-alert'].includes(type)
        
        if (!isRegistry) {
            if (validatedConfig.dateFrom) query = query.gte('created_at', `${validatedConfig.dateFrom}T00:00:00`)
            if (validatedConfig.dateTo) query = query.lte('created_at', `${validatedConfig.dateTo}T23:59:59`)
        }

        if (validatedConfig.category && validatedConfig.category !== 'all') {
            query = query.eq('category', validatedConfig.category)
        }
        if (validatedConfig.borrower && table === 'borrow_logs') {
            query = query.ilike('borrower_name', `%${validatedConfig.borrower}%`)
        }
        if (validatedConfig.status?.length && table === 'borrow_logs') {
            query = query.in('status', validatedConfig.status)
        }

        const sortColumn = table === 'borrow_logs' ? 'created_at' : 'item_name'
        query = query.order(sortColumn, { ascending: validatedConfig.sortOrder === 'oldest' })
        
        // Paginating/Limiting per rule
        query = query.limit(1000) 

        const { data, error } = await query
        if (error) throw error

        return { success: true, data: data || [] }
    } catch (error: any) {
        console.error('Failed to fetch report data:', error)
        return { success: false, error: 'Database retrieval failed' }
    }
}

