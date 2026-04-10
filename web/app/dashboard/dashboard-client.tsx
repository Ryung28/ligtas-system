'use client'

import { Package, Activity, Clock, CheckCircle2, Box, ClipboardList, Plus, AlertCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'

import useSWR from 'swr'
import { createBrowserClient } from '@supabase/ssr'
import { useDashboardStats } from '@/hooks/use-dashboard-stats'
import { useTrendingInventory } from '@/hooks/use-trending-inventory'
import { StatsCard } from '@/components/dashboard/stats-card'
import { ResourcePulseChart } from '@/components/dashboard/resource-pulse-chart'
import { LogisticsIntelQueue } from '@/components/dashboard/logistics-intel-queue'
import { TrendingInventoryChart } from '@/components/dashboard/trending-inventory-chart'
import { DeploymentClustersChart } from '@/components/dashboard/deployment-clusters-chart'
import { OperationalControls } from '@/components/dashboard/operational-controls'

const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export default function DashboardClient() {
    const { stats, isLoading, topItemsData, categoryDistribution } = useDashboardStats()
    const { trendingData } = useTrendingInventory(5)

    // Reactive Intel Count for the Hub Badge
    const { data: intel = [] } = useSWR<any[]>('system_intel_count', async () => {
        const { data } = await supabase.from('system_intel').select('id');
        return data || [];
    }, { refreshInterval: 10000 });

    // Empty State UI
    if (!isLoading && stats.totalItems === 0) {
        return (
            <div className="flex flex-col items-center justify-center min-h-[80vh] p-6 text-center space-y-6 animate-in fade-in duration-700">
                <div className="h-20 w-20 bg-blue-50 rounded-[2rem] flex items-center justify-center shadow-xl shadow-blue-100 ring-1 ring-blue-100">
                    <Package className="h-8 w-8 text-blue-600" />
                </div>
                <div className="max-w-md space-y-2">
                    <h1 className="text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic">LIGTAS Command</h1>
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
                <div className="relative z-10">
                    <div className="flex items-center gap-2 mb-1">
                        <div className="h-1 w-8 bg-blue-600 rounded-full" />
                        <span className="text-[10px] font-bold text-blue-600 uppercase tracking-widest">Overview</span>
                    </div>
                    <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic">
                        Main Dashboard
                    </h1>
                </div>
                <div className="flex gap-2">
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

                {(() => {
                    const readiness = ((stats.totalItems - (stats.outOfStockCount + stats.damagedCount)) / (stats.totalItems || 1)) * 100;
                    let color: 'emerald' | 'amber' | 'rose' = 'emerald';
                    if (readiness < 50) color = 'rose';
                    else if (readiness < 85) color = 'amber';

                    return (
                        <StatsCard
                            title="Inventory Readiness"
                            value={`${readiness.toFixed(0)}%`}
                            icon={Activity}
                            color={color}
                            description={readiness < 100 ? `${stats.damagedCount + stats.outOfStockCount} UNITS OFF-LINE` : "FULLY READY FOR DUTY"}
                        />
                    );
                })()}
            </section>

            {/* THE TACTICAL GRID: Optimized for 14" Enterprise Viewing */}
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
    
    {/* 🎯 CORE ANALYTICS HUB: Stock Summary */}
    <div className="lg:col-span-7">
        <Card className="bg-white/80 backdrop-blur-md shadow-xl shadow-slate-200/40 border-none rounded-[1.5rem] ring-1 ring-slate-100 overflow-hidden min-h-[460px]">
            <Tabs defaultValue="stock" className="w-full h-full flex flex-col">
                <CardHeader className="p-6 pb-2 bg-slate-50/30 border-b border-slate-100/50">
                    <div className="flex items-center justify-between">
                        <div>
                            <CardTitle className="text-sm font-heading font-semibold text-slate-900 uppercase tracking-wide">Stock Performance</CardTitle>
                            <CardDescription className="text-[10px] text-slate-500 font-medium uppercase tracking-tight mt-0.5">Inventory levels and trends</CardDescription>
                        </div>
                        <TabsList className="bg-slate-100/80 p-0.5 rounded-xl h-9">
                            <TabsTrigger 
                                value="stock" 
                                className="text-[10px] uppercase font-bold tracking-tight rounded-lg px-4 py-1.5 data-[state=active]:bg-white data-[state=active]:text-blue-600 data-[state=active]:shadow-sm transition-all"
                            >
                                Current Stock
                            </TabsTrigger>
                            <TabsTrigger 
                                value="borrowed" 
                                className="text-[10px] uppercase font-bold tracking-tight rounded-lg px-4 py-1.5 data-[state=active]:bg-white data-[state=active]:text-emerald-600 data-[state=active]:shadow-sm transition-all"
                            >
                                Usage History
                            </TabsTrigger>
                        </TabsList>
                    </div>
                </CardHeader>
                
                <div className="flex-1">
                    <TabsContent value="stock" className="m-0 border-none outline-none animate-in fade-in slide-in-from-left-2 duration-300">
                        <ResourcePulseChart data={topItemsData} />
                    </TabsContent>
                    <TabsContent value="borrowed" className="m-0 border-none outline-none animate-in fade-in slide-in-from-right-2 duration-300">
                        <TrendingInventoryChart data={trendingData} />
                    </TabsContent>
                </div>
            </Tabs>
        </Card>
    </div>

    {/* 🛠️ OPERATIONS HUB: Action Center (Wider for High-Density Data) */}
    <div className="lg:col-span-5 space-y-6">
        <Card className="bg-white/80 backdrop-blur-md shadow-xl shadow-slate-200/40 border-none rounded-[1.5rem] ring-1 ring-slate-100 overflow-hidden min-h-[460px]">
            <Tabs defaultValue="tasks" className="w-full h-full flex flex-col">
                <CardHeader className="p-6 pb-2 bg-slate-50/30 border-b border-slate-100/50">
                    <div className="flex items-center justify-between">
                        <div>
                            <CardTitle className="text-sm font-heading font-semibold text-slate-900 uppercase tracking-wide">Action Center</CardTitle>
                            <CardDescription className="text-[10px] text-slate-500 font-medium uppercase tracking-tight mt-0.5">Items needing attention</CardDescription>
                        </div>
                        <TabsList className="bg-slate-100/80 p-0.5 rounded-xl h-9">
                            <TabsTrigger 
                                value="tasks" 
                                className="text-[10px] uppercase font-bold tracking-tight rounded-lg px-4 py-1.5 data-[state=active]:bg-white data-[state=active]:text-slate-900 data-[state=active]:shadow-sm transition-all flex items-center gap-2"
                            >
                                <span>Tasks</span>
                                {intel.length > 0 && (
                                    <span className="flex h-2 w-2 rounded-full bg-red-500 ring-2 ring-white"></span>
                                )}
                            </TabsTrigger>
                            <TabsTrigger 
                                value="sectors" 
                                className="text-[10px] uppercase font-bold tracking-tight rounded-lg px-4 py-1.5 data-[state=active]:bg-white data-[state=active]:text-slate-900 data-[state=active]:shadow-sm transition-all"
                            >
                                Categories
                            </TabsTrigger>
                        </TabsList>
                    </div>
                </CardHeader>
                
                <div className="flex-1 overflow-hidden">
                    <TabsContent value="tasks" className="m-0 h-full border-none outline-none animate-in fade-in slide-in-from-left-2 duration-300">
                        <LogisticsIntelQueue />
                    </TabsContent>
                    <TabsContent value="sectors" className="m-0 h-full border-none outline-none animate-in fade-in slide-in-from-right-2 duration-300">
                        <DeploymentClustersChart data={categoryDistribution} />
                    </TabsContent>
                </div>
            </Tabs>
        </Card>

        <OperationalControls />
    </div>
</div>
        </div>
    )
}
