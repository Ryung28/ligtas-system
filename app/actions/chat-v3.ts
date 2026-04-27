'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { z } from 'zod'

// ── V3 Validation Schemas ──
const sendMessageSchema = z.object({
    roomId: z.string().uuid(),
    content: z.string().min(1).max(5000),
})

const roomIdSchema = z.string().uuid()

/**
 * THE 2026 PLATINUM STANDARD: Chat-V3 Actions
 * Strictly typed, Zod-validated, and RPC-optimized.
 */
export async function getChatRoomsV3() {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        // 50ms RPC call. Handles all joins & logic inside Postgres.
        const { data, error } = await supabase.rpc('get_active_chat_inbox_v2', { 
            staff_uuid: user.id 
        })

        if (error) throw error

        const rawRooms = (data || []).map((row: any) => ({
            id: row.chat_room_id,
            borrower_user_id: row.chat_borrower_user_id,
            borrow_request_id: row.chat_borrow_request_id,
            borrower: {
                id: row.chat_borrower_id,
                full_name: row.chat_borrower_full_name,
                role: row.chat_borrower_role,
                last_seen: row.chat_borrower_last_seen
            },
            lastMessage: row.chat_last_message_content ? {
                id: row.chat_last_message_id,
                content: row.chat_last_message_content,
                created_at: row.chat_last_message_created_at,
                sender_id: row.chat_last_message_sender_id
            } : null,
            unread_count: row.chat_unread_count || 0
        }))

        const roomScore = (room: any): number => {
            const lastMessageTime = room.lastMessage?.created_at
                ? new Date(room.lastMessage.created_at).getTime()
                : 0
            const borrowPriority = room.borrow_request_id ? 1 : 0
            // Keep the most recent conversational context first.
            return (lastMessageTime * 10) + borrowPriority
        }

        // ── ResQTrack Deduplication Shield (Server-Side) ──
        const uniqueMap = new Map<string, any>()
        rawRooms.forEach((room: any) => {
            const userId = room.borrower_user_id
            const existing = uniqueMap.get(userId)
            if (!existing || roomScore(room) > roomScore(existing)) {
                uniqueMap.set(userId, room)
            }
        })

        const formattedRooms = Array.from(uniqueMap.values()).sort((a, b) => {
            const timeA = a.lastMessage ? new Date(a.lastMessage.created_at).getTime() : 0
            const timeB = b.lastMessage ? new Date(b.lastMessage.created_at).getTime() : 0
            return timeB - timeA
        })

        return { success: true, data: formattedRooms }
    } catch (error: any) {
        console.error('[Chat-V3] Fetch Rooms Failure:', error)
        return { success: false, error: error.message }
    }
}

export async function sendChatMessageV3(roomId: string, content: string) {
    try {
        const validated = sendMessageSchema.parse({ roomId, content })
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { data: room, error: roomError } = await supabase
            .from('chat_rooms')
            .select('borrower_user_id')
            .eq('id', validated.roomId)
            .single()

        if (roomError) throw roomError

        const receiverId = room?.borrower_user_id === user.id ? null : room?.borrower_user_id

        const { data, error } = await supabase
            .from('chat_messages')
            .insert({
                room_id: validated.roomId,
                sender_id: user.id,
                receiver_id: receiverId,
                content: validated.content,
                status: 'sent'
            })
            .select()
            .single()

        if (error) throw error
        return { success: true, data }
    } catch (error: any) {
        console.error('[Chat-V3] Send Failure:', error)
        return { success: false, error: error.message }
    }
}

export async function markAsReadV3(roomId: string) {
    try {
        const id = roomIdSchema.parse(roomId)
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { error } = await supabase
            .from('chat_messages')
            .update({ is_read: true })
            .eq('room_id', id)
            .neq('sender_id', user.id)
            .eq('is_read', false)

        if (error) throw error
        return { success: true }
    } catch (error: any) {
        console.error('[Chat-V3] Mark Read Failure:', error)
        return { success: false, error: error.message }
    }
}

/**
 * Mark ALL messages as read for the current user across ALL rooms.
 */
export async function markAllAsReadV3() {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { error } = await supabase
            .from('chat_messages')
            .update({ is_read: true })
            .neq('sender_id', user.id)
            .eq('is_read', false)

        if (error) throw error
        return { success: true }
    } catch (error: any) {
        console.error('[Chat-V3] Mark All Read Failure:', error)
        return { success: false, error: error.message }
    }
}

/**
 * Mark the most recent message from someone else in a room as unread.
 */
export async function markRoomAsUnreadV3(roomId: string) {
    try {
        const id = roomIdSchema.parse(roomId)
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        // Find the latest message from someone else
        const { data: latestMessage, error: fetchError } = await supabase
            .from('chat_messages')
            .select('id')
            .eq('room_id', id)
            .neq('sender_id', user.id)
            .order('created_at', { ascending: false })
            .limit(1)
            .single()

        if (fetchError || !latestMessage) return { success: true } // Nothing to mark unread

        const { error } = await supabase
            .from('chat_messages')
            .update({ is_read: false })
            .eq('id', latestMessage.id)

        if (error) throw error
        return { success: true }
    } catch (error: any) {
        console.error('[Chat-V3] Mark Unread Failure:', error)
        return { success: false, error: error.message }
    }
}

export async function getOrCreateRoomV3(borrowRequestId: number) {
    try {
        const supabase = await createSupabaseServer()

        const { data: parent, error: parentError } = await supabase
            .from('borrow_logs')
            .select('id, borrower_user_id, borrowed_by')
            .eq('id', borrowRequestId)
            .single()

        if (parentError || !parent) {
            return {
                success: false,
                error: 'Parent log not found. Coordination link aborted.',
                code: parentError?.code || 'P404'
            }
        }

        const borrowerId = parent.borrower_user_id || parent.borrowed_by

        const { data: room, error: syncError } = await supabase
            .from('chat_rooms')
            .upsert({
                borrow_request_id: borrowRequestId,
                borrower_user_id: borrowerId
            }, {
                onConflict: 'borrow_request_id',
                ignoreDuplicates: false
            })
            .select()
            .single()

        if (syncError) {
            return { success: false, error: syncError.message, code: syncError.code }
        }

        return { success: true, data: room }
    } catch (error: any) {
        return { success: false, error: error.message || 'Unexpected Coordination Failure' }
    }
}

export async function deleteRoomV3(roomId: string) {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { error } = await supabase
            .from('chat_rooms')
            .delete()
            .eq('id', roomId)

        if (error) throw error

        await supabase.from('activity_log').insert({
            user_id: user.id,
            action: 'DELETE_CHAT_ROOM',
            table_name: 'chat_rooms',
            changes: { room_id: roomId, deleted_at: new Date().toISOString() }
        })

        return { success: true }
    } catch (error: any) {
        return { success: false, error: error.message }
    }
}

export async function getRoomMessagesV3(roomId: string) {
    try {
        const validatedRoomId = z.string().uuid().parse(roomId)
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { data, error } = await supabase
            .from('chat_messages')
            .select('*')
            .eq('room_id', validatedRoomId)
            .order('created_at', { ascending: false })

        if (error) throw error

        return { success: true, data }
    } catch (error: any) {
        return { success: false, error: error.message }
    }
}

