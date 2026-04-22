'use client'

import useSWR from 'swr'
import { getTrendingItemsAction } from '@/actions/analytics-actions'

/**
 * 🛰️ USE TRENDING INVENTORY HOOK: TACTICAL ANALYTICS SINK
 * COMPLIANCE: Next.js 14+ Hook Pattern.
 * PERFORMANCE: Cached with 1h refresh interval (Enterprise Standard).
 */
export function useTrendingInventory(limit: number = 5) {
  const { data, error, isLoading, mutate } = useSWR(
    ['trending_inventory', limit],
    async () => {
      const result = await getTrendingItemsAction(limit)
      if (!result.success) throw new Error(result.message)
      return result.data
    },
    {
      revalidateOnFocus: false,
      dedupingInterval: 60000,
      refreshInterval: 3600000, // Hourly Sync (Materialized View Refresh Window)
    }
  )

  return {
    trendingData: data || [],
    isLoading,
    isError: !!error,
    error,
    refresh: mutate
  }
}
