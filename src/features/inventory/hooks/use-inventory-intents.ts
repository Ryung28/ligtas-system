'use client'

import { useEffect, useCallback } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import { BatchLine, BatchMode } from '../types'
import { toast } from 'sonner'

interface IntentConfig {
    inventory: any[]
    isLoading: boolean
    setBatchMode: (mode: BatchMode) => void
    setSelectedItems: (items: (prev: BatchLine[]) => BatchLine[]) => void
    setReviewOpen: (open: boolean) => void
}

/**
 * 🛰️ useInventoryIntents
 * Senior Dev Intent Dispatcher
 * 🏛️ ARCHITECTURE: Feature-First Silo logic for handling cross-feature navigation intents.
 */
export function useInventoryIntents({
    inventory,
    isLoading,
    setBatchMode,
    setSelectedItems,
    setReviewOpen
}: IntentConfig) {
    const searchParams = useSearchParams()

    const processIntents = useCallback(() => {
        const action = searchParams.get('action')
        const itemId = searchParams.get('itemId')

        if (!action || !itemId || isLoading) return

        // 🛡️ TACTICAL CLEANUP: Always clear intent parameters to prevent spam/re-triggering
        const cleanupIntent = () => {
            const params = new URLSearchParams(searchParams.toString())
            params.delete('action')
            params.delete('itemId')
            params.delete('itemName')
            const newUrl = `${window.location.pathname}${params.toString() ? '?' + params.toString() : ''}`
            window.history.replaceState(null, '', newUrl)
        }

        // 🛡️ INTENT: BORROW
        if (action === 'borrow') {
            const item = inventory.find(i => String(i.id) === String(itemId))

            if (!item) {
                // If not in cache, we stop and cleanup to prevent spam
                toast.error('Logistics Error', { 
                    id: 'intent-error',
                    description: 'Requested item not found in local cache.' 
                })
                cleanupIntent()
                return
            }

            if ((item.stock_available || 0) <= 0) {
                toast.error('Tactical Block', { 
                    id: 'intent-error',
                    description: `${item.item_name} is out of stock.` 
                })
                cleanupIntent()
                return
            }

            // 🚀 HYDRATE STATE: Match Analyst Terminal "Fast Dispatch"
            setBatchMode('borrow')
            setSelectedItems(() => [{
                id: item.id,
                item_name: item.item_name,
                quantity: 1,
                variant_id: item.variants?.[0]?.id || item.id,
                location: item.storage_location || item.primary_location,
                item_type: item.item_type || 'equipment',
                image_url: item.image_url
            }])
            setReviewOpen(true)
            cleanupIntent()
        }
    }, [searchParams, inventory, isLoading, setBatchMode, setSelectedItems, setReviewOpen])

    useEffect(() => {
        processIntents()
    }, [processIntents])
}
