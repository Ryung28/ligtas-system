'use client'

import { Button } from '@/components/ui/button'

interface UserHeaderProps {
    isLoading: boolean
    isValidating: boolean
    onInvite: (email: string, role: string) => Promise<boolean>
}

export function UserHeader({ isLoading, isValidating, onInvite }: UserHeaderProps) {
    return (
        <div className="flex flex-col md:flex-row gap-4 justify-between items-start md:items-center bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
            <div className="relative z-10">
                <div className="flex items-center gap-2 mb-1">
                    <div className="h-2 w-2 rounded-full bg-purple-500 animate-pulse" />
                    <span className="text-[10px] font-black text-purple-600 uppercase tracking-[0.2em]">Security & Permissions</span>
                </div>
                <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic leading-none">
                    System Users
                </h1>
            </div>
            <div className="flex items-center gap-3">
                {/* No manual sync button */}
            </div>
        </div>
    )
}
