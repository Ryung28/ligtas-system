'use client'

import { useState } from 'react'
import { Eye, EyeOff, Loader2 } from 'lucide-react'
import { AuthMode } from '@/hooks/use-auth'

interface AuthFormProps {
    mode: AuthMode
    isLoading: boolean
    onSubmit: (data: any) => void
    onGoogleSignIn: () => void
    onForgotPassword?: () => void
}

export function AuthForm({ mode, isLoading, onSubmit, onGoogleSignIn, onForgotPassword }: AuthFormProps) {
    const [showPassword, setShowPassword] = useState(false)
    const [formData, setFormData] = useState({
        email: '',
        password: '',
        confirmPassword: '',
        fullName: ''
    })

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault()
        onSubmit(formData)
    }

    const isReset = mode === 'forgot-password'

    return (
        <form onSubmit={handleSubmit} className="space-y-4 3xl:space-y-5 4xl:space-y-6 animate-in fade-in duration-500 delay-200 fill-mode-both">



            {/* ── Social Login: Continue with Google (Hidden in Reset) ── */}
            {!isReset && (
                <button
                    type="button"
                    onClick={onGoogleSignIn}
                    disabled={isLoading}
                    className="w-full h-11 3xl:h-12 4xl:h-14 flex items-center justify-center gap-3 bg-white border border-slate-200 rounded-xl px-4 py-2 text-sm 3xl:text-base 4xl:text-lg font-semibold text-slate-600 hover:bg-slate-50 hover:border-slate-300 transition-all duration-200 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    <svg viewBox="0 0 24 24" className="w-5 h-5 3xl:w-6 3xl:h-6 4xl:w-7 4xl:h-7">
                        <path
                            d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                            fill="#4285F4"
                        />
                        <path
                            d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                            fill="#34A853"
                        />
                        <path
                            d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"
                            fill="#FBBC05"
                        />
                        <path
                            d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                            fill="#EA4335"
                        />
                    </svg>
                    <span>Continue with Google</span>
                </button>
            )}

            {/* ── Divider (Hidden in Reset) ── */}
            {!isReset && (
                <div className="flex items-center gap-3 my-2 opacity-60">
                    <div className="flex-1 h-px bg-slate-200" />
                    <span className="text-[10px] 3xl:text-[11px] 4xl:text-xs font-bold text-slate-400 uppercase tracking-widest whitespace-nowrap">
                        or Sign in with Email
                    </span>
                    <div className="flex-1 h-px bg-slate-200" />
                </div>
            )}

            {/* ── Full Name (Register only) ── */}
            {mode === 'register' && (
                <div className="space-y-1.5 3xl:space-y-2">
                    <label className="text-[13px] 3xl:text-sm 4xl:text-base font-semibold text-slate-700">
                        Full Name
                    </label>
                    <input
                        type="text"
                        placeholder="Juan Dela Cruz"
                        value={formData.fullName}
                        onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                        disabled={isLoading}
                        required
                        className="w-full h-11 3xl:h-12 4xl:h-14 px-4 3xl:px-5 4xl:px-6 rounded-xl border border-slate-200 bg-white text-sm 3xl:text-base 4xl:text-lg text-slate-700 placeholder:text-slate-300 outline-none focus:border-[#832838]/40 focus:ring-2 focus:ring-[#832838]/10 transition-all duration-200 disabled:opacity-50 caret-[#832838] cursor-text"
                    />
                </div>
            )}

            {/* ── Email ── */}
            <div className="space-y-1.5 3xl:space-y-2">
                <label className="text-[13px] 3xl:text-sm 4xl:text-base font-semibold text-slate-700">
                    Email
                </label>
                <input
                    type="email"
                    placeholder="mail@abc.com"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    disabled={isLoading}
                    required
                    className="w-full h-11 3xl:h-12 4xl:h-14 px-4 3xl:px-5 4xl:px-6 rounded-xl border border-slate-200 bg-white text-sm 3xl:text-base 4xl:text-lg text-slate-700 placeholder:text-slate-300 outline-none focus:border-[#832838]/40 focus:ring-2 focus:ring-[#832838]/10 transition-all duration-200 disabled:opacity-50 caret-[#832838] cursor-text"
                />
            </div>

            {/* ── Password ── */}
            {!isReset && (
                <div className="space-y-1.5 3xl:space-y-2">
                    <label className="text-[13px] 3xl:text-sm 4xl:text-base font-semibold text-slate-700">
                        Password
                    </label>
                    <div className="relative">
                        <input
                            type={showPassword ? 'text' : 'password'}
                            placeholder="••••••••"
                            value={formData.password}
                            onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                            disabled={isLoading}
                            required
                            className="w-full h-11 3xl:h-12 4xl:h-14 px-4 3xl:px-5 4xl:px-6 pr-11 3xl:pr-12 4xl:pr-14 rounded-xl border border-slate-200 bg-white text-sm 3xl:text-base 4xl:text-lg text-slate-700 placeholder:text-slate-300 outline-none focus:border-[#832838]/40 focus:ring-2 focus:ring-[#832838]/10 transition-all duration-200 disabled:opacity-50 caret-[#832838] cursor-text"
                        />
                        <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3.5 3xl:right-4 4xl:right-5 top-1/2 -translate-y-1/2 text-slate-300 hover:text-slate-600 transition-colors duration-200 cursor-pointer z-20"
                            tabIndex={-1}
                        >
                            {showPassword ? <EyeOff className="h-4 w-4 3xl:h-5 3xl:w-5 4xl:h-6 4xl:w-6" /> : <Eye className="h-4 w-4 3xl:h-5 3xl:w-5 4xl:h-6 4xl:w-6" />}
                        </button>
                    </div>
                </div>
            )}

            {/* ── Confirm Password (Register only) ── */}
            {mode === 'register' && !isReset && (
                <div className="space-y-1.5 3xl:space-y-2">
                    <label className="text-[13px] 3xl:text-sm 4xl:text-base font-semibold text-slate-700">
                        Confirm Password
                    </label>
                    <input
                        type="password"
                        placeholder="••••••••"
                        value={formData.confirmPassword}
                        onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                        disabled={isLoading}
                        required
                        className="w-full h-11 3xl:h-12 4xl:h-14 px-4 3xl:px-5 4xl:px-6 rounded-xl border border-slate-200 bg-white text-sm 3xl:text-base 4xl:text-lg text-slate-700 placeholder:text-slate-300 outline-none focus:border-[#832838]/40 focus:ring-2 focus:ring-[#832838]/10 transition-all duration-200 disabled:opacity-50 caret-[#832838] cursor-text"
                    />
                </div>
            )}

            {/* ── Remember Me & Forgot Password (Login only) ── */}
            {mode === 'login' && (
                <div className="flex items-center justify-between pt-0.5">
                    <label className="flex items-center gap-2 cursor-pointer group">
                        <input
                            type="checkbox"
                            id="remember"
                            className="w-4 h-4 3xl:w-5 3xl:h-5 4xl:w-6 4xl:h-6 rounded border-slate-300 text-[#832838] focus:ring-[#832838]/20 transition-all cursor-pointer accent-[#832838]"
                        />
                        <span className="text-[12px] 3xl:text-sm 4xl:text-base font-medium text-slate-500 group-hover:text-slate-700 transition-colors">
                            Remember Me
                        </span>
                    </label>
                    <button
                        type="button"
                        onClick={onForgotPassword}
                        className="text-[12px] 3xl:text-sm 4xl:text-base font-bold text-[#832838] hover:text-[#6B1D2E] transition-colors duration-200"
                    >
                        Forgot Password?
                    </button>
                </div>
            )}

            {/* ── Submit Button ── */}
            <button
                type="submit"
                disabled={isLoading}
                className="w-full h-12 3xl:h-14 4xl:h-16 bg-[#832838] hover:bg-[#6B1D2E] active:bg-[#5A1526] text-white rounded-xl font-bold text-[14px] 3xl:text-base 4xl:text-lg tracking-wide transition-all duration-200 hover:shadow-lg hover:shadow-[#832838]/20 active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed mt-2 relative overflow-hidden group"
            >
                {/* Shimmer effect on hover */}
                <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/[0.06] to-transparent -translate-x-full group-hover:animate-shimmer pointer-events-none" />

                {isLoading ? (
                    <span className="flex items-center justify-center gap-2.5">
                        <Loader2 className="h-4 w-4 3xl:h-5 3xl:w-5 4xl:h-6 4xl:w-6 animate-spin" />
                        <span className="opacity-90">
                            {mode === 'login' ? 'Signing in...' : mode === 'register' ? 'Creating account...' : 'Sending link...'}
                        </span>
                    </span>
                ) : (
                    <span>{mode === 'login' ? 'Login' : mode === 'register' ? 'Create Account' : 'Send Reset Link'}</span>
                )}
            </button>
        </form>
    )
}
