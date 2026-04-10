'use client'

import useSWR from 'swr'
import { useMemo, useEffect } from 'react'
import { supabase, type InventoryItem } from '@/lib/supabase'

import { getInventory } from '@/lib/queries/inventory'

export interface DashboardStats {
    totalItems: number
    lowStockCount: number
    outOfStockCount: number
    totalStock: number
    activeBorrows: number
    damagedCount: number
}

export interface DashboardData {
    inventory: InventoryItem[]
    stats: DashboardStats
    timestamp: string
}

const CATEGORY_COLORS: Record<string, string> = {
    'Rescue': '#f59e0b',
    'Medical': '#ef4444',
    'Comms': '#8b5cf6',
    'Vehicles': '#14b8a6',
    'Office': '#64748b',
    'Tools': '#3b82f6',
    'PPE': '#f97316',
    'Logistics': '#6366f1',
    'Default': '#94a3b8'
}

export const fetchDashboardData = async (): Promise<DashboardData> => {
    // Use centralized query
    const inventoryItems = await getInventory()

    // Fetch borrow logs for active borrows count (Sum of quantities in field)
    const { data: logs, error: logsError } = await supabase
        .from('borrow_logs')
        .select('quantity')
        .eq('status', 'borrowed')

    if (logsError) throw logsError

    const totalItems = inventoryItems?.length || 0
    const totalStock = inventoryItems?.reduce((sum, item) => sum + (item.stock_available || 0), 0) || 0
    const lowStockCount = inventoryItems?.filter(item => {
        const available = item.stock_available || 0
        const total = (item as any).stock_total || 1
        const threshold = total * 0.5
        return available > 0 && available < threshold
    }).length || 0
    const outOfStockCount = inventoryItems?.filter(item => (item.stock_available || 0) === 0).length || 0
    const damagedCount = inventoryItems?.filter(item =>
        ['Maintenance', 'Damaged', 'Lost'].includes(item.status || '')
    ).length || 0
    const activeBorrows = logs?.reduce((sum, log) => sum + (log.quantity || 0), 0) || 0

    return {
        inventory: (inventoryItems || []) as InventoryItem[],
        stats: {
            totalItems,
            lowStockCount,
            outOfStockCount,
            totalStock,
            activeBorrows,
            damagedCount,
        },
        timestamp: new Date().toLocaleTimeString()
    }
}

export function useDashboardStats() {
    const { data, error, isLoading, mutate: refresh } = useSWR('dashboard_stats', fetchDashboardData, {
        revalidateOnFocus: false, // 🚀 ZERO LATENCY: UI remains responsive during focus events
        dedupingInterval: 5000, 
    })

    const topItemsData = useMemo(() => {
        const inventoryData = data?.inventory || []
        return inventoryData
            .sort((a, b) => b.stock_available - a.stock_available)
            .slice(0, 7)
            .map(item => ({
                name: item.item_name.length > 16 ? item.item_name.substring(0, 16) + '...' : item.item_name,
                stock: item.stock_available,
            }))
    }, [data?.inventory])

    const categoryDistribution = useMemo(() => {
        const inventoryData = data?.inventory || []
        const categoryMap = new Map<string, number>()
        inventoryData.forEach(item => {
            const category = item.category || 'Uncategorized'
            categoryMap.set(category, (categoryMap.get(category) || 0) + item.stock_available)
        })
        return Array.from(categoryMap.entries())
            .map(([name, value]) => ({
                name,
                value,
                fill: CATEGORY_COLORS[name] || CATEGORY_COLORS['Default']
            }))
            .sort((a, b) => b.value - a.value)
            .slice(0, 5)
    }, [data?.inventory])

    // Real-time updates subscription
    useEffect(() => {
        // Subscribe to inventory changes
        const inventoryChannel = supabase
            .channel('dashboard-inventory-realtime')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, () => {
                refresh(undefined, { revalidate: true })
            })
            .on('postgres_changes', { event: '*', schema: 'public', table: 'activity_log' }, () => {
                refresh(undefined, { revalidate: true })
            })
            .subscribe()

        // Subscribe to borrow_logs changes
        const logsChannel = supabase
            .channel('dashboard-logs-realtime')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => {
                refresh(undefined, { revalidate: true })
            })
            .subscribe()

        return () => {
            supabase.removeChannel(inventoryChannel)
            supabase.removeChannel(logsChannel)
        }
    }, [refresh])

    return {
        data,
        error,
        isLoading,
        refresh,
        topItemsData,
        categoryDistribution,
        stats: data?.stats || { totalItems: 0, lowStockCount: 0, outOfStockCount: 0, totalStock: 0, activeBorrows: 0, damagedCount: 0 }
    }
}
