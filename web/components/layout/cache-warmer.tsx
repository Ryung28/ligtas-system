'use client'

import { useCacheWarmer } from '@/hooks/use-cache-warmer'

/**
 * 🛰️ LIGTAS Omni-Ignition Protocol
 * This component runs in the background of the Dashboard Layout.
 * It hydrates the data-cache for ALL core modules asynchronously,
 * ensuring that by the time an admin clicks a navigation link,
 * the data is already resident in memory.
 */
export function CacheWarmer() {
    // ⚡ Ignite background prefetching
    useCacheWarmer()
    
    return null
}
