'use client'

import React, { useState, useMemo, useEffect } from 'react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { ChevronDown, ChevronRight as ChevronRightIcon, Package, Search, ChevronLeft, ChevronRight } from 'lucide-react'
import { BorrowLog, BorrowSession } from '@/lib/types/inventory'
import { InitialsAvatar } from './log-avatar'
import { ReturnDialog } from '@/components/transactions/return-dialog'
import { Card, CardContent, CardHeader, CardFooter } from '@/components/ui/card'

interface LogSessionTableProps {
    sessions: BorrowSession[]
    expandedSessions: Set<string>
    toggleSessionExpansion: (key: string) => void
}

const ITEMS_PER_PAGE = 10

export function LogSessionTable({
    sessions,
    expandedSessions,
    toggleSessionExpansion
}: LogSessionTableProps) {
    const [searchQuery, setSearchQuery] = useState('')
    const [statusFilter, setStatusFilter] = useState<'all' | 'borrowed' | 'returned' | 'overdue' | 'mixed'>('all')
    const [currentPage, setCurrentPage] = useState(1)

    // Filter Sessions
    const filteredSessions = useMemo(() => {
        return sessions.filter((session) => {
            const matchesSearch = session.borrower_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                session.borrower_organization.toLowerCase().includes(searchQuery.toLowerCase())

            let matchesFilter = true
            if (statusFilter === 'borrowed') matchesFilter = session.status === 'borrowed'
            if (statusFilter === 'returned') matchesFilter = session.status === 'returned'
            if (statusFilter === 'overdue') matchesFilter = session.status === 'overdue'
            if (statusFilter === 'mixed') matchesFilter = session.status === 'mixed'

            return matchesSearch && matchesFilter
        })
    }, [sessions, searchQuery, statusFilter])

    // Paginate Sessions
    const totalPages = Math.ceil(filteredSessions.length / ITEMS_PER_PAGE)
    const paginatedSessions = useMemo(() => {
        const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
        return filteredSessions.slice(startIndex, startIndex + ITEMS_PER_PAGE)
    }, [filteredSessions, currentPage])

    // Reset page on filter change
    useEffect(() => {
        setCurrentPage(1)
    }, [searchQuery, statusFilter])

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
                        <span className="text-amber-600">Pending</span>
                    </span>
                )
            case 'cancelled':
                return (
                    <span className={baseClass}>
                        <span className="text-slate-500">Cancelled</span>
                    </span>
                )
            case 'rejected':
                return (
                    <span className={baseClass}>
                        <span className="text-slate-500">Rejected</span>
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
                        <h2 className="text-[13px] font-semibold text-gray-900">Borrow & Return Logs</h2>
                        <span className="text-[11px] text-gray-400 font-medium">{filteredSessions.length} results</span>
                    </div>

                    <div className="flex flex-wrap gap-2 w-full md:w-auto">
                        <div className="relative flex-1 md:w-64">
                            <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-gray-400" />
                            <Input
                                placeholder="Search logs..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-9 h-9 text-[13px] bg-white border-gray-200 rounded-lg focus-visible:ring-1 focus-visible:ring-gray-300 focus-visible:border-gray-300 placeholder:text-gray-400"
                            />
                        </div>

                        <Select value={statusFilter} onValueChange={(v: any) => setStatusFilter(v)}>
                            <SelectTrigger className="w-[140px] h-9 bg-white border-gray-200 rounded-lg text-[13px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                                <SelectValue placeholder="Status" />
                            </SelectTrigger>
                            <SelectContent className="rounded-lg border-gray-200 shadow-lg p-1">
                                <SelectItem value="all" className="text-[13px] rounded-md">All Status</SelectItem>
                                <SelectItem value="borrowed" className="text-[13px] rounded-md">Borrowed</SelectItem>
                                <SelectItem value="returned" className="text-[13px] rounded-md">Returned</SelectItem>
                                <SelectItem value="overdue" className="text-[13px] rounded-md">Overdue</SelectItem>
                                <SelectItem value="mixed" className="text-[13px] rounded-md">Partial Return</SelectItem>
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
                                <TableHead className="w-[40px] pl-4 14in:pl-6 pr-3 py-3"></TableHead>
                                <TableHead className="w-[200px] px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Borrower</TableHead>
                                <TableHead className="w-[160px] px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Session Summary</TableHead>
                                <TableHead className="w-[120px] px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Date Borrowed</TableHead>
                                <TableHead className="w-[120px] px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Date Returned</TableHead>
                                <TableHead className="w-[100px] px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Status</TableHead>
                                <TableHead className="pl-3 pr-4 14in:pr-6 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {paginatedSessions.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={7} className="h-72 text-center">
                                        <div className="flex flex-col items-center justify-center p-10">
                                            <div className="bg-gray-50 h-12 w-12 rounded-xl flex items-center justify-center mb-4">
                                                <Package className="h-6 w-6 text-gray-300" />
                                            </div>
                                            <p className="text-gray-900 font-semibold text-sm">No logs found</p>
                                            <p className="text-[13px] text-gray-400 mt-1 max-w-[280px]">
                                                Try adjusting your search or filter criteria.
                                            </p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                paginatedSessions.map((session) => (
                                    <LogSessionRow
                                        key={session.key}
                                        session={session}
                                        isExpanded={expandedSessions.has(session.key)}
                                        onToggleExpand={() => toggleSessionExpansion(session.key)}
                                        formatDate={formatDate}
                                        getUrgencyColor={getUrgencyColor}
                                        getStatusBadge={getStatusBadge}
                                    />
                                ))
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>

            {totalPages > 1 && (
                <CardFooter className="border-t border-zinc-100/80 bg-white/50 px-4 14in:px-6 py-3 flex items-center justify-between">
                    <p className="text-[12px] text-gray-500">
                        Page <span className="font-semibold text-gray-900">{currentPage}</span> of <span className="font-semibold text-gray-900">{totalPages}</span>
                        <span className="text-gray-400 ml-2">·</span>
                        <span className="ml-2 text-gray-400">{filteredSessions.length} sessions</span>
                    </p>
                    <div className="flex gap-1.5">
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                            disabled={currentPage === 1}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200 hover:bg-gray-50 text-gray-600"
                        >
                            <ChevronLeft className="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                            disabled={currentPage === totalPages}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200 hover:bg-gray-50 text-gray-600"
                        >
                            <ChevronRight className="h-4 w-4" />
                        </Button>
                    </div>
                </CardFooter>
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
    getStatusBadge
}: any) {
    return (
        <React.Fragment>
            <TableRow
                className="hover:bg-zinc-50/40 group border-b border-zinc-100/60 cursor-pointer select-none transition-colors"
                onClick={onToggleExpand}
            >
                <TableCell className="pl-4 14in:pl-6 pr-3 w-[40px] text-center">
                    {isExpanded ? <ChevronDown className="h-4 w-4 text-gray-400 mx-auto" /> : <ChevronRightIcon className="h-4 w-4 text-gray-400 mx-auto" />}
                </TableCell>
                <TableCell className="px-3 py-3">
                    <div className="flex items-center gap-3">
                        <InitialsAvatar name={session.borrower_name} />
                        <div className="flex flex-col min-w-0">
                            <span className="text-sm 14in:text-base font-semibold text-gray-900 truncate">{session.borrower_name}</span>
                            <span className="text-[11px] text-gray-500 truncate">{session.borrower_organization}</span>
                        </div>
                    </div>
                </TableCell>
                <TableCell className="px-3 py-3">
                    <div className="flex items-center gap-2">
                        <div className="h-8 w-8 rounded-lg bg-gray-50 border border-gray-100 flex items-center justify-center flex-shrink-0">
                            <Package className="h-4 w-4 text-gray-500" />
                        </div>
                        <div className="flex flex-col min-w-0">
                            <span className="text-sm font-medium text-gray-900">{session.items.length} Unique Items</span>
                            <span className="text-xs text-gray-500">{session.total_quantity} total units</span>
                        </div>
                    </div>
                </TableCell>
                <TableCell className="px-3 py-3">
                    <div className="flex flex-col text-left">
                        <span className="text-sm font-medium text-zinc-950 font-sans tracking-tight leading-none mb-1">
                            {new Date(session.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                        </span>
                        <span className="text-[11px] font-mono text-zinc-500 uppercase leading-none">
                            {new Date(session.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })}
                        </span>
                    </div>
                </TableCell>
                <TableCell className="px-3 py-3">
                    {session.status === 'returned' || session.status === 'mixed' ? (() => {
                        const returnDates = session.items
                            .map((i: any) => i.actual_return_date)
                            .filter(Boolean)
                            .map((d: any) => new Date(d));
                        const lastReturnDate = returnDates.length > 0 ? new Date(Math.max(...returnDates.map((d: Date) => d.getTime()))) : null;

                        if (!lastReturnDate) {
                            return <span className="text-zinc-400 text-[10px] uppercase tracking-wider font-bold">Pending</span>;
                        }

                        return (
                            <div className="flex flex-col text-left">
                                <span className="text-sm font-medium text-zinc-950 font-sans tracking-tight leading-none mb-1">
                                    {lastReturnDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                                </span>
                                <span className="text-[11px] font-mono text-zinc-500 uppercase leading-none">
                                    {lastReturnDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })}
                                </span>
                            </div>
                        );
                    })() : (
                        <div className="text-left py-1">
                            <span className="text-zinc-400 text-[10px] uppercase tracking-wider font-bold">Pending</span>
                        </div>
                    )}
                </TableCell>
                <TableCell className="px-3 py-3">
                    {session.status === 'mixed' ? (
                        <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[9px] font-black uppercase tracking-widest bg-white border border-amber-200 shadow-[0_1px_2px_rgba(0,0,0,0.03)] whitespace-nowrap">
                            <span className="text-amber-700">PARTIAL RETURN</span>
                        </span>
                    ) : (
                        getStatusBadge(session.status)
                    )}
                </TableCell>
                <TableCell className="pl-3 pr-4 14in:pr-6 py-3 text-right" onClick={(e) => e.stopPropagation()}>
                    <Button
                        variant="ghost"
                        size="sm"
                        className="h-8 px-3 text-blue-600 hover:text-blue-700 hover:bg-blue-50 font-medium text-[11px] transition-colors cursor-pointer"
                        onClick={(e) => {
                            e.stopPropagation()
                            onToggleExpand()
                        }}
                    >
                        {isExpanded ? 'CLOSE' : 'VIEW ITEMS'}
                    </Button>
                </TableCell>
            </TableRow>

            {isExpanded && session.items.map((item: BorrowLog) => {
                const hasReturnRequest = item.notes?.includes('BORROWER INITIATED RETURN');

                return (
                    <TableRow key={item.id} className={`${hasReturnRequest ? 'bg-amber-50/20' : 'bg-zinc-50/20'} hover:bg-zinc-50/40 border-b border-zinc-100/40 animate-in fade-in duration-200 select-none cursor-default`}>
                        <TableCell className="pl-4 14in:pl-6 pr-3">
                            <div className="flex justify-center">
                                <div className="h-6 w-[2px] bg-slate-200 rounded-full" />
                            </div>
                        </TableCell>
                        <TableCell colSpan={2} className="px-3 py-3">
                            <div className="flex items-center gap-2">
                                <span className="text-sm font-medium text-gray-700 truncate">{item.item_name}</span>
                                <span className="text-[10px] text-gray-400 font-mono">ID:{item.inventory_id}</span>
                                <span className="text-xs text-gray-500 ml-2">Qty: <span className="font-semibold">{item.quantity}</span></span>

                                {hasReturnRequest && (
                                    <span className="ml-2 px-1.5 py-0.5 rounded-md bg-amber-100 text-amber-700 text-[9px] font-black uppercase tracking-tighter ring-1 ring-amber-200">
                                        Return Requested
                                    </span>
                                )}
                            </div>
                        </TableCell>
                        <TableCell className="px-3 py-3">
                            <div className="flex flex-col">
                                <span className="text-[10px] text-gray-400 uppercase font-medium leading-none mb-1">Due Date</span>
                                <span className={`text-[11px] font-medium ${getUrgencyColor(item.expected_return_date, item.status)}`}>
                                    {formatDate(item.expected_return_date)}
                                </span>
                            </div>
                        </TableCell>
                        <TableCell className="px-3 py-3">
                            {item.actual_return_date ? (
                                <div className="flex flex-col text-left">
                                    <span className="text-[10px] text-zinc-950 font-medium font-sans leading-none mb-1">
                                        {new Date(item.actual_return_date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                                    </span>
                                    <span className="text-[9px] font-mono text-zinc-500 uppercase leading-none">
                                        {new Date(item.actual_return_date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })}
                                    </span>
                                </div>
                            ) : (
                                <span className="text-zinc-300 font-mono">—</span>
                            )}
                        </TableCell>
                        <TableCell className="px-3 py-3">
                            {getStatusBadge(item.status)}
                        </TableCell>
                        <TableCell className="pl-3 pr-4 14in:pr-6 py-3 text-right">
                            {item.status === 'borrowed' && (
                                <div className="relative group/btn cursor-pointer">
                                    {hasReturnRequest && (
                                        <div className="absolute -top-1 -right-1 h-2 w-2 bg-amber-500 rounded-full animate-ping z-10" />
                                    )}
                                    <ReturnDialog
                                        logId={item.id}
                                        itemName={item.item_name}
                                        borrowerName={item.borrower_name}
                                        quantity={item.quantity}
                                    />
                                </div>
                            )}
                        </TableCell>
                    </TableRow>
                );
            })}
        </React.Fragment>
    )
}
