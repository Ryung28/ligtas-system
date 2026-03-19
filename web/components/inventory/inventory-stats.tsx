'use client'

import { useMemo } from 'react'
import { InventoryItem } from '@/lib/supabase'
import { Package, Layers, AlertTriangle, XCircle } from 'lucide-react'

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
            <StatCard label="Total Items" value={stats.totalItems} icon={Package} color="slate" />
            <StatCard label="Total Stock" value={stats.totalStock} icon={Layers} color="blue" />
            <StatCard label="Low Stock" value={stats.lowStockItems} icon={AlertTriangle} color="amber" accent={stats.lowStockItems > 0 ? 'amber' : undefined} />
            <StatCard label="Out of Stock" value={stats.outOfStockItems} icon={XCircle} color="rose" accent={stats.outOfStockItems > 0 ? 'red' : undefined} />
        </div>
    )
}

function StatCard({ 
    label, 
    value, 
    icon: Icon,
    color = 'slate',
    accent 
}: { 
    label: string
    value: number
    icon: any
    color?: string
    accent?: 'amber' | 'red' 
}) {
    const colorTheme: Record<string, { text: string }> = {
        slate: { text: 'text-slate-500' },
        blue: { text: 'text-blue-500' },
        amber: { text: 'text-amber-500' },
        rose: { text: 'text-rose-500' },
    }

    const theme = colorTheme[color] || colorTheme.slate
    const valueColor = accent === 'red' ? 'text-red-600' : accent === 'amber' ? 'text-orange-600' : 'text-slate-900'

    return (
        <div className="relative overflow-hidden bg-white border-none ring-1 ring-zinc-200/60 shadow-sm hover:shadow-[0_8px_16px_-6px_rgba(0,0,0,0.05)] hover:ring-zinc-300 transition-all duration-300 rounded-2xl group">
            <div className="p-3.5 14in:p-5 flex items-center justify-between gap-3">
                <div className="min-w-0 flex-1">
                    <div className="flex items-center mb-1.5">
                        <p className="text-[9px] 14in:text-[10px] font-bold tracking-[0.1em] text-zinc-400 uppercase truncate leading-none">
                            {label}
                        </p>
                    </div>
                    <div className="flex items-baseline gap-1.5 overflow-hidden">
                        <p className={`text-xl 14in:text-2xl font-mono font-black tabular-nums tracking-tighter ${valueColor} group-hover:translate-x-0.5 transition-transform duration-300`}>
                            {value}
                        </p>
                        {accent && (
                            <span className="text-[8px] 14in:text-[9px] font-bold text-zinc-400 uppercase tracking-widest leading-none opacity-60 italic shrink-0">
                                {accent === 'red' ? 'ALERT' : 'WARNING'}
                            </span>
                        )}
                    </div>
                </div>
                
                <div className={`flex-shrink-0 h-10 w-10 rounded-xl flex items-center justify-center bg-white border border-zinc-200 shadow-sm shadow-[inset_0_2px_4px_rgba(255,255,255,0.8)] transition-all duration-300 group-hover:border-zinc-300 group-hover:-translate-y-0.5`}>
                    <Icon className={`h-5 w-5 ${theme.text} stroke-[2px] transition-transform duration-300 group-hover:scale-110`} />
                </div>
            </div>
            
            {/* Minimal Grid - Faint Operational Texture */}
            <div className="absolute inset-x-0 bottom-0 h-8 opacity-[0.015] pointer-events-none" 
                 style={{ backgroundImage: 'radial-gradient(circle, #000 1px, transparent 1px)', backgroundSize: '10px 10px' }} />
        </div>
    )
}
