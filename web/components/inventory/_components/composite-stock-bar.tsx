'use client'

import { cn } from '@/lib/utils'
import { Clock, ChevronDown, AlertTriangle, ChevronRight, ArrowUpRight } from 'lucide-react'
import { useRouter } from 'next/navigation'
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

type StockPopoverRow = {
    key: string
    borrower_name: string
    status: string
    quantity: number
    expected_return_date: string | null
    created_at: string | null
    purpose: string | null
    href: string
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
    const router = useRouter()
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
        ? (borrowedCount > 0 || dispensedRows.length > 0 || isLoadingActiveLoans)
        : (borrowedCount > 0 || activeLoans.length > 0)
    const displayRows: StockPopoverRow[] = isConsumable
        ? Array.from(
            weeklyDispensedRows.reduce((acc, row) => {
                const rawBorrower = (row.borrower_name || 'Unknown').trim() || 'Unknown'
                const borrowerKey = rawBorrower.toLowerCase()
                const existing = acc.get(borrowerKey)
                
                if (existing) {
                    existing.quantity += row.quantity || 0
                    if (!existing.created_at || new Date(row.created_at).getTime() > new Date(existing.created_at).getTime()) {
                        existing.created_at = row.created_at || null
                    }
                } else {
                    acc.set(borrowerKey, {
                        key: `dispensed::${item.id}::${borrowerKey}`,
                        borrower_name: rawBorrower,
                        status: 'dispensed',
                        quantity: row.quantity || 0,
                        expected_return_date: null,
                        created_at: row.created_at || null,
                        purpose: null,
                        href: `/dashboard/logs?search=${encodeURIComponent(rawBorrower)}&status=dispensed&item_id=${item.id}&range=week`,
                    })
                }
                return acc
            }, new Map<string, StockPopoverRow>())
        )
            .sort((a, b) => b.quantity - a.quantity)
            .slice(0, 8)
        : []

    const groupedActiveLoans = activeLoans.reduce((acc, loan) => {
        const borrower = (loan.borrower_name || 'Unknown').trim()
        const status = (loan.status || (isConsumable ? 'dispensed' : 'borrowed')).trim().toLowerCase()
        
        // 🛡️ SESSION CLUSTERING: Group by borrower and 15-minute time window
        const time = new Date(loan.created_at).getTime()
        const timeKey = Math.floor(time / (15 * 60 * 1000))
        const key = `active::${item.id}::${borrower.toLowerCase()}::${status}::${timeKey}`
        const existing = acc.get(key)

        if (existing) {
            existing.quantity += loan.quantity || 0
            if (!existing.expected_return_date && loan.expected_return_date) {
                existing.expected_return_date = loan.expected_return_date
            }
            return acc
        }

        acc.set(key, {
            key,
            borrower_name: borrower,
            status,
            quantity: loan.quantity || 0,
            expected_return_date: loan.expected_return_date || null,
            created_at: loan.created_at,
            purpose: loan.purpose || null,
            href: `/dashboard/logs?id=${loan.id}&search=${encodeURIComponent(borrower)}&highlight=true`,
        })
        return acc
    }, new Map<string, StockPopoverRow>())

    const renderedRows: StockPopoverRow[] = isConsumable ? displayRows : Array.from(groupedActiveLoans.values()).sort((a, b) => 
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    )

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
                        <PopoverContent 
                            side="bottom" 
                            align="start" 
                            className="w-64 p-0 rounded-xl overflow-hidden shadow-2xl border-gray-200 bg-white z-[100]" 
                            onClick={(e) => e.stopPropagation()}
                        >
                            <div className="p-3 bg-gray-50 border-b border-gray-100 text-[11px] font-black text-gray-900 uppercase tracking-wider">Pending Requests</div>
                            <div className="max-h-[200px] overflow-y-auto p-1.5 space-y-1">
                                {isLoadingPending ? (
                                    <div className="py-6 text-center text-[10px] font-bold text-gray-400">Loading requests...</div>
                                ) : pendingRequests.map((r) => (
                                    <button 
                                        key={r.id} 
                                        onClick={() => router.push(`/dashboard/logs?id=${r.id}&search=${encodeURIComponent(r.borrower_name)}&highlight=true`)}
                                        className="w-full text-left p-3 rounded-lg bg-white border border-gray-100 flex items-center justify-between shadow-sm hover:bg-gray-50 transition-all group/pending"
                                    >
                                        <div className="flex flex-col">
                                            <span className="text-[12px] font-black text-gray-950">{r.borrower_name}</span>
                                            <span className="text-[8px] font-bold text-gray-500 uppercase tracking-tight mt-1">Awaiting Approval</span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <Badge variant="outline" className="text-[10px] font-black bg-gray-100 border-transparent text-gray-950">{r.quantity} UNITS</Badge>
                                            <ChevronRight className="h-3 w-3 text-gray-400 group-hover/pending:text-gray-950 transition-colors" />
                                        </div>
                                    </button>
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
                        <PopoverContent 
                            side="bottom" 
                            align="start" 
                            className="w-72 p-0 rounded-xl overflow-hidden shadow-2xl border-gray-200 bg-white z-[110]" 
                            onClick={(e) => e.stopPropagation()}
                        >
                            <div className="p-3 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
                                <span className="text-[11px] font-black text-gray-900 uppercase tracking-wider">{activeHeader}</span>
                                {!isConsumable && (
                                    <button 
                                        onClick={() => router.push('/dashboard/logs')}
                                        className="text-[9px] font-bold text-gray-500 hover:text-gray-950 transition-colors flex items-center gap-1"
                                    >
                                        VIEW ALL <ArrowUpRight className="h-2.5 w-2.5" />
                                    </button>
                                )}
                            </div>
                            {isConsumable && (
                                <div className="px-3 py-2 border-b border-gray-100 bg-gray-50/50 space-y-1">
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-gray-500 uppercase tracking-tight">This Week</span>
                                        <span className="font-black text-gray-950">{weeklyDispensedQty} units</span>
                                    </div>
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-gray-500 uppercase tracking-tight">Lifetime</span>
                                        <span className="font-black text-gray-700">{lifetimeDispensedQty} units</span>
                                    </div>
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-gray-500 uppercase tracking-tight">Last Activity</span>
                                        <span className="font-black text-gray-700">
                                            {lastDispensedAt
                                                ? lastDispensedAt.toLocaleDateString('en-US', {
                                                    month: 'short',
                                                    day: 'numeric',
                                                })
                                                : '—'}
                                        </span>
                                    </div>
                                    <div className="flex items-center justify-between text-[10px]">
                                        <span className="font-extrabold text-gray-500 uppercase tracking-tight">Top Recipient</span>
                                        <span className="font-black text-gray-950 text-right">
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
                                        <button 
                                            key={loan.key} 
                                            onClick={() => router.push(loan.href)}
                                            className={cn(
                                                "w-full text-left p-3 rounded-lg border flex flex-col gap-1 transition-all group/row hover:ring-1 hover:ring-gray-200",
                                                loan.status === 'overdue' 
                                                    ? "bg-rose-50 border-rose-100 hover:bg-rose-100" 
                                                    : "bg-white border-gray-100 hover:bg-gray-50"
                                            )}
                                        >
                                            <div className="flex items-center justify-between">
                                                <div className="flex flex-col">
                                                    <span className={cn(
                                                        "text-[12px] font-black leading-none",
                                                        loan.status === 'overdue' ? "text-rose-600" : "text-gray-950"
                                                    )}>{loan.borrower_name}</span>
                                                    {loan.status === 'overdue' ? (
                                                        <span className="text-[9px] font-bold text-rose-500 uppercase tracking-tight mt-1 flex items-center gap-1">
                                                            🚨 OVERDUE SESSION
                                                        </span>
                                                    ) : (
                                                        <div className="flex flex-col gap-0.5 mt-1">
                                                            {loan.created_at && (
                                                                <span className="text-[9px] font-bold text-gray-500 uppercase tracking-tight">
                                                                    {new Date(loan.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                                                                </span>
                                                            )}
                                                            {loan.purpose && (
                                                                <span className="text-[8px] font-bold text-blue-600 uppercase truncate max-w-[150px]">
                                                                    {loan.purpose}
                                                                </span>
                                                            )}
                                                        </div>
                                                    )}
                                                </div>
                                                <div className="flex items-center gap-2">
                                                    <Badge variant="outline" className={cn(
                                                        "text-[10px] font-black px-1.5 h-5 border-transparent",
                                                        loan.status === 'overdue' ? "bg-rose-500 text-white" : "bg-gray-100 text-gray-950"
                                                    )}>{loan.quantity} UNITS</Badge>
                                                    <ChevronRight className="h-3 w-3 text-gray-300 group-hover/row:text-gray-950 transition-colors" />
                                                </div>
                                            </div>
                                            {loan.expected_return_date && (
                                                <span className={cn(
                                                    "text-[8px] font-bold uppercase tracking-widest mt-1",
                                                    loan.status === 'overdue' ? "text-rose-500/70" : "text-gray-400"
                                                )}>
                                                    Due: {new Date(loan.expected_return_date).toLocaleDateString()}
                                                </span>
                                            )}
                                        </button>
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
