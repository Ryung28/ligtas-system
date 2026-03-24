'use client'

import { useState, useEffect, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import { getChatRooms } from '@/app/actions/chat'

export interface ChatRoom {
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
    unread_count: number
}

// Exported fetch function for cache warming
export const fetchChatRooms = async () => {
    const result = await getChatRooms()
    return result.success && result.data ? result.data : []
}

export function useChatRooms() {
    const [rooms, setRooms] = useState<ChatRoom[]>([])
    const [isLoading, setIsLoading] = useState(true)

    // The Gold Standard Fetcher: 
    // Resolves instantly because all aggregation happens inside Supabase Postgres Engine
    const fetchRooms = useCallback(async () => {
        setIsLoading(true)
        const data = await fetchChatRooms()
        setRooms(data as ChatRoom[])
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
                            },
                            unread_count: room.unread_count + 1
                        }
                    }
                    return room
                }).sort((a, b) => {
                    const timeA = a.lastMessage ? new Date(a.lastMessage.created_at).getTime() : 0
                    const timeB = b.lastMessage ? new Date(b.lastMessage.created_at).getTime() : 0
                    return timeB - timeA
                }))
            })
            // Reset unread count locally if we mark something as read
            .on('postgres_changes', {
                event: 'UPDATE',
                schema: 'public',
                table: 'chat_messages',
                filter: 'is_read=eq.true'
            }, (payload) => {
                setRooms(prev => prev.map(room => {
                    if (room.id === payload.new.room_id) {
                        return { ...room, unread_count: 0 }
                    }
                    return room
                }))
            })
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [fetchRooms])

    return { rooms, isLoading, refresh: fetchRooms }
}
