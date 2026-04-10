'use client'

import React from 'react'
import { Package, RefreshCw, AlertCircle, Clock, CheckCircle2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { formatDistanceToNow } from 'date-fns'

interface LogCardProps {
    log: {
        id: string | number
        item_name: string
        borrower_name: string
        quantity: number
        status: string
        borrow_date?: string
        return_date?: string
        created_at: string
    }
}

/**
 * 📱 LIGTAS Mobile Log Card (Timeline Entry)
 * 🏛️ ARCHITECTURE: "Event Ledger Record"
 * High-signal timeline entry for tracking logistical movements.
 */
export function LogCard({ log }: LogCardProps) {
    const isReturned = log.status === 'returned'
    const isOverdue = log.status === 'overdue'
    const isPending = log.status === 'pending'
    
    let statusColor = 'bg-blue-50 text-blue-600 border-blue-100'
    let StatusIcon = Package
    
    if (isReturned) {
        statusColor = 'bg-green-50 text-green-600 border-green-100'
        StatusIcon = RefreshCw
    } else if (isOverdue) {
        statusColor = 'bg-red-50 text-red-600 border-red-100'
        StatusIcon = AlertCircle
    } else if (isPending) {
        statusColor = 'bg-amber-50 text-amber-600 border-amber-100'
        StatusIcon = Clock
    }

    const dateDisplay = formatDistanceToNow(new Date(log.borrow_date || log.created_at), { addSuffix: true })

    return (
        <div className="relative pl-8 pb-8 last:pb-0">
            {/* Timeline Vertical Line Connector */}
            <div className="absolute left-4 top-0 bottom-0 w-px bg-gray-100" />
            
            {/* Timeline Dot/Icon */}
            <div className={cn(
                "absolute left-0 w-8 h-8 rounded-full border-2 border-white flex items-center justify-center z-10 shadow-sm",
                statusColor
            )}>
                <StatusIcon className="w-4 h-4" />
            </div>

            {/* Event Content */}
            <div className="bg-white rounded-2xl border border-gray-100 p-4 shadow-sm space-y-2 active:scale-[0.99] transition-all">
                <div className="flex items-start justify-between gap-4">
                    <div className="space-y-0.5">
                        <h4 className="font-bold text-gray-900 text-sm leading-tight">
                            {log.item_name}
                        </h4>
                        <p className="text-xs text-gray-500 font-medium">
                            {log.borrower_name}
                        </p>
                    </div>
                    <div className="shrink-0 text-right">
                        <span className="text-[10px] font-black text-gray-900 tabular-nums bg-gray-50 px-2 py-1 rounded-lg border border-gray-100">
                            ×{log.quantity}
                        </span>
                    </div>
                </div>

                <div className="flex items-center justify-between pt-1 border-t border-gray-50 mt-1">
                    <div className="flex items-center gap-1.5">
                        <span className={cn(
                            "text-[10px] font-bold uppercase tracking-widest px-1.5 py-0.5 rounded",
                            statusColor
                        )}>
                            {log.status}
                        </span>
                    </div>
                    <span className="text-[10px] text-gray-400 font-medium italic">
                        {dateDisplay}
                    </span>
                </div>
            </div>
        </div>
    )
}
