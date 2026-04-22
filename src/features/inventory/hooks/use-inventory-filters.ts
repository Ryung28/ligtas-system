import { useMemo, useCallback } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { AggregatedInventoryItem } from '../types'
import { isLowStock } from '../utils'

export function useInventoryFilters(items: AggregatedInventoryItem[], rawItems: any[]) {
    const router = useRouter()
    const searchParams = useSearchParams()

    // 🎯 URL-SYNCHRONIZED STATE: Mirrors desktop dashboard persistence
    const searchQuery = searchParams.get('q') || ''
    const selectedCategory = searchParams.get('category') || 'All'
    const selectedLocation = searchParams.get('location') || 'All'
    const showAlertsOnly = searchParams.get('alerts') === 'true'

    // TACTICAL STATE UPDATER: Atomic URL updates
    const updateFilter = useCallback((key: string, value: string | boolean) => {
        const params = new URLSearchParams(searchParams.toString())
        if (value === 'All' || value === false || !value) {
            params.delete(key)
        } else {
            params.set(key, value.toString())
        }
        router.push(`?${params.toString()}`, { scroll: false })
    }, [searchParams, router])

    const categories = useMemo(() => {
        const unique = new Set(items.map(item => item.category).filter(Boolean))
        return ['All', ...Array.from(unique)].sort()
    }, [items])

    const locations = useMemo(() => {
        const unique = new Set(rawItems.map(item => item.storage_location).filter(Boolean))
        return ['All', ...Array.from(unique)].sort()
    }, [rawItems])

    const filteredItems = useMemo(() => {
        return items.filter(item => {
            const matchesSearch = item.item_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                                 item.category?.toLowerCase().includes(searchQuery.toLowerCase())
            
            const matchesCategory = selectedCategory === 'All' || item.category === selectedCategory
            
            const matchesLocation = selectedLocation === 'All' || 
                                   item.variants.some(v => v.location === selectedLocation)
            
            const matchesAlert = !showAlertsOnly || isLowStock(item) || (item.qty_damaged ?? 0) > 0 || (item.qty_maintenance ?? 0) > 0

            return matchesSearch && matchesCategory && matchesLocation && matchesAlert
        })
    }, [items, searchQuery, selectedCategory, selectedLocation, showAlertsOnly])

    return {
        searchQuery,
        setSearchQuery: (val: string) => updateFilter('q', val),
        selectedCategory,
        setSelectedCategory: (val: string) => updateFilter('category', val),
        selectedLocation,
        setSelectedLocation: (val: string) => updateFilter('location', val),
        showAlertsOnly,
        setShowAlertsOnly: (val: boolean) => updateFilter('alerts', val),
        categories,
        locations,
        filteredItems
    }
}

