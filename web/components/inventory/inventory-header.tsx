'use client'

import { useMemo } from 'react'
import { Button } from '@/components/ui/button'
import { Plus, ListPlus, Package, Layers, AlertTriangle, XCircle, Trash2, CheckSquare, Settings2 } from 'lucide-react'
import { BulkAddDialog } from './bulk-add-dialog'
import { InventoryPrintCatalog } from './inventory-print-catalog'
import { LocationManagerDialog } from './location-manager-dialog'
import { InventoryItem } from '@/lib/supabase'
import { isLowStock } from '@/lib/inventory-utils'
import { DispatchCommandSheet } from '@/src/features/transactions/v2/dispatch-command-sheet'

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
    activeStatus?: string | null
    onStatusChange?: (status: string | null) => void
}

export function InventoryHeader({ lastUpdated, isLoading, onRefresh, items = [], selectedCount = 0, onBulkDelete, selectionMode = false, onToggleSelectionMode, onAddItem, activeStatus, onStatusChange }: InventoryHeaderProps) {
    const stats = useMemo(() => {
        const totalItems = items.length
        const lowStockItems = items.filter(item => isLowStock(item)).length
        const outOfStockItems = items.filter(item => item.stock_available === 0).length
        const totalStock = items.reduce((sum, item) => sum + item.stock_available, 0)
        return { totalItems, lowStockItems, outOfStockItems, totalStock }
    }, [items])

    return (
        <div className="bg-white/95 backdrop-blur-xl border border-zinc-200/60 p-3 14in:p-4 rounded-2xl shadow-[0_8px_40px_rgb(0,0,0,0.03),inset_0_1px_0_rgba(255,255,255,0.8)]">
            {/* Title + Actions Row */}
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between mb-4">
                <h1 className="text-xl 14in:text-2xl font-black tracking-tight text-slate-900 font-heading uppercase italic leading-none">
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
                            
                            <LocationManagerDialog />
                            <InventoryPrintCatalog items={items} />
                            <DispatchCommandSheet />
                            
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
                <InlineStat 
                    label="Total Items" 
                    value={stats.totalItems} 
                    icon={Package} 
                    isActive={!activeStatus || activeStatus === 'all'}
                    onClick={() => onStatusChange?.(null)}
                />
                <InlineStat 
                    label="Total Stock" 
                    value={stats.totalStock} 
                    icon={Layers} 
                    color="blue" 
                />
                <InlineStat 
                    label="Low Stock" 
                    value={stats.lowStockItems} 
                    icon={AlertTriangle} 
                    color="amber" 
                    alert={stats.lowStockItems > 0} 
                    isActive={activeStatus === 'low_stock'}
                    onClick={() => onStatusChange?.(activeStatus === 'low_stock' ? null : 'low_stock')}
                />
                <InlineStat 
                    label="Out of Stock" 
                    value={stats.outOfStockItems} 
                    icon={XCircle} 
                    color="rose" 
                    alert={stats.outOfStockItems > 0} 
                    isActive={activeStatus === 'out_of_stock'}
                    onClick={() => onStatusChange?.(activeStatus === 'out_of_stock' ? null : 'out_of_stock')}
                />
            </div>
        </div>
    )
}

function InlineStat({ 
    label, 
    value, 
    icon: Icon, 
    color = 'slate',
    alert = false,
    isActive = false,
    onClick
}: { 
    label: string
    value: number
    icon: any
    color?: string
    alert?: boolean
    isActive?: boolean
    onClick?: () => void
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
        <div 
            onClick={onClick}
            className={`relative overflow-hidden bg-white border-none ring-1 shadow-sm transition-all duration-300 rounded-2xl group ${onClick ? 'cursor-pointer hover:shadow-[0_8px_16px_-6px_rgba(0,0,0,0.05)] active:scale-95' : ''} ${
                isActive ? 'ring-2 ring-blue-500 bg-blue-50/30' : 'ring-zinc-200/60 hover:ring-zinc-300'
            }`}
        >
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
