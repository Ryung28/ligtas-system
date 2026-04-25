import React, { useMemo, useCallback, useState, useEffect } from 'react'
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
    const selectedCondition = searchParams.get('condition') || 'all'
    const showAlertsOnly = searchParams.get('alerts') === 'true'
    const isFlatMode = searchParams.get('flat') === 'true'

    // 🎯 LOCAL STATE: Instant typing feedback
    const [localSearch, setLocalSearch] = React.useState(searchQuery)

    // ⏳ DEBOUNCED SYNC: Update URL only after typing stops
    React.useEffect(() => {
        const timer = setTimeout(() => {
            if (localSearch !== searchQuery) {
                const params = new URLSearchParams(searchParams.toString())
                if (!localSearch) params.delete('q')
                else params.set('q', localSearch)
                router.push(`?${params.toString()}`, { scroll: false })
            }
        }, 300)
        return () => clearTimeout(timer)
    }, [localSearch, searchQuery, router, searchParams])

    // Update local state when URL changes (e.g., browser back button)
    React.useEffect(() => {
        setLocalSearch(searchQuery)
    }, [searchQuery])

    // TACTICAL STATE UPDATER: Atomic URL updates for other filters
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
            const searchLower = searchQuery.toLowerCase().trim()
            const matchesSearch = !searchLower || 
                                 item.item_name.toLowerCase().includes(searchLower) ||
                                 item.category?.toLowerCase().includes(searchLower) ||
                                 item.description?.toLowerCase().includes(searchLower)
            
            const matchesCategory = selectedCategory === 'All' || 
                                   item.category?.toLowerCase() === selectedCategory.toLowerCase()
            
            const matchesLocation = selectedLocation === 'All' || 
                                   item.variants.some(v => v.location === selectedLocation)
            
            const matchesAlert = !showAlertsOnly || isLowStock(item) || (item.qty_damaged ?? 0) > 0 || (item.qty_maintenance ?? 0) > 0

            let matchesCondition = true
            if (selectedCondition !== 'all') {
                if (selectedCondition === 'Operational') matchesCondition = item.qty_good > 0
                else if (selectedCondition === 'Maintenance') matchesCondition = (item.qty_maintenance ?? 0) > 0
                else if (selectedCondition === 'Damaged') matchesCondition = (item.qty_damaged ?? 0) > 0
                else if (selectedCondition === 'Lost') matchesCondition = (item.qty_lost ?? 0) > 0
            }

            return matchesSearch && matchesCategory && matchesLocation && matchesAlert && matchesCondition
        })
    }, [items, searchQuery, selectedCategory, selectedLocation, showAlertsOnly])

    return {
        searchQuery: localSearch,
        setSearchQuery: setLocalSearch,
        selectedCategory,
        setSelectedCategory: (val: string) => updateFilter('category', val),
        selectedLocation,
        setSelectedLocation: (val: string) => updateFilter('location', val),
        selectedCondition,
        setSelectedCondition: (val: string) => updateFilter('condition', val),
        isFlatMode,
        setIsFlatMode: (val: boolean) => updateFilter('flat', val ? 'true' : 'false'),
        showAlertsOnly,
        setShowAlertsOnly: (val: boolean) => updateFilter('alerts', val),
        categories,
        locations,
        filteredItems
    }
}

