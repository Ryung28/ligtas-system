'use client'

import React from 'react'
import useSWR from 'swr'
import { BorrowLog } from '@/lib/types/inventory'
import { useGlobalInventory } from '@/providers/inventory-provider'
export { fetchInventory } from '@/lib/queries/inventory'

export const INVENTORY_CACHE_KEY = 'inventory_data'

/**
 * 📦 useInventory
 * ⚡ SENIOR ARCHITECT FIX: Shared Context Consumer
 * This hook is now a ultra-lightweight proxy to the Global Inventory Provider.
 * High-performance, realtime, and zero-redundancy.
 */
export function useInventory() {
    const { inventory, isLoading, lastUpdated, refresh: globalRefresh } = useGlobalInventory()
    
    // TIER-1 INTEGRATION: Maintain availability mapping via borrow_logs
    // (SWR dedupes this automatically across all page transitions)
    const { data: logs = [] } = useSWR<BorrowLog[]>('borrow_logs', { revalidateOnFocus: false })

    const inventoryWithBorrows = React.useMemo(() => {
        if (!Array.isArray(inventory)) return []
        
        const activeBorrowsMap = new Map<number, any[]>()
        
        for (const log of (logs || [])) {
            if (log.status === 'borrowed') {
                const existing = activeBorrowsMap.get(log.inventory_id) || []
                existing.push({
                    name: log.borrower_name,
                    quantity: log.quantity,
                    org: log.borrower_organization
                })
                activeBorrowsMap.set(log.inventory_id, existing)
            }
        }

        return inventory.map(item => ({
            ...item,
            active_borrows: activeBorrowsMap.get(item.id) || []
        }))
    }, [inventory, logs])

    return {
        inventory: inventoryWithBorrows,
        isLoading,
        lastUpdated,
        error: null,
        refresh: globalRefresh
    }
}
