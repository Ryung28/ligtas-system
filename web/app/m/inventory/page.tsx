import React, { Suspense } from 'react'
import { InventoryClient } from './inventory-client'
import { GridSkeleton } from '@/components/mobile/skeletons/grid-skeleton'

export const dynamic = 'force-dynamic'

/**
 * 📱 LIGTAS Mobile Inventory Page
 * 🏛️ ARCHITECTURE: "The Suspenseful Orchestrator"
 * 
 * NOTE: This is a Server Component shell to satisfy Next.js 15 Suspense
 * requirements for clients using useSearchParams.
 */
export default function MobileInventoryPage() {
    return (
        <Suspense fallback={<GridSkeleton />}>
            <InventoryClient />
        </Suspense>
    )
}
