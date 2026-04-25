'use client'

import React from 'react'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { LogCard } from '@/components/mobile/log-card'
import { Activity, Filter, Search, PackageX } from 'lucide-react'
import { cn } from '@/lib/utils'
import { TimelineSkeleton } from '@/components/mobile/skeletons/timeline-skeleton'
import { MobileHeader } from '@/components/mobile/mobile-header'

/**
 * 📱 ResQTrack Mobile Transaction Logs Client
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
        { id: 'borrowed', label: 'Out' },
        { id: 'returned', label: 'Back' },
        { id: 'overdue', label: 'Late' }
    ]

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center p-12 text-center space-y-4">
                <div className="bg-red-50 p-4 rounded-full text-red-500">
                    <PackageX className="w-12 h-12" />
                </div>
                <h2 className="font-bold text-gray-900">Sync Error</h2>
                <p className="text-sm text-gray-500">We can't reach the server. Please check your internet.</p>
            </div>
        )
    }

    return (
        <div className="space-y-6 pb-20">
            <MobileHeader 
                title="Usage History" 
                onRefresh={() => refresh()} 
                isLoading={isLoading || isValidating} 
            />

            <div className="px-4 space-y-6">
                {/* Search & Filter Tactical Row */}
                <div className="space-y-4">
                    <div className="relative">
                        <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">
                            <Search className="w-5 h-5" />
                        </div>
                        <input 
                            type="text"
                            placeholder="Search history..."
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
                                <h3 className="font-bold text-gray-900">History Empty</h3>
                                <p className="text-sm text-gray-500">Nothing was found for your search.</p>
                            </div>
                        )}
                    </div>
                )}
                </div>
            </div>
        </div>
    )
}
