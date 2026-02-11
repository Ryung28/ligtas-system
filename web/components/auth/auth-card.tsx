'use client'

import { Card, CardContent } from '@/components/ui/card'
import { AuthMode } from '@/hooks/use-auth'
import { AlertCircle, CheckCircle2 } from 'lucide-react'

interface AuthCardProps {
    mode: AuthMode
    onModeToggle: () => void
    children: React.ReactNode
    error?: string | null
    success?: string | null
}

export function AuthCard({ mode, onModeToggle, children, error, success }: AuthCardProps) {
    return (
        <Card className="border-none shadow-[0_8px_30px_rgb(0,0,0,0.02)] sm:shadow-[0_30px_60px_rgba(0,0,0,0.05)] rounded-[2.5rem] overflow-hidden bg-white/80 backdrop-blur-2xl ring-1 ring-white/20 delay-300 animate-in fade-in zoom-in-95 duration-1000 fill-mode-both">
            {/* Minimalist Progress/Mode Line */}
            <div className="flex w-full h-[4px] bg-slate-100/50">
                <div
                    className={`h-full bg-gradient-to-r from-blue-600 via-indigo-500 to-blue-400 transition-all duration-1000 ease-in-out shadow-[0_0_10px_rgba(59,130,246,0.5)] ${mode === 'login' ? 'w-1/2 translate-x-0' : 'w-1/2 translate-x-full'}`}
                />
            </div>

            <CardContent className="p-8 14in:p-12"> 
                {/* Feedback Alerts */}
                {error && (
                    <div className="mb-8 p-4 rounded-2xl bg-red-50/30 border border-red-100/30 flex items-start gap-3 animate-in slide-in-from-top-2">
                        <AlertCircle className="h-4 w-4 text-red-500 shrink-0 mt-0.5" />
                        <div className="space-y-0.5">
                            <p className="text-[9px] font-bold text-red-800 uppercase tracking-widest">Notice</p>
                            <p className="text-[11px] text-red-600 font-medium leading-relaxed">{error}</p>
                        </div>
                    </div>
                )}

                {success && (
                    <div className="mb-8 p-4 rounded-2xl bg-emerald-50/30 border border-emerald-100/30 flex items-start gap-3 animate-in slide-in-from-top-2">
                        <CheckCircle2 className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                        <div className="space-y-0.5">
                            <p className="text-[9px] font-bold text-emerald-800 uppercase tracking-widest">Success</p>
                            <p className="text-[11px] text-emerald-600 font-medium leading-relaxed">{success}</p>
                        </div>
                    </div>
                )}

                {children}

                {/* Simplified Mode Toggle Trigger at Bottom */}
                <div className="mt-8 pt-8 border-t border-slate-50/50 text-center">
                    <button
                        onClick={onModeToggle}
                        className="text-[10px] font-medium text-slate-400 hover:text-blue-600 uppercase tracking-[0.15em] transition-all duration-300"
                    >
                        {mode === 'login' ? "Don't have an account?" : "Already have access?"}
                        <span className="ml-2 font-bold text-blue-600 underline underline-offset-4 decoration-blue-600/20 hover:decoration-blue-600">
                            {mode === 'login' ? "Join Registry" : "Sign In"}
                        </span>
                    </button>
                </div>
            </CardContent>
        </Card>
    )
}
