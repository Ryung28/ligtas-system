import { Suspense } from 'react'
import { BorrowersClient } from './borrowers-client'
import { BorrowersSkeleton } from './borrowers-skeleton'

export const dynamic = 'force-dynamic'

export default function MobileBorrowersPage() {
    return (
        <Suspense fallback={<BorrowersSkeleton />}>
            <BorrowersClient />
        </Suspense>
    )
}
