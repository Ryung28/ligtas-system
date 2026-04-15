'use client'

import { useEffect, useMemo } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import { supabase } from '@/lib/supabase'
import { getChatRoomsV3 } from '@/app/actions/chat-v3'

export interface ChatRoomV3 {
    id: string
    borrower_user_id: string
    borrow_request_id: number | null
    borrower: {
        id: string
        full_name: string | null
        role: string
        last_seen: string | null
    } | null
    lastMessage: {
        id: string
        content: string
        created_at: string
        sender_id: string
    } | null
    unread_count: number
}

const CHAT_ROOMS_KEY = 'chat_rooms_v3'

/**
 * LIGTAS Platinum Inbox Hook (V3)
 * Powered by SWR for instant navigation and background revalidation.
 */
export function useChatRoomsV3() {
    const { mutate } = useSWRConfig()
    
    // ── Platinum SWR Implementation ──
    const { data, error, isLoading, mutate: revalidate } = useSWR(CHAT_ROOMS_KEY, async () => {
        const result = await getChatRoomsV3()
        if (!result.success) throw new Error(result.error)
        return result.data as ChatRoomV3[]
    }, {
        revalidateOnFocus: true,
        revalidateOnReconnect: true,
        dedupingInterval: 2000
    })

    const rooms = useMemo(() => data || [], [data])

    useEffect(() => {
        const channel = supabase
            .channel('global_chat_v3_sync')
            .on('postgres_changes', {
                event: '*',
                schema: 'public',
                table: 'chat_messages'
            }, (payload) => {
                // Instantly revalidate the cache on any new message or update
                mutate(CHAT_ROOMS_KEY)
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [mutate])

    return { 
        rooms, 
        isLoading: isLoading && !data, // Only "loading" if we have zero stale data
        refresh: revalidate 
    }
}
