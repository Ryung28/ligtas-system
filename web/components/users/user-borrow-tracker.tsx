'use client'

import {
    Sheet,
    SheetContent,
    SheetDescription,
    SheetHeader,
    SheetTitle,
} from '@/components/ui/sheet'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Package, RotateCcw, Calendar, User, History, ArrowUpRight, ArrowDownLeft, Clock, RefreshCcw } from 'lucide-react'
import { BorrowLog } from '@/lib/types/inventory'
import { returnItem } from '@/app/actions/inventory'
import { toast } from 'sonner'
import { useState, useEffect, useCallback } from 'react'
import { createBrowserClient } from '@supabase/ssr'

interface UserBorrowTrackerProps {
    userName: string
    activeBorrows: BorrowLog[]
    open: boolean
    onOpenChange: (open: boolean) => void
    onRefresh: () => void
}

export function UserBorrowTracker({ userName, activeBorrows, open, onOpenChange, onRefresh }: UserBorrowTrackerProps) {
    const [activeTab, setActiveTab] = useState<'active' | 'history'>('active')
    const [processingId, setProcessingId] = useState<number | null>(null)
    const [assessingLog, setAssessingLog] = useState<any>(null)
    const [condition, setCondition] = useState('Good')
    const [notes, setNotes] = useState('')

    // History State
    const [historyLogs, setHistoryLogs] = useState<BorrowLog[]>([])
    const [isHistoryLoading, setIsHistoryLoading] = useState(false)

    const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    const fetchHistory = useCallback(async () => {
        try {
            setIsHistoryLoading(true)
            const { data, error } = await supabase
                .from('borrow_logs')
                .select('*')
                .eq('borrower_name', userName)
                .order('created_at', { ascending: false })

            if (error) throw error
            setHistoryLogs(data || [])
        } catch (error) {
            console.error('Error fetching history:', error)
            toast.error('Failed to load borrowing history')
        } finally {
            setIsHistoryLoading(false)
        }
    }, [supabase, userName])

    // Auto-fetch history when tab changes
    useEffect(() => {
        if (open && activeTab === 'history') {
            fetchHistory()
        }
    }, [open, activeTab, userName])

    const handleReturn = async () => {
        if (!assessingLog) return
        try {
            setProcessingId(assessingLog.id)
            const result = await returnItem(assessingLog.id, condition, notes)
            if (result.success) {
                toast.success('Item returned successfully')
                setAssessingLog(null)
                onRefresh()
                // Refresh history if we are in that tab context
                if (activeTab === 'history') fetchHistory()
            } else {
                toast.error(result.error)
            }
        } catch (error) {
            toast.error('Failed to process return')
        } finally {
            setProcessingId(null)
        }
    }

    return (
        <Sheet open={open} onOpenChange={(val) => {
            onOpenChange(val)
            if (!val) {
                setAssessingLog(null)
                setActiveTab('active')
            }
        }}>
            <SheetContent className="w-full sm:max-w-md border-l border-gray-200 p-0 overflow-hidden flex flex-col bg-white">
                <SheetHeader className="p-6 bg-blue-600 text-white shadow-lg relative overflow-hidden">
                    <div className="absolute right-0 top-0 opacity-10 -mr-4 -mt-4">
                        <History className="h-32 w-32" />
                    </div>
                    <div className="flex items-center gap-4 mb-2 relative z-10">
                        <div className="h-14 w-14 rounded-2xl bg-white/20 flex items-center justify-center border border-white/30 backdrop-blur-sm shadow-inner">
                            <User className="h-7 w-7 text-white" />
                        </div>
                        <div>
                            <SheetTitle className="text-white text-2xl font-heading font-semibold tracking-tight leading-none mb-1">{userName}</SheetTitle>
                            <SheetDescription className="text-blue-100 font-medium text-[11px] uppercase tracking-[0.15em] opacity-90">
                                Institutional Audit Profile
                            </SheetDescription>
                        </div>
                    </div>

                    {/* Simple Tab Switcher */}
                    <div className="flex gap-1 bg-blue-700/50 p-1.5 rounded-2xl mt-4 relative z-10">
                        <button
                            onClick={() => setActiveTab('active')}
                            className={`flex-1 py-2 text-[11px] font-semibold uppercase tracking-wider rounded-xl transition-all ${activeTab === 'active' ? 'bg-white text-blue-600 shadow-md' : 'text-blue-100 hover:bg-white/10'}`}
                        >
                            Active ({activeBorrows.length})
                        </button>
                        <button
                            onClick={() => setActiveTab('history')}
                            className={`flex-1 py-2 text-[11px] font-semibold uppercase tracking-wider rounded-xl transition-all ${activeTab === 'history' ? 'bg-white text-blue-600 shadow-md' : 'text-blue-100 hover:bg-white/10'}`}
                        >
                            History
                        </button>
                    </div>
                </SheetHeader>

                <div className="flex-1 overflow-y-auto">
                    {activeTab === 'active' ? (
                        <div className="p-0">
                            {!assessingLog ? (
                                <div className="p-6 space-y-4">
                                    <div className="flex items-center justify-between mb-2">
                                        <h3 className="text-[11px] font-bold text-slate-400 uppercase tracking-widest px-1">Equipment in Field</h3>
                                        <Badge className="bg-orange-50 text-orange-600 border-none font-semibold text-[10px]">Live Audit</Badge>
                                    </div>

                                    {activeBorrows.length === 0 ? (
                                        <div className="flex flex-col items-center justify-center py-20 text-center bg-slate-50/50 rounded-[2rem] border border-slate-100">
                                            <Package className="h-10 w-10 text-slate-200 mb-3" />
                                            <p className="text-sm text-slate-600 font-semibold tracking-tight">No Items Assigned</p>
                                            <p className="text-[11px] text-slate-400 mt-1">Everything is safely in storage.</p>
                                        </div>
                                    ) : (
                                        <div className="space-y-3">
                                            {activeBorrows.map((log) => (
                                                <div key={log.id} className="group relative bg-white rounded-2xl border border-slate-100 p-5 shadow-sm hover:shadow-md transition-all duration-300 border-l-[3px] border-l-blue-500">
                                                    <div className="flex justify-between items-start mb-4">
                                                        <div>
                                                            <h4 className="font-semibold text-slate-900 leading-tight tracking-tight text-base mb-2">{log.item_name}</h4>
                                                            <div className="flex items-center gap-3">
                                                                <Badge variant="secondary" className="bg-blue-50/80 text-blue-600 hover:bg-blue-50 border-none text-[11px] font-semibold py-0.5 px-3 rounded-lg">
                                                                    {log.quantity} Units
                                                                </Badge>
                                                                <span className="text-[11px] text-slate-400 font-medium flex items-center gap-1.5">
                                                                    <Clock className="h-3.5 w-3.5 text-slate-300" />
                                                                    {new Date(log.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <Button
                                                        size="sm"
                                                        variant="outline"
                                                        className="w-full h-11 rounded-xl border-slate-100 text-[11px] font-bold uppercase tracking-[0.1em] text-blue-600 hover:bg-blue-50 hover:text-blue-700 hover:border-blue-100 transition-all gap-2"
                                                        onClick={() => {
                                                            setAssessingLog(log)
                                                            setCondition('Good')
                                                            setNotes('')
                                                        }}
                                                    >
                                                        <RotateCcw className="h-3.5 w-3.5" />
                                                        Verify Return
                                                    </Button>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            ) : (
                                <div className="p-6 space-y-6 animate-in slide-in-from-right duration-300">
                                    <div className="flex items-center gap-4 p-5 bg-orange-50/50 rounded-2xl border border-orange-100">
                                        <div className="p-2.5 bg-orange-500 rounded-xl text-white shadow-sm">
                                            <RotateCcw className="h-5 w-5" />
                                        </div>
                                        <div>
                                            <h3 className="font-bold tracking-tight text-orange-900">Return Assessment</h3>
                                            <p className="text-[11px] text-orange-700 font-medium uppercase tracking-wider opacity-80">Safety & Quality Check</p>
                                        </div>
                                    </div>

                                    <div className="space-y-6">
                                        <div className="space-y-2.5">
                                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-widest px-1">Item Condition</label>
                                            <Select value={condition} onValueChange={setCondition}>
                                                <SelectTrigger className="h-14 rounded-2xl border-slate-200 shadow-sm font-semibold text-sm text-slate-700 bg-white">
                                                    <SelectValue />
                                                </SelectTrigger>
                                                <SelectContent className="rounded-2xl shadow-xl border-none p-1">
                                                    <SelectItem value="Good" className="font-semibold text-[11px] uppercase text-green-600 py-3 rounded-xl">Deployable (Good)</SelectItem>
                                                    <SelectItem value="Maintenance" className="font-semibold text-[11px] uppercase text-orange-600 py-3 rounded-xl">Repair Needed</SelectItem>
                                                    <SelectItem value="Damaged" className="font-semibold text-[11px] uppercase text-red-600 py-3 rounded-xl">Damaged / Broken</SelectItem>
                                                    <SelectItem value="Lost" className="font-semibold text-[11px] uppercase text-slate-600 py-3 rounded-xl">Unaccounted (Lost)</SelectItem>
                                                </SelectContent>
                                            </Select>
                                        </div>

                                        <div className="space-y-2.5">
                                            <label className="text-[11px] font-bold text-slate-400 uppercase tracking-widest px-1">Audit Remarks</label>
                                            <Input
                                                placeholder="Add context to this assessment..."
                                                className="h-14 rounded-2xl border-slate-200 bg-white font-medium text-slate-600 placeholder:text-slate-300"
                                                value={notes}
                                                onChange={(e) => setNotes(e.target.value)}
                                            />
                                        </div>

                                        <div className="flex gap-3 pt-2">
                                            <Button
                                                variant="ghost"
                                                className="flex-1 h-14 rounded-2xl font-bold text-slate-400 uppercase tracking-widest text-[11px]"
                                                onClick={() => setAssessingLog(null)}
                                            >
                                                Cancel
                                            </Button>
                                            <Button
                                                className="flex-[2] bg-blue-600 hover:bg-blue-700 text-white h-14 rounded-2xl font-bold uppercase tracking-widest text-[11px] shadow-lg shadow-blue-100 transition-all active:scale-95"
                                                onClick={handleReturn}
                                                disabled={processingId === assessingLog.id}
                                            >
                                                {processingId === assessingLog.id ? 'Processing...' : 'Complete Return'}
                                            </Button>
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>
                    ) : (
                        <div className="p-6 space-y-5 animate-in fade-in duration-500">
                            <div className="flex items-center justify-between mb-2">
                                <h3 className="text-[11px] font-bold text-slate-400 uppercase tracking-[0.2em] px-1">Activity Timeline</h3>
                                <button
                                    onClick={fetchHistory}
                                    disabled={isHistoryLoading}
                                    className="p-2 hover:bg-slate-100 rounded-xl transition-colors text-slate-400"
                                >
                                    <RefreshCcw className={`h-3.5 w-3.5 ${isHistoryLoading ? 'animate-spin text-blue-600' : ''}`} />
                                </button>
                            </div>

                            {isHistoryLoading && historyLogs.length === 0 ? (
                                <div className="space-y-4">
                                    {[1, 2, 3, 4].map(i => (
                                        <div key={i} className="h-24 bg-slate-50 rounded-3xl animate-pulse" />
                                    ))}
                                </div>
                            ) : historyLogs.length === 0 ? (
                                <div className="flex flex-col items-center justify-center py-24 text-center">
                                    <div className="h-16 w-16 bg-slate-50 rounded-[2rem] flex items-center justify-center mb-4">
                                        <History className="h-8 w-8 text-slate-200" />
                                    </div>
                                    <p className="text-sm text-slate-500 font-semibold tracking-tight">Empty Registry</p>
                                    <p className="text-[11px] text-slate-400 mt-1 uppercase tracking-wider">No history recorded yet.</p>
                                </div>
                            ) : (
                                <div className="space-y-4 relative">
                                    {historyLogs.map((log) => (
                                        <div key={log.id} className="relative flex items-center justify-between bg-white border border-slate-100 p-5 rounded-[1.5rem] shadow-sm hover:shadow-md transition-all group overflow-hidden">
                                            <div className="flex items-center gap-4 relative z-10">
                                                <div className={`p-2.5 rounded-[1rem] border ${log.status === 'borrowed' ? 'bg-orange-50/50 border-orange-100 text-orange-500' : 'bg-emerald-50/50 border-emerald-100 text-emerald-500'}`}>
                                                    {log.status === 'borrowed' ? <ArrowUpRight className="h-4 w-4" /> : <ArrowDownLeft className="h-4 w-4" />}
                                                </div>
                                                <div>
                                                    <h4 className="font-semibold text-slate-900 group-hover:text-blue-600 transition-colors tracking-tight text-sm mb-1">{log.item_name}</h4>
                                                    <div className="flex items-center gap-2.5">
                                                        <span className={`text-[10px] font-bold uppercase tracking-widest ${log.status === 'borrowed' ? 'text-orange-500' : 'text-emerald-500'}`}>
                                                            {log.status === 'borrowed' ? 'Dispatched' : 'Accounted'}
                                                        </span>
                                                        <span className="h-1 w-1 bg-slate-200 rounded-full" />
                                                        <span className="text-[10px] text-slate-400 font-semibold uppercase tracking-wider">{log.quantity} Units</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div className="text-right relative z-10">
                                                <p className="text-[10px] text-slate-900 font-bold mb-0.5">{new Date(log.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}</p>
                                                <p className="text-[9px] text-slate-400 font-medium uppercase tracking-tight">{new Date(log.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    )}
                </div>

                <div className="p-6 bg-slate-50 border-t border-slate-100">
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-[0.2em] text-center">Institutional Audit Standard</p>
                </div>
            </SheetContent>
        </Sheet>
    )
}

