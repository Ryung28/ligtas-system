'use client'

import { Button } from '@/components/ui/button'
import { Plus, ListPlus, Package, Layers, AlertTriangle, XCircle, Trash2, CheckSquare } from 'lucide-react'
import { BulkAddDialog } from './bulk-add-dialog'
import { InventoryPrintCatalog } from './inventory-print-catalog'
import { InventoryItem } from '@/lib/supabase'
import { useMemo } from 'react'

interface InventoryHeaderProps {
    lastUpdated: Date
    isLoading: boolean
    onRefresh: () => void
    items?: InventoryItem[]
    selectedCount?: number
    onBulkDelete?: () => void
    selectionMode?: boolean
    onToggleSelectionMode?: () => void
    onAddItem?: () => void
}

export function InventoryHeader({ lastUpdated, isLoading, onRefresh, items = [], selectedCount = 0, onBulkDelete, selectionMode = false, onToggleSelectionMode, onAddItem }: InventoryHeaderProps) {
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
                    {selectionMode ? (
                        <>
                            {selectedCount > 0 && onBulkDelete && (
                                <Button 
                                    variant="destructive" 
                                    size="sm" 
                                    onClick={onBulkDelete}
                                    className="h-9 text-[13px] font-semibold transition-all rounded-xl px-4 shadow-lg hover:shadow-xl hover:-translate-y-0.5 active:scale-95"
                                >
                                    <Trash2 className="h-4 w-4 mr-1.5" />
                                    Delete {selectedCount} Item{selectedCount > 1 ? 's' : ''}
                                </Button>
                            )}
                            <Button 
                                variant="outline" 
                                size="sm" 
                                onClick={onToggleSelectionMode}
                                className="h-9 text-[13px] font-medium transition-all rounded-lg px-3"
                            >
                                Cancel
                            </Button>
                        </>
                    ) : (
                        <>
                            <Button 
                                variant="ghost" 
                                size="sm" 
                                onClick={onToggleSelectionMode}
                                className="h-9 text-gray-600 hover:text-gray-900 hover:bg-gray-100 text-[13px] font-medium transition-colors rounded-lg px-3"
                            >
                                <CheckSquare className="h-4 w-4 mr-1.5" />
                                Select Multiple
                            </Button>
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
                            <Button 
                                onClick={onAddItem}
                                size="sm" 
                                className="h-9 bg-blue-600 hover:bg-blue-700 text-white text-[13px] font-semibold transition-all rounded-xl px-4 shadow-lg shadow-blue-600/20 hover:shadow-xl hover:shadow-blue-600/30 hover:-translate-y-0.5 active:scale-95"
                            >
                                <Plus className="h-4 w-4 mr-1.5" />
                                Add Item
                            </Button>
                        </>
                    )}
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
        slate: 'text-slate-500',
        blue: 'text-blue-500',
        amber: 'text-amber-500',
        rose: 'text-rose-500',
    }

    const iconBg: Record<string, string> = {
        slate: 'bg-slate-50',
        blue: 'bg-blue-50',
        amber: 'bg-amber-50',
        rose: 'bg-rose-50',
    }

    const valueColor = alert && color === 'rose' ? 'text-red-600' : alert && color === 'amber' ? 'text-orange-600' : 'text-slate-900'

    return (
        <div className="relative overflow-hidden bg-white border-none ring-1 ring-zinc-200/60 shadow-sm hover:shadow-[0_8px_16px_-6px_rgba(0,0,0,0.05)] hover:ring-zinc-300 transition-all duration-300 rounded-2xl group">
            <div className="p-2.5 14in:p-3 flex items-center justify-between gap-3">
                <div className="min-w-0 flex-1">
                    <div className="flex items-center mb-1">
                        <p className="text-[9px] 14in:text-[10px] font-bold tracking-[0.1em] text-zinc-400 uppercase truncate leading-none">
                            {label}
                        </p>
                    </div>
                    <div className="flex items-baseline gap-1.5 overflow-hidden">
                        <p 
                            key={value}
                            className={`text-lg 14in:text-xl font-mono font-black tabular-nums tracking-tighter ${valueColor} group-hover:translate-x-0.5 transition-all duration-300 animate-in fade-in zoom-in-95 duration-500`}
                        >
                            {value}
                        </p>
                        {alert && (
                            <span className="text-[8px] 14in:text-[9px] font-bold text-zinc-400 uppercase tracking-widest leading-none opacity-60 italic shrink-0">
                                {color === 'rose' ? 'ALERT' : 'WARNING'}
                            </span>
                        )}
                    </div>
                </div>
                
                <div className="flex-shrink-0 h-8 w-8 rounded-xl flex items-center justify-center bg-white border border-zinc-200 shadow-sm shadow-[inset_0_2px_4px_rgba(255,255,255,0.8)] transition-all duration-300 group-hover:border-zinc-300 group-hover:-translate-y-0.5">
                    <Icon className={`h-4 w-4 ${colorClasses[color]} stroke-[2px] transition-transform duration-300 group-hover:scale-110`} />
                </div>
            </div>
            
            {/* Minimal Grid - Faint Operational Texture */}
            <div className="absolute inset-x-0 bottom-0 h-8 opacity-[0.015] pointer-events-none" 
                 style={{ backgroundImage: 'radial-gradient(circle, #000 1px, transparent 1px)', backgroundSize: '10px 10px' }} />
        </div>
    )
}
