'use client'

import React, { useEffect, useState } from 'react'
import useSWR from 'swr'
import {
    ShieldCheck,
    Package,
    AlertTriangle,
    CheckCircle2,
    Mail,
    Hash,
    Clock,
    History,
    Loader2,
} from 'lucide-react'
import Link from 'next/link'
import { formatDistanceToNow } from 'date-fns'
import { BottomSheet, MBadge, EmptyState } from '@/components/mobile/primitives'
import {
    type BorrowerStats,
    getBorrowerHistory,
} from '@/hooks/use-borrower-registry'
import { cn } from '@/lib/utils'

interface BorrowerDetailSheetProps {
    borrower: BorrowerStats | null
    onOpenChange: (open: boolean) => void
}

interface HistoryRow {
    id: number | string
    item_name?: string
    inventory?: { item_name?: string; category?: string; image_url?: string | null } | null
    quantity: number
    status: string
    borrow_date?: string
    created_at: string
}

export function BorrowerDetailSheet({ borrower, onOpenChange }: BorrowerDetailSheetProps) {
    const open = !!borrower

    return (
        <BottomSheet
            open={open}
            onOpenChange={onOpenChange}
            title={borrower?.borrower_name || 'Borrower'}
            description={borrower?.borrower_email || 'Unregistered guest'}
            size="full"
        >
            {borrower && <BorrowerDetailBody borrower={borrower} />}
        </BottomSheet>
    )
}

function BorrowerDetailBody({ borrower }: { borrower: BorrowerStats }) {
    const { data: history, isLoading } = useSWR<HistoryRow[]>(
        `borrower-history|${borrower.borrower_user_id || 'null'}|${borrower.borrower_name}`,
        () => getBorrowerHistory(borrower.borrower_user_id, borrower.borrower_name),
        { revalidateOnFocus: false },
    )

    const returnRate = Math.round(borrower.return_rate_percent || 0)
    const initials =
        (borrower.borrower_name || 'NA')
            .split(/\s+/)
            .map((w) => w[0])
            .slice(0, 2)
            .join('')
            .toUpperCase() || 'NA'

    return (
        <div className="space-y-6">
            {/* Identity */}
            <section className="flex items-center gap-3">
                <div
                    className={cn(
                        'w-14 h-14 rounded-2xl flex items-center justify-center font-black text-base shrink-0',
                        borrower.is_verified_user
                            ? 'bg-gray-900 text-white'
                            : 'bg-gray-100 text-gray-700',
                    )}
                    aria-hidden
                >
                    {initials}
                </div>
                <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-1.5">
                        <h3 className="text-base font-bold text-gray-900 truncate">
                            {borrower.borrower_name}
                        </h3>
                        {borrower.is_verified_user && (
                            <ShieldCheck
                                className="w-4 h-4 text-blue-600 shrink-0"
                                aria-label="Verified account"
                            />
                        )}
                    </div>
                    <p className="text-xs text-gray-500 truncate flex items-center gap-1 mt-0.5">
                        <Mail className="w-3 h-3 shrink-0" aria-hidden />
                        {borrower.borrower_email || 'No email on record'}
                    </p>
                    <div className="flex items-center gap-1.5 mt-2 flex-wrap">
                        {borrower.user_role && (
                            <MBadge tone="info" size="xs">
                                {borrower.user_role}
                            </MBadge>
                        )}
                        <MBadge
                            tone={borrower.is_verified_user ? 'success' : 'neutral'}
                            size="xs"
                        >
                            {borrower.is_verified_user ? 'Verified' : 'Guest'}
                        </MBadge>
                        {borrower.user_status && (
                            <MBadge
                                tone={borrower.user_status === 'active' ? 'success' : 'warning'}
                                size="xs"
                            >
                                {borrower.user_status}
                            </MBadge>
                        )}
                    </div>
                </div>
            </section>

            {/* Metrics */}
            <section aria-label="Borrower metrics">
                <div className="grid grid-cols-2 gap-3">
                    <Metric
                        label="Return rate"
                        value={`${returnRate}%`}
                        tone={
                            returnRate >= 90
                                ? 'success'
                                : returnRate >= 60
                                    ? 'warning'
                                    : 'danger'
                        }
                        icon={CheckCircle2}
                    />
                    <Metric
                        label="Overdue"
                        value={borrower.overdue_count}
                        tone={borrower.overdue_count > 0 ? 'danger' : 'neutral'}
                        icon={AlertTriangle}
                    />
                    <Metric
                        label="Active items"
                        value={borrower.active_items}
                        tone={borrower.active_items > 0 ? 'info' : 'neutral'}
                        icon={Package}
                    />
                    <Metric
                        label="Total borrows"
                        value={borrower.total_borrows}
                        tone="neutral"
                        icon={Hash}
                    />
                </div>
            </section>

            {/* History */}
            <section aria-label="Transaction history" className="space-y-3">
                <div className="flex items-center justify-between px-1">
                    <h4 className="text-sm font-bold text-gray-900 uppercase tracking-tight flex items-center gap-2">
                        <History className="w-4 h-4 text-red-600" aria-hidden />
                        Recent activity
                    </h4>
                    {history && history.length > 0 && (
                        <span className="text-[10px] font-bold uppercase tracking-widest text-gray-400">
                            {history.length} record{history.length === 1 ? '' : 's'}
                        </span>
                    )}
                </div>

                {isLoading ? (
                    <div className="flex items-center justify-center py-10 text-gray-400">
                        <Loader2 className="w-5 h-5 animate-spin" aria-hidden />
                    </div>
                ) : history && history.length > 0 ? (
                    <div className="bg-white rounded-2xl border border-gray-100 divide-y divide-gray-50 overflow-hidden">
                        {history.slice(0, 25).map((row) => {
                            const name = row.inventory?.item_name || row.item_name || 'Item'
                            const ts = row.borrow_date || row.created_at
                            const status = (row.status || '').toLowerCase()
                            return (
                                <Link 
                                    key={row.id} 
                                    href={`?id=${row.id}&triage=true`}
                                    scroll={false}
                                    className="p-3.5 flex gap-3 hover:bg-gray-50 active:bg-gray-100 transition-colors cursor-pointer"
                                >
                                    <div
                                        className={cn(
                                            'w-9 h-9 rounded-xl flex items-center justify-center shrink-0 border',
                                            status === 'returned'
                                                ? 'bg-emerald-50 text-emerald-600 border-emerald-100'
                                                : status === 'overdue'
                                                    ? 'bg-rose-50 text-rose-600 border-rose-100'
                                                    : 'bg-blue-50 text-blue-600 border-blue-100',
                                        )}
                                    >
                                        <Package className="w-4 h-4" aria-hidden />
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-start justify-between gap-2">
                                            <p className="text-sm font-bold text-gray-900 truncate">
                                                {name}
                                            </p>
                                            <MBadge
                                                tone={
                                                    status === 'returned'
                                                        ? 'success'
                                                        : status === 'overdue'
                                                            ? 'danger'
                                                            : 'info'
                                                }
                                                size="xs"
                                            >
                                                {status || 'unknown'}
                                            </MBadge>
                                        </div>
                                        <p className="text-[11px] text-gray-500 mt-0.5 flex items-center gap-1">
                                            <Clock className="w-3 h-3" aria-hidden />
                                            {row.quantity} unit{row.quantity === 1 ? '' : 's'} ·{' '}
                                            {ts
                                                ? formatDistanceToNow(new Date(ts), {
                                                      addSuffix: true,
                                                  })
                                                : 'unknown time'}
                                        </p>
                                    </div>
                                </Link>
                            )
                        })}
                    </div>
                ) : (
                    <EmptyState
                        icon={History}
                        title="No activity yet"
                        description="This borrower hasn't taken out any items."
                    />
                )}
            </section>
        </div>
    )
}

type MetricTone = 'neutral' | 'success' | 'warning' | 'danger' | 'info'

function Metric({
    label,
    value,
    tone = 'neutral',
    icon: Icon,
}: {
    label: string
    value: React.ReactNode
    tone?: MetricTone
    icon: React.ComponentType<{ className?: string }>
}) {
    const toneMap: Record<MetricTone, string> = {
        neutral: 'bg-gray-50 border-gray-100 text-gray-900',
        success: 'bg-emerald-50 border-emerald-100 text-emerald-900',
        warning: 'bg-amber-50 border-amber-100 text-amber-900',
        danger: 'bg-rose-50 border-rose-100 text-rose-900',
        info: 'bg-blue-50 border-blue-100 text-blue-900',
    }
    const iconToneMap: Record<MetricTone, string> = {
        neutral: 'text-gray-400',
        success: 'text-emerald-500',
        warning: 'text-amber-500',
        danger: 'text-rose-500',
        info: 'text-blue-500',
    }

    return (
        <div className={cn('rounded-2xl border p-3.5', toneMap[tone])}>
            <div className="flex items-center justify-between">
                <span className="text-[10px] font-bold uppercase tracking-widest opacity-70">
                    {label}
                </span>
                <Icon className={cn('w-4 h-4', iconToneMap[tone])} aria-hidden />
            </div>
            <p className="mt-1 text-xl font-black tabular-nums">{value}</p>
        </div>
    )
}
