'use client'

import { useEffect, useState, useCallback, useMemo } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import { createBrowserClient } from '@supabase/ssr'
import { ChatMessage } from '@/lib/types/chat'
import { sendChatMessageV3, markAsReadV3, getRoomMessagesV3 } from '@/app/actions/chat-v3'
import { toast } from 'sonner'
import { CHAT_ROOMS_KEY } from '@/hooks/use-chat-rooms-v3'

/**
 * ResQTrack CHAT-V3 Kinetic Hook
 * Full Isolation from V1/V2. Powered by SWR for unblocked navigation.
 */
export function useChatV3(roomId: string | null) {
    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])
    
    const [currentUserId, setCurrentUserId] = useState<string | null>(null)
    const [presence, setPresence] = useState<Record<string, any>>({})
    const { mutate: mutateGlobal } = useSWRConfig()

    const markRoomReadAndSync = useCallback(async (targetRoomId: string) => {
        const result = await markAsReadV3(targetRoomId)
        if (!result.success) return

        // Optimistic unread sync for sidebar badge responsiveness.
        mutateGlobal(
            CHAT_ROOMS_KEY,
            (prev: unknown) => {
                if (!Array.isArray(prev)) return prev
                return prev.map((room) => {
                    if (!room || typeof room !== 'object') return room
                    const typedRoom = room as { id?: string; unread_count?: number }
                    if (typedRoom.id !== targetRoomId) return room
                    return { ...typedRoom, unread_count: 0 }
                })
            },
            false,
        )

        // Then reconcile with server truth.
        mutateGlobal(CHAT_ROOMS_KEY)
    }, [mutateGlobal])

    // Identity pre-warm
    useEffect(() => {
        const getIdentity = async () => {
            const { data: { session } } = await supabase.auth.getSession()
            if (session?.user) setCurrentUserId(session.user.id)
        }
        getIdentity()
    }, [supabase])

    // ── Platinum SWR Implementation ──
    const { 
        data: history, 
        mutate, 
        isLoading: isLoadingHistory 
    } = useSWR(roomId ? `chat_history_v3_${roomId}` : null, async () => {
        if (!roomId) return []
        const result = await getRoomMessagesV3(roomId)
        if (!result.success) throw new Error(result.error)
        await markRoomReadAndSync(roomId)
        return result.data as ChatMessage[]
    }, {
        revalidateOnFocus: false, // Focus revalidation handled by realtime
        dedupingInterval: 1000,
        keepPreviousData: false // We want fresh data per room
    })

    const messages = useMemo(() => history || [], [history])

    const sendOptimisticMessage = async (content: string) => {
        if (!roomId || !currentUserId) return

        const fakeId = crypto.randomUUID()
        const optimisticMsg: Partial<ChatMessage> = {
            id: fakeId,
            room_id: roomId,
            sender_id: currentUserId,
            content,
            status: 'sending',
            created_at: new Date().toISOString()
        }

        // Kinetic Update: Update the local cache instantly
        mutate([optimisticMsg as ChatMessage, ...messages], false)

        const result = await sendChatMessageV3(roomId, content)
        if (!result.success) {
            toast.error('Transmission Blocked', { description: result.error })
            mutate(messages, false) // Revert on failure
        }
    }

    useEffect(() => {
        if (!roomId) return

        // ── Realtime Signal Stream ──
        const msgChannel = supabase.channel(`v3_msg_${roomId.replace(/-/g, '_')}`)
        msgChannel
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages',
                filter: `room_id=eq.${roomId}`
            }, (payload) => {
                const newMessage = payload.new as ChatMessage
                // Trigger SWR mutation to integrate the new message
                mutate()
                if (newMessage.sender_id !== currentUserId) {
                    void markRoomReadAndSync(roomId)
                }
            })
            .subscribe()

        const presenceChannel = supabase.channel(`v3_pres:${roomId}`)
        presenceChannel
            .on('presence', { event: 'sync' }, () => setPresence(presenceChannel.presenceState()))
            .subscribe(async (status) => {
                if (status === 'SUBSCRIBED' && currentUserId) {
                    await presenceChannel.track({ user_id: currentUserId, online_at: new Date().toISOString() })
                }
            })

        return () => {
            supabase.removeChannel(msgChannel)
            supabase.removeChannel(presenceChannel)
        }
    }, [roomId, supabase, currentUserId, mutate, markRoomReadAndSync])

    return { 
        messages, 
        isLoadingHistory: isLoadingHistory && !history, 
        presence, 
        currentUserId, 
        sendOptimisticMessage,
        refresh: () => mutate() 
    }
}
