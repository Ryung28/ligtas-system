'use client'

import { useEffect, useRef, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

/**
 * LIGTAS Chat-V3 Notification Listener
 * Headless architecture for global sound/toast alerts.
 */
export function ChatNotificationListenerV3() {
    const router = useRouter()
    const lastPlayedRef = useRef<number>(0)
    const [currentUserId, setCurrentUserId] = useState<string | null>(null)

    useEffect(() => {
        const getIdentity = async () => {
            const { data: { user } } = await supabase.auth.getUser()
            if (user) setCurrentUserId(user.id)
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
                if (!currentUserId || newMessage.sender_id === currentUserId) return

                // Kinetic Debounce: Max once every 2 seconds
                const now = Date.now()
                if (now - lastPlayedRef.current > 2000) {
                    try {
                        new Audio('/sounds/notification.mp3').play().catch(() => {})
                        lastPlayedRef.current = now
                    } catch (err) {}
                }

                // Entity Hydration (LIGTAS Identity Resolver)
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
