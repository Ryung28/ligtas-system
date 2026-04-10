'use client'

import { useState, useEffect } from 'react'
import { useSearchParams } from 'next/navigation'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { RefreshCw, Filter } from 'lucide-react'
import { BorrowLog } from '@/lib/types/inventory'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'

import { LogStatsCards } from '@/components/logs/log-stats'
import { LogFilters } from '@/components/logs/log-filters'
import { LogSessionTable } from '@/components/logs/log-session-table'
import { BorrowItemDialog } from '@/components/transactions/borrow-item-dialog'
import { PendingTriageHeader } from '@/components/logs/pending-triage-header'

interface LogsClientProps {
    initialLogs: BorrowLog[]
}

export function LogsClient({ initialLogs }: LogsClientProps) {
    const logsHook = useBorrowLogs('all')
    
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
        toggleSessionExpansion,
        expandedSessions,
    } = logsHook

    const searchParams = useSearchParams()
    const [highlightedName, setHighlightedName] = useState<string | null>(null)

    // Deep-Link Hook (Enterprise Drill-Down)
    useEffect(() => {
        const search = searchParams.get('search')
        const shouldHighlight = searchParams.get('highlight') === 'true'
        
        if (search) {
            setSearchQuery(search)
            if (shouldHighlight) setHighlightedName(search)
        }
    }, [searchParams, setSearchQuery])

    return (
        <div className="max-w-screen-3xl mx-auto space-y-4 p-1 14in:p-2 animate-in fade-in duration-500">
            {/* Page Header */}
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-slate-100 shadow-sm">
                <div>
                    <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic">
                        Borrow/Return Logs
                    </h1>
                </div>
                <div className="flex items-center gap-2 font-heading">
                    <BorrowItemDialog />
                </div>
            </div>
            
            {/* Triage Hook: Contextual Command Bar */}
            <PendingTriageHeader searchQuery={searchQuery} />

            {/* Stats Section */}
            <LogStatsCards 
                stats={stats} 
                currentFilter={statusFilter}
                onFilterChange={setStatusFilter}
            />

            {/* Main Log Section */}
            <Card className="bg-white/90 backdrop-blur-xl shadow-2xl shadow-slate-200/50 border-none rounded-[2.5rem] ring-1 ring-slate-100 overflow-hidden flex flex-col">
                <CardHeader className="bg-white/50 border-b border-slate-50 p-4 14in:p-5">
                    <LogFilters
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
                            expandedSessions={expandedSessions}
                            toggleSessionExpansion={toggleSessionExpansion}
                            highlightedName={highlightedName}
                            searchQuery={searchQuery}
                            setSearchQuery={setSearchQuery}
                            statusFilter={statusFilter}
                            setStatusFilter={setStatusFilter}
                            currentPage={currentPage}
                            setCurrentPage={setCurrentPage}
                            totalPages={totalPages}
                        />
                    )}
                </CardContent>
            </Card>
        </div>
    )
}
