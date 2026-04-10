'use client'

import React, { useEffect } from 'react'
import useSWR, { mutate } from 'swr'
import { supabase } from '@/lib/supabase'
import { InventoryItem } from '@/lib/supabase'
import { BorrowLog } from '@/lib/types/inventory'

import { getInventoryWithAvailability } from '@/lib/queries/inventory'

export const INVENTORY_CACHE_KEY = 'inventory_data'

export const fetchInventory = async () => {
    // Use centralized query
    const items = await getInventoryWithAvailability()
    
    const itemsWithUrls = items.map((item) => {
        if (!item.image_url) {
            return item
        }

        let imagePath = item.image_url

        // If it's a full URL (signed or public), extract just the path
        if (imagePath.includes('/storage/v1/object/')) {
            const match = imagePath.match(/item-images\/(.+?)(\?|$)/)
            if (match) {
                imagePath = match[1]
            }
        }

        // Always generate a fresh public URL from the path
        const { data } = supabase.storage
            .from('item-images')
            .getPublicUrl(imagePath)

        return {
            ...item,
            image_url: data.publicUrl
        }
    })

    return itemsWithUrls
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
        // --- 🏛️ HIGHER-FIDELITY DELTA SYNC ENGINE ---
        // Instead of a full reload, we 'patch' the individual item in the SWR cache.
        
        const inventoryChannel = supabase
            .channel('inventory-realtime-delta')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, (payload) => {
                refresh((currentInventory: InventoryItem[] | undefined) => {
                    if (!currentInventory) return []

                    switch (payload.eventType) {
                        case 'INSERT':
                            return [payload.new as InventoryItem, ...currentInventory]
                        
                        case 'UPDATE':
                            return currentInventory.map(item => {
                                if (item.id === payload.old.id) {
                                    // 🧩 IMAGE PERSISTENCE: If the update didn't touch the image_url, keep the resolved public URL.
                                    const updatedItem = { ...item, ...payload.new }
                                    if (payload.new.image_url === payload.old.image_url) {
                                        updatedItem.image_url = item.image_url 
                                    }
                                    return updatedItem
                                }
                                return item
                            })
                        
                        case 'DELETE':
                            return currentInventory.filter(item => item.id !== payload.old.id)
                        
                        default:
                            return currentInventory
                    }
                }, { revalidate: false }) // Don't trigger a network fetch if we patched locally
            })
            .on('postgres_changes', { event: '*', schema: 'public', table: 'activity_log' }, () => {
                // For activity logs, we still revalidate to ensure broad inventory consistency
                refresh(undefined, { revalidate: true })
            })
            .subscribe((status) => {
                if (status === 'SUBSCRIBED') {
                    console.log('🏛️ LIGTAS REALTIME: Streaming established for Inventory')
                }
            })

        // Subscribe to borrow_logs changes (for active status)
        const logsChannel = supabase
            .channel('inventory-logs-sync')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => {
                // Patches for complex views/joins are safer with a background revalidate
                refresh(undefined, { revalidate: true }) 
                mutate('borrow_logs') 
            })
            .subscribe()

        return () => {
            supabase.removeChannel(inventoryChannel)
            supabase.removeChannel(logsChannel)
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
