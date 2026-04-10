'use client'

import React from 'react'
import Link from 'next/link'
import { 
    Package, 
    Truck, 
    Clock, 
    ShieldCheck, 
    ArrowRight, 
    Search, 
    PlusCircle,
    Activity
} from 'lucide-react'
import { useDashboardStats } from '@/hooks/use-dashboard-stats'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { StatCard } from '@/components/mobile/stat-card'
import { cn } from '@/lib/utils'
import { formatDistanceToNow } from 'date-fns'

import { DashboardSkeleton } from '@/components/mobile/skeletons/dashboard-skeleton'

/**
 * 📱 LIGTAS Mobile Dashboard
 * 🏛️ ARCHITECTURE: "The Command Hub"
 * Focuses on high-frequency field operations: Stats, Actions, and Intel.
 */
export default function MobileDashboard() {
    const { stats, isLoading: statsLoading, refresh: refreshStats } = useDashboardStats()
    const { logs, isLoading: logsLoading, refresh: refreshLogs } = useBorrowLogs()

    const handleRefresh = async () => {
        await Promise.all([refreshStats(), refreshLogs()])
    }

    if (statsLoading && logs.length === 0) {
        return <DashboardSkeleton />
    }

    const recentLogs = logs.slice(0, 5)

    return (
        <div className="space-y-6">
            <MobileHeader 
                title="LIGTAS" 
                onRefresh={handleRefresh} 
                isLoading={statsLoading || logsLoading} 
            />
            {/* 1. Quick Insight Grid */}
            <section className="grid grid-cols-2 gap-3">
                <StatCard 
                    label="Total Items" 
                    value={stats.totalItems} 
                    icon={Package} 
                    color="blue"
                    isLoading={statsLoading}
                />
                <StatCard 
                    label="Total Stock" 
                    value={stats.totalStock} 
                    icon={ShieldCheck} 
                    color="green"
                    isLoading={statsLoading}
                />
                <StatCard 
                    label="Active Loans" 
                    value={stats.activeBorrows} 
                    icon={Truck} 
                    color="amber"
                    isLoading={statsLoading}
                />
                <StatCard 
                    label="Low Stock" 
                    value={stats.lowStockCount} 
                    icon={Clock} 
                    color="red"
                    isLoading={statsLoading}
                />
            </section>

            {/* 2. Tactical Actions */}
            <section className="space-y-3">
                <h2 className="text-sm font-bold text-gray-900 uppercase tracking-tight px-1 flex items-center gap-2">
                    <PlusCircle className="w-4 h-4 text-red-600" />
                    Quick Actions
                </h2>
                <div className="grid grid-cols-2 gap-3">
                    <Link 
                        href="/m/inventory"
                        className="p-4 bg-gray-900 text-white rounded-2xl flex flex-col gap-2 items-start transition-all active:scale-[0.98]"
                    >
                        <Search className="w-5 h-5 opacity-70" />
                        <span className="font-semibold text-sm">Browse Items</span>
                    </Link>
                    <Link 
                        href="/m/approvals"
                        className="p-4 bg-red-600 text-white rounded-2xl flex flex-col gap-2 items-start shadow-lg shadow-red-200 transition-all active:scale-[0.98]"
                    >
                        <CheckSquareIcon className="w-5 h-5 opacity-70" />
                        <span className="font-semibold text-sm">View Requests</span>
                    </Link>
                </div>
            </section>

            {/* 3. Live Activity Feed */}
            <section className="space-y-3">
                <div className="flex items-center justify-between px-1">
                    <h2 className="text-sm font-bold text-gray-900 uppercase tracking-tight flex items-center gap-2">
                        <Activity className="w-4 h-4 text-blue-600" />
                        Recent Activity
                    </h2>
                    <Link href="/m/logs" className="text-xs font-semibold text-red-600 flex items-center gap-0.5">
                        View All
                        <ArrowRight className="w-3 h-3" />
                    </Link>
                </div>

                <div className="bg-white rounded-2xl border border-gray-100 divide-y divide-gray-50 overflow-hidden shadow-sm">
                    {logsLoading ? (
                        Array(3).fill(0).map((_, i) => (
                            <div key={i} className="p-4 animate-pulse flex gap-3">
                                <div className="w-10 h-10 bg-gray-100 rounded-xl" />
                                <div className="flex-1 space-y-2">
                                    <div className="h-4 bg-gray-100 rounded w-3/4" />
                                    <div className="h-3 bg-gray-50 rounded w-1/2" />
                                </div>
                            </div>
                        ))
                    ) : recentLogs.length > 0 ? (
                        recentLogs.map((log) => (
                            <div key={log.id} className="p-4 flex gap-4 hover:bg-gray-50/50 transition-colors">
                                <div className={cn(
                                    "w-10 h-10 rounded-xl flex items-center justify-center shrink-0 border",
                                    log.status === 'returned' 
                                        ? "bg-green-50 text-green-600 border-green-100" 
                                        : "bg-blue-50 text-blue-600 border-blue-100"
                                )}>
                                    <Package className="w-5 h-5" />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center justify-between gap-2">
                                        <p className="text-sm font-bold text-gray-900 truncate">
                                            {log.item_name}
                                        </p>
                                        <span className="text-[10px] text-gray-400 font-medium whitespace-nowrap">
                                            {formatDistanceToNow(new Date(log.borrow_date || log.created_at), { addSuffix: true })}
                                        </span>
                                    </div>
                                    <p className="text-xs text-gray-500 truncate">
                                        {log.borrower_name} • {log.quantity} units {log.status}
                                    </p>
                                </div>
                            </div>
                        ))
                    ) : (
                        <div className="p-10 text-center">
                            <p className="text-sm text-gray-400">No recent activity detected.</p>
                        </div>
                    )}
                </div>
            </section>
        </div>
    )
}

function CheckSquareIcon({ className }: { className?: string }) {
    return (
        <svg 
            xmlns="http://www.w3.org/2000/svg" 
            width="24" 
            height="24" 
            viewBox="0 0 24 24" 
            fill="none" 
            stroke="currentColor" 
            strokeWidth="2" 
            strokeLinecap="round" 
            strokeLinejoin="round" 
            className={className}
        >
            <rect width="18" height="18" x="3" y="3" rx="2" />
            <path d="m9 12 2 2 4-4" />
        </svg>
    )
}
