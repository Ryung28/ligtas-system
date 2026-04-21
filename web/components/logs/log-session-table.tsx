'use client'

import React, { useState, useTransition, useRef, useEffect } from 'react'
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
    Calendar,
    MapPin,
    Monitor,
    Smartphone
} from 'lucide-react'
import Image from 'next/image'
import { motion, AnimatePresence } from 'framer-motion'
import { getInventoryImageUrl } from '@/lib/supabase'
import { BorrowLog, BorrowSession, TransactionStatus } from '@/lib/types/inventory'
import { InitialsAvatar } from './log-avatar'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { ReturnCommandSheet } from '@/src/features/transactions/v2/return-command-sheet'
import { Card, CardContent, CardHeader, CardFooter } from '@/components/ui/card'
import { cn } from '@/lib/utils'
import { bulkReturnItems, revertReturnItem, releaseReservedItem } from '@/src/features/transactions'
import { InventoryImagePreviewDialog } from '@/components/ui/inventory-image-preview-dialog'
import { toast } from 'sonner'
import { useSearchParams } from 'next/navigation'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { PackagingPill } from '../inventory/_components/packaging-pill'

import { TransactionDetailBody } from '@/src/features/transactions/components/transaction-detail-body'

const ITEM_PREVIEW_LIMIT = 4

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
    const searchParams = useSearchParams()
    const triageId = searchParams.get('id')

    // --- Selection & Batch Data ---
    const allReturnableIds = sessions.flatMap(s =>
        s.items.filter(i => i.status !== 'returned').map(i => i.id)
    )

    const selectedItemsData = React.useMemo(() => {
        return sessions
            .flatMap(s => s.items)
            .filter(i => selectedLogIds.has(i.id))
            .map(i => ({
                logId: i.id,
                itemName: i.item_name,
                quantity: i.quantity,
                inventoryId: i.inventory_id,
                imageUrl: (i as any).inventory?.image_url,
                borrowedFrom: (i as any).borrowed_from_warehouse || (i as any).inventory?.storage_location
            }))
    }, [sessions, selectedLogIds])

    const batchBorrowerName = React.useMemo(() => {
        if (selectedLogIds.size === 0) return ""
        const firstId = Array.from(selectedLogIds)[0]
        const session = sessions.find(s => s.items.some(i => i.id === firstId))
        return session?.borrower_name || "Borrower"
    }, [sessions, selectedLogIds])

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

    const formatDateTime = (dateString: string | null) => {
        if (!dateString) return 'N/A'
        return new Date(dateString).toLocaleString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
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
                                <TableHead className="w-[45px] pl-4 py-1.5 text-center overflow-hidden whitespace-nowrap opacity-100">
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
                                        onImageClick={(url: string, name: string) => setExpandedImage({ url, name })}
                                        formatDate={formatDate}
                                        formatDateTime={formatDateTime}
                                        getUrgencyColor={getUrgencyColor}
                                        getStatusBadge={getStatusBadge}
                                        isHighlighted={highlightedName === session.borrower_name}
                                        triageId={triageId}
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

                            <ReturnCommandSheet
                                items={selectedItemsData}
                                borrowerName={batchBorrowerName}
                                onActionSuccess={() => setSelectedLogIds(new Set())}
                            >
                                <Button
                                    size="sm"
                                    className="bg-white text-zinc-950 hover:bg-zinc-200 h-9 px-6 rounded-xl font-black text-[12px] uppercase tracking-wide shadow-lg group relative overflow-hidden"
                                >
                                    <div className="flex items-center gap-2">
                                        <CheckCircle2 className="h-4 w-4 mr-1 text-emerald-600" />
                                        Batch Return
                                    </div>
                                </Button>
                            </ReturnCommandSheet>
                        </div>
                    </div>
                </div>
            )}
            <InventoryImagePreviewDialog
                image={expandedImage}
                onOpenChange={(open) => !open && setExpandedImage(null)}
            />
        </Card>
    )
}

function LogSessionRow({
    session,
    isExpanded,
    onToggleExpand,
    onImageClick,
    formatDate,
    formatDateTime,
    getUrgencyColor,
    getStatusBadge,
    isHighlighted,
    triageId,
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
    const selectedSessionItems = session.items.filter((i: any) => selectedLogIds.has(i.id) && i.status !== 'returned')
    const [isItemsPreviewOpen, setIsItemsPreviewOpen] = useState(false)
    const itemsPreviewCloseTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null)
    const isPointerInsidePreviewRef = useRef(false)

    // 🛡️ ANCHOR REF: Targeted item location tracking
    const targetedItemRef = useRef<HTMLDivElement>(null)

    // 🏎️ AUTO-SCROLL ENGINE: Triggers when the parent session is expanded
    useEffect(() => {
        if (isExpanded && triageId) {
            const hasTarget = session.items.some((item: any) => String(item.id) === String(triageId))
            if (hasTarget) {
                const timer = setTimeout(() => {
                    targetedItemRef.current?.scrollIntoView({
                        behavior: 'smooth',
                        block: 'center'
                    })
                }, 350)
                return () => clearTimeout(timer)
            }
        }
    }, [isExpanded, triageId, session.items])

    useEffect(() => {
        return () => {
            if (itemsPreviewCloseTimerRef.current) {
                clearTimeout(itemsPreviewCloseTimerRef.current)
            }
        }
    }, [])

    const openItemsPreview = () => {
        if (itemsPreviewCloseTimerRef.current) {
            clearTimeout(itemsPreviewCloseTimerRef.current)
            itemsPreviewCloseTimerRef.current = null
        }
        isPointerInsidePreviewRef.current = true
        setIsItemsPreviewOpen(true)
    }

    const closeItemsPreview = () => {
        isPointerInsidePreviewRef.current = false
        if (itemsPreviewCloseTimerRef.current) {
            clearTimeout(itemsPreviewCloseTimerRef.current)
        }
        // Tiny delay prevents flicker while cursor moves to overlay.
        itemsPreviewCloseTimerRef.current = setTimeout(() => {
            if (!isPointerInsidePreviewRef.current) {
                setIsItemsPreviewOpen(false)
            }
        }, 120)
    }

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
                        hasReturnable ? "w-[45px] opacity-100 pl-4" : "w-0 opacity-0"
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
                            <div className="flex items-center gap-1">
                                <span className="text-[13px] font-bold text-gray-900 truncate tracking-tight leading-none mb-0.5">{session.borrower_name}</span>
                                {(session.created_origin ?? session.platform_origin) === 'Web' ? (
                                    <Monitor className="h-2.5 w-2.5 text-blue-400" />
                                ) : (session.created_origin ?? session.platform_origin) === 'Mobile' ? (
                                    <Smartphone className="h-2.5 w-2.5 text-orange-400" />
                                ) : null}
                            </div>
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
                    <Popover open={isItemsPreviewOpen} onOpenChange={setIsItemsPreviewOpen}>
                        <PopoverTrigger asChild>
                            <button
                                type="button"
                                className="flex items-center gap-1 rounded-md px-1 py-0.5 hover:bg-zinc-100/70 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-400/60"
                                onClick={(e) => e.stopPropagation()}
                                onMouseDown={(e) => e.stopPropagation()}
                                onMouseEnter={openItemsPreview}
                                onMouseLeave={closeItemsPreview}
                                onKeyDown={(e) => {
                                    if (e.key === 'Enter' || e.key === ' ') {
                                        e.preventDefault()
                                        setIsItemsPreviewOpen((prev) => !prev)
                                    } else if (e.key === 'Escape') {
                                        setIsItemsPreviewOpen(false)
                                    }
                                }}
                                aria-label={`View ${session.items.length} item details`}
                            >
                                <Package className="h-3.5 w-3.5 text-gray-400" />
                                <span className="text-[13px] font-bold text-gray-900 leading-none">{session.items.length} ITEMS</span>
                            </button>
                        </PopoverTrigger>
                        <PopoverContent
                            align="start"
                            side="top"
                            className="w-[300px] p-3 border-zinc-200 shadow-xl"
                            onClick={(e) => e.stopPropagation()}
                            onMouseEnter={openItemsPreview}
                            onMouseLeave={closeItemsPreview}
                            onCloseAutoFocus={(e) => e.preventDefault()}
                        >
                            <p className="text-[10px] font-black text-zinc-500 uppercase tracking-wider mb-2">
                                Equipment Preview
                            </p>
                            <div className="space-y-2">
                                {session.items.slice(0, ITEM_PREVIEW_LIMIT).map((item: BorrowLog, idx: number) => (
                                    <motion.div
                                        key={item.id}
                                        initial={{ opacity: 0, y: 4 }}
                                        animate={{ opacity: 1, y: 0, transition: { duration: 0.18, delay: idx * 0.04 } }}
                                        whileHover={{ x: 2 }}
                                        className="flex items-center gap-2.5 rounded-md p-1 transition-colors hover:bg-zinc-50"
                                    >
                                        <div className="h-8 w-8 rounded-md overflow-hidden border border-zinc-200 bg-zinc-50 shrink-0">
                                            <TacticalAssetImage
                                                url={item.image_url}
                                                alt={item.item_name}
                                                size="full"
                                            />
                                        </div>
                                        <div className="min-w-0">
                                            <p className="text-[12px] font-bold text-zinc-900 truncate">{item.item_name}</p>
                                            <p className="text-[10px] font-bold text-zinc-400 uppercase tracking-wide">
                                                Qty: {item.quantity}
                                            </p>
                                        </div>
                                    </motion.div>
                                ))}
                            </div>
                            {session.items.length > ITEM_PREVIEW_LIMIT && (
                                <p className="mt-2 text-[10px] font-bold text-zinc-500 uppercase tracking-wide">
                                    +{session.items.length - ITEM_PREVIEW_LIMIT} more item(s)
                                </p>
                            )}
                        </PopoverContent>
                    </Popover>
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
                                <span className="text-[10px] font-bold text-emerald-500 uppercase leading-none mt-0.5">
                                    {lastReturnDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })}
                                </span>
                            </div>
                        );
                    })() : (
                        <span className="text-zinc-200 text-[10px] font-bold uppercase tracking-tight">—</span>
                    )}
                </TableCell>
                <TableCell className="pl-1.5 pr-4 14in:pr-6 py-1.5 text-right">
                    <div className="flex justify-end">
                        {(() => {
                            const isLiveOverdue = session.status === 'borrowed' && session.items.some((item: any) =>
                                item.expected_return_date && new Date(item.expected_return_date) < new Date()
                            );
                            return getStatusBadge(isLiveOverdue ? 'overdue' : session.status);
                        })()}
                    </div>
                </TableCell>
            </TableRow>

            <AnimatePresence initial={false}>
                {isExpanded && (
                    <TableRow className="bg-slate-50/10 hover:bg-slate-50/10 border-none overflow-hidden">
                        <TableCell colSpan={9} className="p-0 border-b border-zinc-100 overflow-hidden">
                            <motion.div
                                initial={{ height: 0, opacity: 0 }}
                                animate={{ height: 'auto', opacity: 1 }}
                                exit={{ height: 0, opacity: 0 }}
                                transition={{ duration: 0.3, ease: [0.33, 1, 0.68, 1] }}
                                className="overflow-hidden"
                            >
                                <div className="p-3 14in:p-5 bg-white border-b border-zinc-100/50">
                                    <div className="flex flex-col md:flex-row gap-4 14in:gap-6">
                                        {/* 👤 LEFT RAIL: PERSONNEL DETAILS */}
                                        <div className="w-full md:w-[250px] space-y-4 shrink-0">
                                            <div className="space-y-3">
                                                <p className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">Personnel Details</p>
                                                <div className="bg-white rounded-[26px] border border-slate-100 p-5 shadow-sm border-b-2 border-b-slate-100/30">
                                                    <div className="flex items-center gap-4 mb-6">
                                                        <InitialsAvatar name={session.borrower_name} size={11} />
                                                        <div>
                                                            <h3 className="text-lg font-bold text-gray-900 tracking-tight leading-none mb-1">{session.borrower_name}</h3>
                                                            <p className="text-[11px] font-bold text-gray-400 uppercase tracking-tight">{session.borrower_organization || 'External'}</p>
                                                        </div>
                                                    </div>

                                                    <div className="space-y-4">
                                                        <div className="flex items-center gap-3 text-slate-600">
                                                            <div className="h-7 w-7 rounded-lg bg-slate-50 flex items-center justify-center">
                                                                <Phone className="w-3.5 h-3.5 text-slate-300" />
                                                            </div>
                                                            <span className="text-[12px] font-bold tracking-tight">{session.borrower_contact || 'No Contact'}</span>
                                                        </div>
                                                        <div className="flex items-center gap-3 text-slate-600">
                                                            <div className="h-7 w-7 rounded-lg bg-slate-50 flex items-center justify-center">
                                                                <Building className="w-3.5 h-3.5 text-slate-300" />
                                                            </div>
                                                            <span className="text-[12px] font-bold tracking-tight line-clamp-1">{session.borrower_organization || 'Department'}</span>
                                                        </div>
                                                    </div>

                                                    <div className="mt-8 pt-6 border-t border-slate-50 space-y-5">
                                                        <div className="space-y-1.5 opacity-90">
                                                            <span className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Authorized By</span>
                                                            <div className="flex items-center gap-2">
                                                                <ShieldCheck className="w-3 h-3 text-blue-500" />
                                                                <span className="text-[11px] font-bold text-slate-900 uppercase tracking-tight">{session.approved_by_name?.split(' ')[0] || 'System'}</span>
                                                            </div>
                                                        </div>
                                                        <div className="space-y-1.5 opacity-90">
                                                            <span className="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Issued By</span>
                                                            <div className="flex items-center gap-2">
                                                                <CheckCircle2 className="w-3 h-3 text-emerald-500" />
                                                                <span className="text-[11px] font-bold text-slate-900 uppercase tracking-tight">{session.released_by_name?.split(' ')[0] || 'Staff'}</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                {session.items[0]?.purpose && (
                                                    <div className="bg-blue-50/20 rounded-2xl p-4 border border-blue-100/30 shadow-sm animate-in fade-in slide-in-from-left-2">
                                                        <div className="flex items-center gap-2 mb-2">
                                                            <MessageSquare className="w-3 h-3 text-blue-500" />
                                                            <span className="text-[9px] font-black text-blue-600 uppercase tracking-widest">Declared Purpose</span>
                                                        </div>
                                                        <p className="text-[13px] text-blue-900 font-medium italic leading-relaxed">
                                                            &ldquo;{session.items[0].purpose}&rdquo;
                                                        </p>
                                                    </div>
                                                )}
                                            </div>
                                        </div>

                                        {/* 📦 RIGHT RAIL: EQUIPMENT LIST */}
                                        <div className="flex-1 min-w-0 space-y-4">
                                            <div className="flex items-center justify-between mb-2">
                                                <p className="text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] ml-1">Equipment List ({session.items.length})</p>
                                            </div>

                                            <div className="space-y-2.5">
                                                {session.items.map((item: BorrowLog) => (
                                                        <div
                                                            key={item.id}
                                                            className={cn(
                                                                "group bg-white rounded-[20px] 14in:rounded-[24px] border border-zinc-100 p-3 14in:p-4 transition-all hover:bg-slate-50/50 flex items-center gap-3 14in:gap-5",
                                                                item.id === Number(triageId) && "border-blue-500 ring-4 ring-blue-500/5 shadow-blue-500/10 bg-blue-50/10"
                                                            )}
                                                        ref={item.id === Number(triageId) ? targetedItemRef : null}
                                                    >
                                                        {/* Multi-Select Handle */}
                                                        <div className="pl-1">
                                                            <Checkbox
                                                                checked={selectedLogIds.has(item.id)}
                                                                onCheckedChange={() => toggleLogId(item.id)}
                                                                disabled={item.status === 'returned'}
                                                                className="h-5 w-5 rounded-md border-slate-300 data-[state=checked]:bg-zinc-950 data-[state=checked]:border-zinc-950"
                                                            />
                                                        </div>

                                                        <div className="relative h-16 w-16 bg-slate-50 rounded-xl overflow-hidden border border-slate-200 shrink-0 group-hover:scale-105 transition-all shadow-xs flex items-center justify-center">
                                                            <TacticalAssetImage
                                                                url={item.image_url}
                                                                alt={item.item_name}
                                                                size="full"
                                                            />
                                                        </div>

                                                        <div className="flex-1 min-w-0">
                                                            <div className="flex items-center gap-2 mb-1">
                                                                <h4 className="text-[14px] font-black text-slate-900 uppercase tracking-tight truncate">{item.item_name}</h4>
                                                                {(item as any).inventory?.packaging_json?.enabled && (
                                                                    <PackagingPill 
                                                                        packaging={(item as any).inventory.packaging_json} 
                                                                        className="scale-90"
                                                                    />
                                                                )}
                                                            </div>
                                                            <div className="flex flex-wrap items-center gap-x-5 gap-y-1">
                                                                <span className="text-[10px] font-bold text-slate-400 flex items-center gap-1.5 uppercase tracking-wide">
                                                                    <Clock className="w-3 h-3" />
                                                                    Quantity: <span className="text-slate-900">{item.quantity}</span>
                                                                </span>
                                                                <span className="text-[10px] font-bold text-slate-400 flex items-center gap-1.5 uppercase tracking-wide">
                                                                    <MapPin className="w-3 h-3" />
                                                                    Location: <span className="text-slate-900">{String((item as any).borrowed_from_warehouse || (item as any).inventory?.storage_location || 'N/A').replace(/_/g, ' ')}</span>
                                                                </span>
                                                                <span className={cn(
                                                                    "text-[10px] font-bold flex items-center gap-1.5 uppercase tracking-wide",
                                                                    getUrgencyColor(item.expected_return_date, item.status)
                                                                )}>
                                                                    <Calendar className="w-3 h-3" />
                                                                    Due: {formatDate(item.expected_return_date)}
                                                                </span>
                                                            </div>
                                                        </div>

                                                        {/* Status + Actions */}
                                                        <div className="flex items-center gap-4 pr-1">
                                                            {getStatusBadge(item.status)}
                                                            {item.status !== 'returned' && item.status !== 'pending' && (
                                                                <ReturnCommandSheet
                                                                    logId={item.id}
                                                                    itemName={item.item_name}
                                                                    borrowerName={item.borrower_name || session.borrower_name}
                                                                    quantity={item.quantity}
                                                                    inventoryId={item.inventory_id}
                                                                >
                                                                    <Button variant="outline" size="sm" className="h-8.5 px-5 rounded-xl border-slate-200 text-blue-600 font-bold text-[10px] gap-2 hover:bg-white hover:border-blue-200 shadow-sm transition-all active:scale-95">
                                                                        <RotateCcw className="w-3 h-3" />
                                                                        Return Item
                                                                    </Button>
                                                                </ReturnCommandSheet>
                                                            )}
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
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
