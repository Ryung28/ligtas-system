'use client'

import { useState, useEffect, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import { getChatRoomsV2 } from '@/app/actions/chat-v2'

export interface ChatRoomV2 {
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
        content: string
        created_at: string
        sender_id: string
    } | null
}

export function useChatRoomsV2() {
    const [rooms, setRooms] = useState<ChatRoomV2[]>([])
    const [isLoading, setIsLoading] = useState(true)

    // The Gold Standard Fetcher: 
    // Resolves instantly because all aggregation happens inside Supabase Postgres Engine
    const fetchRooms = useCallback(async () => {
        setIsLoading(true)
        const result = await getChatRoomsV2()
        if (result.success && result.data) {
            setRooms(result.data as ChatRoomV2[])
        }
        setIsLoading(false)
    }, [])

    useEffect(() => {
        fetchRooms()

        // ── Tactical Room Observer ──
        // Listen for ANY new messages across ALL rooms to update the last message preview
        const channel = supabase
            .channel('global_chat_updates_v2')
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages'
            }, (payload) => {
                const newMessage = payload.new
                setRooms(prev => prev.map(room => {
                    if (room.id === newMessage.room_id) {
                        return {
                            ...room,
                            lastMessage: {
                                content: newMessage.content,
                                created_at: newMessage.created_at,
                                sender_id: newMessage.sender_id
                            }
                        }
                    }
                    return room
                }).sort((a, b) => {
                    const timeA = a.lastMessage ? new Date(a.lastMessage.created_at).getTime() : 0
                    const timeB = b.lastMessage ? new Date(b.lastMessage.created_at).getTime() : 0
                    return timeB - timeA
                }))
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [fetchRooms])

    return { rooms, isLoading, refresh: fetchRooms }
}
