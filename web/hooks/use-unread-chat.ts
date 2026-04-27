'use client'

import { useState, useEffect, useCallback } from 'react'
import { createBrowserClient } from '@supabase/ssr'

export function useUnreadChat() {
    const [unreadCount, setUnreadCount] = useState(0)
    
    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
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

        if (profile.role === 'viewer') {
            // Viewers only see messages in their own room
            query = query.eq('room.borrower_user_id', user.id)
        } else {
            // Admins/Editors see messages in all rooms involving viewers, 
            // OR rooms where they are the borrower.
            const { data: viewerProfiles } = await supabase
                .from('user_profiles')
                .select('id')
                .eq('role', 'viewer')
            
            const viewerIds = (viewerProfiles || []).map(p => p.id)
            
            const { data: rooms } = await supabase
                .from('chat_rooms')
                .select('id')
                .or(`borrower_user_id.eq.${user.id}${viewerIds.length > 0 ? `,borrower_user_id.in.(${viewerIds.join(',')})` : ''}`)
            
            if (rooms && rooms.length > 0) {
                query = query.in('room_id', rooms.map(r => r.id))
            } else {
                setUnreadCount(0)
                return
            }
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

        return () => {
            supabase.removeChannel(channel)
        }
    }, [checkUnread, supabase])

    return { unreadCount, refresh: checkUnread }
}
