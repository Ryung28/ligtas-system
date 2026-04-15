import dynamic from 'next/dynamic'
import { Suspense } from 'react'
import BorrowersLoading from './loading'

const BorrowersClient = dynamic(() => import('./borrowers-client').then(mod => mod.BorrowersClient), {
    loading: () => <BorrowersLoading />
})

export default function BorrowerRegistryPage() {
    return (
        <Suspense fallback={<BorrowersLoading />}>
            <BorrowersClient initialData={{ borrowers: [], stats: {} }} />
        </Suspense>
    )
}
