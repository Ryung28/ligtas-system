'use client'

import { AuthHeader } from '@/components/auth/auth-header'
import { AuthForm } from '@/components/auth/auth-form'
import { useAuth } from '@/hooks/use-auth'
import { AlertCircle, CheckCircle2, Shield, Radio, Wifi, Activity, Package, Loader2 } from 'lucide-react'
import Image from 'next/image'
import { useState, useCallback } from 'react'

export default function LoginPage() {
    const {
        mode,
        setMode,
        isLoading,
        error,
        success,
        handleSubmit,
        signInWithGoogle,
        toggleMode
    } = useAuth()

    const [imageLoaded, setImageLoaded] = useState(false)

    // Senior Dev: Use a callback ref to handle cached images that don't trigger onLoad
    const onImageRef = useCallback((node: HTMLImageElement | null) => {
        if (node?.complete) {
            setImageLoaded(true)
        }
    }, [])
    return (
        <div className="min-h-screen flex items-center justify-center bg-[#F0F2F5] p-4 sm:p-6 lg:p-8 selection:bg-[#832838]/20 selection:text-[#832838] relative overflow-hidden">
            {/* ── Senior Dev: Modern Premium Dot Grid Background ── */}
            <div className="absolute inset-0 z-0 pointer-events-none">
                <div
                    className="absolute inset-0 opacity-[0.45]"
                    style={{
                        backgroundImage: `radial-gradient(#832838 1.5px, transparent 1.5px)`,
                        backgroundSize: '32px 32px',
                        maskImage: 'radial-gradient(ellipse at center, black, transparent 90%)'
                    }}
                />
                {/* Secondary accent dots */}
                <div
                    className="absolute inset-0 opacity-[0.2]"
                    style={{
                        backgroundImage: `radial-gradient(#1d4ed8 2px, transparent 1px)`,
                        backgroundSize: '64px 64px',
                        maskImage: 'radial-gradient(ellipse at center, black, transparent 95%)'
                    }}
                />
            </div>

            <div className="w-full max-w-[1100px] 3xl:max-w-[1300px] 4xl:max-w-[1500px] bg-white rounded-[2rem] shadow-[0_25px_60px_rgba(0,0,0,0.08)] overflow-hidden flex flex-col lg:flex-row min-h-[660px] 3xl:min-h-[780px] 4xl:min-h-[850px] animate-in fade-in zoom-in-95 duration-700 relative z-10">

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

                    {/* Center Illustration Area */}
                    {/* Center Illustration Area */}
                    <div className="relative z-10 flex flex-col items-center translate-y-[-45px]">
                        {/* Layered Circles (Background) */}
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[480px] h-[480px] bg-white/10 backdrop-blur-[4px] rounded-full border border-white/20 shadow-[inset_0_0_100px_rgba(255,255,255,0.1)] z-0" />
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[420px] h-[420px] bg-white/20 backdrop-blur-[8px] rounded-full border border-white/30 shadow-2xl z-0" />
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[360px] h-[360px] bg-gradient-to-br from-white/40 to-transparent backdrop-blur-[12px] rounded-full border border-white/40 z-0" />

                        {/* ── LIGTAS Definition: Inner Circular Text Seal ── */}
                        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[330px] h-[330px] pointer-events-none select-none z-0 opacity-90">
                            <svg viewBox="0 0 400 400" className="w-full h-full animate-[spin_60s_linear_infinite] will-change-transform" style={{ backfaceVisibility: 'hidden' }}>
                                <defs>
                                    {/* Adjusted path for Goldilocks radius (180px radius) */}
                                    <path id="innerCircle" d="M 200, 200 m -180, 0 a 180,180 0 1,1 360,0 a 180,180 0 1,1 -360,0" />
                                    <linearGradient id="sealGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                                        <stop offset="0%" stopColor="#1e3a8a" />
                                        <stop offset="50%" stopColor="#be123c" />
                                        <stop offset="100%" stopColor="#ea580c" />
                                    </linearGradient>
                                </defs>
                                <text className="font-black uppercase tracking-[0.16em] text-[16px]" fill="url(#sealGradient)">
                                    {/* Senior Dev: 'spacing' only stretches gaps, preserving font shape. 1115 is calibrated for seamless loop. */}
                                    <textPath xlinkHref="#innerCircle" textLength="1115" lengthAdjust="spacing">
                                        ( LIGTAS ) • Local • Inventory • & Gear • Tracking • for Administrative • Services •
                                    </textPath>
                                </text>
                            </svg>
                        </div>

                        {/* Main Illustration Container */}
                        <div className="relative z-10 w-[540px] h-[540px] 3xl:w-[650px] 3xl:h-[650px] 4xl:w-[750px] 4xl:h-[750px] animate-float-slow group-hover:scale-[1.03] transition-transform duration-1000 ease-out flex items-center justify-center">
                            {/* Themed Loading Skeleton: Atmospheric Nebula */}
                            {!imageLoaded && (
                                <div className="absolute inset-0 z-0 flex items-center justify-center">
                                    <div className="w-[300px] h-[300px] bg-white/5 rounded-full blur-3xl animate-pulse-slow active:scale-95 transition-transform" />
                                    <div className="absolute w-[150px] h-[150px] bg-blue-500/10 rounded-full blur-2xl animate-shimmer" />
                                </div>
                            )}

                            <div className="relative w-full h-full" style={{ perspective: '1000px', backfaceVisibility: 'hidden' }}>
                                <Image
                                    ref={onImageRef}
                                    src="/img.webp"
                                    alt="LIGTAS Inventory System"
                                    fill
                                    className={`relative z-10 object-contain drop-shadow-[0_45px_45px_rgba(0,0,0,0.18)] transition-all duration-1000 ease-out bg-transparent ${imageLoaded ? 'opacity-100 visible' : 'opacity-0 invisible'}`}
                                    priority
                                    unoptimized
                                    draggable={false}
                                    style={{
                                        color: 'transparent', // Hides alt text which causes white box
                                        transform: 'translate3d(0, 0, 0)', // Force GPU
                                        backfaceVisibility: 'hidden'
                                    }}
                                    sizes="(max-width: 1024px) 100vw, 55vw"
                                    onLoad={() => setImageLoaded(true)}
                                />
                            </div>
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
                    <div className="relative z-10 text-center translate-y-[-85px] 3xl:translate-y-[-100px] 4xl:translate-y-[-120px]">
                        <h2 className="text-[2.15rem] 3xl:text-[2.75rem] 4xl:text-[3.25rem] font-black text-[#1A1A2E] font-heading leading-tight tracking-tight">
                            Empowering Readiness.<br />
                            <span className="bg-gradient-to-r from-blue-700 via-[#832838] to-[#D4723C] bg-clip-text text-transparent">Securing Every Resource.</span>
                        </h2>
                        <p className="text-[14px] 3xl:text-[16px] 4xl:text-[18px] text-slate-600 font-semibold mt-3 max-w-[440px] 3xl:max-w-[550px] 4xl:max-w-[650px] leading-relaxed mx-auto">
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
                {/* RIGHT FORM PANEL (Social Only Refinement) */}
                {/* ═══════════════════════════════════════════ */}
                <div className="w-full lg:w-[45%] px-8 py-10 sm:px-10 lg:px-12 lg:py-0 flex flex-col justify-center relative overflow-hidden bg-white">
                    {/* ── Decorative: Subtle Right-side Blooms ── */}
                    <div className="absolute top-[-5%] right-[-5%] w-[300px] h-[300px] bg-blue-50/50 rounded-full blur-[80px] pointer-events-none" />
                    <div className="absolute bottom-[-10%] left-[-10%] w-[250px] h-[250px] bg-rose-50/50 rounded-full blur-[70px] pointer-events-none" />

                    <div className="relative z-10 flex flex-col items-center gap-8 3xl:gap-10">
                        <AuthHeader
                            title="Official LIGTAS Access"
                            description="CDRRMO Inventory & Asset Management"
                        />

                        {/* ── Senior Dev: Secure Portal Aesthetic ── */}
                        <div className="w-full p-7 3xl:p-9 rounded-[2.5rem] bg-slate-50 border border-slate-100/80 shadow-[0_15px_40px_rgba(0,0,0,0.02)] flex flex-col items-center text-center relative group">
                            {/* Inner Glow */}
                            <div className="absolute inset-0 bg-white/40 rounded-[2.5rem] opacity-0 group-hover:opacity-100 transition-opacity duration-700 pointer-events-none" />

                            {/* Technical Badge */}
                            <div className="w-14 h-14 rounded-2xl bg-[#832838]/5 flex items-center justify-center mb-5 relative">
                                <Shield className="w-7 h-7 text-[#832838] opacity-80" />
                                <div className="absolute inset-x-[-8px] inset-y-[-8px] border border-[#832838]/10 rounded-2xl animate-pulse-slow" />
                            </div>

                            <h3 className="text-lg font-bold text-slate-800 mb-1.5">Secure Authentication Required</h3>
                            <p className="text-[13px] text-slate-500 max-w-[280px] leading-relaxed">
                                Personnel are required to sign in using their official government-affiliated Google account for accountability.
                            </p>

                            {/* ── Senior Dev: Dynamic Feedback Alerts ── */}
                            {(error || success) && (
                                <div className="w-full mt-6 animate-in fade-in slide-in-from-top-4 duration-500">
                                    {error && (
                                        <div className="p-4 rounded-2xl bg-rose-50/95 border border-rose-200/60 shadow-sm flex items-start gap-3 text-left animate-error-shake relative overflow-hidden group/error">
                                            {/* Senior Dev: Authority Edge Highlight */}
                                            <div className="absolute top-0 left-0 w-[2.5px] h-full bg-rose-600/90" />

                                            <div className="w-10 h-10 rounded-xl bg-rose-100 flex items-center justify-center shrink-0">
                                                <Shield className="h-5 w-5 text-rose-600" />
                                            </div>

                                            <div className="flex flex-col gap-1">
                                                <span className="text-[13px] font-bold text-rose-950 flex items-center gap-2">
                                                    Security Alert
                                                    <span className="w-1 h-1 bg-rose-500 rounded-full" />
                                                </span>
                                                <p className="text-[12px] text-rose-900/80 leading-relaxed font-medium">
                                                    {error.includes('SECURITY ALERT')
                                                        ? error // This is our diagnostic message
                                                        : (error.includes('UNAUTHORIZED') || error.includes('Database error saving new user'))
                                                            ? "This system is restricted to authorized CDRRMO personnel only. If you are an official staff member, please contact the administrator to whitelist your account."
                                                            : error}
                                                </p>
                                            </div>
                                        </div>
                                    )}
                                    {success && (
                                        <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-100/50 flex items-start gap-3 text-left">
                                            <CheckCircle2 className="h-5 w-5 text-emerald-600 shrink-0 mt-0.5" />
                                            <p className="text-[12px] text-emerald-800 font-medium leading-relaxed">
                                                {success}
                                            </p>
                                        </div>
                                    )}
                                </div>
                            )}

                            {/* Authentication Action */}
                            <div className="w-full mt-8">
                                <button
                                    type="button"
                                    onClick={signInWithGoogle}
                                    disabled={isLoading}
                                    className="w-full h-16 flex items-center justify-center gap-4 bg-white border border-slate-200 rounded-[1.25rem] px-8 text-base font-bold text-slate-700 hover:bg-slate-50 hover:border-slate-300 transition-all duration-300 shadow-sm hover:shadow-md active:scale-[0.98] disabled:opacity-50 group/btn overflow-hidden relative"
                                >
                                    {/* Shimmer on hover */}
                                    <div className="absolute inset-0 bg-gradient-to-r from-transparent via-slate-400/[0.03] to-transparent -translate-x-full group-hover/btn:animate-shimmer pointer-events-none" />

                                    {isLoading ? (
                                        <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
                                    ) : (
                                        <>
                                            <svg viewBox="0 0 24 24" className="w-6 h-6 shrink-0">
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
                                        </>
                                    )}
                                </button>
                            </div>
                        </div>

                        {/* Footer / Contact Information */}
                        <div className="flex flex-col items-center gap-3">
                            <div className="flex items-center gap-2.5 py-1.5 px-4 rounded-full bg-slate-50 border border-slate-100">
                                <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-pulse" />
                                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">System Status: Operational</span>
                            </div>

                            <p className="text-[11px] text-slate-300 font-medium text-center max-w-[240px] leading-relaxed">
                                Having trouble logging in?<br />Contact IT Support at <span className="text-slate-400">admin@ligtas-cdrrmo.ph</span>
                            </p>
                        </div>
                    </div>

                    {/* Footer Copyright */}
                    <div className="absolute bottom-10 left-0 right-0 text-center">
                        <p className="text-[10px] text-slate-300 font-medium tracking-wider uppercase">
                            © 2026 CDRRMO Management Systems
                        </p>
                    </div>
                </div>
            </div>
        </div>
    )
}
