'use client'

import { useMemo } from 'react'
import { InventoryItem } from '@/lib/supabase'

interface InventoryStatsProps {
    items: InventoryItem[]
}

export function InventoryStats({ items }: InventoryStatsProps) {
    const stats = useMemo(() => {
        const totalItems = items.length
        const lowStockItems = items.filter(item => item.stock_available > 0 && item.stock_available < 5).length
        const outOfStockItems = items.filter(item => item.stock_available === 0).length
        const totalStock = items.reduce((sum, item) => sum + item.stock_available, 0)

        return { totalItems, lowStockItems, outOfStockItems, totalStock }
    }, [items])

    return (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <StatCard label="Total Items" value={stats.totalItems} />
            <StatCard label="Total Stock" value={stats.totalStock} />
            <StatCard label="Low Stock" value={stats.lowStockItems} accent={stats.lowStockItems > 0 ? 'amber' : undefined} />
            <StatCard label="Out of Stock" value={stats.outOfStockItems} accent={stats.outOfStockItems > 0 ? 'red' : undefined} />
        </div>
    )
}

function StatCard({ label, value, accent }: { label: string; value: number; accent?: 'amber' | 'red' }) {
    const valueColor = accent === 'red' ? 'text-red-600' : accent === 'amber' ? 'text-orange-600' : 'text-slate-900'

    return (
        <div className="bg-white border border-gray-200/60 rounded-xl p-3 14in:p-4 flex items-center justify-between shadow-sm hover:shadow-md transition-all duration-300 group">
            <div>
                <p className="text-[9px] font-bold text-slate-400 uppercase tracking-[0.15em] mb-1.5 transition-colors group-hover:text-slate-500 leading-none">{label}</p>
                <div className="flex items-baseline gap-2">
                    <p className={`text-2xl 14in:text-3xl font-heading font-bold tabular-nums leading-none tracking-tight ${valueColor} group-hover:scale-105 transition-transform origin-left`}>
                        {value}
                    </p>
                    {accent && (
                        <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{accent === 'red' ? 'ALERT' : 'WARNING'}</span>
                    )}
                </div>
            </div>
            {accent && (
                <div className={`h-2 w-2 rounded-full relative ${accent === 'red' ? 'bg-red-500 shadow-[0_0_10px_rgba(239,68,68,0.5)]' : 'bg-orange-500 shadow-[0_0_10px_rgba(245,158,11,0.5)]'} animate-pulse`} />
            )}
        </div>
    )
}
