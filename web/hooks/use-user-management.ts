'use client'

import React, { useState, useEffect, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'

export function useUserManagement() {
    const [users, setUsers] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [isValidating, setIsValidating] = useState(false)

    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    const fetchUsers = async () => {
        try {
            setIsValidating(true)
            const { data, error } = await supabase
                .from('user_profiles')
                .select('*')
                .order('role', { ascending: true })

            if (error) {
                console.error('Error fetching users:', error)
                toast.error('Failed to load user profiles')
            } else {
                setUsers(data || [])
            }
        } catch (err) {
            console.error(err)
        } finally {
            setIsLoading(false)
            setIsValidating(false)
        }
    }

    useEffect(() => {
        fetchUsers()
    }, [])

    const stats = useMemo(() => {
        return {
            totalStaff: users.length,
            adminsCount: users.filter(u => u.role === 'admin').length,
            editorsCount: users.filter(u => u.role === 'editor').length
        }
    }, [users])

    return {
        users,
        stats,
        isLoading,
        isValidating,
        refresh: fetchUsers
    }
}
