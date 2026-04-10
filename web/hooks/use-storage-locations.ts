'use client'

import useSWR from 'swr'
import { getStorageLocations } from '@/app/actions/storage-locations'
import { STORAGE_LOCATION_LABELS, StorageLocation } from '@/lib/supabase'

const STORAGE_LOCATIONS_KEY = 'storage_locations_registry'

export function useStorageLocations() {
    const { data: result, error, isLoading, mutate } = useSWR(STORAGE_LOCATIONS_KEY, getStorageLocations, {
        revalidateOnFocus: false,
        dedupingInterval: 60000, // 1 minute cache
    })

    const locations = (result?.data as any[]) || []

    /**
     * Resolves a raw database location string to a friendly display name.
     * Prioritizes: Dynamic Registry > Hardcoded Labels > Raw String
     */
    const resolveLocationName = (rawName: string | null | undefined): string => {
        if (!rawName) return 'Main Hub'
        
        // 1. Check if it's in the Dynamic Registry (User-added via Settings)
        // We match by name for legacy support, but return the official registry name.
        const dynamicMatch = locations.find(loc => loc.location_name.toLowerCase() === rawName.toLowerCase())
        if (dynamicMatch) return dynamicMatch.location_name

        // 2. Check the legacy hardcoded labels
        if (rawName in STORAGE_LOCATION_LABELS) {
            return STORAGE_LOCATION_LABELS[rawName as StorageLocation]
        }

        // 3. Fallback to the raw string (Prettified)
        return rawName.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
    }

    return {
        locations,
        resolveLocationName,
        isLoading,
        error,
        refresh: mutate
    }
}
