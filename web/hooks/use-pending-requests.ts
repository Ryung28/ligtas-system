'use client'

import useSWR from 'swr'
import { supabase } from '@/lib/supabase'
import { BorrowLog } from '@/lib/types/inventory'
import { useEffect } from 'react'

export const PENDING_REQUESTS_KEY = 'pending_requests'

const fetchPendingRequests = async () => {
    // Senior Dev: Use identity resolution via join to fix "Unknown Item" issues from mobile
    const { data, error } = await supabase
        .from('borrow_logs')
        .select(`
            *,
            inventory:inventory_id (
                item_name
            )
        `)
        .eq('status', 'pending')
        .order('created_at', { ascending: false })

    if (error) throw error

    // Self-healing logic: fallback to inventory name if log entry is corrupted or generic
    return (data as any[]).map(log => ({
        ...log,
        item_name: (log.item_name && log.item_name !== 'Unknown Item')
            ? log.item_name
            : (log.inventory?.item_name || log.item_name || 'Unknown Item')
    })) as BorrowLog[]
}

export function usePendingRequests() {
    const { data: requests = [], error, isLoading, mutate: refresh } = useSWR(
        PENDING_REQUESTS_KEY,
        fetchPendingRequests,
        {
            revalidateOnFocus: true,
            refreshInterval: 10000, // Faster refresh for approvals
        }
    )

    useEffect(() => {
        const channel = supabase
            .channel('pending-requests-realtime')
            .on('postgres_changes', {
                event: '*',
                schema: 'public',
                table: 'borrow_logs',
                filter: 'status=eq.pending'
            }, () => {
                refresh()
            })
            .on('postgres_changes', {
                event: 'UPDATE',
                schema: 'public',
                table: 'borrow_logs'
            }, () => {
                // Refresh if status changed from pending to something else
                refresh()
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [refresh])

    return {
        requests,
        isLoading,
        error: error?.message || null,
        refresh
    }
}
