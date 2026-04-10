import { Suspense } from 'react'
import { getInitialLogs } from '@/lib/queries/logs'
import { LogsClient } from './logs-client'
import LogsLoading from './loading'

// 🚀 ENTERPRISE PERFORMANCE: Shell Pattern (No force-dynamic)

export default async function BorrowReturnLogs() {
    // ⚡ INSTANT NAVIGATION: Page returns immediately, SWR handles hydration via CacheWarmer
    // const initialLogs = await getInitialLogs() // Disabled blocking fetch

    return (
        <Suspense fallback={<LogsLoading />}>
            <LogsClient initialLogs={[]} />
        </Suspense>
    )
}
