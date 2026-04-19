'use client'

import React from 'react'
import Image from 'next/image'
import { useRouter } from 'next/navigation'
import { Package, AlertTriangle, CheckCircle2, XCircle, MapPin, Clock } from 'lucide-react'
import { cn } from '@/lib/utils'
import { getInventoryImageUrl } from '@/lib/supabase'
import { isLowStock } from '@/src/features/inventory/utils'
import { getExpiryInfo } from '@/lib/expiry-utils'

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
    }
}

export function MobileInventoryCard({ item }: MobileInventoryCardProps) {
    const router = useRouter()
    
    // Status Logic
    const available = item.stock_available || 0
    const total = item.stock_total || 1
    const imageUrl = item.image_url ? getInventoryImageUrl(item.image_url) : null;
    const isAlert = isLowStock(item as any)
    const needsRepair = (item.qty_damaged || 0) > 0 || (item.qty_maintenance || 0) > 0
    const expiry = getExpiryInfo(item.expiry_date, item.expiry_alert_days)
    const hasExpiryAlert = expiry.status === 'expired' || expiry.status === 'critical' || expiry.status === 'warning'
    
    let statusLabel = 'In Stock'
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

    return (
        <div 
            onClick={() => router.push(`/m/inventory/${item.id}`)}
            className={cn(
                "bg-white rounded-2xl border overflow-hidden shadow-sm flex flex-col active:scale-[0.98] transition-all",
                available === 0 ? "border-red-200" :
                isAlert ? "border-amber-200" :
                (expiry.status === 'expired' || expiry.status === 'critical') ? "border-red-200" :
                expiry.status === 'warning' ? "border-amber-200" :
                "border-gray-100"
            )}
        >
            <div className="relative h-40 bg-gray-50 flex items-center justify-center">
                {imageUrl ? (
                    <Image 
                        src={imageUrl} 
                        alt={item.item_name} 
                        fill
                        className="object-cover"
                        sizes="(max-width: 768px) 100vw, 33vw"
                    />
                ) : (
                    <div className="flex flex-col items-center gap-2 text-gray-300">
                        <Package className="w-12 h-12 stroke-[1.5]" />
                        <span className="text-[10px] font-bold uppercase tracking-widest">No Image</span>
                    </div>
                )}
                
                <div className="absolute top-3 left-3 flex flex-col gap-1.5">
                    <span className="px-2.5 py-1 bg-white/90 backdrop-blur-sm rounded-lg text-[10px] font-black text-gray-900 border border-white/20 shadow-sm uppercase tracking-tighter">
                        {item.category || 'General'}
                    </span>
                    {item.is_multi_location && (
                        <span className="px-2.5 py-1 bg-gray-900/90 backdrop-blur-sm rounded-lg text-[9px] font-black text-white border border-white/10 shadow-sm uppercase tracking-tighter flex items-center gap-1">
                            <MapPin className="w-2.5 h-2.5" />
                            Multi-Site
                        </span>
                    )}
                    {hasExpiryAlert && (
                        <span className={cn(
                            "px-3 py-1.5 min-h-7 backdrop-blur-sm rounded-lg text-[10px] font-black border shadow-sm uppercase tracking-tight flex items-center gap-1.5",
                            expiry.badgeClass
                        )}>
                            <Clock className="h-3.5 w-3.5" strokeWidth={2.5} />
                            {expiry.label}
                        </span>
                    )}
                </div>
            </div>

            <div className="p-4 space-y-3">
                <div className="space-y-1">
                    <h3 className="font-bold text-gray-900 leading-tight line-clamp-2">
                        {item.item_name}
                    </h3>
                    <p className="text-[10px] text-gray-400 font-bold uppercase tracking-widest flex items-center gap-1">
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
                    
                    <div className="flex items-center justify-between border-t border-gray-50 pt-2">
                        <span className="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Stock</span>
                        <p className="text-base font-black text-gray-900 tabular-nums">
                            {available} <span className="text-gray-300 font-medium text-[10px]">/ {total}</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    )
}
