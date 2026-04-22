'use client'

import { Clock, ChevronDown } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { InventoryItem } from '@/lib/supabase'
import { PendingRequest } from '@/src/features/transactions'

interface StockStatusBadgesProps {
    item: InventoryItem
    pendingCount: number
    pendingRequests: PendingRequest[]
    isLoadingPending: boolean
    isInternalOpen: boolean
    setIsInternalOpen: (open: boolean) => void
    fetchPending: () => void
}

export function StockStatusBadges({
    item,
    pendingCount,
    pendingRequests,
    isLoadingPending,
    isInternalOpen,
    setIsInternalOpen,
    fetchPending
}: StockStatusBadgesProps) {
    const hasPendingRequests = pendingCount > 0

    return (
        <div className="flex flex-wrap items-center gap-1.5 min-w-[140px]">
            {/* ENTERPRISE HEALTH BUCKETS */}
            {item.qty_good > 0 && (
                <Badge variant="outline" className="text-[10px] font-bold px-2 py-1 flex items-center gap-1 bg-emerald-50 border-emerald-200 text-emerald-700 shadow-sm transition-all hover:scale-105">
                    <span className="opacity-60 tabular-nums">{item.qty_good}×</span> READY
                </Badge>
            )}
            {item.qty_damaged > 0 && (
                <Badge variant="outline" className="text-[10px] font-bold px-2 py-1 flex items-center gap-1 bg-rose-50 border-rose-200 text-rose-700 shadow-sm transition-all hover:scale-105">
                    <span className="opacity-60 tabular-nums">{item.qty_damaged}×</span> REPAIR
                </Badge>
            )}
            {item.qty_maintenance > 0 && (
                <Badge variant="outline" className="text-[10px] font-bold px-2 py-1 flex items-center gap-1 bg-amber-50 border-amber-200 text-amber-700 shadow-sm transition-all hover:scale-105">
                    <span className="opacity-60 tabular-nums">{item.qty_maintenance}×</span> MAINT.
                </Badge>
            )}
            {item.qty_lost > 0 && (
                <Badge variant="outline" className="text-[10px] font-bold px-2 py-1 flex items-center gap-1 bg-slate-50 border-slate-200 text-slate-600 shadow-sm transition-all hover:scale-105">
                    <span className="opacity-60 tabular-nums">{item.qty_lost}×</span> LOST
                </Badge>
            )}

            {/* PENDING REQUEST ALERT */}
            {hasPendingRequests && (
                <Popover open={isInternalOpen} onOpenChange={(open) => {
                    setIsInternalOpen(open)
                    if (open) fetchPending()
                }}>
                    <PopoverTrigger asChild>
                        <button
                            onClick={(e) => e.stopPropagation()}
                            className="inline-flex items-center gap-1 px-2 py-1 rounded-lg text-[10px] font-bold bg-blue-50 border border-blue-200 text-blue-700 hover:bg-blue-100 transition-all duration-200 shadow-sm shrink-0"
                        >
                            <Clock className="h-3 w-3 text-blue-600" />
                            {pendingCount} PENDING
                            <ChevronDown className={`h-2.5 w-2.5 transition-transform duration-200 ${isInternalOpen ? 'rotate-180' : ''}`} />
                        </button>
                    </PopoverTrigger>
                    <PopoverContent 
                        side="bottom" 
                        align="start" 
                        className="w-[300px] p-0 rounded-xl overflow-hidden shadow-2xl border-blue-200 z-[100]"
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className="flex items-center gap-2 px-4 py-3 bg-blue-50/50 border-b border-blue-100">
                            <Clock className="h-3.5 w-3.5 text-blue-600" />
                            <h4 className="text-xs font-bold text-blue-900 uppercase">Approval Queue</h4>
                        </div>
                        <div className="max-h-[250px] overflow-y-auto p-2 space-y-1">
                            {isLoadingPending ? (
                                <div className="flex items-center justify-center py-6 text-xs text-blue-700">
                                    <div className="h-4 w-4 animate-spin rounded-full border-2 border-blue-500 border-t-transparent mr-2" />
                                    Loading...
                                </div>
                            ) : pendingRequests.map((request) => (
                                <div key={request.id} className="p-2 rounded-lg bg-white border border-blue-100/40 flex items-center justify-between">
                                    <div className="min-w-0">
                                        <p className="text-[12px] font-bold text-gray-900 truncate">{request.borrower_name}</p>
                                        <p className="text-[11px] text-gray-500">{request.quantity} Units</p>
                                    </div>
                                    <Badge variant="outline" className="text-[9px] bg-blue-50 text-blue-700">RESERVED</Badge>
                                </div>
                            ))}
                        </div>
                    </PopoverContent>
                </Popover>
            )}
        </div>
    )
}
