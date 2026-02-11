'use client'

import { Button } from '@/components/ui/button'
import { RefreshCw, UserPlus } from 'lucide-react'

interface UserHeaderProps {
    isLoading: boolean
    isValidating: boolean
    onRefresh: () => void
}

export function UserHeader({ isLoading, isValidating, onRefresh }: UserHeaderProps) {
    return (
        <div className="flex flex-col md:flex-row gap-4 justify-between items-start md:items-center bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
            <div>
                <h1 className="text-xl 14in:text-2xl font-bold tracking-tight text-slate-900 font-heading">Staff Management</h1>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] mt-1">Manage staff accounts and permissions</p>
            </div>
            <div className="flex items-center gap-2">
                <Button
                    variant="outline"
                    size="sm"
                    onClick={onRefresh}
                    disabled={isLoading || isValidating}
                    className="h-8 14in:h-9 text-[10px] 14in:text-xs uppercase tracking-wide font-medium bg-white border-slate-200 hover:bg-slate-50 transition-all active:scale-95"
                >
                    <RefreshCw className={`mr-1.5 h-3 w-3 14in:h-3.5 14in:w-3.5 ${isValidating ? 'animate-spin' : ''}`} />
                    Sync
                </Button>
                <Button size="sm" className="h-8 14in:h-9 bg-blue-600 hover:bg-blue-700 text-white shadow-sm text-[10px] 14in:text-xs uppercase tracking-wide font-semibold transition-all active:scale-95">
                    <UserPlus className="mr-1.5 h-3.5 w-3.5" />
                    Invite Staff
                </Button>
            </div>
        </div>
    )
}
