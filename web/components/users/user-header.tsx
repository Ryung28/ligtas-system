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
            <div>
                <h1 className="text-xl 14in:text-2xl font-bold tracking-tight text-slate-900 font-heading">System Users</h1>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] mt-1">Manage staff and mobile app accounts</p>
            </div>
            <div className="flex items-center gap-3">
                {/* No manual sync button */}
            </div>
        </div>
    )
}
