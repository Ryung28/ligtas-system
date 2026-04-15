import dynamic from 'next/dynamic'
import { Suspense } from 'react'
import Loading from './loading'

const ApprovalsClient = dynamic(() => import('./approvals-client').then(mod => mod.ApprovalsClient), {
    loading: () => <Loading />
})

export default function ApprovalsPage() {
    return (
        <Suspense fallback={<Loading />}>
            <ApprovalsClient initialRequests={[]} />
        </Suspense>
    )
}
