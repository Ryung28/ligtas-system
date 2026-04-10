'use client'

import React, { useState, useEffect, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import { updateUserRole as updateUserRoleAction } from '@/app/actions/user-management'
import {
    approveUserAction,
    rejectUserAction,
    suspendUserAction,
    reactivateUserAction,
    authorizeUserAction,
    unauthorizeUserAction,
} from '@/app/actions/user-management'

export type UserStatus = 'pending' | 'active' | 'suspended'

export interface UserProfile {
    id: string
    email: string
    full_name?: string
    role: 'admin' | 'editor' | 'viewer' | 'responder'
    status: UserStatus
    department?: string
    assigned_warehouse?: string | null
    created_at: string
    approved_at?: string
    approved_by?: string
    isPending?: boolean
}

export interface AccessRequest {
    id: number
    user_id: string
    email: string
    full_name?: string
    requested_at: string
    approved_at?: string
    approved_by?: string
    status: 'pending' | 'approved' | 'rejected'
}

// Exported fetch functions for cache warming
export const fetchUsers = async () => {
    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
    const { data } = await supabase.from('user_profiles').select('*').order('created_at', { ascending: false })
    return data || []
}

export const fetchAuthorizedEmails = async () => {
    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
    const { data } = await supabase.from('authorized_emails').select('*')
    return data || []
}

export function useUserManagement() {
    const [users, setUsers] = useState<UserProfile[]>([])
    const [pendingRequests, setPendingRequests] = useState<AccessRequest[]>([])
    const [authorizedEmails, setAuthorizedEmails] = useState<Record<string, unknown>[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [isValidating, setIsValidating] = useState(false)

    // 🛡️ Browser client: READ-ONLY usage (SELECT + realtime subscriptions)
    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    const fetchData = async () => {
        try {
            setIsValidating(true)

            const { data: profiles, error: profileError } = await supabase
                .from('user_profiles')
                .select('*')
                .order('created_at', { ascending: false })

            const { data: requests } = await supabase
                .from('access_requests')
                .select('*')
                .eq('status', 'pending')
                .order('requested_at', { ascending: false })

            const { data: whitelist } = await supabase
                .from('authorized_emails')
                .select('*')

            if (profileError) {
                console.error('Error fetching profiles:', profileError)
                toast.error('Failed to load personnel data')
            } else {
                setUsers((profiles as UserProfile[]) || [])
                setPendingRequests((requests as AccessRequest[]) || [])
                setAuthorizedEmails((whitelist as Record<string, unknown>[]) || [])
            }
        } catch (err) {
            console.error(err)
        } finally {
            setIsLoading(false)
            setIsValidating(false)
        }
    }

    // ── MUTATION FUNCTIONS — all delegated to Server Actions ──────────────────

    const approveUser = async (userId: string, role: 'admin' | 'editor' | 'viewer' | 'responder' = 'responder') => {
        const result = await approveUserAction(userId, role)
        if (result.success) {
            toast.success(result.message)
            await fetchData()
            return true
        }
        toast.error('Failed to approve user: ' + result.message)
        return false
    }

    const rejectUser = async (userId: string) => {
        const result = await rejectUserAction(userId)
        if (result.success) {
            toast.success(result.message)
            await fetchData()
            return true
        }
        toast.error('Failed to reject user: ' + result.message)
        return false
    }

    const suspendUser = async (userId: string) => {
        // Pending invites route to unauthorize (synthetic ID)
        if (userId.startsWith('pending-')) {
            const email = userId.replace('pending-', '')
            return unauthorizeUser(email)
        }

        // UUID validation guard
        const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
        if (!uuidRegex.test(userId)) {
            toast.error('Tactical Error: Invalid Account Signature (UUID)')
            return false
        }

        // Optimistic UI update
        setUsers(prev => prev.filter(u => u.id !== userId))

        const result = await suspendUserAction(userId)
        if (result.success) {
            toast.success(result.message)
            await fetchData()
            return true
        }
        // Revert optimistic update on failure
        await fetchData()
        toast.error(result.message)
        return false
    }

    const reactivateUser = async (userId: string) => {
        const result = await reactivateUserAction(userId)
        if (result.success) {
            toast.success(result.message)
            await fetchData()
            return true
        }
        toast.error('Failed to reactivate user: ' + result.message)
        return false
    }

    const updateUserRole = async (userId: string, newRole: 'admin' | 'editor') => {
        const result = await updateUserRoleAction(userId, newRole)
        if (result.success) {
            toast.success(result.message || `User ${newRole}ed successfully`)
            await fetchData()
            return true
        }
        toast.error(result.error || `Failed to ${newRole === 'admin' ? 'promote' : 'demote'} user`)
        return false
    }

    const authorizeUser = async (email: string, role: string) => {
        const result = await authorizeUserAction(email, role)
        if (result.success) {
            toast.success(result.message)
            await fetchData()
            return true
        }
        toast.error('Failed to authorize email: ' + result.message)
        return false
    }

    const unauthorizeUser = async (email: string) => {
        const result = await unauthorizeUserAction(email)
        if (result.success) {
            toast.success(result.message)
            await fetchData()
            return true
        }
        toast.error(result.message)
        return false
    }

    const assignWarehouse = async (userId: string, warehouse: string | null) => {
        try {
            const { error } = await supabase
                .from('user_profiles')
                .update({ assigned_warehouse: warehouse })
                .eq('id', userId)

            if (error) throw error

            toast.success(warehouse ? `Warehouse assigned: ${warehouse}` : 'Warehouse assignment removed')
            await fetchData()
            return true
        } catch (err: any) {
            toast.error('Failed to assign warehouse: ' + err.message)
            return false
        }
    }

    // ── REALTIME SUBSCRIPTIONS & EFFECTS ─────────────────────────────────────

    useEffect(() => {
        fetchData()

        const profilesChannel = supabase
            .channel('user-profiles-sync')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'user_profiles' }, () => fetchData())
            .subscribe()

        const requestsChannel = supabase
            .channel('access-requests-sync')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'access_requests' }, () => fetchData())
            .subscribe()

        return () => {
            supabase.removeChannel(profilesChannel)
            supabase.removeChannel(requestsChannel)
        }
    }, [])

    const stats = useMemo(() => {
        const activeUsers = users.filter(u => u.status === 'active')
        return {
            totalStaff: activeUsers.length,
            pendingCount: users.filter(u => u.status === 'pending').length,
            suspendedCount: users.filter(u => u.status === 'suspended').length,
            adminsCount: activeUsers.filter(u => u.role === 'admin').length,
            editorsCount: activeUsers.filter(u => u.role === 'editor').length,
            viewersCount: activeUsers.filter(u => u.role === 'viewer' || u.role === 'responder').length,
            whitelistedCount: authorizedEmails.length,
        }
    }, [users, authorizedEmails])

    return {
        users,
        pendingRequests,
        authorizedEmails,
        stats,
        isLoading,
        isValidating,
        refresh: fetchData,
        approveUser,
        rejectUser,
        suspendUser,
        reactivateUser,
        updateUserRole,
        authorizeUser,
        unauthorizeUser,
        assignWarehouse,
    }
}
