import { Suspense } from 'react'
import DashboardClient from './dashboard-client'
import DashboardLoading from './loading'

export default function DashboardOverview() {
    return (
        <Suspense fallback={<DashboardLoading />}>
            <DashboardClient />
        </Suspense>
    )
}
