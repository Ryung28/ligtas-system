'use client'

import { Search, Activity } from 'lucide-react'
import { Input } from '@/components/ui/input'

interface BorrowerHeaderProps {
    lastSync: Date
    isValidating: boolean
    searchQuery: string
    onSearchChange: (value: string) => void
}

export function BorrowerHeader({ lastSync, isValidating, searchQuery, onSearchChange }: BorrowerHeaderProps) {
    return (
        <div className="relative">
            <div className="flex flex-col gap-4 bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
                <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                    <div className="relative z-10">
                        <div className="flex items-center gap-2 mb-1">
                            <div className="h-2 w-2 rounded-full bg-blue-500 animate-pulse" />
                            <span className="text-[10px] font-black text-blue-600 uppercase tracking-[0.2em]">Personnel Command</span>
                        </div>
                        <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic leading-none">
                            Borrower Registry
                        </h1>
                    </div>
                </div>

                <div className="relative w-full max-w-md group">
                    <Search className="absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                    <Input
                        placeholder="Search for a name..."
                        className="pl-12 h-10 14in:h-11 bg-slate-50/50 border-slate-100 rounded-xl focus:ring-blue-500 text-sm placeholder:text-slate-300 transition-all"
                        value={searchQuery}
                        onChange={(e) => onSearchChange(e.target.value)}
                    />
                </div>
            </div>
        </div>
    )
}
