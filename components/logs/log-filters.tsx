'use client'

import * as React from 'react'
import { Input } from '@/components/ui/input'
import { ArrowDownUp, Search } from 'lucide-react'
import { TransactionStatus } from '@/lib/types/inventory'
import { DatePicker } from '@/components/ui/date-picker'
import { format } from 'date-fns'
import { cn } from '@/lib/utils'
import { motion } from 'framer-motion'

interface LogFiltersProps {
    filter: TransactionStatus
    setFilter: (f: TransactionStatus) => void
    dateFilter: string
    setDateFilter: (d: string) => void
    searchQuery: string
    setSearchQuery: (s: string) => void
    sortOrder: 'latest' | 'oldest'
    setSortOrder: (o: 'latest' | 'oldest') => void
}

function LogFilterButton({ children, onClick, isActive }: { children: React.ReactNode, onClick: () => void, isActive: boolean }) {
    return (
        <button
            onClick={onClick}
            className={cn(
                "px-5 h-9 rounded-lg text-[10px] font-black uppercase tracking-[0.12em] transition-colors duration-200 relative group",
                isActive ? "text-white" : "text-zinc-500 hover:text-zinc-950"
            )}
        >
            <span className="relative z-20 block">
                {children}
            </span>

            {isActive && (
                <motion.div
                    layoutId="active-filter-segment"
                    className="absolute inset-0 bg-zinc-950 rounded-lg shadow-[0_4px_12px_rgba(0,0,0,0.12)] z-10"
                    transition={{
                        type: "spring",
                        stiffness: 380,
                        damping: 30
                    }}
                />
            )}

            {/* Hover Indicator */}
            <div className="absolute inset-0 bg-zinc-100/50 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity z-0" />
        </button>
    );
}

export function LogFilters({
    dateFilter,
    setDateFilter,
    searchQuery,
    setSearchQuery,
    sortOrder,
    setSortOrder,
}: Omit<LogFiltersProps, 'filter' | 'setFilter'>) {
    const [mounted, setMounted] = React.useState(false)
    const activeDate = dateFilter ? new Date(dateFilter) : undefined

    React.useEffect(() => {
        setMounted(true)
    }, [])

    if (!mounted) {
        return <div className="flex flex-col sm:flex-row gap-2 w-full h-10 bg-white/50 animate-pulse rounded-lg"></div>
    }

    return (
        <div className="flex flex-col sm:flex-row gap-2 w-full">
            <DatePicker
                date={activeDate}
                setDate={(date: Date | undefined) => setDateFilter(date ? format(date, "yyyy-MM-dd") : '')}
                className="w-full sm:w-44"
                placeholder="Filter by date"
            />

            <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-400" />
                <Input
                    type="text"
                    placeholder="Search logs..."
                    value={searchQuery}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearchQuery(e.target.value)}
                    className={cn(
                        "pl-10 h-10 border-zinc-200 rounded-lg text-xs font-medium shadow-sm bg-white",
                        "focus-visible:ring-2 focus-visible:ring-zinc-900/10 focus-visible:border-zinc-900 focus-visible:ring-offset-0 transition-all"
                    )}
                />
            </div>

            {/* Sort Toggle */}
            <button
                onClick={() => setSortOrder(sortOrder === 'latest' ? 'oldest' : 'latest')}
                className={cn(
                    "flex items-center gap-1.5 px-3 h-10 rounded-lg border text-[10px] font-black uppercase tracking-[0.1em] transition-all shrink-0",
                    "border-zinc-200 bg-white text-zinc-600 hover:bg-zinc-50 hover:text-zinc-900"
                )}
            >
                <ArrowDownUp className="h-3.5 w-3.5" />
                {sortOrder === 'latest' ? 'Latest First' : 'Oldest First'}
            </button>
        </div>
    )
}
