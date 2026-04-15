import dynamic from 'next/dynamic'
import { Suspense } from 'react'
import LogsLoading from './loading'

const LogsClient = dynamic(() => import('./logs-client').then(mod => mod.LogsClient), {
    loading: () => <LogsLoading />
})

export default async function BorrowReturnLogs() {
    return (
        <Suspense fallback={<LogsLoading />}>
            <LogsClient initialLogs={[]} />
        </Suspense>
    )
}
