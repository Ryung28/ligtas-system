'use client'

import React, { useEffect } from 'react'
import { createBrowserClient } from '@supabase/ssr'

const HEARTBEAT_INTERVAL = 1000 * 60 * 2 // 2 minutes

/**
 * Presence Heartbeat component.
 * Updates the user's `last_seen` timestamp in the database periodically
 * while the application is in the foreground.
 */
export function PresenceHeartbeat() {
    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    useEffect(() => {
        let timeoutId: NodeJS.Timeout

        const updatePresence = async () => {
            try {
                const { data: { user } } = await supabase.auth.getUser()
                if (!user) return

                await supabase
                    .from('user_profiles')
                    .update({ last_seen: new Date().toISOString() })
                    .eq('id', user.id)

            } catch (error) {
                console.error('[Presence] Heartbeat failed:', error)
            } finally {
                timeoutId = setTimeout(updatePresence, HEARTBEAT_INTERVAL)
            }
        }

        // Initial update
        updatePresence()

        // Sync on visibility change
        const handleVisibilityChange = () => {
            if (document.visibilityState === 'visible') {
                updatePresence()
            }
        }

        document.addEventListener('visibilitychange', handleVisibilityChange)

        return () => {
            clearTimeout(timeoutId)
            document.removeEventListener('visibilitychange', handleVisibilityChange)
        }
    }, [supabase])

    return null
}
