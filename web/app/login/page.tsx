'use client'

import { AuthHeader } from '@/components/auth/auth-header'
import { AuthForm } from '@/components/auth/auth-form'
import { useAuth } from '@/hooks/use-auth'
import { AlertCircle, CheckCircle2, Shield, Radio, Wifi, Activity, Package } from 'lucide-react'
import Image from 'next/image'

export default function LoginPage() {
    const {
        mode,
        isLoading,
        error,
        success,
        handleSubmit,
        signInWithGoogle,
        toggleMode
    } = useAuth()

    return (
        <div className="min-h-screen flex items-center justify-center bg-[#F0F2F5] p-4 sm:p-6 lg:p-8 selection:bg-[#832838]/20 selection:text-[#832838]">
            <div className="w-full max-w-[1100px] bg-white rounded-[2rem] shadow-[0_25px_60px_rgba(0,0,0,0.08)] overflow-hidden flex flex-col lg:flex-row min-h-[660px] animate-in fade-in zoom-in-95 duration-700">

                {/* ═══════════════════════════════════════════ */}
                {/* LEFT ILLUSTRATION PANEL */}
                {/* ═══════════════════════════════════════════ */}
                <div className="hidden lg:flex relative w-[55%] bg-gradient-to-br from-[#FDDCBF] via-[#F5D0B5] to-[#EFC4A3] flex-col items-center justify-center p-12 overflow-hidden">

                    {/* ── Decorative: Background Blooms ── */}
                    <div className="absolute top-[-10%] right-[-10%] w-[400px] h-[400px] bg-white/10 rounded-full blur-[100px]" />
                    <div className="absolute bottom-[0%] left-[-10%] w-[300px] h-[300px] bg-[#832838]/5 rounded-full blur-[80px]" />

                    {/* ── Decorative: Large Planet ── */}
                    <div className="absolute -top-14 -left-14 w-44 h-44 bg-[#832838]/80 rounded-full shadow-[0_0_40px_rgba(131,40,56,0.3)] group-hover:scale-105 transition-transform duration-700" />
                    <div className="absolute -top-6 -left-6 w-44 h-44 border-[2px] border-[#832838]/15 rounded-full" />

                    {/* ── Decorative: Floating Spheres ── */}
                    <div className="absolute top-[12%] right-[14%] w-5 h-5 bg-[#832838]/50 rounded-full animate-float-slow shadow-md" />
                    <div className="absolute top-[22%] right-[28%] w-2 h-2 bg-[#D4837A] rounded-full opacity-70" />
                    <div className="absolute bottom-[28%] right-[8%] w-7 h-7 bg-[#832838]/40 rounded-full animate-float-medium shadow-sm" />
                    <div className="absolute bottom-[18%] left-[8%] w-3 h-3 bg-[#832838]/30 rounded-full animate-float-fast" />

                    {/* ── Center Illustration Area ── */}
                    <div className="relative z-10 flex flex-col items-center translate-y-[-45px]">
                        {/* Senior Dev Glassmorphism Stack (Enlarged) */}
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[480px] h-[480px] bg-white/10 backdrop-blur-[4px] rounded-full border border-white/20 shadow-[inset_0_0_100px_rgba(255,255,255,0.1)]" />
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[420px] h-[420px] bg-white/20 backdrop-blur-[8px] rounded-full border border-white/30 shadow-2xl" />
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[360px] h-[360px] bg-gradient-to-br from-white/40 to-transparent backdrop-blur-[12px] rounded-full border border-white/40" />

                        {/* Main Illustration — User Provided Image (X-Large) */}
                        <div className="relative z-10 w-[540px] h-[540px] animate-float-slow group-hover:scale-[1.03] transition-transform duration-1000 ease-out">
                            <Image
                                src="/img.png"
                                alt="CDRRMO Inventory Management"
                                fill
                                className="object-contain drop-shadow-[0_45px_45px_rgba(0,0,0,0.18)]"
                                priority
                            />
                        </div>

                        {/* Live Status Overlay (Refined) */}
                        <div className="absolute bottom-10 left-1/2 -translate-x-1/2 flex items-center gap-6 bg-white/30 px-6 py-3 rounded-2xl border border-white/50 backdrop-blur-xl shadow-[0_10px_30px_rgba(0,0,0,0.05)] transform translate-y-4 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-700 ease-in-out">
                            <div className="flex items-center gap-2.5 text-[#3D1A29]">
                                <div className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse shadow-[0_0_8px_rgba(16,185,129,0.5)]" />
                                <span className="text-[11px] font-bold uppercase tracking-[0.2em]">Real-time</span>
                            </div>
                            <div className="h-4 w-px bg-[#3D1A29]/10" />
                            <div className="flex items-center gap-2.5 text-[#3D1A29]">
                                <Package className="w-4 h-4 opacity-70 text-indigo-600" />
                                <span className="text-[11px] font-bold uppercase tracking-[0.2em]">Inventory</span>
                            </div>
                            <div className="h-4 w-px bg-[#3D1A29]/10" />
                            <div className="flex items-center gap-2.5 text-[#3D1A29]">
                                <Shield className="w-4 h-4 opacity-70 text-blue-600" />
                                <span className="text-[11px] font-bold uppercase tracking-[0.2em]">Secured</span>
                            </div>
                        </div>
                    </div>

                    {/* ── Decorative: Organic Bottom Leaves (Adjusted for larger image) ── */}
                    <div className="absolute bottom-[-40px] left-0 right-0 h-48 overflow-hidden pointer-events-none opacity-90">
                        <div className="absolute bottom-0 left-[2%] w-24 h-40 bg-[#D4723C] rounded-t-full rotate-[-25deg] origin-bottom shadow-2xl" />
                        <div className="absolute bottom-0 left-[15%] w-20 h-44 bg-[#E8963F] rounded-t-full rotate-[-10deg] origin-bottom shadow-2xl" />
                        <div className="absolute bottom-0 left-[30%] w-16 h-32 bg-[#C2883E] rounded-t-full rotate-[5deg] origin-bottom shadow-2xl" />
                        <div className="absolute bottom-0 right-[2%] w-24 h-40 bg-[#D4723C] rounded-t-full rotate-[25deg] origin-bottom shadow-2xl" />
                        <div className="absolute bottom-0 right-[15%] w-20 h-44 bg-[#E8963F] rounded-t-full rotate-[15deg] origin-bottom shadow-2xl" />
                        <div className="absolute bottom-0 right-[30%] w-16 h-32 bg-[#C2883E] rounded-t-full rotate-[-5deg] origin-bottom shadow-2xl" />
                    </div>

                    {/* ── Bottom Hero Text (Context Aware) ── */}
                    <div className="relative z-10 text-center translate-y-[-85px]">
                        <h2 className="text-[2.15rem] font-black text-[#1A1A2E] font-heading leading-tight tracking-tight">
                            Empowering Readiness.<br />
                            <span className="bg-gradient-to-r from-blue-700 via-[#832838] to-[#D4723C] bg-clip-text text-transparent">Securing Every Resource.</span>
                        </h2>
                        <p className="text-[14px] text-slate-600 font-semibold mt-3 max-w-[440px] leading-relaxed mx-auto">
                            Precision logistics management for LIGTAS CDRRMO operations.
                            Track, manage, and deploy critical assets with zero latency.
                        </p>
                    </div>
                </div>

                {/* ═══════════════════════════════════════════ */}
                {/* VERTICAL DIVIDER */}
                {/* ═══════════════════════════════════════════ */}
                <div className="hidden lg:block w-[2px] bg-gradient-to-b from-transparent via-sky-400 to-transparent" />

                {/* ═══════════════════════════════════════════ */}
                {/* RIGHT FORM PANEL */}
                {/* ═══════════════════════════════════════════ */}
                <div className="w-full lg:w-[45%] px-8 py-10 sm:px-10 lg:px-12 lg:py-0 flex flex-col justify-center">

                    <AuthHeader
                        title={mode === 'login' ? 'Login to your Account' : 'Create your Account'}
                        description={mode === 'login' ? 'Monitor your disaster response network' : 'Join the disaster response network'}
                    />

                    {/* Feedback Alerts */}
                    {error && (
                        <div className="mb-5 p-3.5 rounded-xl bg-red-50 border border-red-100 flex items-start gap-2.5 animate-in slide-in-from-top-2 duration-300">
                            <AlertCircle className="h-4 w-4 text-red-500 shrink-0 mt-0.5" />
                            <p className="text-[13px] text-red-600 font-medium leading-relaxed">{error}</p>
                        </div>
                    )}

                    {success && (
                        <div className="mb-5 p-3.5 rounded-xl bg-emerald-50 border border-emerald-100 flex items-start gap-2.5 animate-in slide-in-from-top-2 duration-300">
                            <CheckCircle2 className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                            <p className="text-[13px] text-emerald-600 font-medium leading-relaxed">{success}</p>
                        </div>
                    )}

                    <AuthForm
                        mode={mode}
                        isLoading={isLoading}
                        onSubmit={handleSubmit}
                        onGoogleSignIn={signInWithGoogle}
                    />

                    {/* Mode Toggle */}
                    <div className="mt-8 text-center">
                        <span className="text-[13px] text-slate-400 font-medium">
                            {mode === 'login' ? 'Not Registered Yet?' : 'Already have access?'}
                        </span>
                        <button
                            onClick={toggleMode}
                            className="ml-1.5 text-[13px] font-bold text-[#832838] hover:text-[#6B1D2E] hover:underline underline-offset-4 transition-colors duration-200"
                        >
                            {mode === 'login' ? 'Create an account' : 'Sign In'}
                        </button>
                    </div>

                    {/* Footer */}
                    <div className="mt-6 text-center">
                        <p className="text-[10px] text-slate-300 font-medium tracking-wider uppercase">
                            © 2024 CDRRMO Management Systems
                        </p>
                    </div>
                </div>
            </div>
        </div>
    )
}
