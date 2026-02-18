'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'

export type AuthMode = 'login' | 'register' | 'forgot-password'

export function useAuth() {
    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
    const router = useRouter()
    const [mode, setMode] = useState<AuthMode>('login')
    const [isLoading, setIsLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)
    const [success, setSuccess] = useState<string | null>(null)

    // ── Senior Dev: Capture OAuth Errors from URL ──
    useEffect(() => {
        const checkError = () => {
            const url = new URL(window.location.href)
            // Supabase sends errors in the URL hash or query params
            const errorDescription = url.searchParams.get('error_description') ||
                url.searchParams.get('error') ||
                new URLSearchParams(url.hash.substring(1)).get('error_description')

            if (errorDescription) {
                // Clean up the URL for a professional look
                const cleanUrl = window.location.pathname
                window.history.replaceState({}, document.title, cleanUrl)

                // Set the error to be displayed
                setError(errorDescription)
                toast.error('Authentication failed')
            }
        }
        checkError()
    }, [])

    const handleSubmit = async (formData: any) => {
        // Disabled: Using Google Sign-In only
        toast.info('Standard login is disabled. Please use Google Sign-In.')
    }

    const signInWithGoogle = async () => {
        setIsLoading(true)
        setError(null)
        try {
            const { error: authError } = await supabase.auth.signInWithOAuth({
                provider: 'google',
                options: {
                    redirectTo: `${window.location.origin}/auth/callback`,
                },
            })

            if (authError) throw authError
        } catch (err: any) {
            const message = err.message || 'Google sign-in failed'
            setError(message)
            toast.error(message)
            setIsLoading(false)
        }
    }

    const toggleMode = () => {
        // No-op as other modes are removed
    }

    return {
        mode,
        setMode,
        isLoading,
        error,
        success,
        handleSubmit,
        signInWithGoogle,
        toggleMode
    }
}
