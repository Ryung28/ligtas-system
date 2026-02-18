'use client'

import React, { useState, useEffect, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'

export type UserStatus = 'pending' | 'active' | 'suspended'

export interface UserProfile {
    id: string
    email: string
    full_name?: string
    role: 'admin' | 'editor' | 'viewer'
    status: UserStatus
    department?: string
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

export function useUserManagement() {
    const [users, setUsers] = useState<UserProfile[]>([])
    const [pendingRequests, setPendingRequests] = useState<AccessRequest[]>([])
    const [authorizedEmails, setAuthorizedEmails] = useState<any[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [isValidating, setIsValidating] = useState(false)

    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    const fetchData = async () => {
        try {
            setIsValidating(true)

            // Fetch all user profiles (active and pending)
            const { data: profiles, error: profileError } = await supabase
                .from('user_profiles')
                .select('*')
                .order('created_at', { ascending: false })

            // Fetch pending access requests
            const { data: requests, error: requestError } = await supabase
                .from('access_requests')
                .select('*')
                .eq('status', 'pending')
                .order('requested_at', { ascending: false })

            // Fetch whitelist (for backward compatibility - can be deprecated later)
            const { data: whitelist, error: whitelistError } = await supabase
                .from('authorized_emails')
                .select('*')

            if (profileError) {
                console.error('Error fetching profiles:', profileError)
                toast.error('Failed to load personnel data')
            } else {
                setUsers(profiles || [])
                setPendingRequests(requests || [])
                setAuthorizedEmails(whitelist || [])
            }
        } catch (err) {
            console.error(err)
        } finally {
            setIsLoading(false)
            setIsValidating(false)
        }
    }

    const approveUser = async (userId: string, role: 'admin' | 'editor' | 'viewer' = 'viewer') => {
        try {
            const { error } = await supabase.rpc('approve_user', {
                target_user_id: userId,
                target_role: role
            })

            if (error) {
                toast.error('Failed to approve user: ' + error.message)
                return false
            }

            toast.success(`User approved as ${role}`)
            await fetchData()
            return true
        } catch (err) {
            console.error(err)
            toast.error('Failed to approve user')
            return false
        }
    }

    const rejectUser = async (userId: string) => {
        try {
            const { error } = await supabase.rpc('reject_user', {
                target_user_id: userId
            })

            if (error) {
                toast.error('Failed to reject user: ' + error.message)
                return false
            }

            toast.success('User access denied')
            await fetchData()
            return true
        } catch (err) {
            console.error(err)
            toast.error('Failed to reject user')
            return false
        }
    }

    const suspendUser = async (userId: string) => {
        try {
            const { error } = await supabase
                .from('user_profiles')
                .update({ status: 'suspended' })
                .eq('id', userId)

            if (error) {
                toast.error('Failed to suspend user: ' + error.message)
                return false
            }

            toast.success('User suspended')
            await fetchData()
            return true
        } catch (err) {
            console.error(err)
            toast.error('Failed to suspend user')
            return false
        }
    }

    const reactivateUser = async (userId: string) => {
        try {
            const { error } = await supabase
                .from('user_profiles')
                .update({ status: 'active' })
                .eq('id', userId)

            if (error) {
                toast.error('Failed to reactivate user: ' + error.message)
                return false
            }

            toast.success('User reactivated')
            await fetchData()
            return true
        } catch (err) {
            console.error(err)
            toast.error('Failed to reactivate user')
            return false
        }
    }

    // Legacy function for backward compatibility
    const authorizeUser = async (email: string, role: string) => {
        const { error } = await supabase
            .from('authorized_emails')
            .insert([{ email: email.toLowerCase().trim(), role }])

        if (error) {
            toast.error('Failed to authorize email: ' + error.message)
            return false
        }

        toast.success(`${email} is now authorized`)
        await fetchData()
        return true
    }

    // Legacy function for backward compatibility
    const unauthorizeUser = async (email: string) => {
        const { error } = await supabase
            .from('authorized_emails')
            .delete()
            .eq('email', email)

        if (error) {
            toast.error('Failed to revoke access')
            return false
        }

        toast.success(`Access revoked for ${email}`)
        await fetchData()
        return true
    }

    useEffect(() => {
        fetchData()

        // Set up real-time subscription for user_profiles
        const profilesChannel = supabase
            .channel('user-profiles-sync')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'user_profiles'
                },
                () => fetchData()
            )
            .subscribe()

        // Set up real-time subscription for access_requests
        const requestsChannel = supabase
            .channel('access-requests-sync')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'access_requests'
                },
                () => fetchData()
            )
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
            viewersCount: activeUsers.filter(u => u.role === 'viewer').length,
            whitelistedCount: authorizedEmails.length
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
        // New approval workflow functions
        approveUser,
        rejectUser,
        suspendUser,
        reactivateUser,
        // Legacy whitelist functions  
        authorizeUser,
        unauthorizeUser
    }
}
