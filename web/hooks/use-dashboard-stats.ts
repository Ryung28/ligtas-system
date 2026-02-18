'use client'

import useSWR from 'swr'
import { useMemo, useEffect } from 'react'
import { supabase } from '@/lib/supabase'

export interface InventoryItem {
    item_name: string
    stock_available: number
    category?: string
    status?: string
}

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
    'Rescue': '#f59e0b',    // Amber
    'Medical': '#ef4444',   // Red
    'Comms': '#8b5cf6',     // Violet
    'Vehicles': '#14b8a6',  // Teal
    'Office': '#64748b',    // Slate
    'Tools': '#3b82f6',     // Blue
    'PPE': '#f97316',       // Orange
    'Logistics': '#6366f1', // Indigo
    'Default': '#94a3b8'
}

const fetchDashboardData = async (): Promise<DashboardData> => {
    // Fetch inventory
    const { data: inventoryItems, error: inventoryError } = await supabase
        .from('inventory')
        .select('item_name, stock_available, category, status')

    if (inventoryError) throw inventoryError

    // Fetch borrow logs for active borrows count (Sum of quantities in field)
    const { data: logs, error: logsError } = await supabase
        .from('borrow_logs')
        .select('quantity')
        .eq('status', 'borrowed')

    if (logsError) throw logsError

    const totalItems = inventoryItems?.length || 0
    const totalStock = inventoryItems?.reduce((sum, item) => sum + (item.stock_available || 0), 0) || 0
    const lowStockCount = inventoryItems?.filter(item => (item.stock_available || 0) > 0 && (item.stock_available || 0) < 5).length || 0
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
        revalidateOnFocus: false,
        dedupingInterval: 30000,
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

    // Real-time subscriptions
    useEffect(() => {
        // Subscribe to inventory changes
        const inventoryChannel = supabase
            .channel('dashboard-inventory-realtime')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, () => {
                refresh()
            })
            .subscribe()

        // Subscribe to borrow_logs changes
        const logsChannel = supabase
            .channel('dashboard-logs-realtime')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => {
                refresh()
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
