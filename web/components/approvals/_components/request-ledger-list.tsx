'use client'

import { BorrowLog } from '@/lib/types/inventory'
import { UserAvatar } from '@/components/ui/user-avatar'
import { formatDistanceToNow } from 'date-fns'
import { cn } from '@/lib/utils'
import { Package, Clock } from 'lucide-react'
import { getInventoryImageUrl } from '@/lib/supabase'
import Image from 'next/image'

interface RequestLedgerListProps {
    requests: BorrowLog[]
    selectedId: number | null
    onSelect: (request: BorrowLog) => void
}

function StatusBadge({ status }: { status: string }) {
    if (status === 'staged') {
        return (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-tight bg-emerald-50 text-emerald-600 border border-emerald-100">
                Ready
            </span>
        )
    }
    if (status === 'reserved') {
        return (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-tight bg-amber-50 text-amber-600 border border-amber-100">
                Reserved
            </span>
        )
    }
    // pending
    return (
        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-tight bg-blue-50 text-blue-600 border border-blue-100">
            Pending
        </span>
    )
}

export function RequestLedgerList({ requests, selectedId, onSelect }: RequestLedgerListProps) {
    if (requests.length === 0) {
        return (
            <div className="flex flex-col items-center justify-center h-full py-12 text-center px-8">
                <div className="h-12 w-12 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-center mb-3">
                    <Package className="h-6 w-6 text-slate-200" strokeWidth={1} />
                </div>
                <p className="text-[12px] font-bold text-slate-800">No active requests</p>
                <p className="text-[10px] text-slate-400 mt-0.5">Everything is up to date.</p>
            </div>
        )
    }

    return (
        <div className="divide-y divide-slate-100/50">
            {requests.map((request) => {
                const isSelected = selectedId === request.id
                const imageUrl = getInventoryImageUrl((request as any).inventory?.image_url)
                const timeAgo = formatDistanceToNow(new Date(request.created_at), { addSuffix: true })
                const isFuture = request.pickup_scheduled_at && new Date(request.pickup_scheduled_at) > new Date()

                return (
                    <button
                        key={request.id}
                        onClick={() => onSelect(request)}
                        className={cn(
                            'w-full text-left px-4 py-2.5 flex items-center gap-3 transition-all duration-150 relative group',
                            isSelected
                                ? 'bg-blue-50/70'
                                : 'hover:bg-slate-50/60'
                        )}
                    >
                        {/* Active indicator bar */}
                        {isSelected && (
                            <div className="absolute left-0 top-2 bottom-2 w-[3px] bg-blue-600 rounded-r-full" />
                        )}

                        {/* Item thumbnail */}
                        <div className="h-9 w-9 rounded-lg bg-white border border-slate-200 flex-shrink-0 flex items-center justify-center relative overflow-hidden shadow-sm">
                            {imageUrl ? (
                                <Image src={imageUrl} alt={request.item_name} fill className="object-contain p-1" unoptimized />
                            ) : (
                                <Package className="h-3.5 w-3.5 text-slate-300" />
                            )}
                        </div>

                        {/* Info */}
                        <div className="flex-1 min-w-0">
                            <div className="flex items-start justify-between gap-2 mb-0.5">
                                <div className="min-w-0">
                                    <p className={cn(
                                        'text-[12px] font-bold truncate leading-tight',
                                        isSelected ? 'text-blue-900' : 'text-slate-900'
                                    )}>
                                        {request.borrower_name}
                                    </p>
                                    <p className="text-[9px] font-medium text-slate-400 truncate uppercase tracking-tight">
                                        {request.borrower_department || 'General Staff'}
                                    </p>
                                </div>
                                <StatusBadge status={request.status} />
                            </div>
                            <div className="flex items-center justify-between gap-2">
                                <p className="text-[11px] text-slate-500 truncate flex-1">
                                    {request.item_name}
                                    <span className="font-bold text-slate-400 ml-1">×{request.quantity}</span>
                                </p>
                                <div className="flex items-center gap-1 flex-shrink-0">
                                    {isFuture ? (
                                        <Clock className="h-2.5 w-2.5 text-amber-400" />
                                    ) : (
                                        <div className="h-1 w-1 rounded-full bg-slate-300" />
                                    )}
                                    <span className={cn(
                                        "text-[9px] font-medium",
                                        isFuture ? "text-amber-600" : "text-slate-400"
                                    )}>{timeAgo}</span>
                                </div>
                            </div>
                        </div>
                    </button>
                )
            })}
        </div>
    )
}
