'use client'

import React, { useEffect } from 'react'
import useSWR, { mutate } from 'swr'
import { supabase } from '@/lib/supabase'
import { InventoryItem } from '@/lib/supabase'
import { BorrowLog } from '@/lib/types/inventory'

export const INVENTORY_CACHE_KEY = 'inventory_data'

export const fetchInventory = async () => {
    // Fetch inventory with stock_pending from availability view
    const { data: inventoryData, error: invError } = await supabase
        .from('inventory')
        .select('*')
        .is('deleted_at', null)
        .order('item_name', { ascending: true })

    if (invError) throw invError

    // Fetch pending counts from availability view
    const { data: availabilityData } = await supabase
        .from('inventory_availability')
        .select('id, stock_pending')

    // Create a map for quick lookup
    const pendingMap = new Map(
        (availabilityData || []).map(item => [item.id, item.stock_pending])
    )

    // Generate signed URLs for all items with images
    const items = (inventoryData || []) as InventoryItem[]
    const itemsWithUrls = await Promise.all(items.map(async (item) => {
        let imageUrl = item.image_url

        if (imageUrl) {
            try {
                // Extract path if it's a full URL from our bucket
                let path = imageUrl
                if (path.includes('/storage/v1/object/')) {
                    // Extract the path after 'item-images/'
                    const parts = path.split('item-images/')
                    if (parts.length > 1) {
                        path = parts[1].split('?')[0] // Get path before query params
                    }
                }

                // If it's still a full URL from elsewhere, keep it
                if (path.startsWith('http')) {
                    imageUrl = path
                } else {
                    // Generate fresh signed URL for the image path
                    const { data, error: storageError } = await supabase.storage
                        .from('item-images')
                        .createSignedUrl(path, 60 * 60 * 24) // 24 hours

                    if (!storageError && data?.signedUrl) {
                        imageUrl = data.signedUrl
                    }
                }
            } catch (err) {
                // Keep original URL on error
            }
        }

        return {
            ...item,
            image_url: imageUrl,
            stock_pending: pendingMap.get(item.id) || 0
        }
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
