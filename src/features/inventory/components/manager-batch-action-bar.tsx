'use client'

import React from 'react'
import { X, ArrowRight, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { BatchMode } from '../types'

interface ManagerBatchActionBarProps {
    mode: BatchMode
    count: number
    onCancel: () => void
    onClear: () => void
    onReview: () => void
}

export function ManagerBatchActionBar({
    mode,
    count,
    onCancel,
    onClear,
    onReview
}: ManagerBatchActionBarProps) {
    if (mode === 'none') return null

    const isReserve = mode === 'reserve'

    return (
        <div className={cn(
            "fixed left-4 right-4 z-50 transition-all duration-300 animate-in slide-in-from-bottom-8",
            "bottom-[calc(72px+env(safe-area-inset-bottom)+16px)]"
        )}>
            <div className="bg-slate-950 rounded-[28px] shadow-2xl shadow-slate-900/40 p-2 flex items-center gap-2 border border-white/10 backdrop-blur-md">
                {/* Cancel/Exit Button */}
                <button
                    onClick={onCancel}
                    className="w-10 h-10 rounded-full flex items-center justify-center text-white/60 hover:text-white hover:bg-white/10 transition-colors"
                    aria-label="Cancel Selection"
                >
                    <X className="w-5 h-5" />
                </button>

                {/* Info Section */}
                <div className="flex-1 px-2">
                    <p className="text-[10px] font-black uppercase tracking-widest text-white/40 leading-none mb-1">
                        {isReserve ? 'Reserving' : 'Borrowing'}
                    </p>
                    <p className="text-sm font-bold text-white leading-none">
                        {count} {count === 1 ? 'Item' : 'Items'} Selected
                    </p>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-1.5">
                    {count > 0 && (
                        <button
                            onClick={onClear}
                            className="w-10 h-10 rounded-full flex items-center justify-center text-rose-400 hover:bg-rose-400/10 transition-colors"
                            aria-label="Clear Selection"
                        >
                            <Trash2 className="w-4 h-4" />
                        </button>
                    )}

                    <button
                        onClick={onReview}
                        disabled={count === 0}
                        className={cn(
                            "h-10 px-5 rounded-full text-xs font-black uppercase tracking-tight flex items-center gap-2 transition-all",
                            count > 0 
                                ? "bg-white text-slate-950 shadow-lg active:scale-95" 
                                : "bg-white/10 text-white/20"
                        )}
                    >
                        Review
                        <ArrowRight className="w-3.5 h-3.5" />
                    </button>
                </div>
            </div>
        </div>
    )
}
