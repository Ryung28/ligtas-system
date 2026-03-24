'use client'

import { useCacheWarmer } from '@/hooks/use-cache-warmer'

/**
 * Cache Warmer Component
 * Invisible component that prefetches all dashboard data on mount
 */
export function CacheWarmer() {
    useCacheWarmer()
    return null
}
