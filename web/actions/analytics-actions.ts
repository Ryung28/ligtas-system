'use server'

import { AnalyticsRepository } from '@/lib/repositories/analytics-repository'
import { revalidatePath } from 'next/cache'

/**
 * 🛰️ TRENDING ANALYTICS ACTIONS: TACTICAL COMMAND CHANNEL
 * COMPLIANCE: Next.js 14+ Server Actions Only.
 * EXCLUSIVITY: Server-Side Execution.
 */

export async function getTrendingItemsAction(limit: number = 5) {
  try {
    // 🛡️ REPOSITORY DELEGATION: Separation of Concerns
    const result = await AnalyticsRepository.getTrendingItems(limit)
    
    if (!result.success) {
      console.error('[Action] TrendingFetch Failure:', result.message)
      return { 
          success: false, 
          data: [], 
          message: result.message || 'Analytics offline.' 
      }
    }

    return { success: true, data: result.data }
  } catch (error) {
    // 🛡️ SAFETY NET: V4.0 Logic Rule IV
    console.error('[Action] Analytics Crash Exception:', error)
    return { 
        success: false, 
        data: [], 
        message: 'System connectivity breach.' 
    }
  }
}

/**
 * Forces a manual refresh of the analytical dashboard cache.
 */
export async function refreshAnalyticsCache() {
  revalidatePath('/dashboard')
  return { success: true, message: 'Intel synchronized.' }
}
