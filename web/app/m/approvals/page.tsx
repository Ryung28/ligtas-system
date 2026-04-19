import React, { Suspense } from 'react'
import { ApprovalsClient } from './approvals-client'

export const dynamic = 'force-dynamic'

/**
 * ✅ LIGTAS Mobile Approvals
 * 🏛️ ARCHITECTURE: "The Command Hub"
 * 
 * NOTE: This is a Server Component shell to satisfy Next.js 15 Suspense
 * requirements for client interactivity and hook-based search param safe-access.
 */
export default function MobileApprovalsPage() {
    return (
        <Suspense fallback={<div className="p-8 animate-pulse text-slate-400 font-bold uppercase text-xs tracking-widest text-center">Syncing Queue...</div>}>
            <ApprovalsClient />
        </Suspense>
    )
}
