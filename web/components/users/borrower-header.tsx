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
                    <div>
                        <h1 className="text-xl 14in:text-2xl font-bold tracking-tight text-slate-900 font-heading">Borrower Registry</h1>
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] mt-1">
                            View who has borrowed equipment
                        </p>
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
