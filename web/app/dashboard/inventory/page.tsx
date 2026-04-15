import dynamic from 'next/dynamic'
import { Suspense } from 'react'

const InventoryClient = dynamic(() => import('./inventory-client').then(mod => mod.InventoryClient), {
    loading: () => <InventorySkeleton />
})

export default function InventoryDashboardPage() {
    return (
        <Suspense fallback={<InventorySkeleton />}>
            <InventoryClient initialInventory={[]} />
        </Suspense>
    )
}

import { Package, Layers, AlertTriangle, XCircle, Plus, Search, CheckSquare, ListPlus, Printer, Settings2 } from 'lucide-react'

function InventorySkeleton() {
    return (
        <div className="space-y-4">
            {/* High-Fidelity Header Frame */}
            <div className="bg-white/95 border border-zinc-200/60 p-4 rounded-2xl shadow-sm">
                <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between mb-4">
                    <h1 className="text-xl 14in:text-2xl font-black tracking-tight text-slate-900 uppercase italic leading-none">
                        Inventory
                    </h1>
                    <div className="flex items-center gap-2 opacity-50 grayscale pointer-events-none">
                        <div className="h-9 w-24 bg-slate-50 border border-slate-200 rounded-lg" />
                        <div className="h-9 w-24 bg-slate-50 border border-slate-200 rounded-lg" />
                        <div className="h-9 w-24 bg-slate-50 border border-slate-200 rounded-lg" />
                        <div className="h-9 w-24 bg-blue-50 border border-blue-100 rounded-xl" />
                    </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                    {[
                        { label: 'Total Items', icon: Package },
                        { label: 'Total Stock', icon: Layers },
                        { label: 'Low Stock', icon: AlertTriangle },
                        { label: 'Out of Stock', icon: XCircle }
                    ].map((stat, i) => (
                        <div key={i} className="bg-white border ring-1 ring-zinc-200/60 p-3 rounded-2xl flex items-center justify-between">
                            <div className="space-y-2">
                                <p className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest">{stat.label}</p>
                                <div className="h-6 w-12 bg-slate-100 rounded" />
                            </div>
                            <stat.icon className="h-4 w-4 text-slate-300" />
                        </div>
                    ))}
                </div>
            </div>

            {/* Filter Bar Frame */}
            <div className="flex items-center gap-4 bg-white/50 p-2 rounded-xl border border-dashed border-slate-200">
                <div className="h-10 flex-1 bg-white border border-slate-200 rounded-lg" />
                <div className="h-10 w-40 bg-white border border-slate-200 rounded-lg" />
                <div className="h-10 w-40 bg-white border border-slate-200 rounded-lg" />
            </div>

            {/* Table Frame */}
            <div className="bg-white rounded-2xl border border-zinc-200/60 overflow-hidden shadow-sm">
                <div className="h-12 bg-slate-50 border-b border-zinc-200/60 px-4 flex items-center gap-4">
                    <div className="h-4 w-4 bg-slate-200 rounded" />
                    <div className="h-4 w-32 bg-slate-200 rounded" />
                    <div className="h-4 w-48 bg-slate-200 rounded" />
                </div>
                <div className="p-4 space-y-4">
                    {[1, 2, 3, 4, 5].map(i => (
                        <div key={i} className="flex items-center justify-between py-4 border-b border-slate-50 last:border-0">
                            <div className="flex items-center gap-4">
                                <div className="h-12 w-12 bg-slate-100 rounded-xl" />
                                <div className="space-y-2">
                                    <div className="h-4 w-48 bg-slate-100 rounded" />
                                    <div className="h-3 w-24 bg-slate-50 rounded" />
                                </div>
                            </div>
                            <div className="h-8 w-32 bg-slate-50 rounded-lg" />
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}
