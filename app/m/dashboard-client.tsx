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
    Activity,
    ArrowUpRight,
    ArrowDownLeft,
    AlertCircle
} from 'lucide-react'
import { useDashboardStats } from '@/hooks/use-dashboard-stats'
import { useBorrowLogs } from '@/hooks/use-borrow-logs'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { StatCard } from '@/components/mobile/stat-card'
import { cn } from '@/lib/utils'
import { formatDistanceToNow } from 'date-fns'
import { DashboardSkeleton } from '@/components/mobile/skeletons/dashboard-skeleton'
import { usePendingRequests } from '@/hooks/use-pending-requests'
import { isLowStock } from '@/lib/inventory-utils'

const getGreeting = () => {
    const hour = new Date().getHours()
    if (hour < 12) return 'GOOD MORNING'
    if (hour < 17) return 'GOOD AFTERNOON'
    return 'GOOD EVENING'
}

/**
 * 📱 ResQTrack Mobile Dashboard Client
 */
export function DashboardClient({ initialUserName = 'ANALYST' }: { initialUserName?: string }) {
    const { stats, data: dashboardData, isLoading: statsLoading, refresh: refreshStats } = useDashboardStats()
    const { requests: pendingRequests, isLoading: pendingLoading } = usePendingRequests()
    const { logs, isLoading: logsLoading, refresh: refreshLogs, stats: logStats } = useBorrowLogs()
    const [userName] = React.useState(initialUserName)

    const handleRefresh = async () => {
        await Promise.all([refreshStats(), refreshLogs()])
    }

    // Senior Dev: Moved hooks to top level to avoid Rules of Hooks violation (early return must be after hooks)
    const recentLogs = React.useMemo(() => logs.slice(0, 5), [logs])

    // 🛰️ TACTICAL ANOMALY ENGINE: Memoized to prevent UI stutter
    const allAlerts = React.useMemo(() => {
        const tactical = dashboardData?.inventory?.filter(item => {
            const isLow = isLowStock(item)
            const isOut = item.stock_available === 0
            const hasHealthIssues = item.qty_damaged > 0 || item.qty_maintenance > 0 || item.qty_lost > 0
            const hasPending = (item as any).stock_pending > 0
            
            let isExpiring = false
            const expiry = (item as any).expiry_date
            if (expiry) {
                const diff = (new Date(expiry).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
                isExpiring = diff <= 30
            }

            return isLow || isOut || hasHealthIssues || hasPending || isExpiring
        }) || []

        return [
            ...tactical.map(item => {
                let label = 'LOW STOCK'
                if (item.stock_available === 0) label = 'CRITICAL'
                else if (item.qty_damaged > 0) label = 'DAMAGED'
                else if ((item as any).expiry_date) label = 'EXPIRING'

                return {
                    id: item.id,
                    type: 'low_stock' as const,
                    label,
                    title: item.item_name,
                    subtitle: item.stock_available === 0 ? 'Out of Stock' : `${item.stock_available} units in registry`
                }
            }),
            ...pendingRequests.map(req => ({ 
                id: req.id,
                type: 'pending' as const, 
                label: 'REQUEST', 
                title: req.item_name, 
                subtitle: `Pending from ${req.borrower_name}` 
            }))
        ]
    }, [dashboardData?.inventory, pendingRequests])

    const displayAlerts = React.useMemo(() => allAlerts.slice(0, 3), [allAlerts])
    const hasMoreAlerts = allAlerts.length > 3

    if (statsLoading && logs.length === 0) {
        return <DashboardSkeleton />
    }

    return (
        <div className="space-y-6 pb-24">
            {/* 🛡️ TACTICAL HEADER — Mirrors Flutter DashboardHeader */}
            <header className="px-5 pt-8 flex items-start gap-4">
                <div className="w-12 h-12 rounded-full bg-slate-900 border-2 border-white shadow-xl flex items-center justify-center shrink-0">
                    <span className="text-white font-black text-lg">{userName[0].toUpperCase()}</span>
                </div>
                <div className="flex-1">
                    <p className="text-[10px] font-black text-slate-400 tracking-[0.2em] mb-0.5">{getGreeting()}</p>
                    <h1 className="text-3xl font-black text-slate-900 tracking-tighter leading-none uppercase italic">
                        {userName.split(' ')[0]}
                    </h1>
                </div>
                <div className="flex items-center gap-2">
                    <div className="flex flex-col items-center">
                        <Activity className="w-5 h-5 text-slate-900" />
                        <span className="text-[10px] font-bold text-slate-900 mt-0.5 tracking-tighter">ONLINE</span>
                    </div>
                </div>
            </header>
            
            <div className="px-4 space-y-6">
                <section className="grid grid-cols-2 gap-3">
                    <StatCard 
                        label="In Field" 
                        value={logStats.borrowed} 
                        icon={ArrowUpRight} 
                        color="blue"
                        isLoading={logsLoading}
                    />
                    <StatCard 
                        label="Depleted" 
                        value={stats.lowStockCount} 
                        icon={AlertCircle} 
                        color="red"
                        isLoading={statsLoading}
                    />
                    <StatCard 
                        label="Late Gear" 
                        value={logStats.overdue} 
                        icon={Clock} 
                        color="amber"
                        isLoading={logsLoading}
                    />
                    <StatCard 
                        label="Registry" 
                        value={stats.totalItems} 
                        icon={Package} 
                        color="slate"
                        isLoading={statsLoading}
                    />
                </section>

                {/* 📡 ALERTS — High-density Triage */}
                <section className="space-y-4">
                    <div className="flex items-center justify-between px-1">
                        <h2 className="text-sm font-bold text-gray-900 uppercase tracking-tight flex items-center gap-2">
                            <AlertCircle className="w-4 h-4 text-red-600" />
                            Alerts
                        </h2>
                        {hasMoreAlerts && (
                            <Link 
                                href="/m/alerts" 
                                className="text-[10px] font-black text-red-600 uppercase tracking-widest flex items-center gap-1"
                            >
                                See All ({allAlerts.length}) <ArrowRight className="w-3 h-3" />
                            </Link>
                        )}
                    </div>
                    
                    {displayAlerts.length > 0 ? (
                        <div className="space-y-3">
                            {displayAlerts.map((alert, idx) => (
                                <Link 
                                    key={idx}
                                    href={alert.type === 'low_stock' ? `/m/inventory/${alert.id}?action=restock` : `/m/alerts?id=${alert.id}`}
                                    className="bg-white p-4 rounded-3xl border border-slate-100 shadow-sm flex items-center justify-between group active:scale-[0.98] transition-all"
                                >
                                    <div className="flex items-center gap-4">
                                        <div className={cn(
                                            "w-10 h-10 rounded-2xl flex items-center justify-center",
                                            alert.type === 'low_stock' ? "bg-red-50 text-red-600" : "bg-blue-50 text-blue-600"
                                        )}>
                                            {alert.type === 'low_stock' ? <Package className="w-5 h-5" /> : <Clock className="w-5 h-5" />}
                                        </div>
                                        <div>
                                            <p className={cn(
                                                "text-[9px] font-black uppercase tracking-widest",
                                                alert.type === 'low_stock' ? "text-red-500" : "text-blue-500"
                                            )}>{alert.label}</p>
                                            <h4 className="font-bold text-slate-900 text-sm">{alert.title}</h4>
                                            <p className="text-[10px] text-slate-400 font-medium">{alert.subtitle}</p>
                                        </div>
                                    </div>
                                    <ArrowRight className="w-4 h-4 text-slate-300 group-active:translate-x-1 transition-transform" />
                                </Link>
                            ))}
                        </div>
                    ) : (
                        <div className="bg-emerald-50 p-6 rounded-3xl border border-emerald-100 flex flex-col items-center text-center">
                            <ShieldCheck className="w-8 h-8 text-emerald-600 mb-2" />
                            <p className="text-xs font-bold text-emerald-700 uppercase tracking-widest">System Stable</p>
                            <p className="text-[10px] text-emerald-600/80 mt-1 font-medium italic">No anomalies detected in this sector.</p>
                        </div>
                    )}
                </section>

                {/* 📜 RECENT ACTIVITY — Forensic Audit Trail */}
                <section className="space-y-4">
                    <div className="flex items-center justify-between px-1">
                        <h2 className="text-sm font-bold text-gray-900 uppercase tracking-tight flex items-center gap-2">
                            <Activity className="w-4 h-4 text-blue-600" />
                            Recent History
                        </h2>
                        <Link 
                            href="/m/logs" 
                            className="text-[10px] font-black text-red-600 uppercase tracking-widest flex items-center gap-1 hover:gap-2 transition-all"
                        >
                            View All <ArrowRight className="w-3 h-3" />
                        </Link>
                    </div>

                    <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
                        {recentLogs.length > 0 ? (
                            <div className="divide-y divide-gray-50">
                                {recentLogs.map((log) => (
                                    <Link 
                                        key={log.id}
                                        href={`/m?id=${log.id}&triage=true`}
                                        className="flex items-start gap-4 p-4 active:bg-gray-50 transition-colors group"
                                    >
                                        <div className={cn(
                                            "w-12 h-12 rounded-2xl flex items-center justify-center shrink-0 border transition-colors",
                                            log.status === 'returned' ? "bg-green-50 border-green-100 text-green-600" :
                                            log.status === 'overdue' ? "bg-red-50 border-red-100 text-red-600" :
                                            "bg-blue-50 border-blue-100 text-blue-600"
                                        )}>
                                            <Package className="w-6 h-6" />
                                        </div>
                                        <div className="flex-1 min-w-0 py-0.5">
                                            <div className="flex items-center justify-between gap-2 mb-0.5">
                                                <h4 className="font-bold text-gray-900 text-sm truncate uppercase tracking-tight">
                                                    {log.item_name}
                                                </h4>
                                                <span className="text-[9px] font-medium text-gray-400 whitespace-nowrap uppercase tracking-widest">
                                                    {formatDistanceToNow(new Date(log.borrow_date || log.created_at), { addSuffix: true })}
                                                </span>
                                            </div>
                                            <p className="text-xs text-gray-500 truncate">
                                                {log.borrower_name} • {log.quantity} items {
                                                    log.status === 'returned' ? 'back' : 
                                                    log.status === 'borrowed' ? 'out' : 
                                                    log.status === 'overdue' ? 'late' : log.status
                                                }
                                            </p>
                                        </div>
                                        <div className="shrink-0 flex items-center self-center text-gray-300">
                                            <ArrowRight className="w-4 h-4 group-active:translate-x-1 transition-transform" />
                                        </div>
                                    </Link>
                                ))}
                            </div>
                        ) : (
                            <div className="p-12 text-center">
                                <p className="text-sm text-gray-400 italic">Everything is quiet for now.</p>
                            </div>
                        )}
                    </div>
                </section>
            </div>
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
