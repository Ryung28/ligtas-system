'use client'

import { useEffect, useState } from 'react'
import { Package, AlertCircle, RefreshCw, Plus, Activity, Box, ClipboardList } from 'lucide-react'
import { Button } from '@/components/ui/button'

// New modular components & hooks
import { useDashboardStats } from '@/hooks/use-dashboard-stats'
import { StatsCard } from '@/components/dashboard/stats-card'
import { ResourcePulseChart } from '@/components/dashboard/resource-pulse-chart'
import { DeploymentClustersChart } from '@/components/dashboard/deployment-clusters-chart'
import { OperationalControls } from '@/components/dashboard/operational-controls'

export default function DashboardOverview() {
    const { stats, data, isLoading, refresh, topItemsData, categoryDistribution } = useDashboardStats()
    const [mounted, setMounted] = useState(false)

    useEffect(() => {
        setMounted(true)
    }, [])

    if (!mounted) return null

    // Empty State UI
    if (!isLoading && stats.totalItems === 0) {
        return (
            <div className="flex flex-col items-center justify-center min-h-[80vh] p-6 text-center space-y-6 animate-in fade-in duration-700">
                <div className="h-20 w-20 bg-blue-50 rounded-[2rem] flex items-center justify-center shadow-xl shadow-blue-100 ring-1 ring-blue-100">
                    <Package className="h-8 w-8 text-blue-600" />
                </div>
                <div className="max-w-md space-y-2">
                    <h2 className="text-3xl font-semibold text-slate-900 tracking-tight font-heading">LIGTAS Command</h2>
                    <p className="text-slate-500">Registry initialized. Awaiting equipment data ingestion.</p>
                </div>
                <Button asChild size="lg" className="h-12 px-6 rounded-xl gap-2 bg-blue-600 hover:bg-blue-700 shadow-lg font-medium uppercase tracking-wide text-[10px]">
                    <a href="/dashboard/inventory"><Plus className="h-4 w-4" /> Initialize Registry</a>
                </Button>
            </div>
        )
    }

    return (
        <div className="space-y-6 animate-in fade-in duration-500">
            {/* Header */}
            <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                    <h1 className="text-xl 14in:text-2xl font-bold tracking-tight text-slate-900 font-heading">Dashboard Summary</h1>
                    <div className="flex items-center gap-2 mt-0.5">
                        <div className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse shadow-[0_0_8px_rgba(16,185,129,0.6)]" />
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em]">
                            System Active • Updated {data?.timestamp || 'just now'}
                        </p>
                    </div>
                </div>
                <div className="flex gap-2">
                    <Button onClick={() => refresh()} disabled={isLoading} variant="outline" className="h-9 px-4 rounded-xl gap-2 bg-white border-slate-200 text-slate-600 font-medium text-[10px] uppercase tracking-wide hover:bg-slate-50 transition-all active:scale-95">
                        <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin' : ''}`} /> Sync
                    </Button>
                    <Button asChild className="h-9 px-5 rounded-xl gap-2 bg-slate-900 hover:bg-slate-800 text-white shadow-md font-medium text-[10px] uppercase tracking-wide transition-all active:scale-95">
                        <a href="/dashboard/inventory"><Plus className="h-3.5 w-3.5" /> Add New Item</a>
                    </Button>
                </div>
            </header>

            {/* KPI Cards */}
            <section className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <StatsCard title="Total Items" value={stats.totalItems} icon={Package} color="blue" description="Types of Items" />
                <StatsCard title="Total Stock" value={stats.totalStock} icon={Box} color="indigo" description="All Units on Hand" />
                <StatsCard title="Items Lent" value={stats.activeBorrows} icon={ClipboardList} color="purple" description="Currently Borrowed" />
                <StatsCard title="Stock Health" value={`${((1 - ((stats.lowStockCount + stats.outOfStockCount) / (stats.totalItems || 1))) * 100).toFixed(0)}%`} icon={Activity} color="emerald" description="Items in Stock" />
            </section>

            {/* Logistics Alert */}
            {(stats.lowStockCount > 0 || stats.outOfStockCount > 0) && (
                <div className="bg-white/80 backdrop-blur-md border border-orange-100 shadow-lg shadow-orange-100/10 rounded-2xl p-4 flex items-center gap-4 animate-in slide-in-from-top-2 duration-500">
                    <div className="h-10 w-10 bg-orange-100 rounded-xl flex items-center justify-center shrink-0">
                        <AlertCircle className="h-5 w-5 text-orange-600" />
                    </div>
                    <div className="flex-1">
                        <p className="text-xs text-slate-600">
                            <span className="font-semibold text-orange-600 uppercase tracking-tight mr-1">Stock Warning:</span>
                            {stats.lowStockCount} items are low on stock and {stats.outOfStockCount} are out. Please restock soon.
                        </p>
                    </div>
                    <Button variant="ghost" asChild className="text-orange-600 font-medium text-[10px] uppercase tracking-wide hover:bg-orange-50 rounded-lg h-8 px-3">
                        <a href="/dashboard/inventory">Resolve</a>
                    </Button>
                </div>
            )}

            {/* Sub-Command Grid */}
            <div className="grid gap-5 lg:grid-cols-12">
                <ResourcePulseChart data={topItemsData} />

                <div className="lg:col-span-4 space-y-5">
                    <DeploymentClustersChart data={categoryDistribution} />
                    <OperationalControls />
                </div>
            </div>
        </div>
    )
}
