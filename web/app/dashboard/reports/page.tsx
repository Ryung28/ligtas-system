import { ReportsClient } from './reports-client'
import { getInventory } from '@/lib/queries/inventory'
import { createSupabaseServer } from '@/lib/supabase-server'
import { Suspense } from 'react'

export const dynamic = 'force-dynamic'

export default async function ReportsDashboardPage() {
    const stats = await getReportStats()

    return (
        <Suspense fallback={<ReportsSkeleton />}>
            <ReportsClient initialStats={stats} />
        </Suspense>
    )
}

async function getReportStats() {
    try {
        const supabase = await createSupabaseServer()
        const [inventory, logsResult] = await Promise.all([
            getInventory(),
            supabase.from('borrow_logs').select('status, expected_return_date')
        ])

        const totalItems = inventory.length
        const lowStock = inventory.filter(i => i.stock_available < 5).length
        const borrowed = logsResult.data?.filter(l => l.status === 'borrowed').length || 0
        const overdue = logsResult.data?.filter(l => 
            l.status === 'borrowed' && new Date(l.expected_return_date) < new Date()
        ).length || 0
        
        const expiringSoon = inventory.filter(i => {
            if (!i.expiry_date) return false
            const daysUntilExpiry = Math.floor((new Date(i.expiry_date).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
            return daysUntilExpiry <= (i.expiry_alert_days || 30) && daysUntilExpiry >= 0
        }).length || 0

        return { totalItems, lowStock, borrowed, overdue, expiringSoon }
    } catch (error) {
        console.error('Failed to load report stats on server:', error)
        return null
    }
}

function ReportsSkeleton() {
    return (
        <div className="space-y-6 p-4 animate-pulse">
            <div className="h-20 bg-white rounded-2xl border border-slate-100"></div>
            <div className="grid grid-cols-5 gap-4">
                {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-24 bg-white rounded-xl border border-slate-100"></div>
                ))}
            </div>
            <div className="h-32 bg-amber-50 rounded-xl border border-amber-200"></div>
            <div className="grid grid-cols-3 gap-6">
                {[1, 2, 3].map(i => (
                    <div key={i} className="h-64 bg-white rounded-2xl border border-slate-100"></div>
                ))}
            </div>
        </div>
    )
}
