'use client'

import React, { useEffect } from 'react'
import useSWR from 'swr'
import { supabase } from '@/lib/supabase'
import { InventoryItem } from '@/lib/supabase'
import { BorrowLog } from '@/lib/types/inventory'

export const INVENTORY_CACHE_KEY = 'inventory_data'

export const fetchInventory = async () => {
    const { data, error } = await supabase
        .from('inventory')
        .select('*')
        .order('item_name', { ascending: true })

    if (error) throw error
    return (data || []) as InventoryItem[]
}

export function useInventory() {
    const [lastUpdated, setLastUpdated] = React.useState(new Date())
    const { data: inventory = [], error, isLoading, mutate: refresh, isValidating } = useSWR(INVENTORY_CACHE_KEY, fetchInventory, {
        revalidateOnFocus: false,
        dedupingInterval: 10000,
    })

    // Update timestamp when data is fetched
    useEffect(() => {
        if (!isLoading && !isValidating && Array.isArray(inventory) && inventory.length > 0) {
            setLastUpdated(new Date())
        }
    }, [isLoading, isValidating, inventory.length])

    // TIER-1 INTEGRATION: Get active borrows from logs cache
    const { data: logs = [] } = useSWR<BorrowLog[]>('borrow_logs', { revalidateOnFocus: false })

    const inventoryWithBorrows = React.useMemo(() => {
        if (!Array.isArray(inventory)) return []
        return inventory.map(item => {
            const activeBorrows = (logs || []).filter(l => l.inventory_id === item.id && l.status === 'borrowed')
            return {
                ...item,
                active_borrows: activeBorrows.map(b => ({
                    name: b.borrower_name,
                    quantity: b.quantity,
                    org: b.borrower_organization
                }))
            }
        })
    }, [inventory, logs])

    useEffect(() => {
        const channel = supabase
            .channel('inventory-realtime-global')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, () => {
                refresh()
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [refresh])

    return {
        inventory: inventoryWithBorrows,
        isLoading: isLoading || isValidating,
        lastUpdated,
        error: error?.message || null,
        refresh
    }
}
