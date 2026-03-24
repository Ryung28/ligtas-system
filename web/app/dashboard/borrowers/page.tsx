import { Suspense } from 'react'
import { getInitialBorrowers } from '@/lib/queries/borrowers'
import { BorrowersClient } from './borrowers-client'
import BorrowersLoading from './loading'

export const dynamic = 'force-dynamic'

export default async function BorrowerRegistryPage() {
    const initialData = await getInitialBorrowers()

    return (
        <Suspense fallback={<BorrowersLoading />}>
            <BorrowersClient initialData={initialData} />
        </Suspense>
    )
}
