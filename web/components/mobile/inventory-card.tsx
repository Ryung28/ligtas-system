'use client'

import React from 'react'
import Image from 'next/image'
import { useRouter } from 'next/navigation'
import { Package, AlertTriangle, CheckCircle2, XCircle } from 'lucide-react'
import { cn } from '@/lib/utils'

interface InventoryCardProps {
    item: {
        id: string | number
        item_name: string
        category?: string
        stock_available: number
        stock_total?: number
        status?: string
        image_url?: string | null
    }
}

/**
 * 📱 LIGTAS Mobile Inventory Card
 * 🏛️ ARCHITECTURE: "Visual Inventory Unit"
 * Designed for quick scanning of stock levels and operational readiness.
 */
export function InventoryCard({ item }: InventoryCardProps) {
    const router = useRouter()
    
    // Status Logic
    const available = item.stock_available || 0
    const total = item.stock_total || 1
    const ratio = available / total
    
    let statusLabel = 'In Stock'
    let statusColor = 'bg-green-50 text-green-700 border-green-100'
    let StatusIcon = CheckCircle2

    if (available === 0 || item.status === 'Out of Stock') {
        statusLabel = 'Out of Stock'
        statusColor = 'bg-red-50 text-red-700 border-red-100'
        StatusIcon = XCircle
    } else if (ratio < 0.5 || item.status === 'Low') {
        statusLabel = 'Low Stock'
        statusColor = 'bg-amber-50 text-amber-700 border-amber-100'
        StatusIcon = AlertTriangle
    }

    return (
        <div 
            onClick={() => router.push(`/m/inventory/${item.id}`)}
            className="bg-white rounded-2xl border border-gray-100 overflow-hidden shadow-sm flex flex-col active:scale-[0.98] transition-all"
        >
            {/* 1. Visual Anchor (Image) */}
            <div className="relative h-40 bg-gray-50 flex items-center justify-center">
                {item.image_url ? (
                    <Image 
                        src={item.image_url} 
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
                
                {/* Overlay Badge for Category */}
                <div className="absolute top-3 left-3">
                    <span className="px-2.5 py-1 bg-white/90 backdrop-blur-sm rounded-lg text-[10px] font-black text-gray-900 border border-white/20 shadow-sm uppercase tracking-tighter">
                        {item.category || 'General'}
                    </span>
                </div>
            </div>

            {/* 2. Information Field */}
            <div className="p-4 space-y-3">
                <div className="space-y-1">
                    <h3 className="font-bold text-gray-900 leading-tight line-clamp-2">
                        {item.item_name}
                    </h3>
                </div>

                <div className="flex items-center justify-between gap-2 pt-1">
                    <div className="flex flex-col">
                        <span className="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Available</span>
                        <p className="text-lg font-black text-gray-900 tabular-nums">
                            {available} <span className="text-gray-300 font-medium text-xs">/ {total}</span>
                        </p>
                    </div>

                    <div className={cn(
                        "px-3 py-1.5 rounded-xl border flex items-center gap-1.5",
                        statusColor
                    )}>
                        <StatusIcon className="w-3.5 h-3.5" />
                        <span className="text-[11px] font-bold whitespace-nowrap">{statusLabel}</span>
                    </div>
                </div>
            </div>
        </div>
    )
}
