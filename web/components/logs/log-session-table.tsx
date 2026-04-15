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
    Loader2,
    RotateCcw,
    Phone,
    Building,
    MessageSquare,
    Maximize2,
    ShieldCheck,
    Clock,
    Calendar
} from 'lucide-react'
import Image from 'next/image'
import { motion, AnimatePresence } from 'framer-motion'
import { getInventoryImageUrl } from '@/lib/supabase'
import { BorrowLog, BorrowSession, TransactionStatus } from '@/lib/types/inventory'
import { InitialsAvatar } from './log-avatar'
import { ReturnCommandSheet } from '@/src/features/transactions/v2/return-command-sheet'
import { Card, CardContent, CardHeader, CardFooter } from '@/components/ui/card'
import { cn } from '@/lib/utils'
import { bulkReturnItems, revertReturnItem, releaseReservedItem } from '@/src/features/transactions'
import { 
    Dialog as ShadinDialog, 
    DialogContent as ShadinDialogContent, 
    DialogHeader as ShadinDialogHeader, 
    DialogTitle as ShadinDialogTitle 
} from '@/components/ui/dialog'
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
    const [expandedImage, setExpandedImage] = useState<{ url: string, name: string } | null>(null)

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
    // UI Helpers
    const getStatusBadge = (status: string) => {
        const baseClass = "inline-flex items-center px-2 py-0.5 rounded-md text-[9px] font-black uppercase tracking-widest bg-white border border-zinc-200 shadow-[0_1px_2px_rgba(0,0,0,0.03)]";
        
        switch (status) {
            case 'borrowed':
                return <span className={baseClass}><span className="text-blue-600">Borrowed</span></span>
            case 'returned':
                return <span className={baseClass}><span className="text-emerald-600">Returned</span></span>
            case 'overdue':
                return <span className={`${baseClass} border-rose-100 bg-rose-50/30 font-black text-rose-600`}>Overdue</span>
            case 'staged':
                return <span className={`${baseClass} border-amber-200 bg-amber-50 text-amber-700`}>Staged</span>
            case 'reserved':
                return <span className={`${baseClass} border-indigo-200 bg-indigo-50 text-indigo-700`}>Reserved</span>
            case 'pending':
                return <span className={baseClass}><span className="text-amber-600">Pending</span></span>
            default:
                return <span className={baseClass}><span className="text-zinc-600">{status}</span></span>
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
                                        onImageClick={(url, name) => setExpandedImage({ url, name })}
                                        formatDate={formatDate}
                                        getUrgencyColor={getUrgencyColor}
                                        getStatusBadge={getStatusBadge}
                                        isHighlighted={highlightedName === session.borrower_name}
                                        selectedLogIds={selectedLogIds}
                                        toggleSession={() => toggleSession(session.items)}
                                        toggleLogId={toggleLogId}
                                        isAllSelected={isAllSelected}
                                        isSomeSelected={isSomeSelected}
                                        isPending={isPending}
                                        startTransition={startTransition}
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
            {/* ── Image Preview Dialog ── */}
            <ShadinDialog open={!!expandedImage} onOpenChange={(open) => !open && setExpandedImage(null)}>
                <ShadinDialogContent className="max-w-3xl border-none bg-black/95 p-0 overflow-hidden rounded-2xl shadow-2xl [&>button]:text-white [&>button]:opacity-100">
                    <ShadinDialogHeader className="absolute top-4 left-4 z-50 pointer-events-none">
                        <ShadinDialogTitle className="text-white text-[10px] font-black uppercase tracking-widest bg-black/60 backdrop-blur-md px-3 py-1.5 rounded-lg border border-white/10">
                            {expandedImage?.name}
                        </ShadinDialogTitle>
                    </ShadinDialogHeader>
                    <div className="relative w-full aspect-square md:aspect-video flex items-center justify-center p-8">
                        {expandedImage && (
                            <Image
                                src={expandedImage.url}
                                alt={expandedImage.name}
                                fill
                                unoptimized
                                className="object-contain rounded-lg animate-in zoom-in-95 duration-300"
                            />
                        )}
                    </div>
                </ShadinDialogContent>
            </ShadinDialog>
        </Card>
    )
}

function LogSessionRow({
    session,
    isExpanded,
    onToggleExpand,
    onImageClick,
    formatDate,
    getUrgencyColor,
    getStatusBadge,
    isHighlighted,
    selectedLogIds,
    toggleSession,
    toggleLogId,
    isAllSelected,
    isSomeSelected,
    isPending,
    startTransition
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
                        {(session.status === 'staged' || session.status === 'reserved') && session.pickup_scheduled_at && (
                            <span className={cn(
                                "text-[9px] font-black uppercase mt-1 leading-none animate-pulse",
                                session.status === 'staged' ? "text-amber-600" : "text-indigo-600"
                            )}>
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

            <AnimatePresence initial={false}>
                {isExpanded && (
                    <TableRow className="bg-slate-50/10 hover:bg-slate-50/10 border-none overflow-hidden">
                        <TableCell colSpan={9} className="p-0 border-b border-zinc-100 overflow-hidden">
                            <motion.div 
                                initial={{ height: 0, opacity: 0, scaleY: 0.95 }}
                                animate={{ height: 'auto', opacity: 1, scaleY: 1 }}
                                exit={{ height: 0, opacity: 0, scaleY: 0.95 }}
                                transition={{ type: 'spring', stiffness: 400, damping: 30 }}
                                className="overflow-hidden"
                            >
                                <div className="px-6 py-5 flex gap-8">
                                    {/* Sidebar: Borrower Profile */}
                                    <div className="w-64 flex-shrink-0 space-y-4">
                                        <div>
                                            <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">Personnel Details</p>
                                            <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm space-y-4">
                                                {/* Borrower Info */}
                                                <div className="flex items-center gap-3">
                                                    <InitialsAvatar name={session.borrower_name} size={10} />
                                                    <div className="min-w-0">
                                                        <p className="text-sm font-black text-slate-900 leading-tight truncate">{session.borrower_name}</p>
                                                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-tighter mt-0.5">{session.borrower_organization || 'External Member'}</p>
                                                    </div>
                                                </div>

                                                {/* Contact Details */}
                                                <div className="pt-3 space-y-2.5 border-t border-slate-50">
                                                    <div className="flex items-center gap-2">
                                                        <Phone className="h-3 w-3 text-slate-400" />
                                                        <p className="text-[11px] font-bold text-slate-600">{session.borrower_contact || 'None'}</p>
                                                    </div>
                                                    <div className="flex items-center gap-2">
                                                        <Building className="h-3 w-3 text-slate-400" />
                                                        <p className="text-[11px] font-bold text-slate-600 truncate">{session.borrower_organization || 'Office not set'}</p>
                                                    </div>
                                                </div>

                                                {/* Dispatch Sign-off: Chain of Command */}
                                                <div className="pt-3 space-y-3 border-t border-slate-50">
                                                    <div className="flex flex-col gap-1">
                                                        <div className="flex items-center gap-1.5 opacity-50">
                                                            <ShieldCheck className="h-3 w-3 text-blue-500" />
                                                            <span className="text-[9px] font-black text-slate-500 uppercase tracking-widest">Approved By</span>
                                                        </div>
                                                        <p className="text-[11px] font-black text-slate-800 pl-4.5">{session.approved_by_name || 'System Auto'}</p>
                                                    </div>
                                                    <div className="flex flex-col gap-1">
                                                        <div className="flex items-center gap-1.5 opacity-50">
                                                            <CheckCircle2 className="h-3 w-3 text-emerald-500" />
                                                            <span className="text-[9px] font-black text-slate-500 uppercase tracking-widest">Released By</span>
                                                        </div>
                                                        <p className="text-[11px] font-black text-slate-800 pl-4.5">{session.released_by_name || 'Handoff Pending'}</p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        {session.items.some((i: any) => i.purpose) && (
                                            <div className="bg-blue-50/50 rounded-2xl p-3 border border-blue-100/50">
                                                <div className="flex items-center gap-1.5 mb-1.5">
                                                    <MessageSquare className="h-3 w-3 text-blue-400" />
                                                    <span className="text-[9px] font-black text-blue-400 uppercase tracking-widest">Declared Purpose</span>
                                                </div>
                                                <p className="text-[11px] text-slate-600 italic leading-snug">
                                                    &ldquo;{session.items.find((i: any) => i.purpose)?.purpose}&rdquo;
                                                </p>
                                            </div>
                                        )}
                                    </div>

                                    {/* Main Content: Equipment List */}
                                    <div className="flex-1">
                                        <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-3">Equipment List ({session.items.length})</p>
                                        <div className="space-y-3">
                                            {session.items.map((item: BorrowLog) => {
                                                const isReturned = item.status === 'returned'
                                                const isOverdue = item.status === 'borrowed' && item.expected_return_date && new Date(item.expected_return_date) < new Date()
                                                const imageUrl = getInventoryImageUrl((item as any).inventory?.image_url)

                                                return (
                                                    <div 
                                                        key={item.id} 
                                                        className={cn(
                                                            "bg-white rounded-2xl border p-4 flex items-center gap-5 transition-all shadow-sm",
                                                            selectedLogIds.has(item.id) ? "border-blue-200 bg-blue-50/20" : "border-slate-100"
                                                        )}
                                                    >
                                                        {/* Item Image with Preview */}
                                                        <div 
                                                            onClick={(e) => { e.stopPropagation(); if (imageUrl) onImageClick(imageUrl, item.item_name); }}
                                                            className="h-14 w-14 rounded-xl bg-slate-50 border border-slate-100 overflow-hidden flex-shrink-0 relative group cursor-pointer hover:border-blue-300 transition-all"
                                                        >
                                                            {imageUrl ? (
                                                                <>
                                                                    <Image src={imageUrl} alt={item.item_name} fill className="object-contain p-1.5 transition-transform group-hover:scale-110" unoptimized />
                                                                    <div className="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                                                                        <Maximize2 className="h-4 w-4 text-white shadow-sm" />
                                                                    </div>
                                                                </>
                                                            ) : (
                                                                <Package className="h-7 w-7 text-slate-200" strokeWidth={1} />
                                                            )}
                                                        </div>

                                                        {/* Item Info */}
                                                        <div className="flex-1 min-w-0">
                                                            <div className="flex items-center justify-between mb-1">
                                                                <p className="text-sm font-black text-slate-900 uppercase tracking-tight truncate">{item.item_name}</p>
                                                                <div className={cn(
                                                                    "text-[11px] font-black px-2.5 py-1 rounded-full uppercase tracking-tighter border",
                                                                    isReturned ? "bg-emerald-50 text-emerald-600 border-emerald-100" :
                                                                    isOverdue ? "bg-rose-50 text-rose-600 border-rose-100 animate-pulse" :
                                                                    "bg-blue-50 text-blue-600 border-blue-100"
                                                                )}>
                                                                    {isReturned ? 'Returned' : 'Borrowed'}
                                                                </div>
                                                            </div>
                                                            <div className="flex items-center gap-4">
                                                                <div className="flex items-center gap-1.5">
                                                                    <Clock className="h-3 w-3 text-slate-400" />
                                                                    <span className="text-[11px] font-bold text-slate-500">QUANTITY: {item.quantity}</span>
                                                                </div>
                                                                <div className="flex items-center gap-1.5">
                                                                    <Calendar className="h-3 w-3 text-slate-400" />
                                                                    <span className={cn(
                                                                        "text-[11px] font-bold",
                                                                        isOverdue ? "text-rose-600" : "text-slate-500"
                                                                    )}>
                                                                        {isReturned ? `Returned: ${formatDate(item.actual_return_date)}` : `Due: ${formatDate(item.expected_return_date)}`}
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        {/* Row Action Cluster */}
                                                        <div className="flex items-center gap-2 pl-4 border-l border-slate-50">
                                                            {isReturned ? (
                                                                <Button
                                                                    variant="ghost"
                                                                    size="sm"
                                                                    onClick={(e) => {
                                                                        e.stopPropagation();
                                                                        if (confirm(`ARE YOU SURE? Revert ${item.item_name} to Borrowed?`)) {
                                                                            startTransition(async () => {
                                                                                const res = await revertReturnItem(item.id);
                                                                                if (res.success) toast.success(res.message);
                                                                                else toast.error(res.error);
                                                                            });
                                                                        }
                                                                    }}
                                                                    disabled={isPending}
                                                                    className="h-8 w-8 rounded-lg text-slate-400 hover:text-blue-600"
                                                                >
                                                                    {isPending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <RotateCcw className="h-3.5 w-3.5" />}
                                                                </Button>
                                                            ) : (item.status === 'reserved' || item.status === 'staged') ? (
                                                                <Button
                                                                    size="sm"
                                                                    onClick={(e) => {
                                                                        e.stopPropagation();
                                                                        startTransition(async () => {
                                                                            const res = await releaseReservedItem(item.id);
                                                                            if (res.success) toast.success(res.message);
                                                                            else toast.error(res.error);
                                                                        });
                                                                    }}
                                                                    disabled={isPending}
                                                                    className="h-8 bg-indigo-600 hover:bg-indigo-700 text-white text-[9px] font-black uppercase px-3 rounded-lg"
                                                                >
                                                                    Release
                                                                </Button>
                                                            ) : (
                                                                <ReturnCommandSheet
                                                                    logId={item.id}
                                                                    itemName={item.item_name}
                                                                    borrowerName={item.borrower_name}
                                                                    quantity={item.quantity}
                                                                    inventoryId={item.inventory_id}
                                                                />
                                                            )}
                                                        </div>
                                                    </div>
                                                )
                                            })}
                                        </div>
                                    </div>
                                </div>
                            </motion.div>
                        </TableCell>
                    </TableRow>
                )}
            </AnimatePresence>
        </React.Fragment>
    )
}
