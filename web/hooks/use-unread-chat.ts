'use client'

import { useState, useEffect, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'

export function useUnreadChat() {
    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])
    const [unreadCount, setUnreadCount] = useState(0)

    useEffect(() => {
        let mounted = true

        const checkUnread = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user) return

            // Query total exact count of unread messages where sender is NOT the current user
            const { count, error } = await supabase
                .from('chat_messages')
                .select('*', { count: 'exact', head: true })
                .eq('is_read', false)
                .neq('sender_id', user.id)

            if (!error && count !== null && mounted) {
                setUnreadCount(count)
            }
        }

        checkUnread()

        // ── Realtime Global Radar for Unread Messages ──
        const channel = supabase
            .channel('global_unread_messages')
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages',
                filter: 'is_read=eq.false'
            }, async (payload) => {
                const { data: { user } } = await supabase.auth.getUser()
                if (user && payload.new.sender_id !== user.id) {
                    setUnreadCount(prev => prev + 1)
                }
            })
            // We also listen to updates (for when a message is read, we MUST recalculate total count securely from server)
            .on('postgres_changes', {
                event: 'UPDATE',
                schema: 'public',
                table: 'chat_messages',
                filter: 'is_read=eq.true'
            }, () => {
                // If a message was marked read, resync the count with the database to ensure perfection
                checkUnread()
            })
            .subscribe()

        return () => {
            mounted = false
            supabase.removeChannel(channel)
        }
    }, [supabase])

    return { unreadCount }
}
