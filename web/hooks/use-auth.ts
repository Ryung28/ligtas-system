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
        setIsLoading(true)
        setError(null)
        setSuccess(null)

        try {
            if (mode === 'login') {
                const { error: authError } = await supabase.auth.signInWithPassword({
                    email: formData.email,
                    password: formData.password,
                })
                if (authError) throw authError
                router.push('/dashboard/inventory')
            } else if (mode === 'register') {
                const { error: authError } = await supabase.auth.signUp({
                    email: formData.email,
                    password: formData.password,
                    options: {
                        data: {
                            full_name: formData.fullName,
                        },
                        emailRedirectTo: `${window.location.origin}/auth/callback`,
                    },
                })
                if (authError) throw authError
                setSuccess('Registration successful! Please check your email for verification.')
            } else if (mode === 'forgot-password') {
                const { error: authError } = await supabase.auth.resetPasswordForEmail(formData.email, {
                    redirectTo: `${window.location.origin}/auth/reset-password`,
                })
                if (authError) throw authError
                setSuccess('Password reset link sent to your email.')
            }
        } catch (err: any) {
            setError(err.message || 'Authentication failed')
            toast.error(err.message || 'Authentication failed')
        } finally {
            setIsLoading(false)
        }
    }

    const signInWithGoogle = async () => {
        setIsLoading(true)
        setError(null)

        // 🛡️ RECOVERY HANDSHAKE: Reset loading after 15s if no redirect occurs
        const safetyTimeout = setTimeout(() => {
            setIsLoading(false)
        }, 15000)

        try {
            const { error: authError } = await supabase.auth.signInWithOAuth({
                provider: 'google',
                options: {
                    redirectTo: `${window.location.origin}/auth/callback`,
                },
            })

            if (authError) {
                clearTimeout(safetyTimeout)
                throw authError
            }
        } catch (err: any) {
            clearTimeout(safetyTimeout)
            const message = err.message || 'Google sign-in failed'
            setError(message)
            toast.error(message)
            setIsLoading(false)
        }
    }

    const toggleMode = () => {
        setError(null)
        setSuccess(null)
        setMode(prev => prev === 'login' ? 'register' : 'login')
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
