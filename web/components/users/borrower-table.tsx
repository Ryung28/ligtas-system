'use client'

import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { Package, ArrowRightCircle, CheckCircle2, AlertCircle, ChevronLeft, ChevronRight } from 'lucide-react'

interface BorrowerTableProps {
    borrowers: any[]
    totalCount: number
    currentPage: number
    itemsPerPage: number
    onPageChange: (page: number) => void
    isLoading: boolean
    onSelectBorrower: (borrower: any) => void
}

export function BorrowerTable({ 
    borrowers, 
    totalCount, 
    currentPage, 
    itemsPerPage, 
    onPageChange, 
    isLoading, 
    onSelectBorrower 
}: BorrowerTableProps) {
    const totalPages = Math.ceil(totalCount / itemsPerPage)
    const hasNextPage = currentPage < totalPages
    const hasPrevPage = currentPage > 1

    return (
        <div className="space-y-4">
            <Card className="bg-white border border-gray-200/60 rounded-xl overflow-hidden flex flex-col shadow-sm">
                <CardContent className="p-0">
                    <div className="overflow-x-auto">
                        <Table>
                            <TableHeader>
                                <TableRow className="bg-gray-50/80 hover:bg-gray-50/80 border-b border-gray-100">
                                    <TableHead className="pl-4 14in:pl-6 pr-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Borrower</TableHead>
                                    <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-center">Transactions</TableHead>
                                    <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-center">Items Held</TableHead>
                                    <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-center">Reliability</TableHead>
                                    <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-center">Past Due</TableHead>
                                    <TableHead className="pl-3 pr-4 14in:pr-6 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-right">Actions</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {isLoading ? (
                                    Array.from({ length: itemsPerPage }).map((_, i) => (
                                        <TableRow key={i} className="border-b border-gray-100/80">
                                            <TableCell className="pl-4 14in:pl-6 pr-3 py-4">
                                                <div className="flex items-center gap-3">
                                                    <Skeleton className="h-9 w-9 rounded-full" />
                                                    <div className="space-y-2">
                                                        <Skeleton className="h-4 w-32" />
                                                        <Skeleton className="h-3 w-16" />
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell><Skeleton className="h-4 w-8 mx-auto" /></TableCell>
                                            <TableCell><Skeleton className="h-8 w-16 mx-auto rounded-lg" /></TableCell>
                                            <TableCell><Skeleton className="h-4 w-12 mx-auto" /></TableCell>
                                            <TableCell><Skeleton className="h-4 w-8 mx-auto" /></TableCell>
                                            <TableCell><Skeleton className="h-8 w-24 ml-auto" /></TableCell>
                                        </TableRow>
                                    ))
                                ) : borrowers.length === 0 ? (
                                    <TableRow>
                                        <TableCell colSpan={6} className="h-72 text-center">
                                            <div className="flex flex-col items-center justify-center p-10">
                                                <div className="bg-gray-50 h-12 w-12 rounded-xl flex items-center justify-center mb-4">
                                                    <Package className="h-6 w-6 text-gray-300" />
                                                </div>
                                                <p className="text-gray-900 font-semibold text-sm">No borrowers found</p>
                                                <p className="text-[13px] text-gray-400 mt-1 max-w-[280px]">
                                                    Try adjusting your search or dispatch items to see them here.
                                                </p>
                                            </div>
                                        </TableCell>
                                    </TableRow>
                                ) : (
                                    borrowers.map((borrower) => (
                                        <TableRow
                                            key={borrower.borrower_user_id || borrower.borrower_name}
                                            className="hover:bg-gray-50/60 cursor-pointer group transition-colors border-b border-gray-100/80"
                                            onClick={() => onSelectBorrower(borrower)}
                                        >
                                            <TableCell className="pl-4 14in:pl-6 pr-3 py-3">
                                                <div className="flex items-center gap-3">
                                                    <Avatar className="h-9 w-9 border-2 border-white shadow-sm ring-1 ring-gray-100 flex-shrink-0">
                                                        <AvatarFallback className={`font-bold text-[10px] text-white ${
                                                            borrower.is_verified_user 
                                                                ? 'bg-gradient-to-br from-indigo-600 to-violet-700' 
                                                                : 'bg-gradient-to-br from-slate-400 to-slate-600'
                                                        }`}>
                                                            {borrower.borrower_name.substring(0, 2).toUpperCase()}
                                                        </AvatarFallback>
                                                    </Avatar>
                                                    <div className="flex flex-col min-w-0">
                                                        <p className="font-semibold text-sm 14in:text-base text-gray-900 group-hover:text-blue-600 transition-colors truncate">
                                                            {borrower.borrower_name}
                                                        </p>
                                                        <div className="flex items-center gap-1.5 mt-0.5">
                                                            {borrower.is_verified_user ? (
                                                                <>
                                                                    <CheckCircle2 className="h-3 w-3 text-indigo-600" />
                                                                    <span className="text-[10px] text-indigo-600 font-medium uppercase tracking-wider">
                                                                        {borrower.user_role || 'Verified'}
                                                                    </span>
                                                                </>
                                                            ) : (
                                                                <span className="text-[10px] text-gray-500 font-medium uppercase tracking-wider">Guest</span>
                                                            )}
                                                        </div>
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell className="px-3 py-3 text-center">
                                                <span className="text-sm font-semibold text-gray-700">{borrower.total_borrows}</span>
                                            </TableCell>
                                            <TableCell className="px-3 py-3 text-center">
                                                <div className="inline-flex items-center gap-2 bg-gray-50 px-3 py-1.5 rounded-lg border border-gray-100 group-hover:bg-white transition-colors">
                                                    <Package className="h-3.5 w-3.5 text-blue-500/70 flex-shrink-0" />
                                                    <span className="text-sm font-semibold text-gray-700">{borrower.active_items}</span>
                                                </div>
                                            </TableCell>
                                            <TableCell className="px-3 py-3 text-center">
                                                <div className="flex items-center justify-center gap-2">
                                                    <div className={`h-1.5 w-1.5 rounded-full ${
                                                        borrower.return_rate_percent >= 90 ? 'bg-emerald-500' :
                                                        borrower.return_rate_percent >= 70 ? 'bg-amber-500' : 'bg-red-500'
                                                    }`} />
                                                    <span className={`text-sm font-semibold ${
                                                        borrower.return_rate_percent >= 90 ? 'text-emerald-700' :
                                                        borrower.return_rate_percent >= 70 ? 'text-amber-700' : 'text-red-700'
                                                    }`}>
                                                        {Math.round(borrower.return_rate_percent)}%
                                                    </span>
                                                </div>
                                            </TableCell>
                                            <TableCell className="px-3 py-3 text-center">
                                                {borrower.overdue_count > 0 ? (
                                                    <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md text-[11px] font-medium bg-red-50 text-red-700 ring-1 ring-red-600/10">
                                                        <AlertCircle className="h-3 w-3" />
                                                        {borrower.overdue_count}
                                                    </span>
                                                ) : (
                                                    <span className="text-sm text-gray-400">—</span>
                                                )}
                                            </TableCell>
                                            <TableCell className="pl-3 pr-4 14in:pr-6 py-3 text-right">
                                                <Button
                                                    variant="ghost"
                                                    size="sm"
                                                    className="h-8 px-3 text-slate-500 hover:text-slate-700 hover:bg-slate-100 font-medium text-[11px] transition-colors"
                                                    onClick={() => onSelectBorrower(borrower)}
                                                >
                                                    History <ArrowRightCircle className="h-3.5 w-3.5 ml-1 opacity-50" />
                                                </Button>
                                            </TableCell>
                                        </TableRow>
                                    ))
                                )}
                            </TableBody>
                        </Table>
                    </div>
                </CardContent>
            </Card>

            {/* Pagination Footer */}
            {!isLoading && totalCount > 0 && (
                <div className="flex items-center justify-between px-2">
                    <p className="text-xs text-gray-500 font-medium">
                        Showing <span className="text-gray-900">{(currentPage - 1) * itemsPerPage + 1}</span> to <span className="text-gray-900">{Math.min(currentPage * itemsPerPage, totalCount)}</span> of <span className="text-gray-900">{totalCount}</span> borrowers
                    </p>
                    <div className="flex items-center gap-2">
                        <Button
                            variant="outline"
                            size="sm"
                            disabled={!hasPrevPage}
                            onClick={() => onPageChange(currentPage - 1)}
                            className="h-8 px-2 border-gray-200"
                        >
                            <ChevronLeft className="h-4 w-4" />
                        </Button>
                        <div className="flex items-center gap-1">
                            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                                // Simple windowed pagination
                                let pageNum = i + 1;
                                if (totalPages > 5 && currentPage > 3) {
                                    pageNum = currentPage - 3 + i + 1;
                                    if (pageNum > totalPages) pageNum = totalPages - (4 - i);
                                }
                                
                                return (
                                    <Button
                                        key={pageNum}
                                        variant={currentPage === pageNum ? "default" : "ghost"}
                                        size="sm"
                                        onClick={() => onPageChange(pageNum)}
                                        className={`h-8 w-8 p-0 text-xs ${currentPage === pageNum ? "bg-slate-900" : "text-gray-500 hover:bg-gray-100"}`}
                                    >
                                        {pageNum}
                                    </Button>
                                );
                            })}
                        </div>
                        <Button
                            variant="outline"
                            size="sm"
                            disabled={!hasNextPage}
                            onClick={() => onPageChange(currentPage + 1)}
                            className="h-8 px-2 border-gray-200"
                        >
                            <ChevronRight className="h-4 w-4" />
                        </Button>
                    </div>
                </div>
            )}
        </div>
    )
}
