'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import { z } from 'zod'

export type AuthMode = 'login' | 'register'

const authSchema = z.object({
    email: z.string().email('Please enter a valid email address'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
    fullName: z.string().min(2, 'Full name is required').optional(),
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

    const handleSubmit = async (formData: any) => {
        setError(null)
        setSuccess(null)
        setIsLoading(true)

        try {
            // Validate based on mode
            const validationData = mode === 'login'
                ? { email: formData.email, password: formData.password }
                : { email: formData.email, password: formData.password, fullName: formData.fullName }

            authSchema.parse(validationData)

            if (mode === 'login') {
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
            } else {
                if (formData.password !== formData.confirmPassword) {
                    throw new Error('Passwords do not match')
                }

                const { data, error: authError } = await supabase.auth.signUp({
                    email: formData.email.trim(),
                    password: formData.password,
                    options: {
                        data: {
                            full_name: formData.fullName,
                        }
                    }
                })

                if (authError) throw authError

                if (data.user) {
                    setSuccess('Account created! Please check your email to confirm.')
                    toast.success('Account created successfully')
                    setTimeout(() => setMode('login'), 3000)
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
        isLoading,
        error,
        success,
        handleSubmit,
        signInWithGoogle,
        toggleMode
    }
}
