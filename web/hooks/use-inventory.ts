'use client'

import React, { useEffect } from 'react'
import useSWR, { mutate } from 'swr'
import { supabase } from '@/lib/supabase'
import { InventoryItem } from '@/lib/supabase'
import { BorrowLog } from '@/lib/types/inventory'

export const INVENTORY_CACHE_KEY = 'inventory_data'

export const fetchInventory = async () => {
    const { data, error } = await supabase
        .from('inventory')
        .select('*')
        .is('deleted_at', null)
        .order('item_name', { ascending: true })

    if (error) throw error

    // Generate signed URLs for all items with images
    const items = (data || []) as InventoryItem[]
    const itemsWithUrls = await Promise.all(items.map(async (item) => {
        if (item.image_url) {
            try {
                // Extract path if it's a full URL from our bucket
                let path = item.image_url
                if (path.includes('/storage/v1/object/')) {
                    // Extract the path after 'item-images/'
                    const parts = path.split('item-images/')
                    if (parts.length > 1) {
                        path = parts[1].split('?')[0] // Get path before query params
                    }
                }

                // If it's still a full URL from elsewhere, keep it
                if (path.startsWith('http')) {
                    return item
                }

                // Generate fresh signed URL for the image path
                const { data, error: storageError } = await supabase.storage
                    .from('item-images')
                    .createSignedUrl(path, 60 * 60 * 24) // 24 hours

                if (storageError || !data || !data.signedUrl) {
                    return item
                }

                return { ...item, image_url: data.signedUrl }
            } catch (err) {
                return item
            }
        }
        return item
    }))

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
        // Subscribe to inventory changes
        const inventoryChannel = supabase
            .channel('inventory-realtime-global')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, () => {
                refresh()
            })
            .subscribe()

        // Subscribe to borrow_logs changes (for active status)
        const logsChannel = supabase
            .channel('inventory-logs-sync')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => {
                refresh() // Refresh inventory
                mutate('borrow_logs') // Refresh logs cache
            })
            .subscribe()

        return () => {
            supabase.removeChannel(inventoryChannel)
            supabase.removeChannel(logsChannel)
        }
    }, [refresh, mutate])

    return {
        inventory: inventoryWithBorrows,
        isLoading: isLoading || isValidating,
        lastUpdated,
        error: error?.message || null,
        refresh
    }
}
