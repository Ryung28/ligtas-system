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
import { returnItem } from '@/src/features/transactions'
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
    }, [open, activeTab, fetchHistory])

    const handleReturn = async () => {
        if (!assessingLog) return
        try {
            setProcessingId(assessingLog.id)
            const result = await returnItem(assessingLog.id, {
                receivedByName: '',
                returnCondition: condition.toLowerCase() as any,
                returnNotes: notes
            })
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
            <SheetContent className="w-full sm:max-w-[480px] border-none p-0 overflow-hidden flex flex-col bg-transparent [&>button]:hidden">
                {/* Floating panel with rounded edges */}
                <div className="h-full m-4 flex flex-col bg-white/95 backdrop-blur-xl rounded-2xl shadow-xl overflow-hidden border border-slate-100">
                    {/* Light header matching app theme */}
                    <SheetHeader className="p-6 bg-white/50 backdrop-blur-sm border-b border-slate-100">
                        <div className="flex items-center gap-4 mb-4">
                            <div className="h-12 w-12 rounded-xl bg-blue-50 flex items-center justify-center border border-blue-100">
                                <User className="h-6 w-6 text-blue-600" />
                            </div>
                            <div>
                                <SheetTitle className="text-slate-900 text-xl font-bold tracking-tight leading-none mb-1">{userName}</SheetTitle>
                                <SheetDescription className="text-slate-500 font-medium text-[10px] uppercase tracking-[0.15em]">
                                    Equipment Audit Profile
                                </SheetDescription>
                            </div>
                        </div>

                        {/* Segmented Control - light theme */}
                        <div className="flex gap-1 bg-slate-100 p-1 rounded-xl">
                            <button
                                onClick={() => setActiveTab('active')}
                                className={`flex-1 py-2.5 text-[10px] font-bold uppercase tracking-wider rounded-lg transition-all ${activeTab === 'active' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-900'}`}
                            >
                                Active ({activeBorrows.length})
                            </button>
                            <button
                                onClick={() => setActiveTab('history')}
                                className={`flex-1 py-2.5 text-[10px] font-bold uppercase tracking-wider rounded-lg transition-all ${activeTab === 'history' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-900'}`}
                            >
                                History
                            </button>
                        </div>
                    </SheetHeader>

                    {/* Content area with light background */}
                    <div className="flex-1 overflow-y-auto bg-gray-50/50">
                    {activeTab === 'active' ? (
                        <div className="p-0">
                            {!assessingLog ? (
                                <div className="p-4 space-y-3">
                                    <div className="flex items-center justify-between mb-1">
                                        <h3 className="text-[10px] font-bold text-slate-500 uppercase tracking-[0.15em]">Equipment in Field</h3>
                                    </div>

                                    {activeBorrows.length === 0 ? (
                                        <div className="flex flex-col items-center justify-center py-16 text-center bg-slate-50/50 rounded-lg border border-slate-200">
                                            <div className="h-12 w-12 rounded-lg bg-white border border-slate-200 flex items-center justify-center mb-3">
                                                <Package className="h-6 w-6 text-slate-300" />
                                            </div>
                                            <p className="text-sm text-slate-700 font-semibold">No Active Deployments</p>
                                            <p className="text-[10px] text-slate-500 mt-1 uppercase tracking-wider font-medium">All equipment secured</p>
                                        </div>
                                    ) : (
                                        <div className="space-y-2">
                                            {activeBorrows.map((log) => (
                                                <div key={log.id} className="group relative bg-gradient-to-br from-white to-slate-50/30 rounded-lg border border-slate-200 ring-1 ring-slate-100 p-3 hover:from-slate-50 hover:to-white hover:border-blue-300 hover:shadow-sm transition-all duration-200">
                                                    {/* Subtle left border accent - 2px */}
                                                    <div className="absolute left-0 top-0 bottom-0 w-[2px] bg-blue-500 rounded-l-lg" />
                                                    
                                                    <div className="pl-3">
                                                        <div className="flex items-start justify-between gap-2 mb-2">
                                                            <div className="flex items-center gap-2">
                                                                {/* Status dot - 3px for visibility */}
                                                                <div className="h-[3px] w-[3px] rounded-full bg-orange-500 flex-shrink-0 mt-1.5" />
                                                                <h4 className="font-semibold text-slate-900 text-sm leading-tight group-hover:text-blue-600 transition-colors">{log.item_name}</h4>
                                                            </div>
                                                        </div>
                                                        
                                                        <div className="flex items-center gap-2 mb-3 flex-wrap">
                                                            <div className="flex items-center gap-1.5 px-2 py-0.5 bg-slate-100 border border-slate-200 rounded">
                                                                <Package className="h-3 w-3 text-slate-500" />
                                                                <span className="text-[11px] text-slate-700 font-medium tabular-nums">{log.quantity}</span>
                                                            </div>
                                                            <div className="flex items-center gap-1.5 px-2 py-0.5 bg-slate-100 border border-slate-200 rounded">
                                                                <Clock className="h-3 w-3 text-slate-500" />
                                                                <span className="text-[11px] text-slate-600 font-medium">
                                                                    {new Date(log.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                                                                </span>
                                                            </div>
                                                        </div>

                                                        <Button
                                                            size="sm"
                                                            variant="outline"
                                                            className="w-full h-9 rounded border-slate-300 hover:bg-blue-50 hover:border-blue-400 hover:text-blue-700 hover:shadow-sm text-slate-700 text-[11px] font-semibold uppercase tracking-wide transition-all gap-2"
                                                            onClick={() => {
                                                                setAssessingLog(log)
                                                                setCondition('Good')
                                                                setNotes('')
                                                            }}
                                                        >
                                                            <RotateCcw className="h-3.5 w-3.5" />
                                                            Process Return
                                                        </Button>
                                                    </div>
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
                        <div className="p-4 space-y-3">
                            <div className="flex items-center justify-between mb-1">
                                <h3 className="text-[10px] font-bold text-slate-500 uppercase tracking-[0.15em]">Activity Timeline</h3>
                                <button
                                    onClick={fetchHistory}
                                    disabled={isHistoryLoading}
                                    className="p-1.5 hover:bg-slate-100 rounded transition-colors text-slate-400 hover:text-slate-600"
                                >
                                    <RefreshCcw className={`h-3.5 w-3.5 ${isHistoryLoading ? 'animate-spin text-blue-600' : ''}`} />
                                </button>
                            </div>

                            {isHistoryLoading && historyLogs.length === 0 ? (
                                <div className="space-y-2">
                                    {[1, 2, 3, 4].map(i => (
                                        <div key={i} className="h-16 bg-slate-50 rounded-lg animate-pulse border border-slate-200" />
                                    ))}
                                </div>
                            ) : historyLogs.length === 0 ? (
                                <div className="flex flex-col items-center justify-center py-20 text-center">
                                    <div className="h-12 w-12 bg-slate-50 rounded-lg flex items-center justify-center mb-3 border border-slate-200">
                                        <History className="h-6 w-6 text-slate-300" />
                                    </div>
                                    <p className="text-sm text-slate-700 font-semibold">Empty Registry</p>
                                    <p className="text-[10px] text-slate-500 mt-1 uppercase tracking-wider font-medium">No history recorded</p>
                                </div>
                            ) : (
                                <div className="space-y-2">
                                    {historyLogs.map((log) => (
                                        <div key={log.id} className="flex items-start gap-3 bg-gradient-to-br from-white to-slate-50/30 border border-slate-200 ring-1 ring-slate-100 p-3 rounded-lg hover:from-slate-50 hover:to-white hover:border-slate-300 hover:shadow-sm transition-all group">
                                            {/* Status icon */}
                                            <div className={`flex-shrink-0 h-8 w-8 rounded flex items-center justify-center border ${
                                                log.status === 'borrowed' 
                                                    ? 'bg-orange-50 border-orange-200 text-orange-600' 
                                                    : 'bg-emerald-50 border-emerald-200 text-emerald-600'
                                            }`}>
                                                {log.status === 'borrowed' ? <ArrowUpRight className="h-4 w-4" /> : <ArrowDownLeft className="h-4 w-4" />}
                                            </div>
                                            
                                            <div className="flex-1 min-w-0">
                                                <div className="flex items-start justify-between gap-2 mb-1.5">
                                                    <h4 className="font-semibold text-slate-900 text-sm leading-tight group-hover:text-blue-600 transition-colors">{log.item_name}</h4>
                                                    <span className="text-[10px] text-slate-500 font-medium uppercase tracking-wide whitespace-nowrap">
                                                        {new Date(log.created_at).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                                                    </span>
                                                </div>
                                                
                                                <div className="flex items-center gap-2">
                                                    <span className={`px-1.5 py-0.5 rounded border text-[10px] font-semibold uppercase tracking-wide ${
                                                        log.status === 'borrowed' 
                                                            ? 'bg-orange-50 border-orange-200 text-orange-700' 
                                                            : 'bg-emerald-50 border-emerald-200 text-emerald-700'
                                                    }`}>
                                                        {log.status === 'borrowed' ? 'Deployed' : 'Returned'}
                                                    </span>
                                                    <span className="text-[11px] text-slate-600 font-medium tabular-nums">{log.quantity} units</span>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    )}
                    </div>

                    {/* Light footer matching theme */}
                    <div className="p-4 bg-white border-t border-slate-100">
                        <p className="text-[9px] text-slate-500 font-bold uppercase tracking-[0.15em] text-center">CDRRMO Equipment Registry</p>
                    </div>
                </div>
            </SheetContent>
        </Sheet>
    )
}

