'use client'

import React from 'react'
import { ShieldCheck, Package, AlertTriangle, ChevronRight, Mail } from 'lucide-react'
import { cn } from '@/lib/utils'
import { mFocus } from '@/lib/mobile/tokens'
import { MBadge } from '@/components/mobile/primitives'
import type { BorrowerStats } from '@/hooks/use-borrower-registry'

interface BorrowerCardProps {
    borrower: BorrowerStats
    onSelect: (borrower: BorrowerStats) => void
}

export function BorrowerCard({ borrower, onSelect }: BorrowerCardProps) {
    const initials =
        (borrower.borrower_name || 'NA')
            .split(/\s+/)
            .map((w) => w[0])
            .slice(0, 2)
            .join('')
            .toUpperCase() || 'NA'

    const returnRate = Math.round(borrower.return_rate_percent || 0)
    const hasOverdue = (borrower.overdue_count || 0) > 0

    return (
        <button
            type="button"
            onClick={() => onSelect(borrower)}
            className={cn(
                'w-full text-left bg-white border border-gray-100 rounded-2xl p-4 shadow-sm',
                'flex items-start gap-3 motion-safe:transition-transform motion-safe:active:scale-[0.99]',
                'hover:border-gray-200',
                mFocus,
            )}
            aria-label={`View details for ${borrower.borrower_name}`}
        >
            <div
                className={cn(
                    'w-11 h-11 rounded-xl flex items-center justify-center shrink-0 font-bold text-sm',
                    borrower.is_verified_user
                        ? 'bg-gray-900 text-white'
                        : 'bg-gray-100 text-gray-700',
                )}
                aria-hidden
            >
                {initials}
            </div>

            <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                    <p className="text-sm font-bold text-gray-900 truncate">
                        {borrower.borrower_name}
                    </p>
                    {borrower.is_verified_user && (
                        <ShieldCheck
                            className="w-3.5 h-3.5 text-blue-600 shrink-0"
                            aria-label="Verified"
                        />
                    )}
                </div>

                {borrower.borrower_email ? (
                    <p className="text-xs text-gray-500 truncate flex items-center gap-1 mt-0.5">
                        <Mail className="w-3 h-3 shrink-0" aria-hidden />
                        {borrower.borrower_email}
                    </p>
                ) : (
                    <p className="text-xs text-gray-400 mt-0.5">Unregistered guest</p>
                )}

                <div className="mt-2 flex items-center gap-1.5 flex-wrap">
                    {borrower.user_role && (
                        <MBadge tone="info" size="xs">
                            {borrower.user_role}
                        </MBadge>
                    )}
                    <MBadge tone="neutral" size="xs" icon={Package}>
                        {borrower.active_items} active
                    </MBadge>
                    {hasOverdue && (
                        <MBadge tone="danger" size="xs" icon={AlertTriangle}>
                            {borrower.overdue_count} overdue
                        </MBadge>
                    )}
                </div>
            </div>

            <div className="flex flex-col items-end gap-1 shrink-0">
                <span
                    className={cn(
                        'text-sm font-black tabular-nums',
                        returnRate >= 90
                            ? 'text-emerald-600'
                            : returnRate >= 60
                                ? 'text-amber-600'
                                : 'text-rose-600',
                    )}
                >
                    {returnRate}%
                </span>
                <span className="text-[9px] font-bold uppercase tracking-widest text-gray-400">
                    Return
                </span>
                <ChevronRight
                    className="w-4 h-4 text-gray-300 mt-1"
                    aria-hidden
                />
            </div>
        </button>
    )
}
