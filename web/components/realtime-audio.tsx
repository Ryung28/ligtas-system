'use client'

import { useEffect, useRef } from 'react'
import { createBrowserClient } from '@supabase/ssr'

export function RealtimeAudioProvider({ children }: { children: React.ReactNode }) {
    const audioRef = useRef<HTMLAudioElement | null>(null)
    const supabaseRef = useRef<any>(null)

    const playNotification = () => {
        if (audioRef.current) {
            audioRef.current.currentTime = 0
            audioRef.current.play()
                .then(() => console.log('[Audio] Notification played'))
                .catch(e => console.warn('[Audio] Play failed (user interaction may be required):', e))
        }
    }

    const playCriticalAlert = () => {
        const criticalAudio = new Audio('/sounds/critical_alarm.mp3')
        criticalAudio.volume = 0.7
        criticalAudio.play()
            .then(() => console.log('[Audio] Critical alert played'))
            .catch(e => console.warn('[Audio] Critical play failed:', e))
    }

    useEffect(() => {
        const supabase = createBrowserClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
        )
        supabaseRef.current = supabase

        // Preload audio (place your MP3 in public/sounds/)
        audioRef.current = new Audio('/sounds/notification.mp3')
        audioRef.current.volume = 0.5

        // ── Realtime Subscription for Borrow Logs (Approvals) ──
        const borrowChannel = supabase.channel('borrow_logs_realtime')

        borrowChannel
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'borrow_logs',
                filter: "status=eq.pending"
            }, (payload) => {
                console.log('[Realtime] New pending approval detected')
                playNotification()
            })
            .subscribe()

        // ── Realtime Subscription for Chat Messages ──
        const chatChannel = supabase.channel('chat_messages_realtime')

        chatChannel
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'chat_messages'
            }, (payload) => {
                console.log('[Realtime] New chat message detected')
                playNotification()
            })
            .subscribe()

        // ── Realtime Subscription for Critical Alerts (Inventory Low Stock) ──
        const inventoryChannel = supabase.channel('inventory_realtime')

        inventoryChannel
            .on('postgres_changes', {
                event: 'UPDATE',
                schema: 'public',
                table: 'inventory',
                filter: "stock_available=lt.5"
            }, (payload) => {
                console.log('[Realtime] Critical low stock alert detected')
                playCriticalAlert()
            })
            .subscribe()

        return () => {
            supabase.removeChannel(borrowChannel)
            supabase.removeChannel(chatChannel)
            supabase.removeChannel(inventoryChannel)
        }
    }, [])

    return <>{children}</>
}
