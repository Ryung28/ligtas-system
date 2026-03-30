'use client'

import { useMemo } from 'react'
import { InventoryItem, STORAGE_LOCATION_LABELS, StorageLocation } from '@/lib/supabase'
import { Package, Layers, AlertTriangle, XCircle, Warehouse } from 'lucide-react'

interface InventoryStatsProps {
    items: InventoryItem[]
    onLocationFilter?: (location: StorageLocation | null) => void
    activeLocation?: StorageLocation | null
}

export function InventoryStats({ items, onLocationFilter, activeLocation }: InventoryStatsProps) {
    const stats = useMemo(() => {
        const totalItems = items.length
        const lowStockItems = items.filter(item => item.stock_available > 0 && item.stock_available < 5).length
        const outOfStockItems = items.filter(item => item.stock_available === 0).length
        const totalStock = items.reduce((sum, item) => sum + item.stock_available, 0)

        // Location breakdown
        const locationStats = items.reduce((acc, item) => {
            const location = item.storage_location || 'lower_warehouse'
            acc[location] = (acc[location] || 0) + 1
            return acc
        }, {} as Record<string, number>)

        return { totalItems, lowStockItems, outOfStockItems, totalStock, locationStats }
    }, [items])

    return (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <StatCard 
                label="Lower Warehouse" 
                value={stats.locationStats.lower_warehouse || 0} 
                icon={Warehouse} 
                color="blue"
                size="compact"
                clickable
                isActive={activeLocation === 'lower_warehouse'}
                onClick={() => onLocationFilter?.(activeLocation === 'lower_warehouse' ? null : 'lower_warehouse')}
                hint="Click to filter"
            />
            <StatCard 
                label="2nd Floor Warehouse" 
                value={stats.locationStats['2nd_floor_warehouse'] || 0} 
                icon={Warehouse} 
                color="purple"
                size="compact"
                clickable
                isActive={activeLocation === '2nd_floor_warehouse'}
                onClick={() => onLocationFilter?.(activeLocation === '2nd_floor_warehouse' ? null : '2nd_floor_warehouse')}
                hint="Click to filter"
            />
            <StatCard 
                label="Office" 
                value={stats.locationStats.office || 0} 
                icon={Warehouse} 
                color="gray"
                size="compact"
                clickable
                isActive={activeLocation === 'office'}
                onClick={() => onLocationFilter?.(activeLocation === 'office' ? null : 'office')}
                hint="Click to filter"
            />
            <StatCard 
                label="Field" 
                value={stats.locationStats.field || 0} 
                icon={Warehouse} 
                color="green"
                size="compact"
                clickable
                isActive={activeLocation === 'field'}
                onClick={() => onLocationFilter?.(activeLocation === 'field' ? null : 'field')}
                hint="Click to filter"
            />
        </div>
    )
}

function StatCard({ 
    label, 
    value, 
    icon: Icon,
    color = 'slate',
    accent,
    size = 'default',
    clickable = false,
    isActive = false,
    onClick,
    hint
}: { 
    label: string
    value: number
    icon: any
    color?: string
    accent?: 'amber' | 'red'
    size?: 'default' | 'compact'
    clickable?: boolean
    isActive?: boolean
    onClick?: () => void
    hint?: string
}) {
    const colorTheme: Record<string, { text: string, activeBg?: string, activeRing?: string }> = {
        slate: { text: 'text-slate-500' },
        blue: { text: 'text-blue-500', activeBg: 'bg-blue-50', activeRing: 'ring-blue-500' },
        purple: { text: 'text-purple-500', activeBg: 'bg-purple-50', activeRing: 'ring-purple-500' },
        gray: { text: 'text-gray-500', activeBg: 'bg-gray-50', activeRing: 'ring-gray-500' },
        green: { text: 'text-green-500', activeBg: 'bg-green-50', activeRing: 'ring-green-500' },
        amber: { text: 'text-amber-500' },
        rose: { text: 'text-rose-500' },
    }

    const theme = colorTheme[color] || colorTheme.slate
    const valueColor = accent === 'red' ? 'text-red-600' : accent === 'amber' ? 'text-orange-600' : 'text-slate-900'
    
    const sizeClasses = size === 'compact' 
        ? 'p-2.5 14in:p-3' 
        : 'p-3.5 14in:p-5'
    
    const numberSize = size === 'compact'
        ? 'text-lg 14in:text-xl'
        : 'text-xl 14in:text-2xl'
    
    const iconSize = size === 'compact'
        ? 'h-8 w-8'
        : 'h-10 w-10'
    
    const iconInnerSize = size === 'compact'
        ? 'h-4 w-4'
        : 'h-5 w-5'

    return (
        <div 
            className={`relative overflow-hidden bg-white border-none ring-1 shadow-sm transition-all duration-300 rounded-2xl group ${
                clickable ? 'cursor-pointer hover:shadow-[0_8px_16px_-6px_rgba(0,0,0,0.08)] hover:-translate-y-0.5 active:scale-[0.98]' : 'hover:shadow-[0_8px_16px_-6px_rgba(0,0,0,0.05)]'
            } ${
                isActive && theme.activeRing 
                    ? `ring-2 ${theme.activeRing} ${theme.activeBg}` 
                    : 'ring-zinc-200/60 hover:ring-zinc-300'
            }`}
            onClick={clickable ? onClick : undefined}
        >
            <div className={`${sizeClasses} flex items-center justify-between gap-3`}>
                <div className="min-w-0 flex-1">
                    <div className="flex items-center mb-1.5">
                        <p className="text-[9px] 14in:text-[10px] font-bold tracking-[0.1em] text-zinc-400 uppercase truncate leading-none">
                            {label}
                        </p>
                    </div>
                    <div className="flex items-baseline gap-1.5 overflow-hidden">
                        <p 
                            key={value}
                            className={`${numberSize} font-mono font-black tabular-nums tracking-tighter ${valueColor} group-hover:translate-x-0.5 transition-all duration-300 animate-in fade-in zoom-in-95 duration-500`}
                        >
                            {value}
                        </p>
                        {accent && (
                            <span className="text-[8px] 14in:text-[9px] font-bold text-zinc-400 uppercase tracking-widest leading-none opacity-60 italic shrink-0">
                                {accent === 'red' ? 'ALERT' : 'WARNING'}
                            </span>
                        )}
                        {isActive && (
                            <span className="text-[8px] 14in:text-[9px] font-bold text-zinc-600 uppercase tracking-widest leading-none ml-auto">
                                ✓
                            </span>
                        )}
                    </div>
                    {hint && (
                        <p className="text-[8px] text-zinc-400 mt-1 leading-none opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                            {hint}
                        </p>
                    )}
                </div>
                
                <div className={`flex-shrink-0 ${iconSize} rounded-xl flex items-center justify-center bg-white border border-zinc-200 shadow-sm shadow-[inset_0_2px_4px_rgba(255,255,255,0.8)] transition-all duration-300 group-hover:border-zinc-300 ${
                    clickable ? 'group-hover:-translate-y-0.5' : ''
                }`}>
                    <Icon className={`${iconInnerSize} ${theme.text} stroke-[2px] transition-transform duration-300 group-hover:scale-110`} />
                </div>
            </div>
            
            {/* Minimal Grid - Faint Operational Texture */}
            <div className="absolute inset-x-0 bottom-0 h-8 opacity-[0.015] pointer-events-none" 
                 style={{ backgroundImage: 'radial-gradient(circle, #000 1px, transparent 1px)', backgroundSize: '10px 10px' }} />
        </div>
    )
}
