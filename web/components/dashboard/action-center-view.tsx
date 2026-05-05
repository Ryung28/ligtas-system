'use client'

import { useState, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import useSWR from 'swr'
import { getInventoryAlerts } from '@/src/features/catalog'
import { Package, ArrowUpRight, ShieldCheck } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'

/**
 * 🎯 GLOBAL ACTION CENTER VIEW - HYBRID EDITION
 * Compact controls (Stats/Filters) combined with breathable, 
 * high-fidelity list items for the inventory alerts.
 */
export function ActionCenterView() {
    const router = useRouter()
    const [filter, setFilter] = useState<'ALL' | 'OOS' | 'LOW' | 'EXPIRE'>('ALL')
    
    const { data: response, isLoading } = useSWR('action_center_global_v5_hybrid', async () => {
        const res = await getInventoryAlerts()
        return res.success ? res : null
    }, { refreshInterval: 60000 })

    const summary = response?.data
    const rawItems = response?.items || []

    const allActions = useMemo(() => {
        const inventoryActions = rawItems.map((item: any) => ({
            id: `inv-${item.id}`,
            referenceId: item.id,
            type: 'INVENTORY',
            title: item.item_name,
            subtitle: item.item_name,
            timestamp: 'less than a minute',
            category: item.is_out_of_stock ? 'OOS' : item.is_expiring_soon ? 'EXPIRE' : 'LOW',
            statusLabel: item.is_out_of_stock ? 'OUT OF STOCK' : item.is_expiring_soon ? 'EXPIRING' : 'LOW STOCK',
            icon: Package,
            color: 'amber'
        }))

        const accessActions = [
            {
                id: 'acc-1',
                type: 'ACCESS',
                title: 'BRANDON',
                subtitle: 'Brandon',
                description: 'Needs approval: open Mobile App Users, then Pending Requests.',
                timestamp: '1 minute ago',
                category: 'ISSUE',
                statusLabel: 'PENDING APPROVAL',
                icon: ShieldCheck,
                color: 'purple'
            }
        ]

        return [...inventoryActions, ...accessActions]
    }, [rawItems])

    const filteredActions = useMemo(() => {
        if (filter === 'ALL') return allActions
        if (filter === 'OOS') return allActions.filter(a => a.category === 'OOS')
        if (filter === 'LOW') return allActions.filter(a => a.category === 'LOW')
        if (filter === 'EXPIRE') return allActions.filter(a => a.category === 'EXPIRE')
        return allActions
    }, [allActions, filter])

    const handleActionClick = (action: any) => {
        if (action.type === 'INVENTORY') {
            router.push(`/dashboard/inventory?id=${action.referenceId}&highlight=true`)
        } else if (action.type === 'ACCESS') {
            router.push('/dashboard/users')
        }
    }

    if (isLoading) {
        return (
            <div className="p-3 space-y-2">
                <div className="grid grid-cols-4 gap-2">
                    {[1, 2, 3, 4].map(i => <div key={i} className="h-10 bg-slate-50 animate-pulse rounded-lg" />)}
                </div>
            </div>
        )
    }

    return (
        <div className="flex flex-col h-full animate-in fade-in duration-300">
            {/* 📋 COMPACT STATS ROW (Kept Small) */}
            <div className="grid grid-cols-4 gap-1.5 px-6 py-2 shrink-0">
                <StatBox value={summary?.out_of_stock || 0} label="OOS" color="rose" />
                <StatBox value={summary?.low_stock || 0} label="LOW" color="amber" />
                <StatBox value={summary?.expiring_soon || 0} label="EXPIRE" color="amber" />
                <StatBox value={allActions.filter(a => a.type === 'ACCESS').length} label="ISSUE" color="slate" />
            </div>

            {/* 🛡️ MINIMAL SUB-HEADER (Kept Small) */}
            <div className="px-6 py-1 flex items-center justify-between border-t border-slate-50 shrink-0">
                <span className="text-[8px] font-black text-slate-500 uppercase tracking-[0.2em]">Inventory Alerts</span>
                <div className="flex items-center gap-1">
                    <div className="h-1 w-1 rounded-full bg-rose-500" />
                    <span className="text-[8px] font-black text-rose-500 uppercase tracking-widest">{allActions.length} Critical</span>
                </div>
            </div>

            {/* 🔍 COMPACT FILTERS (Kept Small) */}
            <div className="px-6 py-1.5 flex gap-1.5 overflow-x-auto no-scrollbar shrink-0 border-b border-slate-50">
                <FilterChip active={filter === 'ALL'} label="ALL" onClick={() => setFilter('ALL')} />
                <FilterChip active={filter === 'OOS'} label="OUT OF STOCK" onClick={() => setFilter('OOS')} />
                <FilterChip active={filter === 'LOW'} label="LOW STOCK" onClick={() => setFilter('LOW')} />
                <FilterChip active={filter === 'EXPIRE'} label="EXPIRING" onClick={() => setFilter('EXPIRE')} />
            </div>

            {/* 📜 BREATHABLE FEED (Expanded Cards as requested) */}
            <div className="flex-1 overflow-y-auto custom-scrollbar px-6 mt-1">
                <div className="divide-y divide-slate-50 pb-4">
                    {filteredActions.map((action: any) => (
                        <div 
                            key={action.id} 
                            onClick={() => handleActionClick(action)}
                            className="py-5 flex gap-4 group items-start border-b border-slate-50 last:border-0 cursor-pointer hover:bg-slate-50/40 -mx-6 px-6 transition-colors"
                        >
                            <div className={cn(
                                "h-11 w-11 rounded-xl flex items-center justify-center shrink-0 border transition-transform group-hover:scale-105 shadow-sm",
                                action.color === 'amber' ? "bg-amber-50 border-amber-100 text-amber-500" : "bg-purple-50 border-purple-100 text-purple-500"
                            )}>
                                <action.icon className="h-5.5 w-5.5" />
                            </div>
                            
                            <div className="flex-1 min-w-0 pt-0.5">
                                <div className="flex items-center gap-1.5 mb-1.5">
                                    <span className={cn(
                                        "text-[9px] font-black uppercase tracking-widest",
                                        action.type === 'INVENTORY' ? "text-orange-500" : "text-purple-500"
                                    )}>
                                        {action.type}
                                    </span>
                                    <span className="text-[9px] font-bold text-slate-300 uppercase tracking-widest">• {action.timestamp}</span>
                                </div>
                                
                                <h4 className="text-[14px] font-black text-slate-900 uppercase tracking-tight leading-none mb-1.5">
                                    {action.title}
                                </h4>
                                
                                {action.description && (
                                    <p className="text-[12px] font-medium text-slate-400 mb-4 leading-tight truncate">
                                        {action.description}
                                    </p>
                                )}
                                    <Badge variant="outline" className="h-6 px-2.5 text-[9px] font-black bg-white text-slate-500 border-slate-200 uppercase tracking-widest rounded-md pointer-events-none">
                                        ITEM: {action.title}
                                    </Badge>
                                    
                                    <div className={cn(
                                        "text-[10px] font-black uppercase tracking-[0.15em] pt-1",
                                        action.type === 'ACCESS' ? "text-purple-400" : "text-slate-400"
                                    )}>
                                        {action.statusLabel}
                                    </div>
                                </div>
                            
                            <div className="pt-1">
                                <div className="h-9 w-9 rounded-xl border border-slate-200 bg-white flex items-center justify-center text-slate-400 shadow-sm transition-all group-hover:text-slate-900 group-hover:border-slate-900 group-hover:bg-slate-50">
                                    <ArrowUpRight className="h-4.5 w-4.5" />
                                </div>
                            </div>
                        </div>
                    ))}
                    <div className="h-8 shrink-0" />
                </div>
            </div>
        </div>
    )
}

function StatBox({ value, label, color }: { value: number, label: string, color: 'rose' | 'amber' | 'slate' }) {
    const colors = {
        rose: 'text-rose-500',
        amber: 'text-amber-500',
        slate: 'text-slate-400'
    }
    return (
        <div className="bg-white border border-slate-100 shadow-sm rounded-lg p-1.5 flex flex-col items-center justify-center transition-shadow hover:shadow-md">
            <span className={cn("text-sm font-black font-heading leading-none mb-0", colors[color])}>
                {value}
            </span>
            <span className="text-[7.5px] font-black text-slate-400 uppercase tracking-widest">
                {label}
            </span>
        </div>
    )
}

function FilterChip({ active, label, onClick }: { active: boolean, label: string, onClick: () => void }) {
    return (
        <button 
            onClick={onClick}
            className={cn(
                "h-6 px-2.5 rounded-md text-[8.5px] font-black uppercase tracking-widest transition-all border shrink-0",
                active 
                    ? "bg-[#1E1B4B] border-[#1E1B4B] text-white shadow-sm" 
                    : "bg-white border-slate-200 text-slate-500 hover:border-slate-300"
            )}
        >
            {label}
        </button>
    )
}
