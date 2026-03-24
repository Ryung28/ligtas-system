'use client'

import { useEffect } from 'react'
import { preload } from 'swr'

/**
 * Cache Warmer Hook
 * Prefetches all dashboard route data in the background on mount
 * Makes subsequent navigation feel instant by serving from cache
 */
export function useCacheWarmer() {
    useEffect(() => {
        const warmCache = async () => {
            try {
                // Delay to avoid blocking initial page render
                await new Promise(resolve => setTimeout(resolve, 1000))

                // Inventory data
                const { INVENTORY_CACHE_KEY, fetchInventory } = await import('@/hooks/use-inventory')
                preload(INVENTORY_CACHE_KEY, fetchInventory)

                // Logs data
                const { LOGS_CACHE_KEY, fetchLogs } = await import('@/hooks/use-borrow-logs')
                preload(LOGS_CACHE_KEY, fetchLogs)

                // Dashboard stats (for Overview page)
                const { fetchDashboardData } = await import('@/hooks/use-dashboard-stats')
                preload('dashboard_stats', fetchDashboardData)

                // Pending requests (for Approvals page)
                const { fetchPendingRequests } = await import('@/hooks/use-pending-requests')
                preload('pending_requests', fetchPendingRequests)

                // User management (for System Users page)
                const { fetchUsers, fetchAuthorizedEmails } = await import('@/hooks/use-user-management')
                preload('user_profiles', fetchUsers)
                preload('authorized_emails', fetchAuthorizedEmails)

                // Chat rooms (for Messages page)
                const { fetchChatRooms } = await import('@/hooks/use-chat-rooms')
                preload('chat_rooms', fetchChatRooms)

                console.log('[Cache Warmer] All route data prefetched')
            } catch (error) {
                console.warn('[Cache Warmer] Prefetch failed:', error)
            }
        }

        warmCache()
    }, [])
}
