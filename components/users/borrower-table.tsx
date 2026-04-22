'use client'

import { useState } from 'react'
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { ChevronLeft, ChevronRight, UserCheck, Users, Briefcase } from "lucide-react"
import { Badge } from "@/components/ui/badge"

interface BorrowerTableProps {
    borrowers: any[]
    totalCount: number
    currentPage: number
    itemsPerPage: number
    onPageChange: (page: number) => void
    isLoading: boolean
    onSelectBorrower: (borrower: any) => void
    selectedBorrower?: any
}

// ─── Progress Bar Atom ──────────────────────────────────────────────────────
function ReliabilityProgress({ value }: { value: number }) {
    const color =
        value >= 90 ? 'bg-emerald-500' :
        value >= 70 ? 'bg-amber-500' : 'bg-red-500'
    
    return (
        <div className="flex items-center gap-3 max-w-[140px]">
            <div className="flex-1 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                <div 
                    className={`h-full rounded-full transition-all duration-500 ${color}`}
                    style={{ width: `${Math.min(100, value)}%` }}
                />
            </div>
            <span className="text-[10px] font-black text-gray-400 tabular-nums w-8">
                {Math.round(value)}%
            </span>
        </div>
    )
}

export function BorrowerTable({ 
    borrowers, 
    totalCount, 
    currentPage, 
    itemsPerPage, 
    onPageChange, 
    isLoading, 
    onSelectBorrower,
    selectedBorrower
}: BorrowerTableProps) {
    const [identityFilter, setIdentityFilter] = useState<'all' | 'staff' | 'guests'>('all')
    const totalPages = Math.ceil(totalCount / itemsPerPage)

    // Identity Filtering Logic
    const filteredBorrowers = borrowers.filter(b => {
        if (identityFilter === 'staff') return b.is_verified_user === true
        if (identityFilter === 'guests') return b.is_verified_user === false
        return true
    })

    return (
        <div className="bg-white border border-gray-100 rounded-xl overflow-hidden flex flex-col h-full shadow-sm">
            {/* ── IDENTITY FILTER BAR (The Triage) ───────────────────────── */}
            <div className="px-4 py-2 border-b border-gray-50 bg-gray-50/30 flex items-center justify-between shrink-0">
                <div className="flex items-center gap-1 bg-white p-0.5 rounded-lg border border-gray-100 shadow-sm">
                    <Button 
                        variant="ghost" 
                        size="sm" 
                        onClick={() => setIdentityFilter('all')}
                        className={`h-7 px-3 text-[10px] font-black uppercase tracking-widest rounded-md ${
                            identityFilter === 'all' ? 'bg-indigo-50 text-indigo-700' : 'text-gray-400'
                        }`}
                    >
                        <Users className="h-3 w-3 mr-1.5" /> All
                    </Button>
                    <Button 
                        variant="ghost" 
                        size="sm" 
                        onClick={() => setIdentityFilter('staff')}
                        className={`h-7 px-3 text-[10px] font-black uppercase tracking-widest rounded-md ${
                            identityFilter === 'staff' ? 'bg-indigo-600 text-white shadow-md' : 'text-gray-400'
                        }`}
                    >
                        <Briefcase className="h-3 w-3 mr-1.5" /> Staff
                    </Button>
                    <Button 
                        variant="ghost" 
                        size="sm" 
                        onClick={() => setIdentityFilter('guests')}
                        className={`h-7 px-3 text-[10px] font-black uppercase tracking-widest rounded-md ${
                            identityFilter === 'guests' ? 'bg-slate-900 text-white shadow-md' : 'text-gray-400'
                        }`}
                    >
                        <UserCheck className="h-3 w-3 mr-1.5" /> Guests
                    </Button>
                </div>
                <div className="flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                    <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest">Live Registry</p>
                </div>
            </div>

            <div className="flex-1 overflow-auto">
                <Table>
                    <TableHeader className="bg-white/80 backdrop-blur-sm sticky top-0 z-10 border-b border-gray-100">
                        <TableRow className="hover:bg-transparent">
                            <TableHead className="w-[240px] h-11 text-[10px] font-black text-gray-400 uppercase tracking-widest pl-4">
                                NAME
                            </TableHead>
                            <TableHead className="h-11 text-[10px] font-black text-gray-400 uppercase tracking-widest">
                                RETURN SCORE
                            </TableHead>
                            <TableHead className="w-[180px] h-11 text-[10px] font-black text-gray-400 uppercase tracking-widest text-right pr-4">
                                BORROWED / RETURNED
                            </TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {isLoading ? (
                            <TableRow>
                                <TableCell colSpan={3} className="h-32 text-center text-xs text-gray-400">
                                    Scanning Registry...
                                </TableCell>
                            </TableRow>
                        ) : filteredBorrowers.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={3} className="h-32 text-center text-xs text-gray-400 font-bold uppercase tracking-widest">
                                    No {identityFilter === 'all' ? 'one' : identityFilter} Found
                                </TableCell>
                            </TableRow>
                        ) : (
                            filteredBorrowers.map((borrower) => {
                                const isActive = selectedBorrower && 
                                    (borrower.borrower_user_id 
                                        ? borrower.borrower_user_id === selectedBorrower.borrower_user_id 
                                        : borrower.borrower_name === selectedBorrower.borrower_name)

                                return (
                                    <TableRow
                                        key={borrower.borrower_user_id || borrower.borrower_name}
                                        className={`cursor-pointer group transition-all border-b border-gray-50 h-[56px] ${
                                            isActive 
                                                ? 'bg-indigo-50/60 hover:bg-indigo-100/60 border-l-4 border-l-indigo-600' 
                                                : 'hover:bg-gray-50/80 border-l-4 border-l-transparent'
                                        }`}
                                        onClick={() => onSelectBorrower(borrower)}
                                    >
                                        <TableCell className="pl-4 py-0">
                                            <div className="flex items-center gap-3">
                                                <div className={`shrink-0 w-8 h-8 rounded-lg flex items-center justify-center text-[10px] font-black border transition-colors ${
                                                    borrower.is_verified_user 
                                                        ? 'bg-indigo-50 border-indigo-100 text-indigo-600' 
                                                        : 'bg-gray-50 border-gray-100 text-gray-400'
                                                }`}>
                                                    {borrower.is_verified_user ? <Briefcase className="h-3.5 w-3.5" /> : 'G'}
                                                </div>
                                                <div className="min-w-0 pr-2">
                                                    <div className="flex items-center gap-2">
                                                        <p className="text-xs font-black truncate tracking-tight uppercase text-gray-900 group-hover:text-indigo-600 transition-colors">
                                                            {borrower.borrower_name}
                                                        </p>
                                                        {borrower.is_verified_user && (
                                                            <Badge variant="outline" className="h-4 px-1 text-[8px] font-black bg-indigo-50 text-indigo-600 border-indigo-100 rounded-[4px] uppercase tracking-tighter shrink-0">
                                                                Staff
                                                            </Badge>
                                                        )}
                                                    </div>
                                                    <p className="text-[9px] font-bold uppercase tracking-widest leading-none mt-0.5 text-gray-400">
                                                        {borrower.is_verified_user ? (borrower.user_role || 'Employee') : 'External Guest'}
                                                    </p>
                                                </div>
                                            </div>
                                        </TableCell>

                                        <TableCell className="py-0">
                                            <ReliabilityProgress value={Number(borrower.return_rate_percent ?? 100)} />
                                        </TableCell>

                                        <TableCell className="text-right pr-4 py-0">
                                            <p className={`text-xs font-black tabular-nums ${
                                                isActive ? 'text-indigo-900' : 'text-gray-900'
                                            }`}>
                                                {borrower.active_items < 0 ? 0 : (borrower.active_borrows ?? 0)} <span className={isActive ? 'text-indigo-400' : 'text-gray-400'}>/</span> {borrower.returned_count ?? 0}
                                            </p>
                                        </TableCell>
                                    </TableRow>
                                )
                            })
                        )}
                    </TableBody>
                </Table>
            </div>

            {/* ── FOOTER PACING ────────────────────────────────────────── */}
            <div className="h-11 px-4 flex items-center justify-between border-t border-gray-100 shrink-0 bg-gray-50/50">
                <p className="text-[10px] font-black uppercase tracking-widest text-gray-400">
                    Registry: <span className="text-gray-900">{totalCount} People</span>
                </p>
                <div className="flex items-center gap-4">
                    <p className="text-[10px] font-black uppercase tracking-widest text-gray-500">
                        Page <span className="text-gray-900">{currentPage}</span> of {totalPages}
                    </p>
                    <div className="flex gap-1">
                        <Button
                            variant="outline"
                            size="icon"
                            disabled={currentPage === 1 || isLoading}
                            onClick={() => onPageChange(currentPage - 1)}
                            className="h-7 w-7 rounded-lg bg-white border-gray-200"
                        >
                            <ChevronLeft className="h-3.5 w-3.5" />
                        </Button>
                        <Button
                            variant="outline"
                            size="icon"
                            disabled={currentPage === totalPages || isLoading}
                            onClick={() => onPageChange(currentPage + 1)}
                            className="h-7 w-7 rounded-lg bg-white border-gray-200"
                        >
                            <ChevronRight className="h-3.5 w-3.5" />
                        </Button>
                    </div>
                </div>
            </div>
        </div>
    )
}
