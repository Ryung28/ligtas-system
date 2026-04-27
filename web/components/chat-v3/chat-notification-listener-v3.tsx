'use client'

import { useEffect, useRef, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

/**
 * ResQTrack Chat-V3 Notification Listener
 * Headless architecture for global sound/toast alerts.
 */
export function ChatNotificationListenerV3() {
    const router = useRouter()
    const lastPlayedRef = useRef<number>(0)
    const [currentUserId, setCurrentUserId] = useState<string | null>(null)

    useEffect(() => {
        const getIdentity = async () => {
            try {
                const { data: { user } } = await supabase.auth.getUser()
                if (user) setCurrentUserId(user.id)
            } catch (err) {
                console.warn('[Notification-V3] Identity fetch failed:', err)
            }
        }
        getIdentity()

        const channel = supabase
            .channel('global-chat-v3-notifications')
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages',
            }, async (payload) => {
                const newMessage = payload.new
                try {
                    if (!currentUserId || newMessage.sender_id === currentUserId) return

                    // Senior Dev: Logic align with useUnreadChat
                    // Ring if:
                    // 1. Direct message specifically for me
                    // 2. Room message in a room I am authorized to monitor (Viewer rooms or my rooms)
                    const { data: room } = await supabase
                        .from('chat_rooms')
                        .select('borrower_user_id, borrower:borrower_user_id(role)')
                        .eq('id', newMessage.room_id)
                        .single()

                    if (!room) return

                    const isDirectToMe = newMessage.receiver_id === currentUserId
                    const isRoomBroadcast = !newMessage.receiver_id
                    const isMyRoom = room.borrower_user_id === currentUserId
                    const isViewerRoom = (room as any).borrower?.role === 'viewer'

                    // Determine if I should be notified
                    const shouldNotify = isDirectToMe || (isRoomBroadcast && (isMyRoom || isViewerRoom))

                    if (!shouldNotify) return
                } catch (err) {
                    console.warn('[Notification-V3] Chat notification evaluation failed:', err)
                    return
                }

                // Kinetic Debounce: Max once every 2 seconds
                const now = Date.now()
                if (now - lastPlayedRef.current > 2000) {
                    try {
                        const audio = new Audio('/sounds/notification.mp3')
                        audio.volume = 0.5
                        audio.play().catch(e => console.warn('[Audio] Playback blocked:', e))
                        lastPlayedRef.current = now
                    } catch (err) {}
                }

                // Entity Hydration (ResQTrack Identity Resolver)
                let senderName = 'A Mobile User'
                try {
                    const { data: profile } = await supabase
                        .from('user_profiles')
                        .select('full_name')
                        .eq('id', newMessage.sender_id)
                        .maybeSingle()
                    
                    if (profile?.full_name) {
                        senderName = profile.full_name
                    } else {
                        // FALLBACK: Resolve from access requests if profile isn't indexed yet
                        const { data: request } = await supabase
                            .from('access_requests')
                            .select('full_name')
                            .eq('user_id', newMessage.sender_id)
                            .maybeSingle()
                        if (request?.full_name) senderName = request.full_name
                    }
                } catch (err) {
                    console.warn('[Notification-V3] Identity resolution failed:', err)
                }

                toast.message(`New Message from ${senderName}`, {
                    description: newMessage.content.length > 60 ? `${newMessage.content.substring(0, 60)}...` : newMessage.content,
                    action: {
                        label: 'Open Chat',
                        onClick: () => router.push('/dashboard/chat'),
                    },
                    duration: 5000,
                })
            })
            .subscribe()

        return () => { supabase.removeChannel(channel) }
    }, [currentUserId, router])

    return null
}
