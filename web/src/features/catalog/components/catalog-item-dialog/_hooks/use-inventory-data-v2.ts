"use client"

import { useMemo } from 'react'
import useSWR from 'swr'
import { createBrowserClient } from '@supabase/ssr'
import { getCategories } from '../../../queries/catalog.queries'
import { getStorageLocations } from '@/app/actions/storage-locations'

/**
 * ResQTrack V2 DATA HOOK
 * Handles all database-fetching logic for the inventory form.
 * Decoupled from UI and State to prevent re-fetch loops.
 * 🛰️ Uses SWR for global caching and instant UI feedback.
 */
export function useInventoryDataV2(isOpen: boolean) {
    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])

    // ── 1. Categories Caching ──
    const { data: categories = [], isLoading: isCatsLoading } = useSWR(
        isOpen ? 'catalog/categories' : null,
        async () => {
            const res = await getCategories()
            return (res.data || []).map((name: string) => ({
                id: name,
                category_name: name
            }))
        },
        { revalidateOnFocus: false, dedupingInterval: 60000 }
    )

    // ── 2. Locations Caching ──
    const { data: locations = [], isLoading: isLocsLoading } = useSWR(
        isOpen ? 'inventory/locations' : null,
        async () => {
            const res = await getStorageLocations()
            return res.success ? res.data : []
        },
        { revalidateOnFocus: false, dedupingInterval: 60000 }
    )

    // ── 3. Parent Items Caching (Limited to 200 for perf) ──
    const { data: parents = [], isLoading: isParentsLoading } = useSWR(
        isOpen ? 'catalog/parent-items' : null,
        async () => {
            const { data } = await supabase
                .from('inventory')
                .select('id, item_name')
                .is('parent_id', null)
                .is('deleted_at', null)
                .limit(200)
                .order('item_name')
            return data || []
        },
        { revalidateOnFocus: false, dedupingInterval: 60000 }
    )

    return {
        categories,
        locations,
        parents,
        isLoading: isCatsLoading || isLocsLoading || isParentsLoading
    }
}
