'use client'

import { useState, useEffect } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import useSWR from 'swr'

interface BorrowerStats {
    borrower_user_id: string
    borrower_name: string
    borrower_email: string | null
    total_borrows: number
    active_borrows: number
    returned_count: number
    overdue_count: number
    active_items: number
    return_rate_percent: number
    is_verified_user: boolean
    user_role: string | null
    user_status: string | null
}

const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

async function fetchBorrowers() {
    const { data, error } = await supabase
        .from('borrower_stats')
        .select('*')
        .order('total_borrows', { ascending: false })

    if (error) throw error
    return data as BorrowerStats[]
}

export function useBorrowerRegistry() {
    const [lastSync, setLastSync] = useState<Date>(new Date())
    
    const { data: borrowers = [], error, isLoading, isValidating, mutate } = useSWR(
        'borrower-stats',
        fetchBorrowers,
        {
            revalidateOnFocus: false,
            revalidateOnReconnect: true,
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
                () => mutate()
            )
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'user_profiles'
                },
                () => mutate()
            )
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [mutate])

    // Update last sync time
    useEffect(() => {
        if (!isValidating && !isLoading) {
            setLastSync(new Date())
        }
    }, [isValidating, isLoading])

    const stats = {
        totalBorrowers: borrowers.length,
        activeBorrowersCount: borrowers.filter(b => b.active_borrows > 0).length,
        totalInField: borrowers.reduce((acc, b) => acc + b.active_items, 0),
        staffCount: borrowers.filter(b => b.is_verified_user && b.user_role !== 'viewer').length,
        guestCount: borrowers.filter(b => !b.is_verified_user || b.user_role === 'viewer').length,
        verifiedCount: borrowers.filter(b => b.is_verified_user).length,
    }

    return {
        borrowers,
        stats,
        isLoading,
        isValidating,
        lastSync,
        refresh: mutate,
        error
    }
}

export async function getBorrowerHistory(borrowerUserId: string) {
    const { data, error } = await supabase
        .from('borrow_logs')
        .select(`
            *,
            inventory:inventory_id (
                item_name,
                category,
                image_url
            )
        `)
        .eq('borrower_user_id', borrowerUserId)
        .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
}
