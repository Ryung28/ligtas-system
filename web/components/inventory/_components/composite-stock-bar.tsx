'use client'

import { cn } from '@/lib/utils'
import { Clock, ChevronDown, AlertTriangle } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { InventoryItem } from '@/lib/supabase'
import { PendingRequest } from '@/src/features/transactions'

interface CompositeStockBarProps {
    item: InventoryItem
    pendingCount: number
    pendingRequests: PendingRequest[]
    isLoadingPending: boolean
    isInternalOpen: boolean
    setIsInternalOpen: (open: boolean) => void
    fetchPending: () => void
}

export function CompositeStockBar({
    item,
    pendingCount,
    pendingRequests,
    isLoadingPending,
    isInternalOpen,
    setIsInternalOpen,
    fetchPending
}: CompositeStockBarProps) {
    const total = item.stock_total || 1
    const goodPct = (item.qty_good / total) * 100
    const maintPct = (item.qty_maintenance / total) * 100
    const damagedPct = (item.qty_damaged / total) * 100
    const lostPct = (item.qty_lost / total) * 100

    const hasIssues = item.qty_damaged > 0 || item.qty_maintenance > 0 || item.qty_lost > 0
    const hasPending = pendingCount > 0

    return (
        <div className="flex flex-col gap-2 min-w-[160px]">
            {/* 🏥 COMPOSITE HEALTH STRIP */}
            <div className="group/strip relative">
                <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden flex shadow-inner border border-slate-200/30">
                    <div className="h-full bg-emerald-500 transition-all duration-500" style={{ width: `${goodPct}%` }} />
                    <div className="h-full bg-amber-400 transition-all duration-500" style={{ width: `${maintPct}%` }} />
                    <div className="h-full bg-rose-500 transition-all duration-500" style={{ width: `${damagedPct}%` }} />
                    <div className="h-full bg-slate-400 transition-all duration-500" style={{ width: `${lostPct}%` }} />
                </div>
                
                {/* Tactical Legend (Visible on Hover or if issues exist) */}
                <div className={cn(
                    "flex items-center gap-3 mt-1.5 transition-opacity duration-200",
                    hasIssues ? "opacity-100" : "opacity-0 group-hover/strip:opacity-100"
                )}>
                    {item.qty_damaged > 0 && (
                        <div className="flex items-center gap-1">
                            <div className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                            <span className="text-[9px] font-black text-rose-600 tabular-nums">{item.qty_damaged}</span>
                        </div>
                    )}
                    {item.qty_maintenance > 0 && (
                        <div className="flex items-center gap-1">
                            <div className="w-1.5 h-1.5 rounded-full bg-amber-400" />
                            <span className="text-[9px] font-black text-amber-600 tabular-nums">{item.qty_maintenance}</span>
                        </div>
                    )}
                    {item.qty_lost > 0 && (
                        <div className="flex items-center gap-1">
                            <div className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                            <span className="text-[9px] font-black text-slate-500 tabular-nums">{item.qty_lost}</span>
                        </div>
                    )}
                </div>
            </div>

            {/* ⚠️ EXCEPTION ALERTS (Only shown if pending) */}
            {hasPending && (
                <Popover open={isInternalOpen} onOpenChange={(open) => {
                    setIsInternalOpen(open)
                    if (open) fetchPending()
                }}>
                    <PopoverTrigger asChild>
                        <button
                            onClick={(e) => e.stopPropagation()}
                            className="inline-flex items-center gap-1 self-start px-2.5 py-1 rounded-md text-[9px] font-black bg-gray-50 border border-gray-200 text-gray-950 hover:bg-gray-100 transition-all shadow-sm group"
                        >
                            <Clock className="h-2.5 w-2.5 text-gray-400 group-hover:text-gray-950" />
                            {pendingCount} PENDING
                        </button>
                    </PopoverTrigger>
                    <PopoverContent side="bottom" align="start" className="w-64 p-0 rounded-xl overflow-hidden shadow-2xl border-gray-200 z-[100]" onClick={(e) => e.stopPropagation()}>
                        <div className="p-3 bg-gray-50/50 border-b border-gray-100 text-[11px] font-black text-gray-950 uppercase tracking-tight">Approval Queue</div>
                        <div className="max-h-[200px] overflow-y-auto p-1.5 space-y-1">
                            {isLoadingPending ? (
                                <div className="py-6 text-center text-[10px] font-bold text-gray-400">Syncing queue...</div>
                            ) : pendingRequests.map((r) => (
                                <div key={r.id} className="p-3 rounded-lg bg-white border border-gray-100 flex items-center justify-between shadow-sm">
                                    <span className="text-[12px] font-black text-gray-950">{r.borrower_name}</span>
                                    <Badge variant="outline" className="text-[10px] font-black bg-gray-50 border-gray-200 text-gray-950">{r.quantity} UNITS</Badge>
                                </div>
                            ))}
                        </div>
                    </PopoverContent>
                </Popover>
            )}
        </div>
    )
}
