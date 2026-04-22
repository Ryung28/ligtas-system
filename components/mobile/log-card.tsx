import React from 'react'
import { ArrowUpRight, ArrowDownLeft, AlertCircle, Clock, Calendar, Users, Package, MapPin } from 'lucide-react'
import { cn } from '@/lib/utils'
import { formatDistanceToNow, format, differenceInDays } from 'date-fns'
import Link from 'next/link'
import Image from 'next/image'
import { BorrowSession } from '@/lib/types/inventory'
import { getInventoryImageUrl } from '@/lib/supabase'

interface LogCardProps {
    session: BorrowSession
}

/**
 * 📱 ResQTrack Mobile Session Ledger Card
 * 🏛️ ARCHITECTURE: "The Transaction Triage Card"
 * Full parity with web borrowing sessions, including images and deep audit dates.
 */
export function LogCard({ session }: LogCardProps) {
    const isReturned = session.status === 'returned'
    const isOverdue = session.status === 'overdue'
    const isMixed = session.status === 'mixed'
    
    // Get primary image from the first item (Hydrated via getBorrowLogsAction)
    const firstItem = session.items[0]
    const rawImageUrl = (firstItem as any).inventory?.image_url
    const imageUrl = rawImageUrl ? getInventoryImageUrl(rawImageUrl) : null

    let statusConfig = {
        label: 'BORROWED',
        color: 'text-blue-600 bg-blue-50 border-blue-100',
        icon: ArrowUpRight,
        ring: 'ring-blue-500/10'
    }
    
    if (isReturned) {
        statusConfig = {
            label: 'RETURNED',
            color: 'text-emerald-600 bg-emerald-50 border-emerald-100',
            icon: ArrowDownLeft,
            ring: 'ring-emerald-500/10'
        }
    } else if (isOverdue) {
        statusConfig = {
            label: 'LATE',
            color: 'text-rose-600 bg-rose-50 border-rose-100',
            icon: AlertCircle,
            ring: 'ring-rose-500/20'
        }
    } else if (isMixed) {
        statusConfig = {
            label: 'MIXED',
            color: 'text-amber-600 bg-amber-50 border-amber-100',
            icon: Clock,
            ring: 'ring-amber-500/10'
        }
    }

    const timeAgo = formatDistanceToNow(new Date(session.created_at), { addSuffix: true })
    const daysOverdue = isOverdue && firstItem.expected_return_date 
        ? differenceInDays(new Date(), new Date(firstItem.expected_return_date)) 
        : 0

    return (
        <div className={cn(
            "bg-white border rounded-[1.5rem] p-4 transition-all active:scale-[0.98] shadow-sm relative overflow-hidden",
            isOverdue ? "border-rose-200 bg-rose-50/20" : "border-gray-100"
        )}>
            {/* 🚨 Overdue Pulse Indicator */}
            {isOverdue && (
                <div className="absolute top-0 right-0 w-32 h-6 bg-rose-600 text-white text-[9px] font-black italic flex items-center justify-center rotate-[25deg] translate-x-12 translate-y-2 shadow-sm uppercase tracking-widest z-10">
                    Overdue
                </div>
            )}

            {/* Header: Identity & Master Status */}
            <div className="flex items-start gap-4 mb-4">
                {/* 🖼️ Hero Thumbnail with Preview Linkage */}
                <div className={cn(
                    "relative w-16 h-16 rounded-2xl overflow-hidden shrink-0 border-2 bg-gray-50 flex items-center justify-center ring-4",
                    statusConfig.ring,
                    imageUrl ? "border-white" : "border-gray-100"
                )}>
                    {imageUrl ? (
                        <Image 
                            src={imageUrl} 
                            alt={session.borrower_name} 
                            fill 
                            className="object-cover"
                            sizes="64px"
                        />
                    ) : (
                        <Package className="w-8 h-8 text-gray-200" />
                    )}
                </div>

                <div className="flex-1 min-w-0 py-0.5">
                    <div className="flex items-center justify-between mb-1">
                        <span className={cn(
                            "inline-flex items-center gap-1 px-2 py-0.5 rounded-lg border text-[9px] font-black uppercase tracking-tighter",
                            statusConfig.color
                        )}>
                            <statusConfig.icon className="w-2.5 h-2.5" />
                            {statusConfig.label}
                        </span>
                        <span className="text-[9px] font-bold text-gray-400 uppercase tabular-nums">
                            {timeAgo}
                        </span>
                    </div>
                    <h4 className="font-black text-gray-900 text-base leading-tight uppercase tracking-tight truncate">
                        {session.borrower_name}
                    </h4>
                    <div className="flex items-center gap-1.5 text-[10px] text-gray-400 font-bold uppercase tracking-widest mt-1">
                        <Users className="w-2.5 h-2.5" />
                        {session.borrower_organization || "Field Ops"}
                    </div>
                </div>
            </div>

            {/* 📋 Itemized High-Density List */}
            <div className="space-y-1.5 py-3 border-y border-gray-100/50 bg-gray-50/30 -mx-4 px-4">
                {session.items.map((item, idx) => (
                    <div key={idx} className="flex items-center justify-between gap-4">
                        <div className="flex items-center gap-2 min-w-0">
                            <div className="w-1.5 h-1.5 rounded-full bg-gray-200 shrink-0" />
                            <p className="text-xs font-bold text-gray-900 truncate leading-none">
                                {item.item_name}
                            </p>
                        </div>
                        <span className="text-[11px] font-black text-gray-500 tabular-nums">
                            ×{item.quantity}
                        </span>
                    </div>
                ))}
            </div>

            {/* 🕰️ The Audit Bar: Chronological Integrity */}
            <div className="grid grid-cols-2 gap-2 mt-4">
                <div className="bg-gray-50/50 rounded-xl p-2 border border-gray-100">
                    <p className="text-[8px] font-black text-gray-400 uppercase tracking-widest mb-1">Borrowed Date</p>
                    <div className="flex items-center gap-1.5">
                        <Calendar className="w-3 h-3 text-blue-500" />
                        <span className="text-[10px] font-black text-gray-900 uppercase">
                            {format(new Date(session.created_at), 'MMM dd, HH:mm')}
                        </span>
                    </div>
                </div>

                <div className={cn(
                    "rounded-xl p-2 border",
                    isOverdue ? "bg-rose-50 border-rose-100" : "bg-gray-50/50 border-gray-100"
                )}>
                    <p className="text-[8px] font-black text-gray-400 uppercase tracking-widest mb-1">
                        {isReturned ? "Returned Date" : "Expected Return"}
                    </p>
                    <div className="flex items-center gap-1.5">
                        <Clock className={cn("w-3 h-3", isOverdue ? "text-rose-500 animate-pulse" : "text-emerald-500")} />
                        <span className={cn(
                            "text-[10px] font-black uppercase",
                            isOverdue ? "text-rose-700" : "text-gray-900"
                        )}>
                            {isReturned && firstItem.actual_return_date ? (
                                format(new Date(firstItem.actual_return_date), 'MMM dd, HH:mm')
                            ) : firstItem.expected_return_date ? (
                                format(new Date(firstItem.expected_return_date), 'MMM dd')
                            ) : "Permanent"}
                        </span>
                    </div>
                </div>
            </div>

            {/* Secondary Metadata */}
            <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100/30">
                <div className="flex items-center gap-1.5 text-[9px] font-bold text-gray-400 uppercase">
                    <MapPin className="w-3 h-3" />
                    From: {(firstItem as any).borrowed_from_warehouse || "Central Depot"}
                </div>
                {isOverdue && (
                   <span className="text-[9px] font-black text-rose-600 uppercase tracking-tighter bg-rose-100/50 px-2 py-0.5 rounded-full">
                       {daysOverdue}D EXPIRED
                   </span>
                )}
            </div>
        </div>
    )
}
