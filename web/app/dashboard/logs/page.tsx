import { Suspense } from 'react'
import { getInitialLogs } from '@/lib/queries/logs'
import { LogsClient } from './logs-client'
import LogsLoading from './loading'

export const dynamic = 'force-dynamic'

export default async function BorrowReturnLogs() {
    const initialLogs = await getInitialLogs()

    return (
        <Suspense fallback={<LogsLoading />}>
            <LogsClient initialLogs={initialLogs} />
        </Suspense>
    )
}
