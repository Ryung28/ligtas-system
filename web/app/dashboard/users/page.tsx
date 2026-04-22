import dynamic from 'next/dynamic'
import { Suspense } from 'react'
import Loading from './loading'

// ⚡ ResQTrack INSTANT-NAV PROTOCOL:
// We lazy-load the client component to ensure the server can eject 
// the high-fidelity skeleton instantly without waiting for the JS bundle.
const UsersClient = dynamic(() => import('./users-client').then(mod => mod.UsersClient), {
    loading: () => <Loading />
})

export default function AccessControlPage() {
    return (
        <Suspense fallback={<Loading />}>
            <UsersClient initialUsers={[]} />
        </Suspense>
    )
}
