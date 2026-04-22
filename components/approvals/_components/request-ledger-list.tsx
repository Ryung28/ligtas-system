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
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wide bg-emerald-50 text-emerald-600 border border-emerald-100">
                Ready
            </span>
        )
    }
    if (status === 'reserved') {
        return (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wide bg-amber-50 text-amber-600 border border-amber-100">
                Reserved
            </span>
        )
    }
    // pending
    return (
        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wide bg-blue-50 text-blue-600 border border-blue-100">
            New
        </span>
    )
}

export function RequestLedgerList({ requests, selectedId, onSelect }: RequestLedgerListProps) {
    if (requests.length === 0) {
        return (
            <div className="flex flex-col items-center justify-center h-full py-20 text-center px-8">
                <div className="h-14 w-14 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-center mb-4">
                    <Package className="h-7 w-7 text-slate-200" strokeWidth={1} />
                </div>
                <p className="text-sm font-bold text-slate-800 mb-1">No requests here</p>
                <p className="text-xs text-slate-400">All clear for now.</p>
            </div>
        )
    }

    return (
        <div className="divide-y divide-slate-50">
            {requests.map((request) => {
                const isSelected = selectedId === request.id
                const imageUrl = getInventoryImageUrl((request as any).inventory?.image_url)
                const timeAgo = formatDistanceToNow(new Date(request.created_at), { addSuffix: true })

                return (
                    <button
                        key={request.id}
                        onClick={() => onSelect(request)}
                        className={cn(
                            'w-full text-left px-5 py-4 flex items-center gap-3.5 transition-all duration-150 relative group',
                            isSelected
                                ? 'bg-blue-50/80'
                                : 'hover:bg-slate-50/80'
                        )}
                    >
                        {/* Active indicator bar */}
                        {isSelected && (
                            <div className="absolute left-0 top-3 bottom-3 w-[3px] bg-blue-600 rounded-r-full" />
                        )}

                        {/* Item thumbnail */}
                        <div className="h-10 w-10 rounded-xl bg-white border border-slate-200 flex-shrink-0 flex items-center justify-center relative overflow-hidden shadow-sm">
                            {imageUrl ? (
                                <Image src={imageUrl} alt={request.item_name} fill className="object-contain p-1.5" unoptimized />
                            ) : (
                                <Package className="h-4 w-4 text-slate-300" />
                            )}
                        </div>

                        {/* Info */}
                        <div className="flex-1 min-w-0">
                            <div className="flex items-start justify-between gap-2 mb-1">
                                <p className={cn(
                                    'text-[13px] font-black truncate leading-tight',
                                    isSelected ? 'text-blue-900' : 'text-slate-900'
                                )}>
                                    {request.borrower_name}
                                </p>
                                <StatusBadge status={request.status} />
                            </div>
                            <p className="text-[11px] text-slate-500 truncate leading-tight">
                                {request.item_name}
                                <span className="font-bold text-slate-400 ml-1">×{request.quantity}</span>
                            </p>
                            <div className="flex items-center gap-1 mt-1.5">
                                <Clock className="h-2.5 w-2.5 text-slate-300" />
                                <span className="text-[9px] text-slate-400 font-medium">{timeAgo}</span>
                            </div>
                        </div>
                    </button>
                )
            })}
        </div>
    )
}
