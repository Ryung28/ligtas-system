'use client'

import React, { useState, useTransition } from 'react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { 
    ChevronDown, 
    ChevronRight as ChevronRightIcon, 
    Package, 
    ChevronLeft, 
    ChevronRight,
    CheckCircle2,
    XCircle,
    Loader2
} from 'lucide-react'
import { BorrowLog, BorrowSession, TransactionStatus } from '@/lib/types/inventory'
import { InitialsAvatar } from './log-avatar'
import { ReturnDialog } from '@/components/transactions/return-dialog'
import { Card, CardContent, CardHeader, CardFooter } from '@/components/ui/card'
import { cn } from '@/lib/utils'
import { bulkReturnItems } from '@/src/features/transactions'
import { toast } from 'sonner'

interface LogSessionTableProps {
    sessions: BorrowSession[]
    expandedSessions: Set<string>
    toggleSessionExpansion: (key: string) => void
    highlightedName?: string | null
    searchQuery: string
    setSearchQuery: (query: string) => void
    statusFilter: TransactionStatus
    setStatusFilter: (status: TransactionStatus) => void
    currentPage: number
    setCurrentPage: (page: number) => void
    totalPages: number
}

export function LogSessionTable({
    sessions,
    expandedSessions,
    toggleSessionExpansion,
    highlightedName,
    searchQuery,
    setSearchQuery,
    statusFilter,
    setStatusFilter,
    currentPage,
    setCurrentPage,
    totalPages
}: LogSessionTableProps) {
    const [selectedLogIds, setSelectedLogIds] = useState<Set<number>>(new Set())
    const [isPending, startTransition] = useTransition()

    // --- Selection Logic ---
    const allReturnableIds = sessions.flatMap(s => 
        s.items.filter(i => i.status !== 'returned').map(i => i.id)
    )
    
    const isAllSelected = allReturnableIds.length > 0 && allReturnableIds.every(id => selectedLogIds.has(id))
    const isSomeSelected = allReturnableIds.some(id => selectedLogIds.has(id)) && !isAllSelected

    const toggleAllVisible = () => {
        const newSelected = new Set(selectedLogIds)
        if (isAllSelected) {
            allReturnableIds.forEach(id => newSelected.delete(id))
        } else {
            allReturnableIds.forEach(id => newSelected.add(id))
        }
        setSelectedLogIds(newSelected)
    }

    const toggleLogId = (id: number) => {
        const newSelected = new Set(selectedLogIds)
        if (newSelected.has(id)) newSelected.delete(id)
        else newSelected.add(id)
        setSelectedLogIds(newSelected)
    }

    const toggleSession = (items: BorrowLog[]) => {
        const returnableIds = items.filter(i => i.status !== 'returned').map(i => i.id)
        const allAlreadySelected = returnableIds.length > 0 && returnableIds.every(id => selectedLogIds.has(id))
        
        const newSelected = new Set(selectedLogIds)
        if (allAlreadySelected) {
            returnableIds.forEach(id => newSelected.delete(id))
        } else {
            returnableIds.forEach(id => newSelected.add(id))
        }
        setSelectedLogIds(newSelected)
    }

    const handleBatchReturn = () => {
        if (selectedLogIds.size === 0) return
        
        startTransition(async () => {
            const result = await bulkReturnItems(Array.from(selectedLogIds))
            if (result.success) {
                toast.success(result.message)
                setSelectedLogIds(new Set())
            } else {
                toast.error(result.error || "Batch return failed")
            }
        })
    }
    // UI Helpers copied from original implementation for consistency
    const getStatusBadge = (status: string) => {
        const baseClass = "inline-flex items-center px-2 py-0.5 rounded-md text-[9px] font-black uppercase tracking-widest bg-white border border-zinc-200 shadow-[0_1px_2px_rgba(0,0,0,0.03)] whitespace-nowrap";
        
        switch (status) {
            case 'borrowed':
                return (
                    <span className={baseClass}>
                        <span className="text-blue-600">Borrowed</span>
                    </span>
                )
            case 'returned':
                return (
                    <span className={baseClass}>
                        <span className="text-emerald-600">Returned</span>
                    </span>
                )
            case 'overdue':
                return (
                    <span className={`${baseClass} border-rose-100`}>
                        <span className="text-rose-600">Overdue</span>
                    </span>
                )
            case 'pending':
                return (
                    <span className={baseClass}>
                        <span className="text-amber-600">Review Pending</span>
                    </span>
                )
            case 'staged':
                return (
                    <span className={`${baseClass} border-amber-200 bg-amber-50`}>
                        <span className="text-amber-700">Ready for Pickup</span>
                    </span>
                )
            case 'reserved':
                return (
                    <span className={`${baseClass} border-indigo-200 bg-indigo-50`}>
                        <span className="text-indigo-700">Reserved</span>
                    </span>
                )
            default:
                return (
                    <span className={baseClass}>
                        <span className="text-zinc-600">{status}</span>
                    </span>
                )
        }
    }

    const getUrgencyColor = (dateString: string | null, status: string) => {
        if (!dateString || status === 'returned') return 'text-gray-700'
        const date = new Date(dateString)
        const now = new Date()
        const diffDays = Math.ceil((date.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
        if (diffDays < 0) return 'text-red-600 font-bold'
        if (diffDays <= 3) return 'text-amber-600 font-semibold'
        return 'text-gray-700'
    }

    const formatDate = (dateString: string | null) => {
        if (!dateString) return 'N/A'
        return new Date(dateString).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        })
    }

    return (
        <Card className="bg-white/95 backdrop-blur-xl border border-zinc-200/60 rounded-2xl overflow-hidden flex flex-col shadow-[0_8px_40px_rgb(0,0,0,0.03),inset_0_1px_0_rgba(255,255,255,0.8)]">
            <CardHeader className="border-b border-zinc-100/80 p-3 14in:p-4 bg-white/50">
                <div className="flex flex-col md:flex-row gap-3 justify-between items-center">
                    <div className="flex items-center gap-3 w-full md:w-auto">
                        <h2 className="text-[13px] font-bold text-gray-900 uppercase tracking-tight">Transaction History</h2>
                        {searchQuery && (
                            <span className="text-[10px] bg-slate-100 px-2 py-0.5 rounded-full text-slate-500 font-bold">
                                Filtering: {searchQuery}
                            </span>
                        )}
                    </div>

                    <div className="flex flex-wrap gap-2 w-full md:w-auto">
                        <Select value={statusFilter} onValueChange={(v: any) => setStatusFilter(v)}>
                            <SelectTrigger className="w-[140px] h-9 bg-white border-gray-200 rounded-lg text-[13px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                                <SelectValue placeholder="Status" />
                            </SelectTrigger>
                            <SelectContent className="rounded-lg border-gray-200 shadow-lg p-1">
                                <SelectItem value="all" className="text-[13px] rounded-md">All Transactions</SelectItem>
                                <SelectItem value="pending" className="text-[13px] rounded-md">Pending Review</SelectItem>
                                <SelectItem value="reserved" className="text-[13px] rounded-md">Reserved</SelectItem>
                                <SelectItem value="staged" className="text-[13px] rounded-md">Ready for Pickup</SelectItem>
                                <SelectItem value="borrowed" className="text-[13px] rounded-md">Borrowed</SelectItem>
                                <SelectItem value="returned" className="text-[13px] rounded-md">Returned</SelectItem>
                                <SelectItem value="overdue" className="text-[13px] rounded-md">Overdue</SelectItem>
                                <SelectItem value="cancelled" className="text-[13px] rounded-md">Cancelled</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>
            </CardHeader>

            <CardContent className="p-0 flex-1">
                <div className="overflow-x-auto">
                    <Table>
                        <TableHeader>
                            <TableRow className="bg-zinc-50/50 hover:bg-zinc-50/50 border-b border-zinc-100/80">
                                <TableHead className={cn(
                                    "transition-all duration-300 pl-4 py-1.5 text-center overflow-hidden whitespace-nowrap",
                                    (isSomeSelected || isAllSelected) ? "w-[45px] opacity-100" : "w-0 opacity-0 -ml-4"
                                )}>
                                    <Checkbox 
                                        checked={isAllSelected || (isSomeSelected ? 'indeterminate' : false)}
                                        onCheckedChange={toggleAllVisible}
                                        className="h-4 w-4 border-zinc-300 data-[state=checked]:bg-zinc-950 data-[state=checked]:border-zinc-950"
                                    />
                                </TableHead>
                                <TableHead className="w-[30px] pr-1 py-1.5 text-center"></TableHead>
                                <TableHead className="px-1.5 py-1.5 font-bold text-gray-400 text-[10px] uppercase tracking-tighter">Borrower</TableHead>
                                <TableHead className="px-1.5 py-1.5 font-bold text-gray-400 text-[10px] uppercase tracking-tighter">Authorized By</TableHead>
                                <TableHead className="px-1.5 py-1.5 font-bold text-gray-400 text-[10px] uppercase tracking-tighter">Issued By</TableHead>
                                <TableHead className="px-1.5 py-1.5 font-bold text-gray-400 text-[10px] uppercase tracking-tighter">Items</TableHead>
                                <TableHead className="px-1.5 py-1.5 font-bold text-gray-400 text-[10px] uppercase tracking-tighter text-left">Borrowed At</TableHead>
                                <TableHead className="px-1.5 py-1.5 font-bold text-gray-400 text-[10px] uppercase tracking-tighter text-left">Return Date</TableHead>
                                <TableHead className="pl-1.5 pr-4 14in:pr-6 py-1.5 text-right font-bold text-gray-400 text-[10px] uppercase tracking-tighter">Status</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {sessions.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={9} className="h-72 text-center border-none">
                                        <div className="flex flex-col items-center justify-center p-10">
                                            <div className="bg-gray-50 h-12 w-12 rounded-xl flex items-center justify-center mb-4 ring-1 ring-slate-100">
                                                <Package className="h-6 w-6 text-gray-300" />
                                            </div>
                                            <p className="text-gray-900 font-bold text-sm">NO LOGS FOUND</p>
                                            <p className="text-[12px] text-gray-400 mt-1 uppercase font-bold tracking-tighter">
                                                No records match your current search
                                            </p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                sessions.map((session) => (
                                    <LogSessionRow
                                        key={session.key}
                                        session={session}
                                        isExpanded={expandedSessions.has(session.key)}
                                        onToggleExpand={() => toggleSessionExpansion(session.key)}
                                        formatDate={formatDate}
                                        getUrgencyColor={getUrgencyColor}
                                        getStatusBadge={getStatusBadge}
                                        isHighlighted={highlightedName === session.borrower_name}
                                        selectedLogIds={selectedLogIds}
                                        toggleSession={() => toggleSession(session.items)}
                                        toggleLogId={toggleLogId}
                                        isAllSelected={isAllSelected}
                                        isSomeSelected={isSomeSelected}
                                    />
                                ))
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>

            {totalPages > 1 && (
                <CardFooter className="border-t border-zinc-100/80 bg-white/50 px-4 14in:px-6 py-3 flex items-center justify-between">
                    <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">
                        Page <span className="text-slate-900">{currentPage}</span> of <span className="text-slate-900">{totalPages}</span>
                    </p>
                    <div className="flex gap-1.5">
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                            disabled={currentPage === 1}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200"
                        >
                            <ChevronLeft className="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                            disabled={currentPage === totalPages}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200"
                        >
                            <ChevronRight className="h-4 w-4" />
                        </Button>
                    </div>
                </CardFooter>
            )}

            {/* 🚀 KINETIC BATCH ACTION DOCK */}
            {selectedLogIds.size > 0 && (
                <div className="sticky bottom-4 left-0 right-0 flex justify-center z-[100] pointer-events-none px-4">
                    <div className="bg-zinc-950/95 backdrop-blur-md text-white px-5 py-3.5 rounded-2xl shadow-2xl flex items-center gap-6 pointer-events-auto border border-white/10 animate-in fade-in slide-in-from-bottom-5 duration-500 max-w-2xl w-full sm:w-auto">
                        <div className="flex items-center gap-3 pr-6 border-r border-white/10">
                            <div className="h-9 w-9 rounded-xl bg-blue-600 flex items-center justify-center shadow-lg shadow-blue-500/20">
                                <Package className="h-5 w-5 text-white" />
                            </div>
                            <div className="flex flex-col">
                                <span className="text-[10px] font-black text-blue-400 uppercase tracking-widest leading-none mb-1">Batch Operations</span>
                                <span className="text-[15px] font-bold tracking-tight leading-none">{selectedLogIds.size} <span className="text-zinc-400 font-medium">Items Selected</span></span>
                            </div>
                        </div>

                        <div className="flex items-center gap-2">
                            <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => setSelectedLogIds(new Set())}
                                disabled={isPending}
                                className="text-zinc-400 hover:text-white hover:bg-white/10 h-9 font-bold text-[12px] uppercase tracking-wide"
                            >
                                <XCircle className="h-4 w-4 mr-2" />
                                Clear
                            </Button>
                            <Button
                                size="sm"
                                onClick={handleBatchReturn}
                                disabled={isPending}
                                className="bg-white text-zinc-950 hover:bg-zinc-200 h-9 px-6 rounded-xl font-black text-[12px] uppercase tracking-wide shadow-lg group relative overflow-hidden"
                            >
                                {isPending ? (
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                ) : (
                                    <div className="flex items-center gap-2">
                                        <CheckCircle2 className="h-4 w-4 mr-1 text-emerald-600" />
                                        Batch Return
                                    </div>
                                )}
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </Card>
    )
}

function LogSessionRow({
    session,
    isExpanded,
    onToggleExpand,
    formatDate,
    getUrgencyColor,
    getStatusBadge,
    isHighlighted,
    selectedLogIds,
    toggleSession,
    toggleLogId,
    isAllSelected,
    isSomeSelected
}: any) {
    const returnableItems = session.items.filter((i: any) => i.status !== 'returned')
    const hasReturnable = returnableItems.length > 0
    const allItemsSelected = hasReturnable && returnableItems.every((i: any) => selectedLogIds.has(i.id))
    const someItemsSelected = hasReturnable && returnableItems.some((i: any) => selectedLogIds.has(i.id)) && !allItemsSelected

    return (
        <React.Fragment>
            <TableRow
                className={cn(
                  "hover:bg-zinc-50/40 group border-b border-zinc-100/40 cursor-pointer select-none transition-all duration-500 h-11",
                  isHighlighted && "animate-highlight-pulse border-l-[4px] z-10"
                )}
                onClick={onToggleExpand}
            >
                <TableCell 
                    className={cn(
                        "p-0 transition-all duration-300 overflow-hidden whitespace-nowrap text-center",
                        (isSomeSelected || isAllSelected || selectedLogIds.size > 0 || allItemsSelected || someItemsSelected) 
                            ? "w-[45px] opacity-100 pl-4" 
                            : hasReturnable ? "w-0 opacity-0 group-hover:w-[45px] group-hover:opacity-100 group-hover:pl-4" : "w-0 opacity-0"
                    )} 
                    onClick={(e) => e.stopPropagation()}
                >
                    {hasReturnable ? (
                        <Checkbox 
                            checked={allItemsSelected || (someItemsSelected ? 'indeterminate' : false)}
                            onCheckedChange={toggleSession}
                            className="h-4 w-4 border-zinc-200 data-[state=checked]:bg-zinc-900 group-hover:border-zinc-400 transition-colors"
                        />
                    ) : (
                        <div className="w-4 h-4 mx-auto" />
                    )}
                </TableCell>
                <TableCell className="px-1 w-[30px] text-center">
                    {isExpanded ? <ChevronDown className="h-4 w-4 text-gray-400 mx-auto" /> : <ChevronRightIcon className="h-4 w-4 text-gray-400 mx-auto" />}
                </TableCell>
                <TableCell className="px-1.5 py-1.5">
                    <div className="flex items-center gap-1.5">
                        <InitialsAvatar name={session.borrower_name} size={7} />
                        <div className="flex flex-col min-w-0">
                            <span className="text-[13px] font-bold text-gray-900 truncate tracking-tight leading-none mb-0.5">{session.borrower_name}</span>
                            <span className="text-[10px] text-gray-400 truncate leading-none uppercase font-bold">{session.borrower_organization}</span>
                        </div>
                    </div>
                </TableCell>
                <TableCell className="px-1.5 py-1.5">
                    <span className="text-[11px] font-black text-zinc-950 uppercase tracking-tight block truncate" title={session.approved_by_name}>
                        {session.approved_by_name?.split(' ')[0] || '—'}
                    </span>
                    <span className="text-[9px] font-bold text-zinc-400 uppercase leading-none block mt-0.5">Authorize</span>
                </TableCell>
                <TableCell className="px-1.5 py-1.5">
                    <span className="text-[11px] font-black text-zinc-950 uppercase tracking-tight block truncate" title={session.released_by_name}>
                        {session.released_by_name?.split(' ')[0] || '—'}
                    </span>
                    <span className="text-[9px] font-bold text-zinc-400 uppercase leading-none block mt-0.5">Release</span>
                </TableCell>
                <TableCell className="px-1.5 py-1.5">
                    <div className="flex items-center gap-1">
                        <Package className="h-3.5 w-3.5 text-gray-400" />
                        <span className="text-[13px] font-bold text-gray-900 leading-none">{session.items.length} ITEMS</span>
                    </div>
                </TableCell>
                <TableCell className="px-1.5 py-1.5">
                    <div className="flex flex-col">
                        <span className="text-[12px] font-bold text-zinc-900 tracking-tight leading-none">
                            {new Date(session.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                        </span>
                        <span className="text-[10px] font-bold text-zinc-300 uppercase leading-none mt-0.5">
                            {new Date(session.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })}
                        </span>
                        {session.status === 'staged' && session.pickup_scheduled_at && (
                            <span className="text-[9px] font-black text-amber-600 uppercase mt-1 leading-none">
                                PICKUP: {new Date(session.pickup_scheduled_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                            </span>
                        )}
                    </div>
                </TableCell>
                <TableCell className="px-1.5 py-1.5">
                    {session.status === 'returned' ? (() => {
                        const returnDates = session.items
                            .map((i: any) => i.actual_return_date)
                            .filter(Boolean)
                            .map((d: any) => new Date(d));
                        const lastReturnDate = returnDates.length > 0 ? new Date(Math.max(...returnDates.map((d: Date) => d.getTime()))) : null;

                        if (!lastReturnDate) return <span className="text-zinc-200 text-[10px] font-bold uppercase tracking-tight">—</span>;

                        return (
                            <div className="flex flex-col">
                                <span className="text-[12px] font-bold text-emerald-900 tracking-tight leading-none">
                                    {lastReturnDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                                </span>
                            </div>
                        );
                    })() : (
                        <span className="text-zinc-200 text-[10px] font-bold uppercase tracking-tight">—</span>
                    )}
                </TableCell>
                <TableCell className="pl-1.5 pr-4 14in:pr-6 py-1.5 text-right">
                    <div className="flex justify-end">
                        {getStatusBadge(session.status)}
                    </div>
                </TableCell>
            </TableRow>

            {isExpanded && (
                <TableRow className="bg-slate-50/30 hover:bg-slate-50/30">
                    <TableCell colSpan={9} className="p-0 border-b border-zinc-200">
                        <div className="flex flex-col animate-in fade-in slide-in-from-top-1 duration-200">
                            {/* 📑 ENTERPRISE MANIFEST VIEW: Clean, Inset Document Pattern */}
                            <div className="flex">
                                {/* Visual Hierarchy Indent */}
                                <div className="w-12 14in:w-16 flex justify-center pt-4">
                                    <div className="w-[2px] h-full bg-blue-600/20 rounded-full" />
                                </div>

                                <div className="flex-1 pr-6 py-4">
                                    {/* Sub-Header: Inset & Minimalist */}
                                    <div className="flex items-center gap-4 mb-4 pb-2 border-b border-zinc-200/60">
                                        <div className="flex items-center gap-2">
                                            <Package className="h-3.5 w-3.5 text-blue-600" />
                                            <h3 className="text-[11px] font-black text-slate-900 uppercase tracking-widest">Return Verification Audit</h3>
                                        </div>
                                        <div className="flex items-center gap-3 text-[10px] font-mono text-slate-400">
                                            <span className="flex items-center gap-1.5">
                                                <span className="w-1 h-1 rounded-full bg-zinc-300" />
                                                ITEMS: <span className="text-slate-600 font-bold">{session.items.length}</span>
                                            </span>
                                        </div>
                                    </div>

                                    {/* FLAT MANIFEST LIST */}
                                    <div className="bg-white rounded-xl border border-zinc-200/80 shadow-sm divide-y divide-zinc-100 overflow-hidden">
                                        {session.items.map((item: BorrowLog, index: number) => {
                                            const hasReturnRequest = item.notes?.includes('BORROWER INITIATED RETURN');
                                            const isReturned = item.status === 'returned';
                                            const isOverdue = item.status === 'borrowed' && item.expected_return_date && new Date(item.expected_return_date) < new Date();
                                            
                                            return (
                                                <div 
                                                    key={item.id} 
                                                    className={cn(
                                                        "flex flex-col md:flex-row items-center gap-6 px-5 py-3 transition-colors",
                                                        index % 2 === 0 ? "bg-white" : "bg-slate-50/20",
                                                        selectedLogIds.has(item.id) && "bg-blue-50/40"
                                                    )}
                                                >
                                                    {/* SELECTION */}
                                                    <div className={cn(
                                                        "transition-all duration-300 overflow-hidden whitespace-nowrap flex justify-center",
                                                        (selectedLogIds.has(item.id) || selectedLogIds.size > 0)
                                                            ? "w-8 opacity-100"
                                                            : (!isReturned) ? "w-0 opacity-0 group-hover:w-8 group-hover:opacity-100" : "w-0 opacity-0"
                                                    )}>
                                                        {!isReturned ? (
                                                            <Checkbox 
                                                                checked={selectedLogIds.has(item.id)}
                                                                onCheckedChange={() => toggleLogId(item.id)}
                                                                className="h-4 w-4 border-zinc-200"
                                                            />
                                                        ) : (
                                                            <div className="w-4 h-4" />
                                                        )}
                                                    </div>
                                                    {/* ID & NAME */}
                                                    <div className="flex-1 flex flex-col min-w-0">
                                                        <div className="flex items-center gap-2 mb-0.5">
                                                            <span className="text-xs font-black text-slate-800 tracking-tight">{item.item_name}</span>
                                                            {hasReturnRequest && (
                                                                <span className="text-[8px] font-black bg-amber-500 text-white px-1.5 py-0.5 rounded-full uppercase tracking-tighter shadow-sm animate-pulse">
                                                                    Return Req
                                                                </span>
                                                            )}
                                                        </div>
                                                    </div>

                                                    {/* TRANSACTION STATUS */}
                                                    <div className="w-28">
                                                        <div className={cn(
                                                            "text-[11px] font-black uppercase tracking-[0.1em] text-center md:text-left",
                                                            isReturned ? "text-emerald-600" : 
                                                            isOverdue ? "text-rose-600" : "text-blue-600"
                                                        )}>
                                                            {item.status}
                                                        </div>
                                                    </div>

                                                    {/* TIMELINE */}
                                                    <div className="w-40 flex flex-col">
                                                        <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-0.5">
                                                            {isReturned ? 'Checked In' : 'Return Due'}
                                                        </span>
                                                        <span className={cn(
                                                            "text-[11px] font-mono font-bold leading-none",
                                                            isOverdue ? "text-rose-600" : "text-slate-600"
                                                        )}>
                                                            {formatDate(isReturned ? item.actual_return_date : item.expected_return_date).toUpperCase()}
                                                        </span>
                                                        <span className="text-[9px] font-bold text-slate-300 uppercase mt-1">
                                                            {isReturned ? 'Arrival Date' : 'Due Date'}
                                                        </span>
                                                    </div>

                                                    {/* AUDIT / ACTION */}
                                                    <div className="w-72 flex items-center justify-end min-h-[32px]">
                                                        {isReturned ? (
                                                            <div className="flex flex-col items-end gap-1">
                                                                <div className="flex items-center gap-2">
                                                                    {item.return_condition && item.return_condition !== 'good' && (
                                                                        <span className={cn(
                                                                            "text-[10px] font-black uppercase px-1.5 py-0.5 rounded border shadow-sm",
                                                                            item.return_condition === 'fair' ? "text-amber-700 bg-amber-50 border-amber-100" :
                                                                            "text-rose-700 bg-rose-50 border-rose-100"
                                                                        )}>
                                                                            {item.return_condition}
                                                                        </span>
                                                                    )}
                                                                    <span className="text-[11px] font-bold text-slate-500 uppercase tracking-tight">
                                                                        Verified: <span className="text-slate-900">{item.received_by_name?.split(' ')[0]}</span>
                                                                    </span>
                                                                </div>
                                                                {item.return_notes && (
                                                                    <p className="text-[9px] text-slate-400 italic max-w-[240px] text-right truncate" title={item.return_notes}>
                                                                        &quot;{item.return_notes}&quot;
                                                                    </p>
                                                                )}
                                                            </div>
                                                        ) : (
                                                            <ReturnDialog
                                                                logId={item.id}
                                                                itemName={item.item_name}
                                                                borrowerName={item.borrower_name}
                                                                quantity={item.quantity}
                                                            />
                                                        )}
                                                    </div>
                                                </div>
                                            );
                                        })}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </TableCell>
                </TableRow>
            )}
        </React.Fragment>
    )
}
