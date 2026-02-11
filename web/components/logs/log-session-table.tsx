'use client'

import React from 'react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Checkbox } from '@/components/ui/checkbox'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { ChevronDown, ChevronRight as ChevronRightIcon, Package } from 'lucide-react'
import { BorrowLog, BorrowSession } from '@/lib/types/inventory'
import { InitialsAvatar } from './log-avatar'
import { ReturnDialog } from '@/components/transactions/return-dialog'

interface LogSessionTableProps {
    sessions: BorrowSession[]
    selectedIds: Set<number>
    setSelectedIds: (ids: Set<number>) => void
    expandedSessions: Set<string>
    toggleSessionExpansion: (key: string) => void
    onBatchSelectToggle: () => void
}

export function LogSessionTable({
    sessions,
    selectedIds,
    setSelectedIds,
    expandedSessions,
    toggleSessionExpansion,
    onBatchSelectToggle
}: LogSessionTableProps) {

    const formatDate = (dateString: string | null) => {
        if (!dateString) return 'N/A'
        return new Date(dateString).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        })
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

    const getStatusBadge = (status: string) => {
        switch (status) {
            case 'borrowed':
                return (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-blue-500/10 text-blue-700 ring-1 ring-blue-500/20">
                        Borrowed
                    </span>
                )
            case 'returned':
                return (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-700 ring-1 ring-emerald-500/20">
                        Returned
                    </span>
                )
            case 'overdue':
                return (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-rose-500/10 text-rose-700 ring-1 ring-rose-500/20">
                        Overdue
                    </span>
                )
            default:
                return (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-slate-500/10 text-slate-700 ring-1 ring-slate-500/20">
                        {status}
                    </span>
                )
        }
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
        <div className="overflow-x-auto min-h-[400px]">
            <Table>
                <TableHeader>
                    <TableRow className="bg-gray-50/50 hover:bg-gray-50/50">
                        <TableHead className="w-[40px] pl-6 py-4">
                            <Checkbox
                                checked={sessions.length > 0 && sessions.every(s => isSessionFullySelected(s))}
                                onCheckedChange={onBatchSelectToggle}
                            />
                        </TableHead>
                        <TableHead className="w-[30px] py-4"></TableHead>
                        <TableHead className="w-[200px] font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em] py-4">Borrower</TableHead>
                        <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em] py-4">Session Summary</TableHead>
                        <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em] py-4">Timestamp</TableHead>
                        <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em] py-4">Status</TableHead>
                        <TableHead className="font-bold text-slate-400 uppercase text-[9px] tracking-[0.15em] text-right pr-6 py-4">Batch Actions</TableHead>
                    </TableRow>
                </TableHeader>
                <TableBody>
                    {sessions.map((session) => (
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
                    ))}
                </TableBody>
            </Table>
        </div>
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
                className={`hover:bg-gray-50/50 group border-b border-gray-100 cursor-pointer ${isSelected ? 'bg-blue-50/30' : ''}`}
                onClick={onToggleExpand}
            >
                <TableCell className="pl-6" onClick={(e) => e.stopPropagation()}>
                    <Checkbox checked={isSelected} onCheckedChange={onToggleSelect} />
                </TableCell>
                <TableCell className="p-0 text-center">
                    {isExpanded ? <ChevronDown className="h-4 w-4 text-gray-400" /> : <ChevronRightIcon className="h-4 w-4 text-gray-400" />}
                </TableCell>
                <TableCell className="py-4">
                    <div className="flex items-center gap-3">
                        <InitialsAvatar name={session.borrower_name} />
                        <div className="flex flex-col">
                            <span className="text-sm 14in:text-base font-bold text-slate-900 font-heading leading-tight">{session.borrower_name}</span>
                            <span className="text-[9px] 14in:text-[10px] text-slate-400 font-bold uppercase tracking-[0.12em] mt-0.5">{session.borrower_organization}</span>
                        </div>
                    </div>
                </TableCell>
                <TableCell>
                    <div className="flex items-center gap-2">
                        <div className="bg-gray-100 p-1.5 rounded-md">
                            <Package className="h-4 w-4 text-gray-500" />
                        </div>
                        <div className="flex flex-col">
                            <span className="text-sm font-medium text-gray-900">{session.items.length} Unique Items</span>
                            <span className="text-xs text-gray-500">{session.total_quantity} total units</span>
                        </div>
                    </div>
                </TableCell>
                <TableCell>
                    <div className="flex flex-col text-sm">
                        <span className="text-slate-900 text-xs 14in:text-sm font-bold">{formatDate(session.created_at)}</span>
                        <span className="text-slate-400 text-[10px] font-bold uppercase tracking-tighter">{new Date(session.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                </TableCell>
                <TableCell>
                    {session.status === 'mixed' ? (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-amber-500/10 text-amber-700 ring-1 ring-amber-500/20">
                            PARTIAL RETURN
                        </span>
                    ) : (
                        getStatusBadge(session.status)
                    )}
                </TableCell>
                <TableCell className="text-right pr-6" onClick={(e) => e.stopPropagation()}>
                    <Button
                        variant="ghost"
                        size="sm"
                        className="text-blue-600 hover:text-blue-700 hover:bg-blue-50 font-bold text-[10px] uppercase tracking-widest px-3 h-8 rounded-lg"
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
                <TableRow key={item.id} className="bg-gray-50/40 border-b border-gray-100 animate-in fade-in duration-200">
                    <TableCell className="pl-6">
                        <div className="flex justify-end pr-1">
                            <div className="h-6 w-[1px] bg-gray-200 mr-2" />
                        </div>
                    </TableCell>
                    <TableCell></TableCell>
                    <TableCell colSpan={2} className="py-3">
                        <div className="flex items-center gap-2 pl-4">
                            <div className="h-1.5 w-1.5 rounded-full bg-blue-500" />
                            <span className="text-sm font-medium text-gray-700">{item.item_name}</span>
                            <span className="text-[10px] text-gray-400 font-mono">ID:{item.inventory_id}</span>
                            <span className="text-xs text-gray-500 ml-2">Qty: <span className="font-bold">{item.quantity}</span></span>
                        </div>
                    </TableCell>
                    <TableCell>
                        <div className="flex flex-col">
                            <span className="text-[10px] text-gray-400 uppercase font-bold">Due Date</span>
                            <span className={`text-[11px] ${getUrgencyColor(item.expected_return_date, item.status)}`}>
                                {formatDate(item.expected_return_date)}
                            </span>
                        </div>
                    </TableCell>
                    <TableCell>
                        {getStatusBadge(item.status)}
                    </TableCell>
                    <TableCell className="text-right pr-6">
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
