'use client'

import { useEffect, useRef, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

/**
 * LIGTAS Chat Notification Listener
 * Headless component that listens for new chat messages globally
 * and triggers a toast notification + sound alert.
 */
export function ChatNotificationListener() {
    const router = useRouter()
    const lastPlayedRef = useRef<number>(0)
    const [currentUserId, setCurrentUserId] = useState<string | null>(null)

    useEffect(() => {
        // 1. Resolve Current Identity
        const getIdentity = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (user) setCurrentUserId(user.id)
        }
        getIdentity()

        // 2. Subscribe to Realtime Data Stream
        const channel = supabase
            .channel('global-chat-notifications')
            .on(
                'postgres_changes',
                {
                    event: 'INSERT',
                    schema: 'public',
                    table: 'chat_messages',
                },
                async (payload) => {
                    const newMessage = payload.new
                    
                    // 🛡️ Security Guard: Don't notify for self-sent messages
                    if (!currentUserId || newMessage.sender_id === currentUserId) return

                    // 🔊 Kinetic Debounce: Max once every 2 seconds to prevent "Notification Storms"
                    const now = Date.now()
                    if (now - lastPlayedRef.current > 2000) {
                        try {
                            const audio = new Audio('/sounds/notification.mp3')
                            audio.play().catch(e => {
                                console.warn('[Notification] Audio blocked by DOM Autoplay Policy', e);
                                toast.info("Acoustic alarm muted by browser. Click anywhere on the dashboard to enable sounds.", {
                                    position: "top-center"
                                });
                            });
                            lastPlayedRef.current = now
                        } catch (err) {
                            console.error('[Notification] Sound Error:', err)
                        }
                    }

                    // 🕵️ Entity Hydration: Resolve the sender's name for the toast
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
                            // Fallback to access requests if profile is pending
                            const { data: request } = await supabase
                                .from('access_requests')
                                .select('full_name')
                                .eq('user_id', newMessage.sender_id)
                                .maybeSingle()
                            
                            if (request?.full_name) senderName = request.full_name
                        }
                    } catch (err) {
                        console.warn('[Notification] Identity resolution failed:', err)
                    }

                    // 🍞 Show Tactical Toast
                    toast.message(`New Message from ${senderName}`, {
                        description: newMessage.content.length > 60 
                            ? `${newMessage.content.substring(0, 60)}...` 
                            : newMessage.content,
                        action: {
                            label: 'Open Chat',
                            onClick: () => router.push('/dashboard/chat'),
                        },
                        duration: 5000,
                    })
                }
            )
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [currentUserId, router])

    return null // 🫥 Headless Architecture
}
