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
        .order('item_name', { ascending: true })

    if (error) throw error
    
    // Generate signed URLs for all items with images
    const items = (data || []) as InventoryItem[]
    const itemsWithUrls = await Promise.all(items.map(async (item) => {
        if (item.image_url) {
            try {
                // Check if image_url is already a full URL or just a path
                if (item.image_url.startsWith('http')) {
                    return item
                }
                
                // Generate signed URL for the image
                const { data: { signedUrl }, error } = await supabase.storage
                    .from('item-images')
                    .createSignedUrl(item.image_url, 60 * 60 * 24) // 24 hours
                
                if (error) {
                    console.warn(`Failed to generate signed URL for ${item.image_url}:`, error)
                    return item
                }
                
                return { ...item, image_url: signedUrl }
            } catch (err) {
                console.warn(`Error processing image for ${item.item_name}:`, err)
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
    }, [refresh])

    return {
        inventory: inventoryWithBorrows,
        isLoading: isLoading || isValidating,
        lastUpdated,
        error: error?.message || null,
        refresh
    }
}
