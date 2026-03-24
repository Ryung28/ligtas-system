'use client'

import { Button } from '@/components/ui/button'
import { Plus, ListPlus, Package, Layers, AlertTriangle, XCircle } from 'lucide-react'
import { BulkAddDialog } from './bulk-add-dialog'
import { InventoryItemDialog } from './inventory-item-dialog'
import { InventoryPrintCatalog } from './inventory-print-catalog'
import { InventoryItem } from '@/lib/supabase'
import { useMemo } from 'react'

interface InventoryHeaderProps {
    lastUpdated: Date
    isLoading: boolean
    onRefresh: () => void
    items?: InventoryItem[]
}

export function InventoryHeader({ lastUpdated, isLoading, onRefresh, items = [] }: InventoryHeaderProps) {
    const stats = useMemo(() => {
        const totalItems = items.length
        const lowStockItems = items.filter(item => item.stock_available > 0 && item.stock_available < 5).length
        const outOfStockItems = items.filter(item => item.stock_available === 0).length
        const totalStock = items.reduce((sum, item) => sum + item.stock_available, 0)
        return { totalItems, lowStockItems, outOfStockItems, totalStock }
    }, [items])

    return (
        <div className="bg-white/95 backdrop-blur-xl border border-zinc-200/60 p-4 14in:p-5 rounded-2xl shadow-[0_8px_40px_rgb(0,0,0,0.03),inset_0_1px_0_rgba(255,255,255,0.8)]">
            {/* Title + Actions Row */}
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between mb-4">
                <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic leading-none">
                    Inventory
                </h1>
                <div className="flex items-center gap-2">
                    <InventoryPrintCatalog items={items} />
                    <BulkAddDialog
                        onSuccess={onRefresh}
                        trigger={
                            <Button variant="ghost" size="sm" className="h-9 text-gray-600 hover:text-gray-900 hover:bg-gray-100 text-[13px] font-medium transition-colors rounded-lg px-3">
                                <ListPlus className="h-4 w-4 mr-1.5" />
                                Bulk Add
                            </Button>
                        }
                    />
                    <InventoryItemDialog
                        onSuccess={onRefresh}
                        trigger={
                            <Button size="sm" className="h-9 bg-blue-600 hover:bg-blue-700 text-white text-[13px] font-semibold transition-all rounded-xl px-4 shadow-lg shadow-blue-600/20 hover:shadow-xl hover:shadow-blue-600/30 hover:-translate-y-0.5 active:scale-95">
                                <Plus className="h-4 w-4 mr-1.5" />
                                Add Item
                            </Button>
                        }
                    />
                </div>
            </div>

            {/* Inline Stats Row */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                <InlineStat label="Total Items" value={stats.totalItems} icon={Package} />
                <InlineStat label="Total Stock" value={stats.totalStock} icon={Layers} color="blue" />
                <InlineStat label="Low Stock" value={stats.lowStockItems} icon={AlertTriangle} color="amber" alert={stats.lowStockItems > 0} />
                <InlineStat label="Out of Stock" value={stats.outOfStockItems} icon={XCircle} color="rose" alert={stats.outOfStockItems > 0} />
            </div>
        </div>
    )
}

function InlineStat({ 
    label, 
    value, 
    icon: Icon, 
    color = 'slate',
    alert = false
}: { 
    label: string
    value: number
    icon: any
    color?: string
    alert?: boolean
}) {
    const colorClasses: Record<string, string> = {
        slate: 'text-slate-600',
        blue: 'text-blue-600',
        amber: 'text-amber-600',
        rose: 'text-rose-600',
    }

    const iconBg: Record<string, string> = {
        slate: 'bg-slate-50',
        blue: 'bg-blue-50',
        amber: 'bg-amber-50',
        rose: 'bg-rose-50',
    }

    return (
        <div className="flex items-center gap-3 p-3 rounded-xl bg-gray-50/50 border border-gray-100">
            <div className={`flex-shrink-0 h-10 w-10 rounded-lg ${iconBg[color]} flex items-center justify-center`}>
                <Icon className={`h-5 w-5 ${colorClasses[color]}`} />
            </div>
            <div className="min-w-0 flex-1">
                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wide truncate leading-none">
                    {label}
                </p>
                <div className="flex items-baseline gap-1.5 mt-1">
                    <p className="text-xl font-black text-gray-900 tabular-nums leading-none">
                        {value}
                    </p>
                    {alert && (
                        <span className="text-[8px] font-bold text-gray-400 uppercase tracking-widest leading-none opacity-60">
                            {color === 'rose' ? 'ALERT' : 'WARNING'}
                        </span>
                    )}
                </div>
            </div>
        </div>
    )
}
