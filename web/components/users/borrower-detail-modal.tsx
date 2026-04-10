'use client'

import { useState, useEffect, useCallback } from 'react'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { CheckCircle2, Package, TrendingUp, AlertCircle, Clock, X } from 'lucide-react'
import { getBorrowerHistory, getBorrowerPending } from '@/hooks/use-borrower-registry'
import { formatDistanceToNow } from 'date-fns'
import { resolveLogisticsAction } from '@/app/actions/logistics-actions'
import { toast } from 'sonner'

interface BorrowerDetailModalProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    borrower: any
    onRefresh: () => void
}

export function BorrowerDetailModal({ open, onOpenChange, borrower, onRefresh }: BorrowerDetailModalProps) {
    const [history, setHistory] = useState<any[]>([])
    const [pending, setPending] = useState<any[]>([])
    const [loading, setLoading] = useState(true)
    const [resolvingId, setResolvingId] = useState<string | null>(null)

    const loadHistory = useCallback(async () => {
        setLoading(true)
        try {
            const [historyData, pendingData] = await Promise.all([
                getBorrowerHistory(borrower.borrower_user_id, borrower.borrower_name),
                getBorrowerPending(borrower.borrower_name)
            ])
            setHistory(historyData)
            setPending(pendingData)
        } catch (error) {
            console.error('Failed to load history:', error)
        } finally {
            setLoading(false)
        }
    }, [borrower])

    useEffect(() => {
        if (open && borrower) {
            loadHistory()
        }
    }, [open, borrower, loadHistory])

    const activeBorrows = history.filter(log => log.status === 'borrowed')
    const completedBorrows = history.filter(log => log.status === 'returned')

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-3xl max-h-[85vh] overflow-y-auto">
                <DialogHeader>
                    <div className="flex items-center gap-4">
                        <Avatar className="h-14 w-14 border-2 border-white shadow-md ring-2 ring-gray-100">
                            <AvatarFallback className={`font-bold text-lg text-white ${
                                borrower.is_verified_user 
                                    ? 'bg-gradient-to-br from-indigo-600 to-violet-700' 
                                    : 'bg-gradient-to-br from-slate-400 to-slate-600'
                            }`}>
                                {borrower.borrower_name.substring(0, 2).toUpperCase()}
                            </AvatarFallback>
                        </Avatar>
                        <div className="flex-1">
                            <DialogTitle className="text-2xl">{borrower.borrower_name}</DialogTitle>
                            <div className="flex items-center gap-2 mt-1">
                                {borrower.is_verified_user ? (
                                    <Badge variant="secondary" className="bg-indigo-50 text-indigo-700">
                                        <CheckCircle2 className="h-3 w-3 mr-1" />
                                        {borrower.user_role || 'Verified User'}
                                    </Badge>
                                ) : (
                                    <Badge variant="outline">Guest</Badge>
                                )}
                                {borrower.borrower_email && (
                                    <span className="text-sm text-gray-500">{borrower.borrower_email}</span>
                                )}
                            </div>
                        </div>
                    </div>
                </DialogHeader>

                {/* 🚨 PENDING AUTHORIZATION QUEUE (The C2 Edge) */}
                {pending.length > 0 && (
                    <div className="mt-4 space-y-2">
                        {pending.map((req) => (
                            <div key={req.id} className="relative overflow-hidden bg-amber-50/50 border border-amber-200/60 rounded-2xl p-4 flex items-center justify-between group animate-in slide-in-from-top-2 duration-300">
                                <div className="absolute left-0 top-0 bottom-0 w-1 bg-amber-500" />
                                <div className="flex items-center gap-4">
                                    <div className="h-10 w-10 bg-amber-500 rounded-xl flex items-center justify-center shadow-lg shadow-amber-200">
                                        <AlertCircle className="h-5 w-5 text-white" />
                                    </div>
                                    <div>
                                        <div className="flex items-center gap-2">
                                            <h4 className="text-[10px] font-black text-amber-900 uppercase tracking-widest">Awaiting Authorization</h4>
                                            <span className="text-[10px] font-bold text-amber-600/60 tabular-nums">
                                                • {formatDistanceToNow(new Date(req.created_at), { addSuffix: true })}
                                            </span>
                                        </div>
                                        <p className="text-sm font-black text-slate-900 mt-0.5">
                                            Requesting {req.quantity}x {req.item_name}
                                        </p>
                                    </div>
                                </div>
                                
                                <div className="flex items-center gap-2">
                                    <Button
                                        size="sm"
                                        variant="outline"
                                        disabled={resolvingId !== null}
                                        onClick={async () => {
                                            setResolvingId(req.id)
                                            const res = await resolveLogisticsAction(req.id, 'flagged', 'Flagged via Identity Insight')
                                            if (res.success) {
                                                toast.warning('Request flagged')
                                                loadHistory()
                                                onRefresh()
                                            }
                                            setResolvingId(null)
                                        }}
                                        className="h-8 px-3 rounded-lg border-amber-200 bg-white text-amber-700 hover:bg-amber-100 font-bold text-[10px] uppercase tracking-wider transition-all"
                                    >
                                        <X className="h-3 w-3 mr-1" /> Flag
                                    </Button>
                                    <Button
                                        size="sm"
                                        disabled={resolvingId !== null}
                                        onClick={async () => {
                                            setResolvingId(req.id)
                                            const res = await resolveLogisticsAction(req.id, 'completed', 'Authorized via Identity Insight')
                                            if (res.success) {
                                                toast.success('Authorized successfully')
                                                loadHistory()
                                                onRefresh()
                                            }
                                            setResolvingId(null)
                                        }}
                                        className="h-8 px-3 rounded-lg bg-slate-900 text-white hover:bg-black font-bold text-[10px] uppercase tracking-wider shadow-lg shadow-slate-200"
                                    >
                                        <CheckCircle2 className="h-3 w-3 mr-1" /> Authorize
                                    </Button>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {/* Stats Cards */}
                <div className="grid grid-cols-5 gap-3 mt-4">
                    <Card className="border-indigo-100 bg-indigo-50/30">
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-indigo-600 text-[10px] font-bold uppercase tracking-wider mb-1">
                                <TrendingUp className="h-3 w-3" />
                                <span>All Items Received</span>
                            </div>
                            <p className="text-2xl font-black text-indigo-900 leading-none">
                                {borrower?.total_items_handled ?? 0}
                            </p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                                <Package className="h-3 w-3" />
                                <span>Distributed Supplies</span>
                            </div>
                            <p className="text-2xl font-bold text-gray-900 leading-none">
                                {borrower?.total_consumables_issued ?? 0}
                            </p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                                <Clock className="h-3 w-3" />
                                <span>Currently Borrowed</span>
                            </div>
                            <p className="text-2xl font-bold text-blue-600 leading-none">{borrower?.active_items ?? 0}</p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                                <CheckCircle2 className="h-3 w-3" />
                                <span>Return Reliability</span>
                            </div>
                            <p className={`text-2xl font-bold leading-none ${
                                (borrower?.return_rate_percent ?? 100) >= 90 ? 'text-emerald-600' :
                                (borrower?.return_rate_percent ?? 100) >= 70 ? 'text-amber-600' : 'text-red-600'
                            }`}>
                                {borrower?.return_rate_percent != null ? Number(borrower.return_rate_percent).toFixed(0) : '100'}%
                            </p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-[10px] font-bold uppercase tracking-wider mb-1">
                                <AlertCircle className="h-3 w-3" />
                                <span>Past Due</span>
                            </div>
                            <p className={`text-2xl font-bold leading-none ${(borrower?.overdue_count ?? 0) > 0 ? 'text-red-600' : 'text-gray-400'}`}>
                                {borrower?.overdue_count ?? 0}
                            </p>
                        </CardContent>
                    </Card>
                </div>

                {/* History Tabs */}
                <Tabs defaultValue="active" className="mt-6">
                    <TabsList className="grid w-full grid-cols-3">
                        <TabsTrigger value="active">
                            Currently Borrowed ({activeBorrows.length})
                        </TabsTrigger>
                        <TabsTrigger value="supplies">
                            Distributed Supplies ({history.filter(log => log.status === 'dispensed').length})
                        </TabsTrigger>
                        <TabsTrigger value="history">
                            Return History ({completedBorrows.length})
                        </TabsTrigger>
                    </TabsList>

                    <TabsContent value="active" className="mt-4 space-y-3">
                        {loading ? (
                            <div className="text-center py-8 text-gray-500">Loading...</div>
                        ) : activeBorrows.length === 0 ? (
                            <div className="text-center py-8 text-gray-500">No items currently borrowed</div>
                        ) : (
                            activeBorrows.map((log) => (
                                <Card key={log.id} className="hover:shadow-md transition-shadow">
                                    <CardContent className="p-4">
                                        <div className="flex items-start justify-between">
                                            <div className="flex-1">
                                                <h4 className="font-semibold text-gray-900">{log.item_name}</h4>
                                                <p className="text-sm text-gray-500 mt-1">
                                                    Quantity: {log.quantity} • Borrowed {formatDistanceToNow(new Date(log.borrow_date), { addSuffix: true })}
                                                </p>
                                                {log.expected_return_date && (
                                                    <p className="text-xs text-gray-400 mt-1">
                                                        Expected return: {new Date(log.expected_return_date).toLocaleDateString()}
                                                    </p>
                                                )}
                                            </div>
                                            <Badge variant={log.status === 'overdue' ? 'destructive' : 'secondary'}>
                                                {log.status}
                                            </Badge>
                                        </div>
                                    </CardContent>
                                </Card>
                            ))
                        )}
                    </TabsContent>

                    <TabsContent value="supplies" className="mt-4 space-y-3">
                        {loading ? (
                            <div className="text-center py-8 text-gray-500">Loading...</div>
                        ) : history.filter(log => log.status === 'dispensed').length === 0 ? (
                            <div className="text-center py-8 text-gray-500">No supplies issued</div>
                        ) : (
                            history.filter(log => log.status === 'dispensed').map((log) => (
                                <Card key={log.id} className="bg-slate-50/50 border-slate-200">
                                    <CardContent className="p-4">
                                        <div className="flex items-start justify-between">
                                            <div className="flex-1">
                                                <h4 className="font-semibold text-slate-900">{log.item_name}</h4>
                                                <p className="text-sm text-slate-500 mt-1">
                                                    Quantity: {log.quantity} • Issued {formatDistanceToNow(new Date(log.borrow_date), { addSuffix: true })}
                                                </p>
                                                <p className="text-[10px] text-slate-400 mt-1 uppercase font-bold tracking-tighter">
                                                    One-time Use / Consumable
                                                </p>
                                            </div>
                                            <Badge variant="outline" className="bg-slate-100 text-slate-600 border-slate-200">
                                                Dispensed
                                            </Badge>
                                        </div>
                                    </CardContent>
                                </Card>
                            ))
                        )}
                    </TabsContent>

                    <TabsContent value="history" className="mt-4 space-y-3">
                        {loading ? (
                            <div className="text-center py-8 text-gray-500">Loading...</div>
                        ) : completedBorrows.length === 0 ? (
                            <div className="text-center py-8 text-gray-500">No completed borrows</div>
                        ) : (
                            completedBorrows.map((log) => (
                                <Card key={log.id} className="hover:shadow-md transition-shadow">
                                    <CardContent className="p-4">
                                        <div className="flex items-start justify-between">
                                            <div className="flex-1">
                                                <h4 className="font-semibold text-gray-900">{log.item_name}</h4>
                                                <p className="text-sm text-gray-500 mt-1">
                                                    Quantity: {log.quantity} • Borrowed {formatDistanceToNow(new Date(log.borrow_date), { addSuffix: true })}
                                                </p>
                                                {log.actual_return_date && (
                                                    <p className="text-xs text-emerald-600 mt-1">
                                                        Returned {formatDistanceToNow(new Date(log.actual_return_date), { addSuffix: true })}
                                                    </p>
                                                )}
                                            </div>
                                            <Badge variant="outline" className="bg-emerald-50 text-emerald-700 border-emerald-200">
                                                <CheckCircle2 className="h-3 w-3 mr-1" />
                                                Returned
                                            </Badge>
                                        </div>
                                    </CardContent>
                                </Card>
                            ))
                        )}
                    </TabsContent>
                </Tabs>
            </DialogContent>
        </Dialog>
    )
}
