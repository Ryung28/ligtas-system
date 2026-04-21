import React, { Suspense } from 'react'
import nextDynamic from 'next/dynamic'
import { ReportsSkeleton as ChatSkeleton } from '../reports/reports-skeleton'

const MobileChatClient = nextDynamic(() => import('./chat-client'), {
    loading: () => <ChatSkeleton />
})

export const dynamic = 'force-dynamic'

/**
 * 📱 LIGTAS Mobile Chat
 * 🏛️ ARCHITECTURE: "The Comm-Link"
 * 
 * NOTE: This is a Server Component shell to satisfy Next.js 15 Suspense
 * requirements for clients using useSearchParams.
 */
export default function MobileChatPage() {
    return (
        <Suspense fallback={<ChatSkeleton />}>
            <MobileChatClient />
        </Suspense>
    )
}
