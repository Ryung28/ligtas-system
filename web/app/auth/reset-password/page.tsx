'use client'

import { useState } from 'react'
import { createBrowserClient } from '@supabase/ssr'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'
import { AuthHeader } from '@/components/auth/auth-header'
import { Loader2, Eye, EyeOff, ShieldCheck } from 'lucide-react'

export default function ResetPasswordPage() {
    const [password, setPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const [showPassword, setShowPassword] = useState(false)
    const [isLoading, setIsLoading] = useState(false)
    const router = useRouter()

    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    const handleUpdatePassword = async (e: React.FormEvent) => {
        e.preventDefault()

        if (password !== confirmPassword) {
            toast.error('Passwords do not match')
            return
        }

        if (password.length < 6) {
            toast.error('Password must be at least 6 characters')
            return
        }

        setIsLoading(true)
        try {
            const { error } = await supabase.auth.updateUser({
                password: password
            })

            if (error) throw error

            toast.success('Password updated successfully!')
            setTimeout(() => {
                router.replace('/dashboard')
            }, 1500)
        } catch (error: any) {
            toast.error(error.message || 'Failed to update password')
        } finally {
            setIsLoading(false)
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-[#F0F2F5] p-4 selection:bg-[#832838]/20 group">
            <div className="w-full max-w-[500px] bg-white rounded-[2rem] shadow-[0_25px_60px_rgba(0,0,0,0.08)] overflow-hidden animate-in fade-in zoom-in-95 duration-700">
                <div className="p-8 sm:p-12">
                    <AuthHeader
                        title="Secure your Account"
                        description="Enter your new password below to regain full access."
                    />

                    <form onSubmit={handleUpdatePassword} className="space-y-6 mt-6">
                        <div className="space-y-2">
                            <label className="text-[13px] font-semibold text-slate-700">New Password</label>
                            <div className="relative">
                                <input
                                    type={showPassword ? 'text' : 'password'}
                                    placeholder="••••••••"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    disabled={isLoading}
                                    required
                                    className="w-full h-12 px-4 pr-11 rounded-xl border border-slate-200 bg-white text-sm outline-none focus:border-[#832838]/40 focus:ring-2 focus:ring-[#832838]/10 transition-all duration-200"
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-300 hover:text-slate-600 transition-colors"
                                >
                                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                </button>
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className="text-[13px] font-semibold text-slate-700">Confirm New Password</label>
                            <input
                                type="password"
                                placeholder="••••••••"
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                disabled={isLoading}
                                required
                                className="w-full h-12 px-4 rounded-xl border border-slate-200 bg-white text-sm outline-none focus:border-[#832838]/40 focus:ring-2 focus:ring-[#832838]/10 transition-all duration-200"
                            />
                        </div>

                        <button
                            type="submit"
                            disabled={isLoading}
                            className="w-full h-12 bg-[#832838] hover:bg-[#6B1D2E] text-white rounded-xl font-bold text-sm tracking-wide transition-all duration-200 shadow-lg shadow-[#832838]/10 flex items-center justify-center gap-2 group/btn active:scale-[0.98]"
                        >
                            {isLoading ? (
                                <>
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                    <span>Updating...</span>
                                </>
                            ) : (
                                <>
                                    <ShieldCheck className="h-4 w-4 transition-transform group-hover/btn:scale-110" />
                                    <span>Update Password</span>
                                </>
                            )}
                        </button>
                    </form>
                </div>
            </div>
        </div>
    )
}
