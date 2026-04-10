'use client'

import { Warehouse, Trash2, PlusCircle, ChevronDown, ChevronUp } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { useState } from 'react'

interface SiteDistribution {
    id?: number
    locationId?: string
    locationName: string
    qtyGood: number
    qtyDamaged: number
    qtyMaintenance: number
    qtyLost: number
}

interface StockDistributionGridProps {
    siteDistributions: SiteDistribution[]
    onUpdateQty: (index: number, bucket: string, value: number | string) => void
    onAddSite: (location: any) => void
    onRemoveSite: (index: number) => void
    savedLocations: any[]
}

export function StockDistributionGrid({
    siteDistributions,
    onUpdateQty,
    onAddSite,
    onRemoveSite,
    savedLocations
}: StockDistributionGridProps) {
    const [expandedRows, setExpandedRows] = useState<Record<number, boolean>>({})

    const toggleRow = (index: number) => {
        setExpandedRows(prev => ({ ...prev, [index]: !prev[index] }))
    }

    return (
        <div className="space-y-3">
            <div className="flex flex-col gap-2.5">
                {siteDistributions.map((dist, idx) => (
                    <div 
                        key={`${dist.locationName}-${idx}`}
                        className="group border border-gray-200 rounded-xl bg-white overflow-hidden transition-all duration-200 shadow-[0_2px_4px_-1px_rgba(0,0,0,0.03)] hover:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.08)] hover:border-gray-300"
                    >
                        {/* Header Row: Compact Location & Good Qty */}
                        <div className="flex items-center gap-3 p-3">
                            <div className="h-9 w-9 shrink-0 rounded-lg bg-gray-50 flex items-center justify-center border border-gray-200 transition-colors group-hover:bg-gray-100">
                                <Warehouse className="h-4 w-4 text-gray-500 transition-colors group-hover:text-gray-950" />
                            </div>
                            
                            <div className="flex-1 min-w-0">
                                <p className="text-[14px] font-bold text-gray-800 truncate uppercase tracking-tight">
                                    {(dist.locationName || 'Unknown Site').replace(/_/g, ' ')}
                                </p>
                            </div>

                            <div className="flex items-center gap-2.5">
                                <span className="text-[10px] font-black text-gray-400 uppercase tracking-[0.1em] whitespace-nowrap px-1">Good Condition</span>
                                <Input 
                                    type="number"
                                    value={dist.qtyGood}
                                    onChange={(e) => onUpdateQty(idx, 'qtyGood', e.target.value)}
                                    className="h-9 w-20 font-black text-[13px] bg-white border-gray-200 focus:ring-1 focus:ring-gray-950 focus:border-gray-950 rounded-lg text-center shadow-sm text-gray-950"
                                />
                            </div>

                            <div 
                                className="flex items-center gap-2 border-l border-gray-100 ml-1 pl-3 cursor-pointer group/action select-none"
                                onClick={() => toggleRow(idx)}
                            >
                                {!expandedRows[idx] && (
                                    <span className="text-[9px] font-black text-gray-400 uppercase tracking-widest group-hover/action:text-gray-950 transition-colors animate-in fade-in slide-in-from-right-1">
                                        Report Damage/Loss
                                    </span>
                                )}
                                <div
                                    className={cn(
                                        "h-8 w-8 transition-all rounded-lg flex items-center justify-center shrink-0",
                                        expandedRows[idx] ? "bg-gray-950 text-white" : "text-gray-400 hover:text-gray-950 hover:bg-gray-100"
                                    )}
                                >
                                    {expandedRows[idx] ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
                                </div>
                                
                                {expandedRows[idx] && (
                                    <Button
                                        type="button"
                                        variant="ghost"
                                        size="icon"
                                        onClick={(e) => { e.stopPropagation(); onRemoveSite(idx); }}
                                        className="h-8 w-8 text-gray-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-all"
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </Button>
                                )}
                            </div>
                        </div>

                        {/* Collapsible Section: Other Buckets (Damaged, Lost, etc.) */}
                        {expandedRows[idx] && (
                            <div className="grid grid-cols-3 gap-3 p-3 pt-0 border-t border-gray-100 bg-gray-50/50 animate-in slide-in-from-top-1 duration-200">
                                <div>
                                    <label className="text-[9px] font-black text-gray-500 uppercase tracking-widest block mb-1.5 whitespace-nowrap">Damaged</label>
                                    <Input 
                                        type="number"
                                        value={dist.qtyDamaged}
                                        onChange={(e) => onUpdateQty(idx, 'qtyDamaged', e.target.value)}
                                        className="h-8 font-black text-[12px] rounded-lg border-gray-200 text-center focus:ring-1 focus:ring-gray-950 text-gray-950"
                                    />
                                </div>
                                <div>
                                    <label className="text-[9px] font-black text-gray-500 uppercase tracking-widest block mb-1.5 whitespace-nowrap">Maintenance</label>
                                    <Input 
                                        type="number"
                                        value={dist.qtyMaintenance}
                                        onChange={(e) => onUpdateQty(idx, 'qtyMaintenance', e.target.value)}
                                        className="h-8 font-black text-[12px] rounded-lg border-gray-200 text-center focus:ring-1 focus:ring-gray-950 text-gray-950"
                                    />
                                </div>
                                <div>
                                    <label className="text-[9px] font-black text-gray-500 uppercase tracking-widest block mb-1.5 whitespace-nowrap">Lost</label>
                                    <Input 
                                        type="number"
                                        value={dist.qtyLost}
                                        onChange={(e) => onUpdateQty(idx, 'qtyLost', e.target.value)}
                                        className="h-8 font-black text-[12px] rounded-lg border-gray-200 text-center focus:ring-1 focus:ring-gray-950 text-gray-950"
                                    />
                                </div>
                            </div>
                        )}
                    </div>
                ))}
            </div>

            {/* Site Add Selector - Compact Inline style */}
            <div className="pt-1">
                <Select onValueChange={(val) => {
                    const loc = savedLocations.find(l => l.id?.toString() === val || l.location_name === val)
                    if (loc) onAddSite(loc)
                }}>
                    <SelectTrigger className="w-full h-10 border-2 border-dashed border-gray-200 bg-white text-gray-500 text-[13px] font-black rounded-xl hover:border-gray-950 hover:text-gray-950 transition-all group">
                        <div className="flex items-center gap-2">
                            <PlusCircle className="h-4 w-4" />
                            <span className="uppercase tracking-tighter">Assign to another facility</span>
                        </div>
                    </SelectTrigger>
                    <SelectContent className="rounded-2xl shadow-2xl border-gray-200 z-[100]">
                        {savedLocations
                            .filter(loc => !siteDistributions.some(d => d.locationId === loc.id?.toString() || d.locationName === loc.location_name))
                            .map(loc => (
                                <SelectItem key={loc.id || loc.location_name} value={loc.id?.toString() || loc.location_name} className="font-bold text-[13px] rounded-lg py-2.5 text-gray-950">
                                    {loc.location_name.replace(/_/g, ' ')}
                                </SelectItem>
                            ))}
                    </SelectContent>
                </Select>
            </div>
        </div>
    )
}
