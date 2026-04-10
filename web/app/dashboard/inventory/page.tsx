import { InventoryClient } from './inventory-client'
import { getInitialInventory } from '@/lib/queries/inventory'
import { Suspense } from 'react'

// 🚀 ENTERPRISE PERFORMANCE: Shell Pattern (No force-dynamic)

export default async function InventoryDashboardPage() {
    // ⚡ INSTANT NAVIGATION: Page returns immediately, SWR handles hydration via CacheWarmer
    // const initialInventory = await getInitialInventory() // Disabled blocking fetch

    return (
        <Suspense fallback={<InventorySkeleton />}>
            <InventoryClient initialInventory={[]} />
        </Suspense>
    )
}

function InventorySkeleton() {
    return (
        <div className="space-y-3 animate-pulse">
            {/* Header Skeleton */}
            <div className="h-16 bg-white rounded-xl border border-gray-200/60"></div>

            {/* Stats Skeleton */}
            <div className="grid gap-3 grid-cols-2 md:grid-cols-4">
                {[1, 2, 3, 4].map(i => (
                    <div key={i} className="h-20 bg-white rounded-xl border border-gray-200/60"></div>
                ))}
            </div>

            {/* Table Skeleton */}
            <div className="h-[500px] bg-white rounded-xl border border-gray-200/60"></div>
        </div>
    )
}
