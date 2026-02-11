import { InventoryClient } from './inventory-client'
import { Suspense } from 'react'

export const dynamic = 'force-dynamic'

export default function InventoryDashboardPage() {
    return (
        <Suspense fallback={<InventorySkeleton />}>
            <InventoryClient />
        </Suspense>
    )
}

function InventorySkeleton() {
    return (
        <div className="max-w-screen-3xl mx-auto space-y-4 p-1 14in:p-2 animate-pulse">
            {/* Header Skeleton */}
            <div className="h-20 14in:h-24 bg-white/50 rounded-xl border border-slate-50 shadow-sm"></div>

            {/* Stats Skeleton */}
            <div className="grid gap-4 grid-cols-2 md:grid-cols-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-24 14in:h-28 bg-white/50 rounded-2xl border border-slate-50 italic"></div>
                ))}
            </div>

            {/* Table Skeleton */}
            <div className="h-[500px] bg-white/50 rounded-[2rem] border border-slate-50 shadow-xl"></div>
        </div>
    )
}
