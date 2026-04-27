'use client'

import { useState, useEffect, useCallback, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'

export function useUnreadChat() {
    const [unreadCount, setUnreadCount] = useState(0)
    const supabase = useMemo(
        () =>
            createBrowserClient(
                process.env.NEXT_PUBLIC_SUPABASE_URL!,
                process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            ),
        [],
    )

    const checkUnread = useCallback(async () => {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) return

        // Fetch user profile to determine role-based visibility
        const { data: profile } = await supabase
            .from('user_profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (!profile) return

        // Senior Dev: Scoped count to match Messenger RPC logic
        // We join with rooms to ensure we only count messages in accessible conversations
        let query = supabase
            .from('chat_messages')
            .select('id, room:room_id!inner(borrower_user_id)', { count: 'exact', head: true })
            .eq('is_read', false)
            .neq('sender_id', user.id)

        const isAdmin = ['admin', 'manager', 'editor'].includes(profile.role)

        if (!isAdmin) {
            // Regular users only see messages in their own rooms
            query = query.eq('room.borrower_user_id', user.id)
        }

        const { count } = await query
        setUnreadCount(count || 0)
    }, [supabase])

    useEffect(() => {
        checkUnread()

        // Centralized subscription: Listen for all state changes that affect count
        const channel = supabase
            .channel('global-unread-sync')
            .on('postgres_changes', {
                event: '*', // Listen for INSERT, UPDATE, and DELETE
                schema: 'public',
                table: 'chat_messages'
            }, () => {
                checkUnread()
            })
            .subscribe()

        const handleLogbookMutation = () => {
            setUnreadCount(0) // Immediate UX clear while recheck runs.
            checkUnread()
        }
        window.addEventListener('resqtrack:logbook-mutated', handleLogbookMutation)

        return () => {
            window.removeEventListener('resqtrack:logbook-mutated', handleLogbookMutation)
            supabase.removeChannel(channel)
        }
    }, [checkUnread, supabase])

    return { unreadCount, refresh: checkUnread }
}
