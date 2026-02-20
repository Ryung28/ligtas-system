'use client'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Calendar, Search, X } from 'lucide-react'
import { TransactionStatus } from '@/lib/types/inventory'

interface LogFiltersProps {
    filter: TransactionStatus
    setFilter: (f: TransactionStatus) => void
    dateFilter: string
    setDateFilter: (d: string) => void
    searchQuery: string
    setSearchQuery: (s: string) => void
}

export function LogFilters({
    filter,
    setFilter,
    dateFilter,
    setDateFilter,
    searchQuery,
    setSearchQuery
}: LogFiltersProps) {
    return (
        <div className="flex flex-col xl:flex-row gap-4 justify-between xl:items-center">
            {/* Filters Left */}
            <div className="flex flex-wrap gap-2">
                {(['all', 'pending', 'borrowed', 'returned', 'overdue', 'rejected'] as const).map((f) => (
                    <Button
                        key={f}
                        onClick={() => setFilter(f)}
                        variant={filter === f ? 'default' : 'outline'}
                        size="sm"
                        className={`rounded-xl px-4 h-9 text-[10px] font-bold uppercase tracking-[0.15em] transition-all duration-200 ${filter === f
                            ? 'bg-slate-900 text-white shadow-md shadow-slate-200 hover:bg-slate-800'
                            : 'text-slate-500 border-slate-100 hover:bg-slate-50 hover:text-slate-900'
                            }`}
                    >
                        {f}
                    </Button>
                ))}
            </div>

            {/* Search & Date Right */}
            <div className="flex flex-col sm:flex-row gap-2 w-full xl:w-auto">
                <div className="relative">
                    <div className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none">
                        <Calendar className="h-4 w-4 text-slate-400" />
                    </div>
                    <Input
                        type="date"
                        value={dateFilter}
                        onChange={(e) => setDateFilter(e.target.value)}
                        onClick={(e) => e.currentTarget.showPicker?.()}
                        className="pl-10 pr-10 h-10 w-full sm:w-48 border-slate-200 rounded-xl text-xs font-medium cursor-pointer [&::-webkit-calendar-picker-indicator]:hidden transition-all focus:ring-2 focus:ring-slate-900/5 hover:border-slate-300"
                    />
                    {dateFilter && (
                        <button
                            onClick={() => setDateFilter('')}
                            className="absolute right-3 top-1/2 -translate-y-1/2 p-1 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 transition-colors"
                        >
                            <X className="h-3.5 w-3.5" />
                        </button>
                    )}
                </div>

                <div className="relative flex-1 sm:w-64">
                    <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
                    <Input
                        type="text"
                        placeholder="Search logs..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="pl-10 h-10 border-gray-200 rounded-lg"
                    />
                </div>
            </div>
        </div>
    )
}
