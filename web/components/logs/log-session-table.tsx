'use client'

import React, { useState, useMemo } from 'react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Checkbox } from '@/components/ui/checkbox'
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
    selectedIds: Set<number>
    setSelectedIds: (ids: Set<number>) => void
    expandedSessions: Set<string>
    toggleSessionExpansion: (key: string) => void
    onBatchSelectToggle: () => void
}

const ITEMS_PER_PAGE = 10

export function LogSessionTable({
    sessions,
    selectedIds,
    setSelectedIds,
    expandedSessions,
    toggleSessionExpansion,
    onBatchSelectToggle
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
    useMemo(() => {
        setCurrentPage(1)
    }, [searchQuery, statusFilter])

    const getStatusBadge = (status: string) => {
        switch (status) {
            case 'borrowed':
                return (
                    <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium bg-blue-50 text-blue-700 ring-1 ring-blue-600/10">
                        Borrowed
                    </span>
                )
            case 'returned':
                return (
                    <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium bg-emerald-50 text-emerald-700 ring-1 ring-emerald-600/10">
                        Returned
                    </span>
                )
            case 'overdue':
                return (
                    <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium bg-rose-50 text-rose-700 ring-1 ring-rose-600/10">
                        Overdue
                    </span>
                )
            default:
                return (
                    <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium bg-slate-50 text-slate-700 ring-1 ring-slate-600/10">
                        {status}
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

    const isSessionFullySelected = (session: BorrowSession) => {
        const borrowable = session.items.filter(i => i.status === 'borrowed')
        return borrowable.length > 0 && borrowable.every(i => selectedIds.has(i.id))
    }

    const toggleSessionSelection = (session: BorrowSession) => {
        const newSelected = new Set(selectedIds)
        const borrowableItems = session.items.filter(i => i.status === 'borrowed')
        const alreadyFull = isSessionFullySelected(session)

        if (alreadyFull) {
            borrowableItems.forEach(i => newSelected.delete(i.id))
        } else {
            borrowableItems.forEach(i => newSelected.add(i.id))
        }
        setSelectedIds(newSelected)
    }

    return (
        <Card className="bg-white border border-gray-200/60 rounded-xl overflow-hidden flex flex-col shadow-sm">
            <CardHeader className="border-b border-gray-100 p-3 14in:p-4">
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
                            <TableRow className="bg-gray-50/80 hover:bg-gray-50/80 border-b border-gray-100">
                                <TableHead className="w-[40px] pl-4 14in:pl-6 pr-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">
                                    <Checkbox
                                        checked={filteredSessions.length > 0 && filteredSessions.every(s => isSessionFullySelected(s))}
                                        onCheckedChange={onBatchSelectToggle}
                                    />
                                </TableHead>
                                <TableHead className="w-[30px] px-3 py-3"></TableHead>
                                <TableHead className="w-[200px] px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Borrower</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Session Summary</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Timestamp</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Status</TableHead>
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
                                        isSelected={isSessionFullySelected(session)}
                                        onToggleExpand={() => toggleSessionExpansion(session.key)}
                                        onToggleSelect={() => toggleSessionSelection(session)}
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
                <CardFooter className="border-t border-gray-100 bg-white px-4 14in:px-6 py-3 flex items-center justify-between">
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
    isSelected,
    onToggleExpand,
    onToggleSelect,
    formatDate,
    getUrgencyColor,
    getStatusBadge
}: any) {
    return (
        <React.Fragment>
            <TableRow
                className={`hover:bg-gray-50/60 group border-b border-gray-100/80 cursor-pointer transition-colors ${isSelected ? 'bg-blue-50/30' : ''}`}
                onClick={onToggleExpand}
            >
                <TableCell className="pl-4 14in:pl-6 pr-3" onClick={(e) => e.stopPropagation()}>
                    <Checkbox checked={isSelected} onCheckedChange={onToggleSelect} />
                </TableCell>
                <TableCell className="px-3 text-center">
                    {isExpanded ? <ChevronDown className="h-4 w-4 text-gray-400" /> : <ChevronRightIcon className="h-4 w-4 text-gray-400" />}
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
                    <div className="flex flex-col">
                        <span className="text-xs 14in:text-sm font-semibold text-gray-900">{formatDate(session.created_at)}</span>
                        <span className="text-[10px] text-gray-500 font-medium">{new Date(session.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                </TableCell>
                <TableCell className="px-3 py-3">
                    {session.status === 'mixed' ? (
                        <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium bg-amber-50 text-amber-700 ring-1 ring-amber-600/10">
                            PARTIAL RETURN
                        </span>
                    ) : (
                        getStatusBadge(session.status)
                    )}
                </TableCell>
                <TableCell className="pl-3 pr-4 14in:pr-6 py-3 text-right" onClick={(e) => e.stopPropagation()}>
                    <Button
                        variant="ghost"
                        size="sm"
                        className="h-8 px-3 text-blue-600 hover:text-blue-700 hover:bg-blue-50 font-medium text-[11px] transition-colors"
                        onClick={(e) => {
                            e.stopPropagation()
                            onToggleExpand()
                        }}
                    >
                        {isExpanded ? 'CLOSE' : 'VIEW ITEMS'}
                    </Button>
                </TableCell>
            </TableRow>

            {isExpanded && session.items.map((item: BorrowLog) => (
                <TableRow key={item.id} className="bg-gray-50/40 hover:bg-gray-50/40 border-b border-gray-100/80 animate-in fade-in duration-200">
                    <TableCell className="pl-4 14in:pl-6 pr-3">
                        <div className="flex justify-end pr-1">
                            <div className="h-6 w-[1px] bg-gray-200 mr-2" />
                        </div>
                    </TableCell>
                    <TableCell></TableCell>
                    <TableCell colSpan={2} className="px-3 py-3">
                        <div className="flex items-center gap-2">
                            <div className="h-1.5 w-1.5 rounded-full bg-blue-500 flex-shrink-0" />
                            <span className="text-sm font-medium text-gray-700 truncate">{item.item_name}</span>
                            <span className="text-[10px] text-gray-400 font-mono">ID:{item.inventory_id}</span>
                            <span className="text-xs text-gray-500 ml-2">Qty: <span className="font-semibold">{item.quantity}</span></span>
                        </div>
                    </TableCell>
                    <TableCell className="px-3 py-3">
                        <div className="flex flex-col">
                            <span className="text-[10px] text-gray-400 uppercase font-medium">Due Date</span>
                            <span className={`text-[11px] ${getUrgencyColor(item.expected_return_date, item.status)}`}>
                                {formatDate(item.expected_return_date)}
                            </span>
                        </div>
                    </TableCell>
                    <TableCell className="px-3 py-3">
                        {getStatusBadge(item.status)}
                    </TableCell>
                    <TableCell className="pl-3 pr-4 14in:pr-6 py-3 text-right">
                        {item.status === 'borrowed' && (
                            <ReturnDialog
                                logId={item.id}
                                itemName={item.item_name}
                                borrowerName={item.borrower_name}
                                quantity={item.quantity}
                            />
                        )}
                    </TableCell>
                </TableRow>
            ))}
        </React.Fragment>
    )
}
