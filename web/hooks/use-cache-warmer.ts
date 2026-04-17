'use client'

import { useEffect } from 'react'
import { preload } from 'swr'

/**
 * 🛰️ LIGTAS Omni-Ignition Protocol
 * Prefetches and hydrates ALL core dashboard modules in the background.
 * Ensures the 'Instant-On' experience where data resides in memory before navigation.
 */
export function useCacheWarmer() {
    useEffect(() => {
        const ignite = async () => {
            try {
                // ⚡ SNAPPY IGNITION: Wait 500ms for layout stability, then flood the cache
                await new Promise(resolve => setTimeout(resolve, 500))

                // 1. Inventory & Master Ledger
                const { INVENTORY_CACHE_KEY, fetchInventory } = await import('@/hooks/use-inventory')
                preload(INVENTORY_CACHE_KEY, fetchInventory)
                
                // 2. Realtime Borrow/Return Logs
                const { LOGS_CACHE_KEY, fetchLogs } = await import('@/hooks/use-borrow-logs')
                preload(LOGS_CACHE_KEY, fetchLogs)

                // 3. Analytics & Logistics Intel
                const { fetchDashboardData } = await import('@/hooks/use-dashboard-stats')
                preload('dashboard_stats', fetchDashboardData)

                // 4. Logistics Approvals Queue
                const { PENDING_REQUESTS_KEY, fetchPendingRequests } = await import('@/hooks/use-pending-requests')
                preload(PENDING_REQUESTS_KEY, fetchPendingRequests)

                // 5. Personnel & System Access (The 'Hang' Fix)
                const { 
                    USER_PROFILES_KEY, 
                    AUTHORIZED_EMAILS_KEY,
                    PENDING_USER_REQUESTS_KEY,
                    fetchUsers, 
                    fetchAuthorizedEmails,
                    fetchPendingUserRequests
                } = await import('@/hooks/use-user-management')
                preload(USER_PROFILES_KEY, fetchUsers)
                preload(AUTHORIZED_EMAILS_KEY, fetchAuthorizedEmails)
                preload(PENDING_USER_REQUESTS_KEY, fetchPendingUserRequests)

                // 6. Borrower Registry & Profiles
                const { fetchBorrowerData, fetchGlobalStats } = await import('@/hooks/use-borrower-registry')
                // Preload first page of registry
                preload('borrower-stats||1|10', () => fetchBorrowerData('borrower-stats||1|10'))
                preload('borrower-global-stats', fetchGlobalStats)

                // 7. Secure Communications (Messaging-V3)
                const { getChatRoomsV3 } = await import('@/app/actions/chat-v3')
                preload('chat_rooms_v3', async () => {
                    const result = await getChatRoomsV3()
                    return result.success ? (result.data || []) : []
                })

                console.log('🚀 [LIGTAS OMNI-IGNITION] All sectors hydrated.')
            } catch (error) {
                console.warn('⚠️ [OMNI-IGNITION] Background sector failure:', error)
            }
        }

        ignite()
    }, [])
}
