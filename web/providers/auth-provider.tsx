"use client"

import React, { createContext, useContext, useEffect, useState } from "react"
import { createClient } from "@/lib/supabase-browser"
import { User } from "@supabase/supabase-js"
import useSWR from "swr"

interface AuthContextType {
    user: any | null
    isLoading: boolean
    refresh: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

/**
 * 🔒 ResQTrack IDENTITY PROVIDER
 * 🛡️ SENIOR ARCHITECT STRATEGY: Global Session Singleton
 * This provider handles the client-side user profile hydration.
 * It prevents navigation blocking by allowing the UI to render while the 
 * profile is fetched in the background.
 */
export function AuthProvider({ children }: { children: React.ReactNode }) {
    const supabase = createClient()

    // 📱 PWA SERVICE WORKER REGISTRATION
    useEffect(() => {
        if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
            window.addEventListener('load', () => {
                navigator.serviceWorker
                    .register('/sw.js')
                    .then((registration) => {
                        console.log('[PWA] Service Worker registered:', registration.scope)
                    })
                    .catch((error) => {
                        console.error('[PWA] Service Worker registration failed:', error)
                    })
            })
        }
    }, [])
    
    // Use SWR for global user caching across navigation
    const { data: user, mutate, isLoading } = useSWR('global_user_profile', async () => {
        // getSession() reads from cookie — no extra network call
        // Middleware already validated the JWT, so this is safe and instant
        const { data: { session } } = await supabase.auth.getSession()
        if (!session?.user) return null

        const { data: profile } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', session.user.id)
            .maybeSingle()

        return {
            ...session.user,
            ...profile,
            role: profile?.role || 'viewer',
            status: profile?.status || 'pending',
            full_name: profile?.full_name || session.user.user_metadata?.full_name || 'Responder'
        }
    }, {
        revalidateOnFocus: false,
        revalidateOnReconnect: true,
        dedupingInterval: 3600000, // Keep in memory for 1 hour
    })

    const refresh = async () => {
        await mutate()
    }

    return (
        <AuthContext.Provider value={{ user: user || null, isLoading, refresh }}>
            {children}
        </AuthContext.Provider>
    )
}

export function useUser() {
    const context = useContext(AuthContext)
    if (context === undefined) {
        throw new Error("useUser must be used within an AuthProvider")
    }
    return context
}
