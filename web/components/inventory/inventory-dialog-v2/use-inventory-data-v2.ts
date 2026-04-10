"use client"

import { useState, useEffect, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { getCategories } from '@/src/features/catalog'
import { getStorageLocations } from '@/app/actions/storage-locations'

/**
 * LIGTAS V2 DATA HOOK
 * Handles all database-fetching logic for the inventory form.
 * Decoupled from UI and State to prevent re-fetch loops.
 */
export function useInventoryDataV2(isOpen: boolean) {
    const [categories, setCategories] = useState<any[]>([])
    const [locations, setLocations] = useState<any[]>([])
    const [parents, setParents] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)

    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])

    useEffect(() => {
        if (!isOpen) return
        
        async function load() {
            setIsLoading(true)
            try {
                // Fetch Categories (Objects) and Locations
                const [catRes, locRes] = await Promise.all([
                    getCategories(),
                    getStorageLocations()
                ])
                
                // Fix for Ghost Dropdown: Normalize flat strings into V2 Entities {id, category_name}
                const normalized = (catRes.data || []).map((name: string) => ({
                    id: name,
                    category_name: name
                }))
                setCategories(normalized)
                if (locRes.success) setLocations(locRes.data)
                
                // Fetch Parent items for "Belongs to set" logic
                const { data: parentData } = await supabase
                    .from('inventory_items')
                    .select('id, item_name')
                    .is('parent_id', null)
                    .order('item_name')
                
                setParents(parentData || [])
            } catch (error) {
                console.error('LIGTAS_V2_DATA_ERROR:', error)
            } finally {
                setIsLoading(false)
            }
        }
        load()
    }, [isOpen, supabase])

    return { categories, locations, parents, isLoading }
}
