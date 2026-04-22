'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { z } from 'zod'

const sendMessageSchema = z.object({
    roomId: z.string().uuid(),
    content: z.string().min(1, 'Cannot send empty message'),
})

export async function sendMessage(roomId: string, content: string) {
    try {
        const validated = sendMessageSchema.parse({ roomId, content })
        const supabase = await createSupabaseServer()

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        // ── Tactical Sync: Identify Receiver ──
        const { data: room } = await supabase
            .from('chat_rooms')
            .select('borrower_user_id')
            .eq('id', validated.roomId)
            .single()

        const receiverId = room?.borrower_user_id === user.id ? null : room?.borrower_user_id

        const { error } = await supabase.from('chat_messages').insert({
            room_id: validated.roomId,
            sender_id: user.id,
            receiver_id: receiverId, // ── Explicit target for mobile sync ──
            content: validated.content,
            status: 'sent'
        })

        if (error) throw error

        return { success: true }
    } catch (error: any) {
        console.error('Chat error:', error)
        return { success: false, error: error.message || 'Failed to send message' }
    }
}


export async function getOrCreateRoom(borrowRequestId: number) {
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

export async function markAsRead(roomId: string) {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { error } = await supabase
            .from('chat_messages')
            .update({ is_read: true })
            .eq('room_id', roomId)
            .neq('sender_id', user.id)

        if (error) throw error
        return { success: true }
    } catch (error: any) {
        return { success: false, error: error.message }
    }
}

export async function getChatRooms() {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        // 1 Call. Less than 50 milliseconds. All logic done via Postgres Engine.
        const { data, error } = await supabase.rpc('get_active_chat_inbox_v2', { 
            staff_uuid: user.id 
        })

        if (error) throw error

        // Transform the flat SQL response into the nested ChatRoom structured format
        // the UI expects, ensuring backward compatibility with the components.
        const formattedRooms = (data || []).map((row: any) => ({
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
                content: row.chat_last_message_content,
                created_at: row.chat_last_message_created_at,
                sender_id: row.chat_last_message_sender_id
            } : null,
            unread_count: Number(row.chat_unread_count || 0)
        }))

        return { success: true, data: formattedRooms }

    } catch (error: any) {
        console.error('[Chat-Rooms] Fetch Failure:', error)
        return { success: false, error: error.message }
    }
}

export async function deleteRoom(roomId: string) {
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

export async function getRoomMessages(roomId: string) {
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
