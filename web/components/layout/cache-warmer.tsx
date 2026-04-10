'use client'

import { useInventory } from '@/hooks/use-inventory'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { useDashboardStats } from '@/hooks/use-dashboard-stats'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { useBorrowerRegistry } from '@/hooks/use-borrower-registry'
import { useNotifications } from '@/hooks/use-notifications'

/**
 * Cache Warmer / Global Data Sync Component
 * 🏛️ ENTERPRISE ARCHITECTURE: Universal Resident Loop
 * Invisible component that mounts the primary SWR data tracks at the layout level.
 * This ensures the 'Delta-Sync' Realtime engines for ALL core modules are 
 * initialized immediately and maintained persistently across the entire session.
 */
export function CacheWarmer() {
    // 🛰️ Operational Tracks
    useInventory()
    useBorrowLogs()
    
    // 📊 Analytics & Intel Tracks
    useDashboardStats()
    useNotifications()
    
    // 📋 Administrative Tracks
    usePendingRequests()
    useBorrowerRegistry({ search: '', page: 1, limit: 10 })
    
    return null
}
