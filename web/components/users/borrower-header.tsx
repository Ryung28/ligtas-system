'use client'

import { Search, Activity } from 'lucide-react'
import { Input } from '@/components/ui/input'

interface BorrowerHeaderProps {
    lastSync: Date
    isValidating: boolean
    syncProgress: number
    searchQuery: string
    onSearchChange: (value: string) => void
}

export function BorrowerHeader({ lastSync, isValidating, syncProgress, searchQuery, onSearchChange }: BorrowerHeaderProps) {
    return (
        <div className="relative">
            {/* Sync Progress Bar */}
            <div className="absolute -top-6 left-0 w-full h-[2px] bg-slate-100/50 overflow-hidden rounded-full">
                <div
                    className="h-full bg-blue-500/40 transition-all duration-100 ease-linear"
                    style={{ width: `${syncProgress}%` }}
                />
            </div>

            <div className="flex flex-col gap-4 bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
                <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                    <div>
                        <h1 className="text-xl 14in:text-2xl font-bold text-slate-900 tracking-tight font-heading">Borrower Registry</h1>
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] mt-1 flex items-center gap-2">
                            View who has borrowed equipment
                            <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-lg bg-slate-100 text-[9px] font-bold text-slate-400 border border-slate-200 uppercase tracking-widest">
                                Updated: {lastSync.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                            </span>
                        </p>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className={`flex items-center gap-2 px-4 py-2 rounded-xl border transition-all duration-300 ${isValidating ? 'bg-blue-600 border-blue-700 shadow-lg shadow-blue-200' : 'bg-slate-50 border-slate-100'}`}>
                            <Activity className={`h-3 w-3 14in:h-3.5 14in:w-3.5 ${isValidating ? 'text-white animate-spin' : 'text-blue-600 animate-pulse'}`} />
                            <span className={`text-[10px] font-bold uppercase tracking-widest ${isValidating ? 'text-white' : 'text-blue-700'}`}>
                                {isValidating ? 'Updating' : 'Live Data'}
                            </span>
                        </div>
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
