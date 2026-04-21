'use client'

import { useState, useEffect, useCallback } from 'react'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import {
    CheckCircle2, Package, TrendingUp, AlertCircle, Clock,
    X, UserCheck, ShieldAlert, Users, Briefcase, Zap
} from 'lucide-react'
import { getBorrowerHistory, getBorrowerPending } from '@/hooks/use-borrower-registry'
import { formatDistanceToNow } from 'date-fns'
import { resolveLogisticsAction } from '@/app/actions/logistics-actions'
import { toast } from 'sonner'

interface BorrowerDossierProps {
    borrower: any | null
    onRefresh: () => void
}

// ─── Empty State ───────────────────────────────────────────────────────────
function DossierEmptyState() {
    return (
        <div className="flex flex-col items-center justify-center h-full min-h-[400px] px-6 text-center gap-4">
            <div className="h-16 w-16 rounded-2xl bg-gray-50 border border-gray-100 flex items-center justify-center">
                <Users className="h-7 w-7 text-gray-200" />
            </div>
            <div>
                <p className="text-sm font-semibold text-gray-400">Select a person</p>
                <p className="text-xs text-gray-300 mt-1 max-w-[200px]">
                    Click any row in the list to see their details here.
                </p>
            </div>
        </div>
    )
}

// ─── Reliability Bar ───────────────────────────────────────────────────────
function ReliabilityBar({ value }: { value: number }) {
    const color =
        value >= 90 ? 'bg-emerald-500' :
        value >= 70 ? 'bg-amber-500' : 'bg-red-500'
    const barBg = 
        value >= 90 ? 'bg-emerald-50' :
        value >= 70 ? 'bg-amber-50' : 'bg-red-50'
    const textColor =
        value >= 90 ? 'text-emerald-700' :
        value >= 70 ? 'text-amber-700' : 'text-red-700'

    return (
        <div className="flex items-center gap-3">
            <div className={`flex-1 h-2 ${barBg} rounded-full overflow-hidden border border-gray-100/50`}>
                <div
                    className={`h-full rounded-full transition-all duration-500 ${color}`}
                    style={{ width: `${Math.min(100, value)}%` }}
                />
            </div>
            <span className={`text-sm font-black tabular-nums ${textColor}`}>
                {Math.round(value)}%
            </span>
        </div>
    )
}

// ─── Main Component ────────────────────────────────────────────────────────
export function BorrowerDossier({ borrower, onRefresh }: BorrowerDossierProps) {
    const [history, setHistory] = useState<any[]>([])
    const [pending, setPending] = useState<any[]>([])
    const [loading, setLoading] = useState(false)
    const [resolvingId, setResolvingId] = useState<string | null>(null)

    const loadHistory = useCallback(async () => {
        if (!borrower) return
        setLoading(true)
        try {
            const [historyData, pendingData] = await Promise.all([
                getBorrowerHistory(borrower.borrower_user_id, borrower.borrower_name),
                getBorrowerPending(borrower.borrower_name)
            ])
            setHistory(historyData)
            setPending(pendingData)
        } catch (error) {
            console.error('Failed to load dossier:', error)
        } finally {
            setLoading(false)
        }
    }, [borrower])

    useEffect(() => {
        if (borrower) loadHistory()
        else {
            setHistory([])
            setPending([])
        }
    }, [borrower, loadHistory])

    if (!borrower) return <DossierEmptyState />

    // Strict Connection Logic for Tabs
    const activeBorrows = history.filter(l => l.status === 'borrowed' || l.status === 'overdue')
    const completedBorrows = history.filter(l => l.status === 'returned')
    const consumablesIssued = history.filter(l => l.status === 'dispensed')

    const reliabilityValue = borrower.return_rate_percent != null
        ? Number(borrower.return_rate_percent)
        : 100
    const isHighRisk = reliabilityValue < 70 || (borrower.overdue_count ?? 0) > 2

    return (
        <div className="flex flex-col h-full bg-white">
            {/* ── PROFILE HEADER ────────────────────────── */}
            <div className={`relative p-6 shrink-0 border-b border-gray-100 ${isHighRisk
                ? 'bg-red-50/30'
                : 'bg-white'
            }`}>
                {isHighRisk && (
                    <div className="absolute top-4 right-4 flex items-center gap-1.5 bg-red-100 border border-red-200 px-2 py-1 rounded-lg">
                        <ShieldAlert className="h-3 w-3 text-red-600" />
                        <span className="text-[9px] font-black text-red-700 uppercase tracking-widest">High Risk</span>
                    </div>
                )}

                <div className="flex items-center gap-4 mb-6">
                    <Avatar className="h-14 w-14 border-2 border-white shadow-xl shadow-gray-200/50 shrink-0">
                        <AvatarFallback className={`font-black text-lg text-white ${
                            borrower.is_verified_user
                                ? 'bg-gradient-to-br from-indigo-500 to-violet-600'
                                : 'bg-gradient-to-br from-slate-400 to-slate-600'
                        }`}>
                            {borrower.borrower_name.substring(0, 2).toUpperCase()}
                        </AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0">
                        <p className="text-gray-900 font-black text-xl leading-tight truncate uppercase tracking-tight">
                            {borrower.borrower_name}
                        </p>
                        <div className="flex items-center gap-2 mt-1">
                            {borrower.is_verified_user ? (
                                <Badge variant="outline" className="bg-indigo-50 text-indigo-700 border-indigo-100 text-[10px] font-bold uppercase tracking-wider">
                                    <Briefcase className="h-3 w-3 mr-1" />
                                    Staff / {borrower.user_role || 'Employee'}
                                </Badge>
                            ) : (
                                <Badge variant="outline" className="bg-gray-50 text-gray-500 border-gray-200 text-[10px] font-bold uppercase tracking-wider">
                                    Guest Responder
                                </Badge>
                            )}
                        </div>
                    </div>
                </div>

                {/* Return Score */}
                <div>
                    <div className="flex items-center justify-between mb-2">
                        <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            Return Score
                        </p>
                    </div>
                    <ReliabilityBar value={reliabilityValue} />
                </div>
            </div>

            {/* ── PENDING APPROVALS  ─────────── */}
            {pending.length > 0 && (
                <div className="px-5 py-4 bg-amber-50/50 border-b border-amber-100/50 shrink-0">
                    <p className="text-[9px] font-black text-amber-700 uppercase tracking-widest mb-3 flex items-center gap-2">
                        <span className="flex h-1.5 w-1.5 rounded-full bg-amber-500 animate-pulse" />
                        Pending Approvals ({pending.length})
                    </p>
                    <div className="space-y-2">
                        {pending.map((req) => (
                            <div key={req.id} className="flex items-center justify-between gap-3 bg-white rounded-xl p-3 border border-amber-200/50 shadow-sm">
                                <div className="flex-1 min-w-0">
                                    <p className="text-xs font-bold text-gray-900 truncate uppercase tracking-tight">
                                        {req.quantity}x {req.item_name}
                                    </p>
                                    <p className="text-[9px] text-gray-400 mt-1 font-semibold uppercase tracking-wider">
                                        Requested {formatDistanceToNow(new Date(req.created_at), { addSuffix: true })}
                                    </p>
                                </div>
                                <div className="flex items-center gap-1.5 shrink-0">
                                    <Button
                                        size="sm"
                                        variant="outline"
                                        disabled={resolvingId !== null}
                                        onClick={async () => {
                                            setResolvingId(req.id)
                                            const res = await resolveLogisticsAction(req.id, 'flagged', 'Flagged via Person Details')
                                            if (res.success) { toast.warning('Flagged'); loadHistory(); onRefresh() }
                                            setResolvingId(null)
                                        }}
                                        className="h-8 px-2.5 text-[10px] font-black border-amber-200 text-amber-700 hover:bg-amber-50 rounded-lg shadow-sm"
                                    >
                                        <X className="h-3.5 w-3.5" />
                                    </Button>
                                    <Button
                                        size="sm"
                                        disabled={resolvingId !== null}
                                        onClick={async () => {
                                            setResolvingId(req.id)
                                            const res = await resolveLogisticsAction(req.id, 'completed', 'Authorized via Person Details')
                                            if (res.success) { toast.success('Authorized'); loadHistory(); onRefresh() }
                                            setResolvingId(null)
                                        }}
                                        className="h-8 px-3 text-[10px] font-black bg-slate-900 text-white hover:bg-slate-800 rounded-lg shadow-md shadow-slate-200"
                                    >
                                        <CheckCircle2 className="h-3.5 w-3.5" />
                                    </Button>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            )}

            {/* ── ITEMS SUMMARY (Active / Consumable / Returned) ─────────────── */}
            <div className="grid grid-cols-3 gap-3 p-6 border-b border-gray-100 shrink-0 bg-gray-50/30">
                <div className="bg-white rounded-xl p-4 text-center border border-emerald-100 shadow-sm">
                    <p className="text-[9px] font-black text-emerald-500 uppercase tracking-[0.1em]">Returned</p>
                    <p className="text-2xl font-black text-emerald-700 leading-tight mt-1">
                        {borrower.returned_count ?? 0}
                    </p>
                </div>
                <div className="bg-white rounded-xl p-4 text-center border border-blue-100 shadow-sm">
                    <p className="text-[9px] font-black text-blue-500 uppercase tracking-[0.1em]">Still Borrowed</p>
                    <p className="text-2xl font-black text-blue-700 leading-tight mt-1">
                        {borrower.active_items < 0 ? 0 : (borrower.active_borrows ?? 0)}
                    </p>
                </div>
                <div className="bg-white rounded-xl p-4 text-center border border-indigo-100 shadow-sm">
                    <p className="text-[9px] font-black text-indigo-500 uppercase tracking-[0.1em]">Consumable</p>
                    <p className="text-2xl font-black text-indigo-700 leading-tight mt-1">
                        {borrower.total_consumables_issued ?? 0}
                    </p>
                </div>
            </div>

            {/* ── HISTORY TABS ───────────────────────────────────────── */}
            <div className="flex-1 min-h-0">
                <Tabs defaultValue="active" className="h-full flex flex-col">
                    <TabsList className="grid grid-cols-3 mx-6 mt-6 shrink-0 bg-gray-100 rounded-xl h-10 p-1">
                        <TabsTrigger value="active" className="text-[10px] font-bold rounded-lg data-[state=active]:bg-white data-[state=active]:shadow-sm">
                            Borrowed ({activeBorrows.length})
                        </TabsTrigger>
                        <TabsTrigger value="consumable" className="text-[10px] font-bold rounded-lg data-[state=active]:bg-white data-[state=active]:shadow-sm">
                            Consumable ({consumablesIssued.length})
                        </TabsTrigger>
                        <TabsTrigger value="history" className="text-[10px] font-bold rounded-lg data-[state=active]:bg-white data-[state=active]:shadow-sm">
                            Returned ({completedBorrows.length})
                        </TabsTrigger>
                    </TabsList>

                    <div className="flex-1 overflow-y-auto px-6 pb-6 mt-4 space-y-3">
                        <TabsContent value="active" className="mt-0 space-y-3">
                            {loading ? (
                                <div className="text-center py-10 text-xs text-gray-400 font-bold uppercase tracking-widest animate-pulse">Syncing Borrows...</div>
                            ) : activeBorrows.length === 0 ? (
                                <div className="text-center py-10 text-xs text-gray-300 font-medium italic">No returnable items out</div>
                            ) : activeBorrows.map((log) => (
                                <BorrowLogCard key={log.id} log={log} variant="active" />
                            ))}
                        </TabsContent>

                        <TabsContent value="consumable" className="mt-0 space-y-3">
                            {loading ? (
                                <div className="text-center py-10 text-xs text-gray-400 font-bold uppercase tracking-widest animate-pulse">Scanning Supplies...</div>
                            ) : consumablesIssued.length === 0 ? (
                                <div className="text-center py-10 text-xs text-gray-300 font-medium italic">No consumable items issued</div>
                            ) : consumablesIssued.map((log) => (
                                <BorrowLogCard key={log.id} log={log} variant="consumable" />
                            ))}
                        </TabsContent>

                        <TabsContent value="history" className="mt-0 space-y-3">
                            {loading ? (
                                <div className="text-center py-10 text-xs text-gray-400 font-bold uppercase tracking-widest animate-pulse">Syncing History...</div>
                            ) : completedBorrows.length === 0 ? (
                                <div className="text-center py-10 text-xs text-gray-300 font-medium italic">No return history found</div>
                            ) : completedBorrows.map((log) => (
                                <BorrowLogCard key={log.id} log={log} variant="returned" />
                            ))}
                        </TabsContent>
                    </div>
                </Tabs>
            </div>
        </div>
    )
}

function BorrowLogCard({ log, variant }: { log: any; variant: 'active' | 'consumable' | 'returned' }) {
    const accent =
        variant === 'active' ? 'border-l-blue-500' :
        variant === 'consumable' ? 'border-l-indigo-400' : 'border-l-emerald-500'

    return (
        <div className={`bg-white rounded-xl border border-gray-100 border-l-4 ${accent} p-4 shadow-sm hover:shadow-md transition-shadow group shrink-0`}>
            <div className="flex items-start justify-between gap-4">
                <div className="flex-1 min-w-0">
                    <p className="text-[13px] font-black text-gray-900 group-hover:text-indigo-600 transition-colors uppercase tracking-tight truncate">{log.item_name}</p>
                    <div className="flex items-center gap-2 mt-1.5">
                        <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">
                            {log.quantity} {log.inventory?.category === 'Consumables' ? 'Units (One-time)' : 'Units'} ·{' '}
                            {formatDistanceToNow(new Date(log.borrow_date ?? log.created_at), { addSuffix: true })}
                        </p>
                    </div>
                </div>
                <Badge variant="outline" className={`text-[8px] font-black uppercase tracking-tighter px-1.5 py-0.5 rounded-md ${
                    variant === 'returned' ? 'bg-emerald-50 text-emerald-700 border-emerald-100' :
                    variant === 'consumable' ? 'bg-indigo-50 text-indigo-700 border-indigo-100' : 
                    'bg-blue-50 text-blue-700 border-blue-100'
                }`}>
                    <Zap className={`h-2.5 w-2.5 mr-1 ${variant === 'consumable' ? 'fill-indigo-400 text-indigo-400' : 'hidden'}`} />
                    {variant === 'active' ? 'Borrowed' : variant === 'consumable' ? 'One-time' : 'Returned'}
                </Badge>
            </div>
        </div>
    )
}
