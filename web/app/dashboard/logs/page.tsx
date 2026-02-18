'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardFooter } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { RefreshCw, ChevronLeft, ChevronRight, Filter } from 'lucide-react'
import { toast } from 'sonner'

import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { returnItem } from '@/app/actions/inventory'

import { LogStatsCards } from '@/components/logs/log-stats'
import { LogFilters } from '@/components/logs/log-filters'
import { LogSessionTable } from '@/components/logs/log-session-table'
import { LogBulkActionBar } from '@/components/logs/log-bulk-bar'
import { BorrowItemDialog } from '@/components/transactions/borrow-item-dialog'

export default function BorrowReturnLogs() {
    const {
        sessions,
        stats,
        isLoading,
        error,
        searchQuery,
        setSearchQuery,
        statusFilter,
        setStatusFilter,
        dateFilter,
        setDateFilter,
        currentPage,
        setCurrentPage,
        totalPages,
        selectedIds,
        setSelectedIds,
        toggleSessionExpansion,
        expandedSessions,
        refresh
    } = useBorrowLogs()

    const [isBulkReturning, setIsBulkReturning] = useState(false)

    const handleBulkReturn = async () => {
        if (selectedIds.size === 0) return
        setIsBulkReturning(true)
        let successCount = 0
        let failCount = 0

        try {
            for (const id of Array.from(selectedIds)) {
                const result = await returnItem(id)
                if (result.success) successCount++
                else failCount++
            }

            if (successCount > 0) {
                toast.success(`Successfully returned ${successCount} item(s)`)
                setSelectedIds(new Set())
                refresh()
            }
            if (failCount > 0) {
                toast.error(`Failed to return ${failCount} item(s)`)
            }
        } catch (err) {
            toast.error('An error occurred during bulk return')
        } finally {
            setIsBulkReturning(false)
        }
    }

    const toggleAllOnPage = () => {
        const allItemIds = sessions.flatMap(s => s.items.filter(l => l.status === 'borrowed').map(l => l.id))
        const allSelected = allItemIds.length > 0 && allItemIds.every(id => selectedIds.has(id))

        const newSelected = new Set(selectedIds)
        if (allSelected) {
            allItemIds.forEach(id => newSelected.delete(id))
        } else {
            allItemIds.forEach(id => newSelected.add(id))
        }
        setSelectedIds(newSelected)
    }

    return (
        <div className="max-w-screen-3xl mx-auto space-y-4 p-1 14in:p-2 animate-in fade-in duration-500">
            {/* Page Header */}
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
                <div>
                    <h1 className="text-xl 14in:text-2xl font-bold tracking-tight text-slate-900 font-heading">Borrow/Return Logs</h1>
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] mt-1.5" suppressHydrationWarning>
                        Operational Transaction Registry
                    </p>
                </div>
                <div className="flex items-center gap-2 font-heading">
                    <BorrowItemDialog />
                </div>
            </div>

            {/* Stats Section */}
            <LogStatsCards stats={stats} />

            {/* Main Log Section */}
            <Card className="bg-white/90 backdrop-blur-xl shadow-2xl shadow-slate-200/50 border-none rounded-[2.5rem] ring-1 ring-slate-100 overflow-hidden flex flex-col">
                <CardHeader className="bg-white/50 border-b border-slate-50 p-4 14in:p-5">
                    <LogFilters
                        filter={statusFilter}
                        setFilter={setStatusFilter}
                        dateFilter={dateFilter}
                        setDateFilter={setDateFilter}
                        searchQuery={searchQuery}
                        setSearchQuery={setSearchQuery}
                    />
                </CardHeader>

                <CardContent className="p-0 flex-1">
                    {error ? (
                        <div className="p-8 text-center text-red-600 font-medium">{error}</div>
                    ) : isLoading && sessions.length === 0 ? (
                        <div className="flex items-center justify-center py-24">
                            <RefreshCw className="h-8 w-8 animate-spin text-gray-300" />
                        </div>
                    ) : sessions.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-24 text-center">
                            <div className="bg-gray-50 p-4 rounded-full mb-3">
                                <Filter className="h-8 w-8 text-gray-300" />
                            </div>
                            <h3 className="text-lg font-medium text-gray-900">No transactions found</h3>
                            <p className="text-sm text-gray-500 mt-1 max-w-xs mx-auto">
                                Adjust your filters to find what you&apos;re looking for.
                            </p>
                        </div>
                    ) : (
                        <LogSessionTable
                            sessions={sessions}
                            selectedIds={selectedIds}
                            setSelectedIds={setSelectedIds}
                            expandedSessions={expandedSessions}
                            toggleSessionExpansion={toggleSessionExpansion}
                            onBatchSelectToggle={toggleAllOnPage}
                        />
                    )}
                </CardContent>

                {/* Pagination Footer */}
                {totalPages > 1 && (
                    <CardFooter className="bg-gray-50/50 border-t border-gray-100 p-4 flex items-center justify-between">
                        <div className="text-sm text-gray-500">
                            Page <span className="font-medium text-gray-900">{currentPage}</span> of <span className="font-medium text-gray-900">{totalPages}</span>
                        </div>
                        <div className="flex gap-2">
                            <Button
                                variant="outline"
                                size="sm"
                                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                                disabled={currentPage === 1}
                                className="bg-white border-gray-200 h-8 w-8 p-0"
                            >
                                <ChevronLeft className="h-4 w-4" />
                            </Button>
                            <Button
                                variant="outline"
                                size="sm"
                                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                                disabled={currentPage === totalPages}
                                className="bg-white border-gray-200 h-8 w-8 p-0"
                            >
                                <ChevronRight className="h-4 w-4" />
                            </Button>
                        </div>
                    </CardFooter>
                )}
            </Card>

            {/* Bulk Actions */}
            <LogBulkActionBar
                selectedCount={selectedIds.size}
                isLoading={isBulkReturning}
                onDeselect={() => setSelectedIds(new Set())}
                onConfirm={handleBulkReturn}
            />
        </div>
    )
}
