'use client'

import { useEffect, useRef, useCallback } from 'react'
import { createBrowserClient } from '@supabase/ssr'

/**
 * 🏛️ ENTERPRISE ACOUSTIC DISPATCHER
 * Unified sound engine that observes the 'system_notifications' sink.
 * Senior Dev Note: This prevents fragmented audio logic and ensures that if a notification 
 * is logged in the DB, it is heard by the Manager.
 */
export function RealtimeAudioProvider({ children }: { children: React.ReactNode }) {
    const audioRef = useRef<HTMLAudioElement | null>(null)
    const criticalAudioRef = useRef<HTMLAudioElement | null>(null)
    const lastPlayTime = useRef<number>(0)
    const supabaseRef = useRef<any>(null)

    const debounceAudio = useCallback((callback: () => void) => {
        const now = Date.now();
        if (now - lastPlayTime.current > 3000) { // 🛡️ 3s Acoustic Grace Period
            callback();
            lastPlayTime.current = now;
        }
    }, [])

    const playNotification = useCallback(() => {
        if (localStorage.getItem('audio_enabled') !== 'true') return;
        debounceAudio(() => {
            if (audioRef.current) {
                audioRef.current.currentTime = 0
                audioRef.current.play().catch(e => {
                    console.warn('[Audio] Playback blocked by browser policy:', e);
                    // 🛡️ TACTICAL FALLBACK: If blocked, the user might need to click the UI again
                })
            }
        });
    }, [debounceAudio])

    const playCriticalAlert = useCallback(() => {
        if (localStorage.getItem('audio_enabled') !== 'true') return;
        debounceAudio(() => {
            if (criticalAudioRef.current) {
                criticalAudioRef.current.currentTime = 0
                criticalAudioRef.current.play().catch(e => {
                    console.warn('[Critical] Playback blocked by browser policy:', e);
                })
            }
        });
    }, [debounceAudio])

    // 🛡️ TACTICAL UNLOCK: The "Acoustic Blessing"
    // This function MUST be called during a User-Initiated Event (Click)
    const unlockAudio = useCallback(() => {
        console.log('[Audio-Dispatcher] Attempting Acoustic Priming...');
        
        const prime = (audio: HTMLAudioElement | null) => {
            if (!audio) return;
            const originalVolume = audio.volume;
            audio.volume = 0; // Mute for priming
            audio.play()
                .then(() => {
                    audio.pause();
                    audio.currentTime = 0;
                    audio.volume = originalVolume;
                    console.log(`[Audio-Dispatcher] ${audio.src.split('/').pop()} primed successfully.`);
                })
                .catch(e => console.warn('[Audio-Dispatcher] Priming failed:', e));
        };

        prime(audioRef.current);
        prime(criticalAudioRef.current);
    }, [])

    useEffect(() => {
        // Expose unlock function to the global scope for the Permission Wrapper to call
        (window as any).RESQTRACK_UNLOCK_AUDIO = unlockAudio;

        const supabase = createBrowserClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
        )
        supabaseRef.current = supabase

        // 🏗️ PRELOAD ASSETS: Minimize latency during high-stress disaster triage
        audioRef.current = new Audio('/sounds/notification.mp3')
        audioRef.current.volume = 0.5
        
        criticalAudioRef.current = new Audio('/sounds/critical_alarm.mp3')
        criticalAudioRef.current.volume = 0.7

        // ── 🛰️ UNIFIED SINK LISTENER: The Centralized Doorbell ──
        const notificationChannel = supabase.channel('system_notifications_audio_sync')

        notificationChannel
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'system_notifications'
            }, (payload) => {
                const type = payload.new.type as string;
                console.log(`[Audio-Dispatcher] Intel Packet Received: ${type}`);

                // 🏗️ TACTICAL MAPPING: Determine urgency based on notification type
                const criticalTypes = ['borrow_request', 'stock_out', 'security_trigger', 'user_pending'];
                
                if (criticalTypes.includes(type)) {
                    playCriticalAlert();
                } else {
                    playNotification();
                }
            })
            .subscribe()

        return () => {
            supabase.removeChannel(notificationChannel)
        }
    }, [playCriticalAlert, playNotification, unlockAudio])

    return <>{children}</>
}
