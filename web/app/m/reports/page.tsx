import React, { Suspense } from 'react'
import { ReportsClient } from './reports-client'
import { ReportsSkeleton } from './reports-skeleton'

export const dynamic = 'force-dynamic'

export const metadata = {
    title: 'Reports - LIGTAS',
    description: 'System-wide analytics and data exports',
}

/**
 * 📊 LIGTAS Mobile Reports
 * 🏛️ ARCHITECTURE: "The Analyst Entry"
 * 
 * NOTE: This is a Server Component shell to satisfy Next.js 15 Suspense
 * requirements for client interactivity and hook-based search param safe-access.
 */
export default function MobileReportsPage() {
    return (
        <Suspense fallback={<ReportsSkeleton />}>
            <ReportsClient />
        </Suspense>
    )
}
