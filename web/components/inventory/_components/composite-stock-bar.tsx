'use client'

import { cn } from '@/lib/utils'
import { Clock, ChevronDown, AlertTriangle } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { InventoryItem } from '@/lib/supabase'
import { PendingRequest, ActiveLoan } from '@/src/features/transactions'

interface CompositeStockBarProps {
    item: InventoryItem
    pendingCount: number
    pendingRequests: PendingRequest[]
    isLoadingPending: boolean
    isInternalOpen: boolean
    setIsInternalOpen: (open: boolean) => void
    fetchPending: () => void
    activeLoans: ActiveLoan[]
    isLoadingActiveLoans: boolean
    isBorrowedPopoverOpen: boolean
    setIsBorrowedPopoverOpen: (open: boolean) => void
    fetchActiveLoans: () => void
}

export function CompositeStockBar({
    item,
    pendingCount,
    pendingRequests,
    isLoadingPending,
    isInternalOpen,
    setIsInternalOpen,
    fetchPending,
    activeLoans,
    isLoadingActiveLoans,
    isBorrowedPopoverOpen,
    setIsBorrowedPopoverOpen,
    fetchActiveLoans
}: CompositeStockBarProps) {
    const isConsumable = (item.item_type || '').toLowerCase() === 'consumable'
    const activeLabel = isConsumable ? 'DISPENSED' : 'BORROWED'
    const activeHeader = isConsumable ? 'Dispensed Items' : 'Borrowed Items'
    const activeEmpty = isConsumable ? 'No dispensed records.' : 'No items borrowed.'
    const now = new Date()
    const rollingWeekStart = new Date(now.getTime() - (7 * 24 * 60 * 60 * 1000))

    const anchor = (item as any).target_stock || item.stock_total || 1
    
    // 📊 SENIOR MATH: Distinguish between Available-Good and Borrowed-Good
    const borrowedCount = Math.max(0, (item.stock_total ?? 0) - (item.stock_available ?? 0) - (item.qty_damaged ?? 0) - (item.qty_maintenance ?? 0) - (item.qty_lost ?? 0))
    const availableGood = Math.max(0, item.qty_good - borrowedCount)
    
    const availablePct = Math.min((availableGood / anchor) * 100, 100)
    const borrowedPct = (borrowedCount / anchor) * 100
    const maintPct = (item.qty_maintenance / anchor) * 100
    const damagedPct = (item.qty_damaged / anchor) * 100
    const lostPct = (item.qty_lost / anchor) * 100

    const hasIssues = item.qty_damaged > 0 || item.qty_maintenance > 0 || item.qty_lost > 0
    const hasPending = pendingCount > 0
    const dispensedRows = isConsumable
        ? activeLoans.filter((loan) => loan.status === 'dispensed')
        : []
    const weeklyDispensedRows = isConsumable
        ? dispensedRows.filter((loan) => new Date(loan.created_at) >= rollingWeekStart)
        : []
    const weeklyDispensedQty = weeklyDispensedRows.reduce((sum, row) => sum + (row.quantity || 0), 0)
    const lifetimeDispensedQty = dispensedRows.reduce((sum, row) => sum + (row.quantity || 0), 0)
    const lastDispensedAt = dispensedRows.length > 0 ? new Date(dispensedRows[0].created_at) : null
    const topRecipientThisWeek = (() => {
        if (!isConsumable || weeklyDispensedRows.length === 0) return null
        const tally = new Map<string, number>()
        for (const row of weeklyDispensedRows) {
            const name = (row.borrower_name || 'Unknown').trim() || 'Unknown'
            tally.set(name, (tally.get(name) || 0) + (row.quantity || 0))
        }
        const ranked = Array.from(tally.entries()).sort((a, b) => b[1] - a[1])
        if (ranked.length === 0) return null
        return { name: ranked[0][0], quantity: ranked[0][1] }
    })()
    const hasActiveLoans = isConsumable
        // For consumables, allow the chip to appear before popover data is fetched.
        // `borrowedCount` reflects outbound quantity from current stock math.
        ? (borrowedCount > 0 || dispensedRows.length > 0 || isLoadingActiveLoans)
        : (borrowedCount > 0 || activeLoans.length > 0)
    const displayRows = isConsumable
        ? Array.from(
            weeklyDispensedRows.reduce((acc, row) => {
                const borrower = (row.borrower_name || 'Unknown').trim() || 'Unknown'
                const existing = acc.get(borrower)
                if (existing) {
                    existing.quantity += row.quantity || 0
                } else {
                    acc.set(borrower, {
                        borrower_name: borrower,
                        status: 'dispensed',
                        quantity: row.quantity || 0,
                        expected_return_date: null,
                    })
                }
                return acc
            }, new Map<string, { borrower_name: string; status: string; quantity: number; expected_return_date: string | null }>())
        )
            .sort((a, b) => b.quantity - a.quantity)
            .slice(0, 8)
        : []
    const groupedActiveLoans = activeLoans.reduce((acc, loan) => {
        const borrower = (loan.borrower_name || 'Unknown').trim()
        const status = (loan.status || (isConsumable ? 'dispensed' : 'borrowed')).trim().toLowerCase()
        const key = `${borrower}::${status}`
        const existing = acc.get(key)

        if (existing) {
            existing.quantity += loan.quantity || 0
            if (!existing.expected_return_date && loan.expected_return_date) {
                existing.expected_return_date = loan.expected_return_date
            }
            return acc
        }

        acc.set(key, {
            borrower_name: borrower,
            status,
            quantity: loan.quantity || 0,
            expected_return_date: loan.expected_return_date || null,
        })
        return acc
    }, new Map<string, { borrower_name: string; status: string; quantity: number; expected_return_date: string | null }>())

    const renderedRows = isConsumable ? displayRows : Array.from(groupedActiveLoans.values())

    return (
        <div className="flex flex-col gap-2 min-w-[160px]">
            {/* 🏥 COMPOSITE HEALTH STRIP */}
            <div className="group/strip relative">
                <div className="h-1.5 w-full bg-slate-100 rounded-full overflow-hidden flex shadow-inner border border-slate-200/30">
                    <div className="h-full bg-emerald-500 transition-all duration-500" style={{ width: `${availablePct}%` }} />
                    <div className="h-full bg-blue-500 transition-all duration-500 shadow-[inset_-1px_0_0_rgba(0,0,0,0.1)]" style={{ width: `${borrowedPct}%` }} />
                    <div className="h-full bg-amber-400 transition-all duration-500" style={{ width: `${maintPct}%` }} />
                    <div className="h-full bg-rose-500 transition-all duration-500" style={{ width: `${damagedPct}%` }} />
                    <div className="h-full bg-slate-400 transition-all duration-500" style={{ width: `${lostPct}%` }} />
                </div>
                
                {/* Tactical Legend (Visible on Hover or if issues exist) */}
                <div className={cn(
                    "flex items-center gap-3 mt-1.5 transition-opacity duration-200",
                    hasIssues ? "opacity-100" : "opacity-0 group-hover/strip:opacity-100"
                )}>
                    {item.qty_damaged > 0 && (
                        <div className="flex items-center gap-1">
                            <div className="w-1.5 h-1.5 rounded-full bg-rose-500" />
                            <span className="text-[9px] font-black text-rose-600 tabular-nums">{item.qty_damaged}</span>
                        </div>
                    )}
                    {item.qty_maintenance > 0 && (
                        <div className="flex items-center gap-1">
                            <div className="w-1.5 h-1.5 rounded-full bg-amber-400" />
                            <span className="text-[9px] font-black text-amber-600 tabular-nums">{item.qty_maintenance}</span>
                        </div>
                    )}
                    {item.qty_lost > 0 && (
                        <div className="flex items-center gap-1">
                            <div className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                            <span className="text-[9px] font-black text-slate-500 tabular-nums">{item.qty_lost}</span>
                        </div>
                    )}
                </div>
            </div>

            {/* ⚠️ EXCEPTION ALERTS (Pending + Borrowed) */}
            <div className="flex flex-wrap gap-2">
                {hasPending && (
                    <Popover open={isInternalOpen} onOpenChange={(open) => {
                        setIsInternalOpen(open)
                        if (open) fetchPending()
                    }}>
                        <PopoverTrigger asChild>
                            <button
                                onClick={(e) => e.stopPropagation()}
                                className="inline-flex items-center gap-1 self-start px-2.5 py-1 rounded-md text-[9px] font-black bg-gray-50 border border-gray-200 text-gray-950 hover:bg-gray-100 transition-all shadow-sm group"
                            >
                                <Clock className="h-2.5 w-2.5 text-gray-400 group-hover:text-gray-950" />
                                {pendingCount} PENDING
                            </button>
                        </PopoverTrigger>
                        <PopoverContent side="bottom" align="start" className="w-64 p-0 rounded-xl overflow-hidden shadow-2xl border-gray-200 z-[100]" onClick={(e) => e.stopPropagation()}>
                            <div className="p-3 bg-gray-50/50 border-b border-gray-100 text-[11px] font-black text-gray-950 uppercase tracking-tight">Pending Requests</div>
                            <div className="max-h-[200px] overflow-y-auto p-1.5 space-y-1">
                                {isLoadingPending ? (
                                    <div className="py-6 text-center text-[10px] font-bold text-gray-400">Loading requests...</div>
                                ) : pendingRequests.map((r) => (
                                    <div key={r.id} className="p-3 rounded-lg bg-white border border-gray-100 flex items-center justify-between shadow-sm">
                                        <span className="text-[12px] font-black text-gray-950">{r.borrower_name}</span>
                                        <Badge variant="outline" className="text-[10px] font-black bg-gray-50 border-gray-200 text-gray-950">{r.quantity} UNITS</Badge>
                                    </div>
                                ))}
                            </div>
                        </PopoverContent>
                    </Popover>
                )}

                {hasActiveLoans && (
                    <Popover open={isBorrowedPopoverOpen} onOpenChange={(open) => {
                        setIsBorrowedPopoverOpen(open)
                        if (open) fetchActiveLoans()
                    }}>
                        <PopoverTrigger asChild>
                            <button
                                onClick={(e) => e.stopPropagation()}
                                className="inline-flex items-center gap-1 self-start px-2.5 py-1 rounded-md text-[9px] font-black bg-blue-50 border border-blue-100 text-blue-700 hover:bg-blue-100 transition-all shadow-sm group"
                            >
                                <AlertTriangle className="h-2.5 w-2.5 text-blue-400 group-hover:text-blue-700" />
                                {isConsumable ? `THIS WEEK: ${weeklyDispensedQty}` : (borrowedCount || activeLoans.length)} {activeLabel}
                            </button>
                        </PopoverTrigger>
                        <PopoverContent side="bottom" align="start" className="w-72 p-0 rounded-xl overflow-hidden shadow-2xl border-gray-200 z-[110]" onClick={(e) => e.stopPropagation()}>
                            <div className="p-3 bg-blue-50/50 border-b border-blue-100 text-[11px] font-black text-blue-900 uppercase tracking-tight">{activeHeader}</div>
                            {isConsumable && (
                                <div className="px-3 py-2 border-b border-blue-100/70 bg-blue-50/30 space-y-1">
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-blue-900 uppercase tracking-tight">This Week</span>
                                        <span className="font-black text-blue-700">{weeklyDispensedQty} units</span>
                                    </div>
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-slate-700 uppercase tracking-tight">Lifetime Dispensed</span>
                                        <span className="font-black text-slate-900">{lifetimeDispensedQty} units</span>
                                    </div>
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-slate-700 uppercase tracking-tight">Last Dispensed</span>
                                        <span className="font-black text-slate-900">
                                            {lastDispensedAt
                                                ? lastDispensedAt.toLocaleDateString('en-US', {
                                                    month: 'long',
                                                    day: 'numeric',
                                                    year: 'numeric',
                                                })
                                                : '—'}
                                        </span>
                                    </div>
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-slate-700 uppercase tracking-tight">Top Recipient (Week)</span>
                                        <span className="font-black text-slate-900 text-right">
                                            {topRecipientThisWeek ? `${topRecipientThisWeek.name} (${topRecipientThisWeek.quantity})` : '—'}
                                        </span>
                                    </div>
                                </div>
                            )}
                            <div className="max-h-[300px] overflow-y-auto p-1.5 space-y-1">
                                {isLoadingActiveLoans ? (
                                    <div className="py-6 text-center text-[10px] font-bold text-gray-400">Fetching borrowers...</div>
                                ) : renderedRows.length === 0 ? (
                                    <div className="py-6 text-center text-[10px] font-bold text-gray-400">{activeEmpty}</div>
                                ) : (
                                    renderedRows.map((loan) => (
                                        <div key={`${loan.borrower_name}-${loan.status}`} className={cn(
                                            "p-3 rounded-lg border flex flex-col gap-1 transition-colors",
                                            loan.status === 'overdue' ? "bg-rose-50 border-rose-100" : "bg-white border-gray-100"
                                        )}>
                                            <div className="flex items-center justify-between">
                                                <span className={cn(
                                                    "text-[12px] font-black leading-none",
                                                    loan.status === 'overdue' ? "text-rose-700" : "text-gray-950"
                                                )}>{loan.borrower_name}</span>
                                                <Badge variant="outline" className={cn(
                                                    "text-[10px] font-black px-1.5 h-5",
                                                    loan.status === 'overdue' ? "bg-rose-100 border-rose-200 text-rose-700" : "bg-gray-50 border-gray-200 text-gray-950"
                                                )}>{loan.quantity} UNITS</Badge>
                                            </div>
                                            {loan.status === 'overdue' && (
                                                <span className="text-[9px] font-bold text-rose-600 uppercase tracking-tighter flex items-center gap-1">
                                                    ⚠️ OVERDUE since {new Date(loan.expected_return_date || '').toLocaleDateString()}
                                                </span>
                                            )}
                                            {loan.status === 'borrowed' && loan.expected_return_date && (
                                                <span className="text-[9px] font-bold text-gray-400 uppercase tracking-tighter">
                                                    Expected back: {new Date(loan.expected_return_date).toLocaleDateString()}
                                                </span>
                                            )}
                                        </div>
                                    ))
                                )}
                            </div>
                        </PopoverContent>
                    </Popover>
                )}
            </div>
        </div>
    )
}
