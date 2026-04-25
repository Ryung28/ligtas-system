'use client'

import { useEffect, useMemo, useState } from 'react'
import useSWR from 'swr'
import { useSearchParams } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import { BorrowLog, BorrowSession, LogStats, TransactionStatus } from '@/lib/types/inventory'
import { getBorrowLogsAction, getBorrowLogByIdAction } from '@/app/actions/logs-actions'

// SWR Configurations
export const LOGS_CACHE_KEY = 'borrow_logs'

export const fetchLogs = async () => {
    // Senior Dev Strategy: Using the "Server Bridge" (getBorrowLogsAction)
    // This solves the "Multiple GoTrueClient" identity leak and empty log issues.
    const res = await getBorrowLogsAction()
    
    if (!res.success) {
        console.error('📡 Log Fetch Error:', res.error)
        throw new Error(res.error || 'Failed to fetch logs')
    }

    return res.data || []
}

export function useBorrowLogs(initialFilter: TransactionStatus = 'all') {
    const searchParams = useSearchParams()
    const triageId = searchParams.get('id')
    const [triageLog, setTriageLog] = useState<BorrowLog | null>(null)

    const {
        data: logs = [],
        error,
        isLoading,
        isValidating,
        mutate: refresh
    } = useSWR(LOGS_CACHE_KEY, fetchLogs, {
        revalidateOnFocus: false, // 🛡️ TRUST THE CACHE: Instant swap from memory
        refreshInterval: 60000, // 60s Loose Heartbeat
        dedupingInterval: 10000,
    })

    const [searchQuery, setSearchQuery] = useState('')
    const [statusFilter, setStatusFilter] = useState<TransactionStatus>(initialFilter)
    const [dateFilter, setDateFilter] = useState<string>('')
    const [sortOrder, setSortOrder] = useState<'latest' | 'oldest'>('latest')
    const [currentPage, setCurrentPage] = useState(1)
    const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set())
    const [expandedSessions, setExpandedSessions] = useState<Set<string>>(new Set())

    // 🛡️ ATOMIC RESOLUTION: Ensure the triage record is ALWAYS available
    useEffect(() => {
        if (!triageId) {
            setTriageLog(null)
            return
        }

        // 1. Optimization: Check if it's already in our loaded list
        const inMemoryRecord = logs.find(l => l.id.toString() === triageId)
        if (inMemoryRecord) {
            setTriageLog(inMemoryRecord)
        } else {
            // 2. Precision Fetch: Pull the exact row from the database (bypass 100-limit)
            getBorrowLogByIdAction(triageId).then(res => {
                if (res.success && res.data) {
                    setTriageLog(res.data)
                }
            })
        }
    }, [triageId, logs])

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
        // 🛡️ SENIOR DATA NORMALIZATION: Use a Map keyed by string IDs to merge pools.
        // This makes duplicate IDs mathematically impossible regardless of source.
        const poolMap = new Map<string, BorrowLog>();
        
        // 1. Load bulk logs
        logs.forEach(log => poolMap.set(String(log.id), log));
        
        // 2. Triage log overrides (Ensures precision data for the deep-linked record)
        if (triageLog) poolMap.set(String(triageLog.id), triageLog);

        const pool = Array.from(poolMap.values());

        return pool.filter((log) => {
            const matchesId = triageId ? String(log.id) === String(triageId) : false
            const matchesSearch =
                log.item_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                log.borrower_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                log.borrower_organization?.toLowerCase().includes(searchQuery.toLowerCase())
            
            const matchesStatus = statusFilter === 'all' 
                ? true 
                : statusFilter === 'overdue'
                    ? (log.status === 'borrowed' && log.expected_return_date && new Date(log.expected_return_date) < new Date())
                    : log.status === statusFilter
            
            let matchesDate = true
            if (dateFilter) {
                const logDate = new Date(log.borrow_date || log.created_at).toISOString().split('T')[0]
                matchesDate = logDate === dateFilter
            }
            
            // Priority: If it matches the deep-link ID, it survives regardless of other filters.
            return matchesId || (matchesSearch && matchesStatus && matchesDate)
        })
    }, [logs, triageLog, searchQuery, statusFilter, dateFilter, triageId])

    // Grouping into Sessions (Time-Gap Algorithm - Optimized O(N))
    const sessions = useMemo(() => {
        if (!filteredLogs.length) return []

        // 1. Sort by transaction date — direction controlled by sortOrder
        const sorted = [...filteredLogs].sort((a, b) => {
            const timeA = new Date(a.borrow_date || a.created_at).getTime()
            const timeB = new Date(b.borrow_date || b.created_at).getTime()
            return sortOrder === 'latest' ? timeB - timeA : timeA - timeB
        })

        const sessionsList: BorrowSession[] = []
        const TIME_GAP_MS = 15 * 60 * 1000 // 15 minutes
        
        let currentSession: BorrowSession | null = null

        sorted.forEach((log) => {
            const logTime = new Date(log.created_at).getTime()
            const isSameSession = currentSession && 
                currentSession.borrower_name === log.borrower_name &&
                Math.abs(new Date(currentSession.created_at).getTime() - logTime) <= TIME_GAP_MS

            if (isSameSession && currentSession) {
                currentSession.items.push(log)
                currentSession.total_quantity += log.quantity
                if (currentSession.status !== log.status) currentSession.status = 'mixed'
                if (logTime > new Date(currentSession.created_at).getTime()) {
                    currentSession.created_at = log.created_at
                }
            } else {
                currentSession = {
                    key: `${log.borrower_name}-${log.id}`,
                    borrower_name: log.borrower_name,
                    borrower_organization: log.borrower_organization,
                    borrower_contact: log.borrower_contact,
                    items: [log],
                    total_quantity: log.quantity,
                    status: log.status,
                    approved_by_name: log.approved_by_name,
                    released_by_name: log.released_by_name,
                    pickup_scheduled_at: log.pickup_scheduled_at,
                    platform_origin: log.platform_origin,
                    created_origin: log.created_origin,
                    created_at: log.created_at
                }
                sessionsList.push(currentSession)
            }
        })

        // 🛡️ DATA HOISTING: Ensure the session containing the triageId is moved to index 0
        return sessionsList.sort((a, b) => {
            if (triageId) {
                const aHasTarget = a.items.some(i => String(i.id) === String(triageId))
                const bHasTarget = b.items.some(i => String(i.id) === String(triageId))
                if (aHasTarget) return -1
                if (bHasTarget) return 1
            }
            const timeA = new Date(a.created_at).getTime()
            const timeB = new Date(b.created_at).getTime()
            return sortOrder === 'latest' ? timeB - timeA : timeA - timeB
        })
    }, [filteredLogs, triageId, sortOrder])

    const stats: LogStats = useMemo(() => {
        const now = new Date();
        return {
            total: logs.length,
            borrowed: logs.filter(l => l.status === 'borrowed').length,
            returned: logs.filter(l => l.status === 'returned').length,
            overdue: logs.filter(l => 
                l.status === 'borrowed' && 
                l.expected_return_date && 
                new Date(l.expected_return_date) < now
            ).length,
            pending: logs.filter(l => l.status === 'pending').length,
            staged: logs.filter(l => l.status === 'staged').length,
            reserved: logs.filter(l => l.status === 'reserved').length,
        };
    }, [logs])

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
        triageLog, // 🎯 Return the targeted record as a separate entity
        triageId,
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
        sortOrder,
        setSortOrder,
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
