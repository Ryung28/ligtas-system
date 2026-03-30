'use client'

import { useState, useEffect, useCallback } from 'react'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { CheckCircle2, Package, TrendingUp, AlertCircle, Clock } from 'lucide-react'
import { getBorrowerHistory } from '@/hooks/use-borrower-registry'
import { formatDistanceToNow } from 'date-fns'

interface BorrowerDetailModalProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    borrower: any
    onRefresh: () => void
}

export function BorrowerDetailModal({ open, onOpenChange, borrower, onRefresh }: BorrowerDetailModalProps) {
    const [history, setHistory] = useState<any[]>([])
    const [loading, setLoading] = useState(true)

    const loadHistory = useCallback(async () => {
        setLoading(true)
        try {
            const data = await getBorrowerHistory(borrower.borrower_user_id)
            setHistory(data)
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

                {/* Stats Cards */}
                <div className="grid grid-cols-4 gap-3 mt-4">
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-xs mb-1">
                                <Package className="h-3.5 w-3.5" />
                                <span>Total Borrows</span>
                            </div>
                            <p className="text-2xl font-bold text-gray-900">{borrower.total_borrows}</p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-xs mb-1">
                                <Clock className="h-3.5 w-3.5" />
                                <span>Active</span>
                            </div>
                            <p className="text-2xl font-bold text-blue-600">{borrower.active_items}</p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-xs mb-1">
                                <TrendingUp className="h-3.5 w-3.5" />
                                <span>Return Rate</span>
                            </div>
                            <p className={`text-2xl font-bold ${
                                borrower.return_rate_percent >= 90 ? 'text-emerald-600' :
                                borrower.return_rate_percent >= 70 ? 'text-amber-600' : 'text-red-600'
                            }`}>
                                {borrower.return_rate_percent.toFixed(0)}%
                            </p>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="p-4">
                            <div className="flex items-center gap-2 text-gray-500 text-xs mb-1">
                                <AlertCircle className="h-3.5 w-3.5" />
                                <span>Overdue</span>
                            </div>
                            <p className={`text-2xl font-bold ${borrower.overdue_count > 0 ? 'text-red-600' : 'text-gray-400'}`}>
                                {borrower.overdue_count}
                            </p>
                        </CardContent>
                    </Card>
                </div>

                {/* History Tabs */}
                <Tabs defaultValue="active" className="mt-6">
                    <TabsList className="grid w-full grid-cols-2">
                        <TabsTrigger value="active">
                            Active Borrows ({activeBorrows.length})
                        </TabsTrigger>
                        <TabsTrigger value="history">
                            History ({completedBorrows.length})
                        </TabsTrigger>
                    </TabsList>

                    <TabsContent value="active" className="mt-4 space-y-3">
                        {loading ? (
                            <div className="text-center py-8 text-gray-500">Loading...</div>
                        ) : activeBorrows.length === 0 ? (
                            <div className="text-center py-8 text-gray-500">No active borrows</div>
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
