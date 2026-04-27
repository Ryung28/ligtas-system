'use client'

import { cn } from '@/lib/utils'

export type FilterType = 'all' | 'critical' | 'requests' | 'health'

interface AlertFiltersProps {
    activeFilter: FilterType
    setActiveFilter: (filter: FilterType) => void
    totalCount: number
    criticalCount: number
    requestsCount: number
    healthCount: number
}

export function AlertFilters({ 
    activeFilter, 
    setActiveFilter, 
    totalCount, 
    criticalCount, 
    requestsCount, 
    healthCount 
}: AlertFiltersProps) {
    const filters = [
        { id: 'all', label: 'All', count: totalCount },
        { id: 'critical', label: 'Critical', count: criticalCount },
        { id: 'requests', label: 'Requests', count: requestsCount },
        { id: 'health', label: 'Gear Health', count: healthCount }
    ]

    return (
        <div className="flex gap-2 overflow-x-auto no-scrollbar py-1">
            {filters.map((f) => (
                <button
                    key={f.id}
                    onClick={() => setActiveFilter(f.id as FilterType)}
                    className={cn(
                        "px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap",
                        activeFilter === f.id 
                            ? "bg-slate-900 text-white shadow-lg shadow-slate-100 scale-105" 
                            : "bg-slate-100 text-slate-500"
                    )}
                >
                    {f.label} ({f.count})
                </button>
            ))}
        </div>
    )
}
