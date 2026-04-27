'use client'

import React from 'react'
import { AggregatedInventoryItem } from '../../types'
import { ShieldAlert, Wrench, MapPin, Clock, AlertTriangle, Boxes, Info } from 'lucide-react'
import { cn } from '@/lib/utils'
import { getExpiryInfo } from '@/lib/expiry-utils'

interface AssetStatusSummaryProps {
    item: AggregatedInventoryItem
    className?: string
}

/**
 * 🏛️ ASSET STATUS SUMMARY (MINIGRID SSOT)
 * Shared component for mobile popovers and web expansion.
 * Consolidates Distribution, Alerts, and Packaging logic.
 */
export function AssetStatusSummary({ item, className }: AssetStatusSummaryProps) {
    const variants = item.variants || []
    const expiry = getExpiryInfo((item as any).expiry_date, (item as any).expiry_alert_days)
    const hasExpiryAlert = ['expired', 'critical', 'warning'].includes(expiry.status)
    const isLowStock = item.stock_available <= (item.stock_total * 0.2) // Simplified check for summary
    const packaging = (item as any).packaging_json
    const hasPackaging = packaging?.enabled && packaging.batches?.length > 0

    if (variants.length === 0 && !hasExpiryAlert && !hasPackaging) return null

    return (
        <div className={cn("flex flex-col w-full bg-white overflow-hidden", className)}>
            {/* 1. DISTRIBUTION SECTION (The "Minigrid") */}
            <div className="p-3 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                <h4 className="text-[10px] font-black text-slate-900 uppercase tracking-widest flex items-center gap-2">
                    <MapPin className="w-3 h-3 text-blue-600" />
                    Tactical Distribution
                </h4>
                <div className="text-[9px] font-black text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full">
                    {variants.length || 1} SITES
                </div>
            </div>

            <div className="max-h-[240px] overflow-y-auto p-2 space-y-1 custom-scrollbar">
                {variants.length > 0 ? (
                    variants.map((variant) => (
                        <div
                            key={variant.id}
                            className="flex flex-col p-3 bg-slate-50/30 rounded-xl border border-slate-100/50 space-y-2 hover:bg-slate-50 transition-colors"
                        >
                            <div className="flex items-center justify-between">
                                <p className="text-[10px] font-black text-slate-900 uppercase tracking-tight truncate pr-4">
                                    {variant.location?.replace(/_/g, ' ') || 'SEC-ALPHA'}
                                </p>
                                <div className="text-right shrink-0">
                                    <p className={cn(
                                        "text-[13px] font-black tabular-nums leading-none",
                                        variant.stock_available === 0 ? "text-rose-600" : "text-slate-900"
                                    )}>
                                        {variant.stock_available}
                                        <span className="text-[9px] text-slate-300 ml-1">/ {variant.stock_total}</span>
                                    </p>
                                </div>
                            </div>

                            {(variant.qty_damaged > 0 || variant.qty_maintenance > 0) && (
                                <div className="pt-2 border-t border-slate-200/30 flex gap-3">
                                    {variant.qty_damaged > 0 && (
                                        <span className="flex items-center gap-1 text-[8px] font-black uppercase text-rose-600">
                                            <ShieldAlert className="w-2.5 h-2.5" />
                                            {variant.qty_damaged} Damaged
                                        </span>
                                    )}
                                    {variant.qty_maintenance > 0 && (
                                        <span className="flex items-center gap-1 text-[8px] font-black uppercase text-amber-600">
                                            <Wrench className="w-2.5 h-2.5" />
                                            {variant.qty_maintenance} Maint
                                        </span>
                                    )}
                                </div>
                            )}
                        </div>
                    ))
                ) : (
                    <div className="p-4 text-center">
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">No distribution data</p>
                    </div>
                )}
            </div>

            {/* 2. ALERTS SECTION (Expiry/Stock) */}
            {(hasExpiryAlert || isLowStock) && (
                <div className="p-2 border-t border-slate-100 bg-white space-y-1">
                    <p className="px-2 py-1 text-[8px] font-black text-slate-400 uppercase tracking-[0.15em]">Health & Alerts</p>
                    <div className="grid grid-cols-1 gap-1">
                        {hasExpiryAlert && (
                            <div className={cn(
                                "flex items-center justify-between p-2 rounded-xl border",
                                (expiry.status === 'expired' || expiry.status === 'critical') ? "bg-rose-50/50 border-rose-100" : "bg-amber-50/50 border-amber-100"
                            )}>
                                <div className="flex items-center gap-2">
                                    <Clock className={cn("h-3 w-3", (expiry.status === 'expired' || expiry.status === 'critical') ? "text-rose-500" : "text-amber-500")} />
                                    <span className="text-[10px] font-black text-slate-900 uppercase tracking-tight">{expiry.label}</span>
                                </div>
                                <div className={cn("h-1.5 w-1.5 rounded-full animate-pulse", (expiry.status === 'expired' || expiry.status === 'critical') ? "bg-rose-500" : "bg-amber-500")} />
                            </div>
                        )}
                        {isLowStock && item.stock_available > 0 && (
                            <div className="flex items-center gap-2 p-2 rounded-xl bg-amber-50/50 border border-amber-100">
                                <AlertTriangle className="h-3 w-3 text-amber-500" />
                                <span className="text-[10px] font-black text-slate-900 uppercase tracking-tight">Low Stock Warning</span>
                            </div>
                        )}
                    </div>
                </div>
            )}

            {/* 3. PACKAGING SECTION */}
            {hasPackaging && (
                <div className="p-2 border-t border-slate-100 bg-slate-50/30">
                    <p className="px-2 py-1 text-[8px] font-black text-slate-400 uppercase tracking-[0.15em]">Packaging Batches</p>
                    <div className="p-1 space-y-1">
                        {packaging.batches.slice(0, 3).map((batch: any) => (
                            <div key={batch.id} className="flex justify-between items-center px-2 py-1.5 rounded-lg bg-white border border-slate-100">
                                <div className="flex items-center gap-2">
                                    <Boxes className="h-2.5 w-2.5 text-blue-600" />
                                    <span className="text-[9px] font-bold text-slate-600 uppercase tracking-tight truncate max-w-[120px]">{batch.label}</span>
                                </div>
                                <span className="text-[10px] font-black text-slate-900 tabular-nums">{batch.units}u</span>
                            </div>
                        ))}
                    </div>
                </div>
            )}

            <div className="p-2 border-t border-slate-50 bg-slate-50/50">
                <p className="text-[8px] font-bold text-slate-400 uppercase tracking-tighter text-center">
                    Data synchronized with regional HQ
                </p>
            </div>
        </div>
    )
}
