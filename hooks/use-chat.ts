'use client'

import { useEffect, useState, useCallback, useMemo } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { ChatMessage } from '@/lib/types/chat'
import { getRoomMessages, sendMessage } from '@/app/actions/chat'
import { toast } from 'sonner'

export function useChat(roomId: string | null) {
    const supabase = useMemo(() => createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    ), [])
    const [messages, setMessages] = useState<ChatMessage[]>([])
    const [isLoadingHistory, setIsLoadingHistory] = useState(false)
    const [presence, setPresence] = useState<Record<string, any>>({})
    const [currentUserId, setCurrentUserId] = useState<string | null>(null)

    // Identity pre-warm
    useEffect(() => {
        const getIdentity = async () => {
            const { data: { session } } = await supabase.auth.getSession()
            if (session?.user) setCurrentUserId(session.user.id)
        }
        getIdentity()
    }, [supabase])

    const fetchMessages = useCallback(async () => {
        if (!roomId) return
        setIsLoadingHistory(true)

        try {
            const result = await getRoomMessages(roomId)
            if (result.success && result.data) {
                setMessages(result.data as ChatMessage[])
            }
        } catch (error) {
            console.error('[Chat-Hook] Fetch Failure:', error)
        } finally {
            setIsLoadingHistory(false)
        }
    }, [roomId])

    const sendOptimisticMessage = async (content: string) => {
        if (!roomId || !currentUserId) return

        // 1. Optimistic Injection (UI updates instantly)
        const fakeId = crypto.randomUUID()
        const optimisticMsg: Partial<ChatMessage> = {
            id: fakeId,
            room_id: roomId,
            sender_id: currentUserId,
            content,
            status: 'sending',
            created_at: new Date().toISOString()
        }

        setMessages(prev => [optimisticMsg as ChatMessage, ...prev])

        // 2. Server Sync
        const result = await sendMessage(roomId, content)
        if (!result.success) {
            toast.error('Failed to deliver message')
            // Revert on failure
            setMessages(prev => prev.filter(m => m.id !== fakeId))
        }
        // If success, we let the realtime listener replace the fake ID with the real database ID
        // or we just trust the insert. The postgres_changes will stream the real insert down.
    }

    useEffect(() => {
        if (!roomId) return

        fetchMessages()

        // ── Realtime Messages Listener ──
        const msgChannelName = `coord_${roomId.replace(/-/g, '_')}`
        const msgChannel = supabase.channel(msgChannelName)

        msgChannel
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages',
                filter: `room_id=eq.${roomId}`
            }, (payload) => {
                const newMessage = payload.new as ChatMessage
                setMessages(prev => {
                    // Remove optimistic "sending" matches by content and sender within 5 seconds
                    const filtered = prev.filter(m => !(m.status === 'sending' && m.content === newMessage.content))
                    if (filtered.find(m => m.id === newMessage.id)) return filtered
                    return [newMessage, ...filtered]
                })
            })
            .subscribe()

        // ── Realtime Presence ──
        const presenceChannel = supabase.channel(`presence:${roomId}`)

        presenceChannel
            .on('presence', { event: 'sync' }, () => {
                const state = presenceChannel.presenceState()
                setPresence(state)
            })
            .subscribe(async (status) => {
                if (status === 'SUBSCRIBED' && currentUserId) {
                    await presenceChannel.track({ 
                        user_id: currentUserId,
                        online_at: new Date().toISOString(),
                        platform: 'web_admin'
                    })
                }
            })

        return () => {
            supabase.removeChannel(msgChannel)
            supabase.removeChannel(presenceChannel)
        }
    }, [roomId, fetchMessages, supabase, currentUserId])

    return { 
        messages, 
        isLoadingHistory, 
        presence, 
        currentUserId, 
        sendOptimisticMessage,
        refresh: fetchMessages 
    }
}
