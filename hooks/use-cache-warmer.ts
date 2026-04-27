'use client'

import { useEffect } from 'react'

/**
 * 🛰️ ResQTrack Omni-Ignition Protocol (DECOMMISSIONED)
 * 
 * SENIOR AUDIT: This was causing massive lag on PWA/Mobile by flooding the network
 * with 12+ simultaneous requests on layout mount. 
 * 
 * We now rely on Next.js 14's native prefetching and SWR's on-demand caching.
 */
export function useCacheWarmer() {
    useEffect(() => {
        // We only log to confirm the flood has been stopped.
        console.log('⚡ [PWA] Network congestion minimized. Omni-Ignition throttled.')
    }, [])
}
