'use client'

import React from 'react'
import Image from 'next/image'
import { useRouter } from 'next/navigation'
import { Package, AlertTriangle, CheckCircle2, XCircle, MapPin, Clock, Info, PackageX } from 'lucide-react'
import { cn } from '@/lib/utils'
import { getInventoryImageUrl } from '@/lib/supabase'
import { isLowStock } from '@/src/features/inventory/utils'
import { getExpiryInfo } from '@/lib/expiry-utils'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'

interface MobileInventoryCardProps {
    item: {
        id: string | number
        item_name: string
        category?: string
        stock_available: number
        stock_total?: number
        status?: string
        image_url?: string | null
        is_multi_location?: boolean
        primary_location?: string
        qty_damaged?: number
        qty_maintenance?: number
        expiry_date?: string | null
        expiry_alert_days?: number | null
        variants?: any[]
    }
    onImageClick?: (url: string, name: string) => void
    isSelected?: boolean
    selectionMode?: boolean
    onSelect?: (item: any) => void
}

export const MobileInventoryCard = React.memo(function MobileInventoryCard({ 
    item, 
    onImageClick,
    isSelected,
    selectionMode,
    onSelect
}: MobileInventoryCardProps) {
    const router = useRouter()

    // ... (rest of the component logic)
    const available = item.stock_available || 0
    const total = item.stock_total || 1
    const isAlert = isLowStock(item as any)
    const needsRepair = (item.qty_damaged || 0) > 0 || (item.qty_maintenance || 0) > 0
    const expiry = getExpiryInfo(item.expiry_date, item.expiry_alert_days)
    const hasExpiryAlert = expiry.status === 'expired' || expiry.status === 'critical' || expiry.status === 'warning'

    let statusLabel = 'Operational'
    let statusColor = 'bg-green-50 text-green-700 border-green-100'
    let StatusIcon = CheckCircle2

    if (available === 0 || item.status === 'Out of Stock') {
        statusLabel = 'Out of Stock'
        statusColor = 'bg-red-50 text-red-700 border-red-100'
        StatusIcon = XCircle
    } else if (needsRepair) {
        statusLabel = 'Needs Maintenance'
        statusColor = 'bg-amber-50 text-amber-700 border-amber-100'
        StatusIcon = AlertTriangle
    } else if (isAlert || item.status === 'Low') {
        statusLabel = 'Low Stock'
        statusColor = 'bg-amber-50 text-amber-700 border-amber-100'
        StatusIcon = AlertTriangle
    }

    const handleClick = () => {
        if (selectionMode && onSelect) {
            onSelect(item)
            return
        }
        router.push(`/m/inventory/${item.id}`)
    }

    return (
        <div
            onClick={handleClick}
            className={cn(
                "relative bg-white rounded-[24px] border overflow-hidden shadow-sm flex flex-col active:scale-[0.98] transition-all cursor-pointer",
                isSelected ? "ring-2 ring-slate-950 border-transparent shadow-md" : (
                    available === 0 ? "border-red-200" :
                        isAlert ? "border-amber-200" :
                            (expiry.status === 'expired' || expiry.status === 'critical') ? "border-red-200" :
                                expiry.status === 'warning' ? "border-amber-200" :
                                    "border-gray-100"
                ),
                (selectionMode && available === 0) && "grayscale opacity-60 pointer-events-auto"
            )}
        >
            {/* Selection Checkmark */}
            {selectionMode && (
                <div className={cn(
                    "absolute top-3 right-3 z-20 w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all",
                    available === 0 ? "bg-gray-100 border-gray-200" : (
                        isSelected 
                            ? "bg-slate-950 border-slate-950 scale-110 shadow-lg" 
                            : "bg-white/40 backdrop-blur-sm border-white/60"
                    )
                )}>
                    {isSelected && <CheckCircle2 className="w-4 h-4 text-white" />}
                    {(available === 0 && !isSelected) && <XCircle className="w-4 h-4 text-gray-400" />}
                </div>
            )}

            <div className="relative h-40 bg-gray-50 flex items-center justify-center overflow-hidden">
                <div
                    onClick={(e) => {
                        e.stopPropagation()
                        if (selectionMode) {
                            handleClick()
                            return
                        }
                        const fullUrl = item.image_url ? getInventoryImageUrl(item.image_url) : null
                        if (fullUrl && onImageClick) onImageClick(fullUrl, item.item_name)
                    }}
                    className="w-full h-full active:scale-95 transition-transform"
                >
                    <TacticalAssetImage
                        url={item.image_url}
                        alt={item.item_name}
                        size="full"
                        className="object-cover"
                    />
                </div>

                <div className="absolute top-3 left-3 flex flex-col gap-1.5 pointer-events-auto">
                    {(selectionMode && available === 0) ? (
                        <div className="px-2.5 py-1 bg-red-600 rounded-lg text-[9px] font-black text-white shadow-sm uppercase tracking-tighter flex items-center gap-1 w-fit">
                            <PackageX className="w-2.5 h-2.5" />
                            Zero Stock
                        </div>
                    ) : (
                        <div className="px-2.5 py-1 bg-white/90 backdrop-blur-sm rounded-lg text-[10px] font-black text-slate-950 border border-white/20 shadow-sm uppercase tracking-tighter w-fit">
                            {item.category || 'General'}
                        </div>
                    )}

                    {(item.is_multi_location && available > 0) && (
                        <span className="px-2.5 py-1 bg-gray-900/90 backdrop-blur-sm rounded-lg text-[9px] font-black text-white border border-white/10 shadow-sm uppercase tracking-tighter flex items-center gap-1 w-fit">
                            <MapPin className="w-2.5 h-2.5" />
                            Multi-Site
                        </span>
                    )}

                    {hasExpiryAlert && (
                        <div 
                            className={cn(
                                "px-3 py-1.5 min-h-7 backdrop-blur-sm rounded-lg text-[10px] font-black border shadow-sm uppercase tracking-tight flex items-center gap-1.5 w-fit",
                                expiry.badgeClass
                            )}
                        >
                            <Clock className="h-3.5 w-3.5" strokeWidth={2.5} />
                            {expiry.label}
                        </div>
                    )}
                </div>
            </div>

            <div className="p-4 space-y-3">
                <div className="space-y-1">
                    <h3 className="font-bold text-slate-950 leading-tight line-clamp-1 tracking-tight text-[14px]">
                        {item.item_name}
                    </h3>
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest flex items-center gap-1">
                        <MapPin className="w-2.5 h-2.5" />
                        {item.primary_location || 'Central Depot'}
                    </p>
                </div>

                <div className="flex flex-col gap-2 pt-1">
                    <div className={cn(
                        "px-3 py-1.5 rounded-xl border flex items-center gap-1.5 w-fit",
                        statusColor
                    )}>
                        <StatusIcon className="w-3.5 h-3.5" />
                        <span className="text-[11px] font-bold whitespace-nowrap">{statusLabel}</span>
                    </div>

                    <div className="flex items-center justify-between border-t border-slate-50 pt-2">
                        <span className="text-[10px] text-slate-400 font-bold uppercase tracking-wider">Stock</span>
                        <p className="text-base font-black text-slate-950 tabular-nums">
                            {available} <span className="text-slate-300 font-medium text-[10px]">/ {total}</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    )
})


