'use client'

import React, { useEffect, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import useSWR from 'swr'
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

// 🛡️ Browser client: READ-ONLY usage (SELECT)
const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Exported fetch functions for cache warming
export const USER_PROFILES_KEY = 'user_profiles'
export const AUTHORIZED_EMAILS_KEY = 'authorized_emails'
export const PENDING_USER_REQUESTS_KEY = 'pending_user_requests'

export const fetchUsers = async () => {
    const { data, error } = await supabase.from('user_profiles').select('*').order('created_at', { ascending: false })
    if (error) throw error
    return (data as UserProfile[]) || []
}

export const fetchAuthorizedEmails = async () => {
    const { data, error } = await supabase.from('authorized_emails').select('*')
    if (error) throw error
    return data || []
}

export const fetchPendingUserRequests = async () => {
    const { data, error } = await supabase
        .from('access_requests')
        .select('*')
        .eq('status', 'pending')
        .order('requested_at', { ascending: false })
    if (error) throw error
    return (data as AccessRequest[]) || []
}

export function useUserManagement() {
    // 🛰️ SWR TRACKS
    const { data: users = [], mutate: mutateUsers, isLoading: usersLoading, isValidating: usersValidating } = useSWR(USER_PROFILES_KEY, fetchUsers, { revalidateOnFocus: false })
    const { data: authorizedEmails = [], mutate: mutateWhitelist, isLoading: whitelistLoading } = useSWR(AUTHORIZED_EMAILS_KEY, fetchAuthorizedEmails, { revalidateOnFocus: false })
    const { data: pendingRequests = [], mutate: mutateRequests, isLoading: requestsLoading } = useSWR(PENDING_USER_REQUESTS_KEY, fetchPendingUserRequests, { revalidateOnFocus: false })

    const isLoading = usersLoading || whitelistLoading || requestsLoading
    const isValidating = usersValidating

    const refresh = async () => {
        await Promise.all([mutateUsers(), mutateWhitelist(), mutateRequests()])
    }

    // ── MUTATION FUNCTIONS — delegation to Server Actions ──────────────────

    const approveUser = async (userId: string, role: 'admin' | 'editor' | 'viewer' | 'responder' = 'responder') => {
        const result = await approveUserAction(userId, role)
        if (result.success) {
            toast.success(result.message)
            await refresh()
            return true
        }
        toast.error('Failed to approve user: ' + result.message)
        return false
    }

    const rejectUser = async (userId: string) => {
        const result = await rejectUserAction(userId)
        if (result.success) {
            toast.success(result.message)
            await refresh()
            return true
        }
        toast.error('Failed to reject user: ' + result.message)
        return false
    }

    const suspendUser = async (userId: string) => {
        if (userId.startsWith('pending-')) {
            const email = userId.replace('pending-', '')
            return unauthorizeUser(email)
        }

        const result = await suspendUserAction(userId)
        if (result.success) {
            toast.success(result.message)
            await refresh()
            return true
        }
        toast.error(result.message)
        return false
    }

    const reactivateUser = async (userId: string) => {
        const result = await reactivateUserAction(userId)
        if (result.success) {
            toast.success(result.message)
            await refresh()
            return true
        }
        toast.error('Failed to reactivate user: ' + result.message)
        return false
    }

    const updateUserRole = async (userId: string, newRole: 'admin' | 'editor') => {
        const result = await updateUserRoleAction(userId, newRole)
        if (result.success) {
            toast.success(result.message || `User role updated successfully`)
            await refresh()
            return true
        }
        toast.error(result.error || `Failed to update user role`)
        return false
    }

    const authorizeUser = async (email: string, role: string) => {
        const result = await authorizeUserAction(email, role)
        if (result.success) {
            toast.success(result.message)
            await refresh()
            return true
        }
        toast.error('Failed to authorize email: ' + result.message)
        return false
    }

    const unauthorizeUser = async (email: string) => {
        const result = await unauthorizeUserAction(email)
        if (result.success) {
            toast.success(result.message)
            await refresh()
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
            await refresh()
            return true
        } catch (err: any) {
            toast.error('Failed to assign warehouse: ' + err.message)
            return false
        }
    }

    // ── REALTIME SUBSCRIPTIONS ─────────────────────────────────────

    useEffect(() => {
        const profilesChannel = supabase
            .channel('user-profiles-sync')
            .on('postgres_changes', { event: '*', schema: 'public', table: 'user_profiles' }, () => mutateUsers())
            .on('postgres_changes', { event: '*', schema: 'public', table: 'access_requests' }, () => mutateRequests())
            .subscribe()

        return () => {
            supabase.removeChannel(profilesChannel)
        }
    }, [mutateUsers, mutateRequests])

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
        refresh,
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
