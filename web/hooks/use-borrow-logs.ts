'use client'

import { useEffect, useMemo, useState } from 'react'
import useSWR, { mutate } from 'swr'
import { supabase } from '@/lib/supabase'
import { BorrowLog, BorrowSession, LogStats, TransactionStatus } from '@/lib/types/inventory'

// SWR Configurations
export const LOGS_CACHE_KEY = 'borrow_logs'

export const fetchLogs = async () => {
    // Senior Dev: Implementing full identity resolution across all logs
    // This fixes "Unknown Item" issues caused by incomplete mobile syncs
    const { data, error } = await supabase
        .from('borrow_logs')
        .select(`
            *,
            inventory:inventory_id (
                item_name
            )
        `)
        .order('created_at', { ascending: false })

    if (error) throw error

    // Resolution Logic: Priority = Log Name > Inventory Name > Fallback
    return (data as any[]).map(log => ({
        ...log,
        item_name: (log.item_name && log.item_name !== 'Unknown Item')
            ? log.item_name
            : (log.inventory?.item_name || log.item_name || 'Unknown Item')
    })) as BorrowLog[]
}

export function useBorrowLogs(initialFilter: TransactionStatus = 'all') {
    const {
        data: logs = [],
        error,
        isLoading,
        isValidating,
        mutate: refresh
    } = useSWR(LOGS_CACHE_KEY, fetchLogs, {
        revalidateOnFocus: true,
        refreshInterval: 30000, // 30s Heartbeat (Senior Dev Best Practice)
        dedupingInterval: 10000,
    })

    const [searchQuery, setSearchQuery] = useState('')
    const [statusFilter, setStatusFilter] = useState<TransactionStatus>(initialFilter)
    const [dateFilter, setDateFilter] = useState<string>('')
    const [currentPage, setCurrentPage] = useState(1)
    const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set())
    const [expandedSessions, setExpandedSessions] = useState<Set<string>>(new Set())

    const ITEMS_PER_PAGE = 10

    // Real-time updates subscription
    useEffect(() => {
        const channel = supabase
            .channel('public:borrow_logs_realtime')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'borrow_logs' }, () => {
                refresh() // Trigger SWR re-fetch
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [refresh])

    // Filter Logic
    const filteredLogs = useMemo(() => {
        return logs.filter((log) => {
            const matchesSearch =
                log.item_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                log.borrower_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                log.borrower_organization?.toLowerCase().includes(searchQuery.toLowerCase())
            const matchesStatus = statusFilter === 'all' || log.status === statusFilter
            let matchesDate = true
            if (dateFilter) {
                const logDate = new Date(log.borrow_date || log.created_at).toISOString().split('T')[0]
                matchesDate = logDate === dateFilter
            }
            return matchesSearch && matchesStatus && matchesDate
        })
    }, [logs, searchQuery, statusFilter, dateFilter])

    // Grouping into Sessions (Time-Gap Algorithm)
    const sessions = useMemo(() => {
        if (!filteredLogs.length) return []

        // 1. Sort by borrower then time
        const sorted = [...filteredLogs].sort((a, b) => {
            if (a.borrower_name !== b.borrower_name) return a.borrower_name.localeCompare(b.borrower_name)
            return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        })

        const sessionsList: BorrowSession[] = []
        const TIME_GAP_MS = 15 * 60 * 1000 // 15 minutes

        sorted.forEach((log) => {
            const logTime = new Date(log.created_at).getTime()

            // Find an existing session for this borrower that is within the time gap
            const parentSession = sessionsList.find(s =>
                s.borrower_name === log.borrower_name &&
                Math.abs(new Date(s.created_at).getTime() - logTime) <= TIME_GAP_MS
            )

            if (parentSession) {
                parentSession.items.push(log)
                parentSession.total_quantity += log.quantity
                if (parentSession.status !== log.status) parentSession.status = 'mixed'
                // Update session time to the latest item in the group
                if (logTime > new Date(parentSession.created_at).getTime()) {
                    parentSession.created_at = log.created_at
                }
            } else {
                sessionsList.push({
                    key: `${log.borrower_name}-${log.id}`,
                    borrower_name: log.borrower_name,
                    borrower_organization: log.borrower_organization,
                    borrower_contact: log.borrower_contact,
                    items: [log],
                    total_quantity: log.quantity,
                    status: log.status,
                    created_at: log.created_at
                })
            }
        })

        return sessionsList.sort((a, b) =>
            new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        )
    }, [filteredLogs])

    const stats: LogStats = useMemo(() => ({
        total: logs.length,
        borrowed: logs.filter(l => l.status === 'borrowed').length,
        returned: logs.filter(l => l.status === 'returned').length,
        overdue: logs.filter(l => l.status === 'overdue').length,
        pending: logs.filter(l => l.status === 'pending').length,
        cancelled: logs.filter(l => l.status === 'cancelled').length,
    }), [logs])

    const paginatedSessions = useMemo(() => {
        const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
        return sessions.slice(startIndex, startIndex + ITEMS_PER_PAGE)
    }, [sessions, currentPage])

    const totalPages = Math.ceil(sessions.length / ITEMS_PER_PAGE)

    const toggleId = (id: number) => {
        const newSelected = new Set(selectedIds)
        if (newSelected.has(id)) newSelected.delete(id)
        else newSelected.add(id)
        setSelectedIds(newSelected)
    }

    const toggleSessionExpansion = (key: string) => {
        const newExpanded = new Set(expandedSessions)
        if (newExpanded.has(key)) newExpanded.delete(key)
        else newExpanded.add(key)
        setExpandedSessions(newExpanded)
    }

    // TIER-1 TRACKER: Group all active borrows by staff name
    const staffTracking = useMemo(() => {
        const tracking: Record<string, { count: number, items: BorrowLog[] }> = {}
        logs.filter(l => l.status === 'borrowed').forEach(log => {
            if (!tracking[log.borrower_name]) {
                tracking[log.borrower_name] = { count: 0, items: [] }
            }
            tracking[log.borrower_name].count += log.quantity
            tracking[log.borrower_name].items.push(log)
        })
        return tracking
    }, [logs])

    return {
        logs, // Raw logs for global lookups
        sessions: paginatedSessions,
        staffTracking, // New tracking data
        stats,
        isLoading,
        error: error?.message || null,
        searchQuery,
        setSearchQuery,
        statusFilter,
        setStatusFilter,
        dateFilter,
        setDateFilter,
        currentPage,
        setCurrentPage,
        totalPages,
        selectedIds,
        setSelectedIds,
        toggleId,
        expandedSessions,
        toggleSessionExpansion,
        refresh,
        isValidating
    }
}
