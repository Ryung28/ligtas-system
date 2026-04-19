import { Suspense } from 'react'
import { UsersClient } from './users-client'
import { UsersSkeleton } from './users-skeleton'

export const dynamic = 'force-dynamic'

export default function MobileUsersPage() {
    return (
        <Suspense fallback={<UsersSkeleton />}>
            <UsersClient />
        </Suspense>
    )
}
