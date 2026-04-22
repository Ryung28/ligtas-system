"use client"

import { Boxes, Clock, AlertTriangle, ChevronRight, Info, AlertCircle } from 'lucide-react'
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { cn } from '@/lib/utils'
import { PackagingPill } from './packaging-pill'
import { Badge } from '@/components/ui/badge'

interface UnifiedStatusHubProps {
    item: any
    expiry?: {
        label: string
        status: string
        badgeClass: string
    }
    stockStatus?: {
        label: string
        isProblematic: boolean
    }
    className?: string
}

export function UnifiedStatusHub({ item, expiry, stockStatus, className }: UnifiedStatusHubProps) {
    const packaging = (item as any).packaging_json
    const hasPackaging = packaging?.enabled && packaging.batches?.length > 0
    const hasExpiry = expiry?.status && ['expired', 'critical', 'warning'].includes(expiry.status)
    const hasStockAlert = stockStatus?.isProblematic

    const activeIndicators = [
        hasExpiry && { type: 'expiry', data: expiry },
        hasStockAlert && { type: 'stock', data: stockStatus },
        hasPackaging && { type: 'logistics', data: packaging }
    ].filter(Boolean) as any[]

    const count = activeIndicators.length

    if (count === 0) return null

    // SCENARIO 1: SINGLE ITEM (Detailed View)
    if (count === 1) {
        const indicator = activeIndicators[0]
        if (indicator.type === 'logistics') {
            return <PackagingPill packaging={packaging} className={className} />
        }
        if (indicator.type === 'expiry') {
            return (
                <Badge className={cn(
                    "text-[10px] font-black tracking-tight px-2.5 min-h-6 h-6 py-0 border flex items-center gap-1.5 rounded-md whitespace-nowrap",
                    expiry?.badgeClass,
                    className
                )}>
                    <Clock className="h-3.5 w-3.5 shrink-0" strokeWidth={2.5} />
                    {expiry?.label}
                </Badge>
            )
        }
        if (indicator.type === 'stock') {
            return (
                <Badge className={cn(
                    "text-[8px] font-black tracking-tighter px-1 h-4 whitespace-nowrap",
                    stockStatus?.label === 'OUT OF STOCK' ? "bg-rose-500 text-white" : "bg-amber-500 text-white",
                    className
                )}>
                    {stockStatus?.label}
                </Badge>
            )
        }
    }

    // SCENARIO 2: MULTIPLE ITEMS (Collapsed Hub)
    const topSeverityStatus = hasExpiry 
        ? (expiry?.status === 'expired' ? 'error' : 'warning')
        : (hasStockAlert ? 'warning' : 'info')

    return (
        <Popover>
            <PopoverTrigger asChild>
                <button 
                    className={cn(
                        "inline-flex items-center gap-1.5 px-2 py-1 rounded-md border shadow-sm transition-all group",
                        topSeverityStatus === 'error' ? "bg-rose-50 border-rose-100" :
                        topSeverityStatus === 'warning' ? "bg-amber-50 border-amber-100" :
                        "bg-white border-gray-200 hover:bg-gray-50",
                        className
                    )}
                >
                    <div className="relative">
                        <Info className={cn(
                            "h-3 w-3",
                            topSeverityStatus === 'error' ? "text-rose-500" :
                            topSeverityStatus === 'warning' ? "text-amber-500" :
                            "text-gray-400 group-hover:text-gray-900"
                        )} />
                        <span className={cn(
                            "absolute -top-1.5 -right-1.5 flex h-3 w-3 items-center justify-center rounded-full text-[8px] font-black text-white",
                            topSeverityStatus === 'error' ? "bg-rose-600" : "bg-amber-600"
                        )}>
                            {count}
                        </span>
                    </div>
                    <span className={cn(
                        "text-[10px] font-black uppercase tracking-tight",
                        topSeverityStatus === 'error' ? "text-rose-700" :
                        topSeverityStatus === 'warning' ? "text-amber-700" :
                        "text-gray-900"
                    )}>
                        Alerts
                    </span>
                    <ChevronRight className="h-2.5 w-2.5 text-gray-400" />
                </button>
            </PopoverTrigger>
            <PopoverContent 
                side="bottom" 
                align="end" 
                className="w-80 p-0 rounded-2xl border-gray-200 bg-white shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200"
            >
                {/* Header: Unified Hub */}
                <div className="bg-gray-50 px-4 py-3 border-b border-gray-100 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <div className="h-6 w-6 rounded-lg bg-white flex items-center justify-center border border-gray-200 shadow-sm">
                             <AlertCircle className="h-3.5 w-3.5 text-gray-900" />
                        </div>
                        <span className="text-[11px] font-black text-gray-900 uppercase tracking-tight">Status Summary</span>
                    </div>
                    <Badge variant="outline" className="bg-white text-[9px] font-black h-5 border-gray-200 uppercase">{count} Alerts</Badge>
                </div>

                <div className="p-2 space-y-1 max-h-[400px] overflow-y-auto custom-scrollbar">
                    {/* CRITICAL ALERTS GROUP */}
                    {(hasExpiry || hasStockAlert) && (
                        <div className="space-y-1">
                            <p className="px-2 pt-1 pb-0.5 text-[8px] font-black text-gray-400 uppercase tracking-[0.1em]">Alerts</p>
                            
                            {hasExpiry && (
                                <div className={cn(
                                    "flex items-center justify-between p-2 rounded-xl border",
                                    expiry?.status === 'expired' ? "bg-rose-50/50 border-rose-100" : "bg-amber-50/50 border-amber-100"
                                )}>
                                    <div className="flex items-center gap-2.5">
                                        <div className={cn(
                                            "h-7 w-7 rounded-lg flex items-center justify-center border shadow-sm",
                                            expiry?.status === 'expired' ? "bg-white border-rose-200" : "bg-white border-amber-200"
                                        )}>
                                            <Clock className={cn("h-3.5 w-3.5", expiry?.status === 'expired' ? "text-rose-500" : "text-amber-500")} />
                                        </div>
                                        <div className="flex flex-col">
                                            <span className="text-[11px] font-black text-gray-950 uppercase tracking-tight leading-none">{expiry?.label}</span>
                                            <span className="text-[9px] font-bold text-gray-500 uppercase mt-0.5">Expiring Soon</span>
                                        </div>
                                    </div>
                                    <div className="h-2 w-2 rounded-full bg-rose-500 animate-pulse" />
                                </div>
                            )}

                            {hasStockAlert && (
                                <div className="flex items-center justify-between p-2 rounded-xl bg-amber-50/50 border border-amber-100">
                                    <div className="flex items-center gap-2.5">
                                        <div className="h-7 w-7 rounded-lg bg-white flex items-center justify-center border border-amber-200 shadow-sm">
                                            <AlertTriangle className="h-3.5 w-3.5 text-amber-500" />
                                        </div>
                                        <div className="flex flex-col">
                                            <span className="text-[11px] font-black text-gray-950 uppercase tracking-tight leading-none">{stockStatus?.label}</span>
                                            <span className="text-[9px] font-bold text-gray-500 uppercase mt-0.5">Stock Status</span>
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>
                    )}

                    {/* LOGISTICS DETAIL GROUP */}
                    {hasPackaging && (
                        <div className="space-y-1">
                            <p className="px-2 pt-2 pb-0.5 text-[8px] font-black text-slate-400 uppercase tracking-[0.1em]">Packaging</p>
                            <div className="p-1 rounded-xl bg-slate-50/50 border border-slate-100">
                                <div className="px-3 py-2 flex items-center justify-between border-b border-white/50">
                                    <div className="flex items-center gap-2">
                                        <div className="h-5 w-5 rounded-md bg-white border border-slate-200 flex items-center justify-center shadow-sm">
                                            <Boxes className="h-3 w-3 text-blue-600" />
                                        </div>
                                        <span className="text-[10px] font-black text-slate-800 uppercase tracking-tight">
                                            {packaging.batches.length} {packaging.containerType || 'Box'}s Total
                                        </span>
                                    </div>
                                    <span className="text-[9px] font-black text-blue-600/60 uppercase tracking-widest italic">Breakdown</span>
                                </div>
                                <div className="p-1.5 space-y-1">
                                    {packaging.batches.map((batch: any) => (
                                        <div 
                                            key={batch.id} 
                                            className="flex justify-between items-center px-2 py-1.5 rounded-lg bg-white/40 border border-transparent hover:border-slate-200 hover:bg-white transition-all group"
                                        >
                                            <div className="flex items-center gap-2">
                                                <div className="h-1.5 w-1.5 rounded-full bg-blue-500 shadow-[0_0_6px_rgba(59,130,246,0.5)]" />
                                                <span className="text-[10px] font-bold text-slate-600 uppercase tracking-tight group-hover:text-slate-900 truncate max-w-[150px]">
                                                    {batch.label}
                                                </span>
                                            </div>
                                            <div className="flex items-baseline gap-1">
                                                <span className={cn(
                                                    "text-[12px] font-black tabular-nums",
                                                    batch.units > 0 ? "text-slate-900" : "text-slate-400"
                                                )}>
                                                    {batch.units}
                                                </span>
                                                {batch.max_units && (
                                                    <span className="text-[9px] font-bold text-slate-400">/ {batch.max_units}</span>
                                                )}
                                                <span className="text-[8px] font-black text-slate-300 uppercase ml-0.5 tracking-tight">Qty</span>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    )}
                </div>

                <div className="bg-gray-50/80 p-2 text-center border-t border-gray-100 mt-1">
                     <p className="text-[9px] font-black text-gray-400 flex items-center justify-center gap-1.5 opacity-80">
                        <Info className="h-3 w-3" />
                        Quick Summary
                     </p>
                </div>
            </PopoverContent>
        </Popover>
    )
}
