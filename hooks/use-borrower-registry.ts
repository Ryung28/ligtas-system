'use client'

import { useState, useEffect } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import useSWR from 'swr'

export interface BorrowerStats {
    borrower_user_id: string
    borrower_name: string
    borrower_email: string | null
    total_borrows: number
    total_items_handled: number
    total_consumables_issued: number
    active_borrows: number
    returned_count: number
    overdue_count: number
    active_items: number
    return_rate_percent: number
    is_verified_user: boolean
    user_role: string | null
    user_status: string | null
    last_contact: string | null
    last_organization: string | null
}

const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export async function fetchBorrowerData(key: string) {
    const [, search, page, limit] = key.split('|')
    const p = parseInt(page)
    const l = parseInt(limit)
    const from = (p - 1) * l
    const to = from + l - 1

    let query = supabase
        .from('borrower_stats')
        .select('*', { count: 'exact' })

    if (search && search.trim() !== '') {
        query = query.ilike('borrower_name', `%${search.trim()}%`)
    }

    const { data, error, count } = await query
        .order('total_borrows', { ascending: false })
        .range(from, to)

    if (error) throw error
    return { data: data as BorrowerStats[], count: count || 0 }
}

export async function fetchGlobalStats() {
    const { data, error } = await supabase
        .from('borrower_stats')
        .select('*')

    if (error) throw error
    const borrowers = data as BorrowerStats[]
    
    return {
        totalBorrowers: borrowers.length,
        activeBorrowersCount: borrowers.filter(b => b.active_borrows > 0).length,
        totalInField: borrowers.reduce((acc, b) => acc + b.active_items, 0),
        staffCount: borrowers.filter(b => b.is_verified_user && b.user_role !== 'viewer').length,
        guestCount: borrowers.filter(b => !b.is_verified_user || b.user_role === 'viewer').length,
        verifiedCount: borrowers.filter(b => b.is_verified_user).length,
    }
}

export function useBorrowerRegistry(params: { search: string; page: number; limit: number }) {
    const [lastSync, setLastSync] = useState<Date>(new Date())
    
    const { data, error, isLoading, isValidating, mutate } = useSWR(
        `borrower-stats|${params.search}|${params.page}|${params.limit}`,
        fetchBorrowerData,
        {
            revalidateOnFocus: false,
            revalidateOnReconnect: true,
            keepPreviousData: true
        }
    )

    const { data: stats, mutate: mutateStats } = useSWR(
        'borrower-global-stats',
        fetchGlobalStats,
        {
            revalidateOnFocus: false,
        }
    )

    // Real-time subscription
    useEffect(() => {
        const channel = supabase
            .channel('borrower-registry-realtime')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'borrow_logs'
                },
                () => {
                    mutate()
                    mutateStats()
                }
            )
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [mutate, mutateStats])

    useEffect(() => {
        if (!isValidating && !isLoading) {
            setLastSync(new Date())
        }
    }, [isValidating, isLoading])

    return {
        borrowers: data?.data || [],
        totalCount: data?.count || 0,
        stats: stats || {
            totalBorrowers: 0,
            activeBorrowersCount: 0,
            totalInField: 0,
            staffCount: 0,
            guestCount: 0,
            verifiedCount: 0,
        },
        isLoading,
        isValidating,
        lastSync,
        refresh: () => {
            mutate()
            mutateStats()
        },
        error
    }
}

export async function getBorrowerHistory(borrowerUserId: string | null, borrowerName: string) {
    let query = supabase
        .from('borrow_logs')
        .select(`
            *,
            inventory:inventory_id (
                item_name,
                category,
                image_url
            )
        `)

    if (borrowerUserId && borrowerUserId !== 'null') {
        query = query.or(`borrower_user_id.eq.${borrowerUserId},borrower_name.ilike."${borrowerName}"`)
    } else {
        query = query.ilike('borrower_name', borrowerName)
    }

    const { data, error } = await query
        .order('created_at', { ascending: false })
        .limit(50)

    if (error) throw error
    return data || []
}

export async function getBorrowerPending(borrowerName: string) {
    const { data, error } = await supabase
        .from('logistics_actions')
        .select('*')
        .eq('requester_name', borrowerName)
        .eq('status', 'pending')
        .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
}
