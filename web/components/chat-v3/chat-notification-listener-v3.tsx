'use client'

import { useEffect, useRef, useState } from 'react'
import { createClient } from '@/lib/supabase-browser'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

/**
 * ResQTrack Chat-V3 Notification Listener
 * Headless architecture for global sound/toast alerts.
 */
export function ChatNotificationListenerV3() {
    const router = useRouter()
    const lastPlayedRef = useRef<number>(0)
    const supabase = createClient()
    const [currentUserId, setCurrentUserId] = useState<string | null>(null)
    const [userRole, setUserRole] = useState<string | null>(null)

    useEffect(() => {
        const getIdentity = async () => {
            try {
                const { data: { user } } = await supabase.auth.getUser()
                if (user) {
                    setCurrentUserId(user.id)
                    const { data: profile } = await supabase
                        .from('user_profiles')
                        .select('role')
                        .eq('id', user.id)
                        .maybeSingle()
                    
                    if (profile) setUserRole(profile.role)
                }
            } catch (err) {
                console.warn('[Notification-V3] Identity fetch failed:', err)
            }
        }
        
        if (!currentUserId) {
            getIdentity()
        }
    }, [currentUserId])

    useEffect(() => {
        if (!currentUserId) return

        const channel = supabase
            .channel('global-chat-v3-notifications')
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages',
            }, async (payload) => {
                const newMessage = payload.new
                try {
                    if (newMessage.sender_id === currentUserId) return

                    const isAdmin = ['admin', 'manager', 'editor'].includes(userRole || '')
                    
                    const isDirectToMe = newMessage.receiver_id === currentUserId
                    const isRoomBroadcast = !newMessage.receiver_id

                    let shouldNotify = isDirectToMe

                    if (isRoomBroadcast) {
                        if (isAdmin) {
                            shouldNotify = true
                        } else {
                            // Non-admins only hear broadcasts in their own room
                            const { data: room } = await supabase
                                .from('chat_rooms')
                                .select('borrower_user_id')
                                .eq('id', newMessage.room_id)
                                .single()
                            
                            if (room?.borrower_user_id === currentUserId) {
                                shouldNotify = true
                            }
                        }
                    }

                    if (!shouldNotify) return
                } catch (err) {
                    console.warn('[Notification-V3] Chat notification evaluation failed:', err)
                    return
                }

                // Kinetic Debounce: Max once every 2 seconds
                const now = Date.now()
                if (now - lastPlayedRef.current > 2000) {
                    try {
                        const playAudio = (window as any).RESQTRACK_PLAY_AUDIO
                        if (typeof playAudio === 'function') {
                            playAudio('notification')
                        } else {
                            console.warn('[Audio] Dispatcher unavailable. Ensure RealtimeAudioProvider is mounted.')
                            const unlock = (window as any).RESQTRACK_UNLOCK_AUDIO
                            if (typeof unlock === 'function') {
                                unlock()
                            }
                            window.setTimeout(() => {
                                const retryPlayAudio = (window as any).RESQTRACK_PLAY_AUDIO
                                if (typeof retryPlayAudio === 'function') {
                                    retryPlayAudio('notification')
                                }
                            }, 150)
                        }
                        lastPlayedRef.current = now
                    } catch (err) {
                        console.warn('[Audio] Dispatcher call failed:', err)
                    }
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
                        // FALLBACK: Resolve from access requests
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
    }, [currentUserId, userRole, router])

    return null
}
