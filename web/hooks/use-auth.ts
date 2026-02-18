'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import { z } from 'zod'

export type AuthMode = 'login' | 'register' | 'forgot-password'

const registerSchema = z.object({
    email: z.string().email('Please enter a valid email address'),
    fullName: z.string().min(2, 'Full name must be at least 2 characters'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
    confirmPassword: z.string()
}).refine((data) => data.password === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"],
})

const loginSchema = z.object({
    email: z.string().email('Please enter a valid email address'),
    password: z.string().min(6, 'Password is required'),
})

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
        setError(null)
        setSuccess(null)
        setIsLoading(true)

        try {
            if (mode === 'forgot-password') {
                const { error: resetError } = await supabase.auth.resetPasswordForEmail(formData.email.trim(), {
                    redirectTo: `${window.location.origin}/auth/reset-password`,
                })
                if (resetError) throw resetError
                setSuccess('Password reset link sent! Please check your email inbox.')
                toast.success('Reset link sent')
                return
            }

            // ── Senior Dev Validation Flow ──
            if (mode === 'register') {
                registerSchema.parse(formData)

                const { data, error: authError } = await supabase.auth.signUp({
                    email: formData.email.trim(),
                    password: formData.password,
                    options: {
                        data: {
                            full_name: formData.fullName,
                        },
                        emailRedirectTo: `${window.location.origin}/auth/callback`,
                    }
                })

                if (authError) throw authError

                if (data.user) {
                    setSuccess('Verification link sent! Please check your email to activate your account.')
                    toast.success('Account created! Check your email.')
                    // Don't auto-switch mode immediately; let them read the message
                    setTimeout(() => {
                        setMode('login')
                        setSuccess(null)
                    }, 6000)
                }
            } else {
                loginSchema.parse(formData)

                const { data, error: authError } = await supabase.auth.signInWithPassword({
                    email: formData.email.trim(),
                    password: formData.password,
                })

                if (authError) throw authError

                if (data.session) {
                    toast.success('Signed in successfully')
                    router.push('/dashboard')
                    router.refresh()
                }
            }
        } catch (err: any) {
            const message = err instanceof z.ZodError
                ? err.errors[0].message
                : err.message || 'Authentication failed'
            setError(message)
            toast.error(message)
        } finally {
            setIsLoading(false)
        }
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
        setMode(prev => prev === 'login' ? 'register' : 'login')
        setError(null)
        setSuccess(null)
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
