'use client'

import React, { useState, useEffect, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'

export function useBorrowerRegistry() {
    const { staffTracking, refresh, isLoading, isValidating } = useBorrowLogs()
    const [registeredStaff, setRegisteredStaff] = useState<Set<string>>(new Set())
    const [lastSync, setLastSync] = useState<Date>(new Date())
    const [syncProgress, setSyncProgress] = useState(0)

    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    // Real-time subscription for user_profiles to keep staff list updated
    useEffect(() => {
        const channel = supabase
            .channel('borrower-registry-profiles')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'user_profiles'
                },
                () => {
                    // Re-fetch staff when profiles change
                    fetchStaff()
                    refresh() // Also refresh logs as they might be related
                }
            )
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [refresh])

    // Update last sync time when validation completes
    useEffect(() => {
        if (!isValidating && !isLoading) {
            setLastSync(new Date())
        }
    }, [isValidating, isLoading])

    // Fetch registered staff to cross-reference
    async function fetchStaff() {
        const { data } = await supabase.from('user_profiles').select('full_name, email')
        if (data) {
            const names = new Set(data.map(u => u.full_name?.toLowerCase() || u.email.split('@')[0].toLowerCase()))
            setRegisteredStaff(names)
        }
    }

    useEffect(() => {
        fetchStaff()
    }, [])

    // Convert staffTracking Object to Array - Memoized for stability
    const allBorrowers = useMemo(() => {
        return Object.entries(staffTracking).map(([name, data]) => {
            const isStaff = registeredStaff.has(name.toLowerCase())
            const typedData = data as { count: number, items: any[] }
            return {
                name,
                isStaff,
                ...typedData
            }
        })
    }, [staffTracking, registeredStaff])

    const stats = useMemo(() => {
        const totalInField = allBorrowers.reduce((acc, b) => acc + b.count, 0)
        const activeBorrowersCount = allBorrowers.filter(b => b.count > 0).length
        const staffCount = allBorrowers.filter(b => b.isStaff).length
        const guestCount = allBorrowers.filter(b => !b.isStaff).length

        return {
            totalInField,
            activeBorrowersCount,
            staffCount,
            guestCount
        }
    }, [allBorrowers])

    return {
        allBorrowers,
        stats,
        isLoading,
        isValidating,
        lastSync,
        refresh
    }
}
