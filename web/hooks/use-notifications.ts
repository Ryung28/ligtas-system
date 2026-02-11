'use client'

import { useEffect, useMemo } from 'react'
import useSWR from 'swr'
import { supabase } from '@/lib/supabase'
import { BorrowLog } from '@/lib/types/inventory'

export interface NotificationItem {
    id: string
    title: string
    message: string
    time: string
    type: 'return' | 'stock' | 'overdue'
    isRead: boolean
}

const fetchNotificationData = async () => {
    // Fetch latest returns
    const { data: recentLogs, error: logsError } = await supabase
        .from('borrow_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10)

    if (logsError) throw logsError

    // Fetch low stock items
    const { data: lowStock, error: stockError } = await supabase
        .from('inventory')
        .select('item_name, stock_available')
        .lt('stock_available', 5)
        .gt('stock_available', 0)

    if (stockError) throw stockError

    const notifications: NotificationItem[] = []
    const TIME_GAP_MS = 15 * 60 * 1000 // 15 mins

    // Group returns by borrower and time
    const returnGroups: Record<string, BorrowLog[]> = {}
    recentLogs?.filter(l => l.status === 'returned').forEach((log: BorrowLog) => {
        const timeKey = Math.floor(new Date(log.created_at).getTime() / TIME_GAP_MS)
        const key = `${log.borrower_name}-${timeKey}`
        if (!returnGroups[key]) returnGroups[key] = []
        returnGroups[key].push(log)
    })

    // Map aggregated returns to notifications
    Object.values(returnGroups).forEach(group => {
        const first = group[0]
        const totalQty = group.reduce((sum, item) => sum + item.quantity, 0)
        notifications.push({
            id: `ret-${first.id}`,
            title: 'Items Returned',
            message: `${first.borrower_name} returned ${totalQty} units (${group.length} unique items)`,
            time: first.created_at,
            type: 'return',
            isRead: false
        })
    })

    // Handle stock alerts (one summary if many)
    if (lowStock && lowStock.length > 0) {
        if (lowStock.length > 3) {
            notifications.push({
                id: 'stock-bulk',
                title: 'Critical Stock Alert',
                message: `${lowStock.length} items are running low on stock`,
                time: new Date().toISOString(),
                type: 'stock',
                isRead: false
            })
        } else {
            lowStock.forEach((item, index) => {
                notifications.push({
                    id: `stock-${index}`,
                    title: 'Low Stock Alert',
                    message: `${item.item_name} is running low (${item.stock_available} left)`,
                    time: new Date().toISOString(),
                    type: 'stock',
                    isRead: false
                })
            })
        }
    }

    return notifications.sort((a, b) => new Date(b.time).getTime() - new Date(a.time).getTime())
}

export function useNotifications() {
    const { data: notifications = [], mutate, isLoading } = useSWR('notifications', fetchNotificationData, {
        revalidateOnFocus: true,
        refreshInterval: 30000, // 30s
    })

    useEffect(() => {
        const channel = supabase
            .channel('notifications-realtime')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => mutate())
            .on('postgres_changes', { event: '*', schema: 'public', table: 'inventory' }, () => mutate())
            .subscribe()

        return () => { supabase.removeChannel(channel) }
    }, [mutate])

    return {
        notifications,
        unreadCount: notifications.filter(n => !n.isRead).length,
        markAsRead: () => {
            // In a real app, update DB. Here we just mutate local cache
            mutate(notifications.map(n => ({ ...n, isRead: true })), false)
        },
        isLoading,
        refresh: mutate
    }
}
