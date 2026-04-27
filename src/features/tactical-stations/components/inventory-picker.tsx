'use client'

import { Search, CheckCircle2, Circle } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { ScrollArea } from '@/components/ui/scroll-area'
import { cn } from '@/lib/utils'
import { isLowStock } from '@/src/features/inventory/utils'
import type { InventoryPickerItem } from '../types'

interface InventoryPickerProps {
    items: InventoryPickerItem[]
    activeStationId: number | null
    manifestItemIds: number[]
    searchQuery: string
    onSearchChange: (q: string) => void
    categoryFilter: string
    onCategoryFilterChange: (c: string) => void
    categories: string[]
    onToggleItem: (id: number) => void
}

export function InventoryPicker({
    items,
    activeStationId,
    manifestItemIds,
    searchQuery,
    onSearchChange,
    categoryFilter,
    onCategoryFilterChange,
    categories,
    onToggleItem
}: InventoryPickerProps) {
    return (
        <div className="w-[380px] flex flex-col bg-slate-50/30 shrink-0 overflow-hidden">
            {/* Search + filter */}
            <div className="p-4 border-b border-slate-100 shrink-0">
                <div className="relative">
                    <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
                    <Input
                        placeholder="SEARCH INVENTORY..."
                        className="h-9 pl-8 bg-white border-slate-200 text-[11px] font-bold uppercase tracking-wider rounded-md focus-visible:ring-blue-600"
                        value={searchQuery}
                        onChange={e => onSearchChange(e.target.value)}
                    />
                </div>
                <div className="flex gap-1.5 mt-3 flex-wrap">
                    {categories.slice(0, 6).map(cat => (
                        <button
                            key={cat}
                            onClick={() => onCategoryFilterChange(cat)}
                            className={cn(
                                'px-3 py-1 rounded-md text-[9px] font-black border transition-all',
                                categoryFilter === cat
                                    ? 'bg-slate-900 border-slate-900 text-white'
                                    : 'bg-white border-slate-200 text-slate-400 hover:border-blue-400'
                            )}
                        >
                            {cat}
                        </button>
                    ))}
                </div>
            </div>

            {/* Picker rows */}
            <ScrollArea className="flex-1">
                <div className="p-2 space-y-1">
                    {items.map(item => {
                        const isMapped = manifestItemIds.includes(item.id)
                        return (
                            <button
                                key={item.id}
                                onClick={() => onToggleItem(item.id)}
                                disabled={!activeStationId}
                                className={cn(
                                    'w-full h-11 flex items-center px-4 rounded-lg transition-all border',
                                    isMapped
                                        ? 'bg-blue-600 border-blue-700 text-white shadow-sm'
                                        : 'bg-white border-slate-100 hover:border-slate-300',
                                    !activeStationId && 'opacity-40 cursor-not-allowed'
                                )}
                            >
                                <div className="mr-3 shrink-0">
                                    {isMapped
                                        ? <CheckCircle2 className="h-4 w-4 text-white" />
                                        : <Circle className="h-4 w-4 text-slate-200" />
                                    }
                                </div>
                                <div className="flex-1 text-left min-w-0 pr-3">
                                    <div className="flex items-center gap-2">
                                        <p className={cn('text-[12px] font-black truncate leading-none', isMapped ? 'text-white' : 'text-slate-900')}>
                                            {item.base_name || item.item_name}
                                        </p>
                                        {item.variant_label && (
                                            <span className={cn(
                                                "text-[8px] font-black px-1 rounded-sm uppercase tracking-tighter",
                                                isMapped ? "bg-white/20 text-white" : "bg-slate-100 text-slate-400"
                                            )}>
                                                {item.variant_label}
                                            </span>
                                        )}
                                    </div>
                                    <p className={cn('text-[9px] font-black uppercase tracking-widest mt-1.5', isMapped ? 'text-blue-200' : 'text-slate-400')}>
                                        {item.category} • <span className={isLowStock(item) && !isMapped ? "text-rose-500 underline decoration-rose-500/30 underline-offset-2" : ""}>
                                            {item.stock_available}/{item.target_stock > 0 ? item.target_stock : item.stock_total}
                                        </span> {item.unit}
                                    </p>
                                </div>
                                {isMapped && (
                                    <span className="text-[9px] font-black uppercase italic text-blue-200 shrink-0">
                                        LISTED
                                    </span>
                                )}
                            </button>
                        )
                    })}
                </div>
            </ScrollArea>
        </div>
    )
}
