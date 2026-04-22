import React, { Suspense } from 'react'
import { DashboardClient } from './dashboard-client'
import { DashboardSkeleton } from '@/components/mobile/skeletons/dashboard-skeleton'

export const dynamic = 'force-dynamic'

/**
 * 📱 ResQTrack Mobile Dashboard
 * 🏛️ ARCHITECTURE: "The Command Hub"
 * 
 * NOTE: This is a Server Component shell to satisfy Next.js 15 Suspense
 * requirements for clients using useSearchParams.
 */
export default function MobileDashboardPage() {
    return (
        <Suspense fallback={<DashboardSkeleton />}>
            <DashboardClient />
        </Suspense>
    )
}
