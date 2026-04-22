import React, { Suspense } from 'react'
import { LogsClient } from './logs-client'
import { TimelineSkeleton } from '@/components/mobile/skeletons/timeline-skeleton'

export const dynamic = 'force-dynamic'

/**
 * 📱 ResQTrack Mobile Transaction Logs
 * 🏛️ ARCHITECTURE: "The Digital Ledger"
 * High-fidelity timeline of all equipment movements in the field.
 * 
 * NOTE: This is a Server Component shell to satisfy Next.js 15 Suspense
 * requirements for components using useSearchParams (inside useBorrowLogs).
 */
export default function MobileLogsPage() {
    return (
        <Suspense fallback={<TimelineSkeleton />}>
            <LogsClient />
        </Suspense>
    )
}
