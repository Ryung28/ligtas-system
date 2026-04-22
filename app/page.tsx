import { redirect } from 'next/navigation'
import { getCachedUser } from '@/lib/auth-server'

/**
 * 🛰️ Root Traffic Controller
 * 🛡️ SUPER SENIOR PROTOCOL: Redundancy removal.
 * The primary routing happens in middleware.ts. This page serves
 * as a secondary safety boundary using the Cached Identity handshake.
 */
export default async function RootPage() {
    const user = await getCachedUser()

    if (user) {
        redirect('/dashboard/inventory')
    } else {
        redirect('/login')
    }
}
