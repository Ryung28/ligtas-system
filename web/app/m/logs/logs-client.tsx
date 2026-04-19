'use client'

import React from 'react'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { LogCard } from '@/components/mobile/log-card'
import { Activity, Filter, Search, PackageX } from 'lucide-react'
import { cn } from '@/lib/utils'
import { TimelineSkeleton } from '@/components/mobile/skeletons/timeline-skeleton'
import { MobileHeader } from '@/components/mobile/mobile-header'

/**
 * 📱 LIGTAS Mobile Transaction Logs Client
 * This component is separate to satisfy Next.js 15 Suspense requirements.
 */
export function LogsClient() {
    const { 
        logs, 
        sessions,
        isLoading, 
        error, 
        refresh, 
        isValidating,
        searchQuery,
        setSearchQuery,
        statusFilter,
        setStatusFilter
    } = useBorrowLogs()
    
    const filters = [
        { id: 'all', label: 'All' },
        { id: 'borrowed', label: 'Borrowed' },
        { id: 'returned', label: 'Returned' },
        { id: 'overdue', label: 'Overdue' }
    ]

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center p-12 text-center space-y-4">
                <div className="bg-red-50 p-4 rounded-full text-red-500">
                    <PackageX className="w-12 h-12" />
                </div>
                <h2 className="font-bold text-gray-900">Connection Terminated</h2>
                <p className="text-sm text-gray-500">The ledger sync failed. Ensure your device has an active uplink.</p>
            </div>
        )
    }

    return (
        <div className="space-y-6 pb-20 px-4 pt-4">
            <MobileHeader 
                title="Log Triage" 
                onRefresh={() => refresh()} 
                isLoading={isLoading || isValidating} 
            />
            
            <div className="sticky top-[56px] bg-gray-50/95 backdrop-blur-md pt-2 pb-4 z-40 space-y-4 -mx-4 px-4 border-b border-gray-100">
                <div className="relative group">
                    <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
                        <Search className="w-5 h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" />
                    </div>
                    <input 
                        type="text"
                        placeholder="Search ledger entries..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full h-12 bg-white border border-gray-200 rounded-2xl pl-12 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all shadow-sm"
                    />
                </div>

                <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar -mx-4 px-4">
                    <div className="flex-shrink-0 p-2 bg-white border border-gray-200 rounded-xl">
                        <Filter className="w-4 h-4 text-gray-500" />
                    </div>
                    {filters.map((filter) => (
                        <button
                            key={filter.id}
                            onClick={() => setStatusFilter(filter.id as any)}
                            className={cn(
                                "flex-shrink-0 px-4 py-2 rounded-xl text-xs font-bold transition-all border",
                                statusFilter === filter.id 
                                    ? "bg-blue-600 text-white border-blue-600 shadow-md shadow-blue-200" 
                                    : "bg-white text-gray-600 border-gray-200 hover:border-gray-300"
                            )}
                        >
                            {filter.label}
                        </button>
                    ))}
                </div>
            </div>

            <div className="mt-4">
                {isLoading && sessions.length === 0 ? (
                    <TimelineSkeleton />
                ) : (
                    <div className="flex flex-col gap-3">
                        {sessions.length > 0 ? (
                            sessions.map((session) => (
                                <LogCard 
                                    key={session.key} 
                                    session={session} 
                                />
                            ))
                        ) : (
                            <div className="flex flex-col items-center justify-center py-20 text-center">
                                <div className="w-16 h-16 bg-gray-100 rounded-3xl flex items-center justify-center mb-4">
                                    <Activity className="w-8 h-8 text-gray-300" />
                                </div>
                                <h3 className="font-bold text-gray-900">Ledger Empty</h3>
                                <p className="text-sm text-gray-500">No transactions match your current search.</p>
                            </div>
                        )}
                    </div>
                )}
            </div>
        </div>
    )
}
