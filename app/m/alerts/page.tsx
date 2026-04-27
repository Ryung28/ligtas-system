import React, { Suspense } from 'react'
import { AlertsClient } from './alerts-client'

export const dynamic = 'force-dynamic'

/**
 * 🛰️ Triage Center: Alerts & Actions
 * Consolidated view for all system anomalies and pending requests.
 */
export default function AlertsHubPage() {
    return (
        <Suspense fallback={<div className="p-8 animate-pulse text-slate-400 font-bold uppercase text-[10px] tracking-widest text-center">Synchronizing Tactical Hub...</div>}>
            <AlertsClient />
        </Suspense>
    )
}
