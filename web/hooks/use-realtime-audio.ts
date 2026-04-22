'use client'

import { useEffect, useRef } from 'react'
import { createBrowserClient } from '@supabase/ssr'

/**
 * The Diagnostic: Database changes don't automatically play sounds
 * The Worker's Tool: Realtime subscription + HTML5 Audio API
 * The Manager's Strategy: Centralized audio trigger prevents duplicate sound logic across components
 * The 12-Year-Old Analogy: Like a doorbell - the doorbell button (database change) sends a signal, but you need wiring (subscription) to ring the bell (play sound)
 */
export function useRealtimeAudio() {
    const audioRef = useRef<HTMLAudioElement | null>(null)
    const supabaseRef = useRef<any>(null)

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

        return () => {
            supabase.removeChannel(borrowChannel)
        }
    }, [])

    const playNotification = () => {
        if (audioRef.current) {
            audioRef.current.currentTime = 0
            audioRef.current.play().catch(e => console.warn('[Audio] Play failed:', e))
        }
    }

    return { playNotification }
}
