'use client'

import React, { useMemo } from 'react'
import { AggregatedInventoryItem } from '@/src/features/inventory/types'
import { aggregateInventory, isLowStock } from '@/src/features/inventory/utils'
import { FilterType } from '../_components/alert-filters'

export function useAlertTriage(inventory: any[] | undefined, activeFilter: FilterType) {
    const inventoryAnomalies = useMemo(() => {
        if (!inventory) return []
        
        const aggregated = aggregateInventory(inventory)
        
        return aggregated.filter(item => {
            const isLow = isLowStock(item)
            const isOut = item.stock_available === 0
            const hasHealthIssues = item.qty_damaged > 0 || item.qty_maintenance > 0 || item.qty_lost > 0
            
            let isExpiring = false
            const expiry = (item as any).expiry_date
            if (expiry) {
                const diff = (new Date(expiry).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
                isExpiring = diff <= 30
            }

            return isLow || isOut || hasHealthIssues || isExpiring
        })
    }, [inventory])

    const filteredAnomalies = useMemo(() => {
        return inventoryAnomalies.filter(item => {
            if (activeFilter === 'all') return true
            if (activeFilter === 'critical') return item.stock_available === 0 || isLowStock(item)
            if (activeFilter === 'health') return item.qty_damaged > 0 || item.qty_maintenance > 0
            return false
        })
    }, [inventoryAnomalies, activeFilter])

    const stats = useMemo(() => ({
        critical: inventoryAnomalies.filter(i => i.stock_available === 0 || isLowStock(i)).length,
        health: inventoryAnomalies.filter(i => i.qty_damaged > 0 || i.qty_maintenance > 0).length
    }), [inventoryAnomalies])

    return {
        inventoryAnomalies,
        filteredAnomalies,
        stats
    }
}
