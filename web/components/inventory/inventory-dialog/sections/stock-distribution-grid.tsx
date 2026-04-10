'use client'

import { Warehouse, Trash2, PlusCircle } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'

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
    return (
        <div className="space-y-4">
            {/* LEDGER HEADER */}
            {siteDistributions.length > 0 && (
                <div className="flex items-center px-2">
                    <p className="flex-1 text-[10px] font-black text-slate-400 uppercase tracking-widest">Facility / Site</p>
                    <p className="w-24 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center pr-10">On Hand</p>
                </div>
            )}

            {/* SITE ROWS */}
            <div className="space-y-1.5">
                {siteDistributions.map((dist, idx) => (
                    <div 
                        key={`${dist.locationName}-${idx}`}
                        className="flex items-center gap-3 p-2 h-14 rounded-xl border border-slate-100 bg-slate-50/30 group transition-all hover:bg-white hover:border-slate-200 hover:shadow-sm"
                    >
                        {/* Icon & Site Name */}
                        <div className="h-9 w-9 shrink-0 rounded-lg bg-white border border-slate-100 flex items-center justify-center text-slate-400 group-hover:text-blue-500 group-hover:border-blue-100 transition-colors">
                            <Warehouse className="h-4 w-4" />
                        </div>
                        
                        <div className="flex-1 min-w-0">
                            <p className="text-[13px] font-bold text-slate-700 truncate capitalize">
                                {(dist.locationName || 'Unknown Site').replace(/_/g, ' ')}
                            </p>
                            <p className="text-[10px] font-medium text-slate-400 leading-none">Primary Storage</p>
                        </div>

                        {/* Quantity Input */}
                        <div className="relative">
                            <Input 
                                type="number"
                                value={dist.qtyGood}
                                onChange={(e) => onUpdateQty(idx, 'qtyGood', e.target.value)}
                                className="h-9 w-24 font-black text-sm bg-white border-slate-200 rounded-lg text-center focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500"
                            />
                        </div>

                        {/* Actions */}
                        <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            onClick={() => onRemoveSite(idx)}
                            className="h-8 w-8 text-slate-300 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-all"
                        >
                            <Trash2 className="h-4 w-4" />
                        </Button>
                    </div>
                ))}
            </div>

            {/* FOOTER: ADD SITE */}
            <div className="pt-2">
                <Select onValueChange={(val) => {
                    const loc = savedLocations.find(l => l.id?.toString() === val || l.location_name === val)
                    if (loc) onAddSite(loc)
                }}>
                    <SelectTrigger className="w-full h-11 border-2 border-dashed border-slate-200 bg-white text-slate-400 text-[12px] font-bold rounded-xl hover:border-blue-400 hover:text-blue-600 hover:bg-blue-50/30 transition-all flex items-center justify-center gap-2">
                        <PlusCircle className="h-4 w-4" />
                        <span className="uppercase tracking-widest">Assign to another site</span>
                    </SelectTrigger>
                    <SelectContent className="rounded-xl shadow-2xl border-slate-200">
                        {savedLocations
                            .filter(loc => !siteDistributions.some(d => d.locationId === loc.id?.toString() || d.locationName === loc.location_name))
                            .map(loc => (
                                <SelectItem key={loc.id || loc.location_name} value={loc.id?.toString() || loc.location_name} className="font-bold text-[13px] py-3">
                                    {loc.location_name.replace(/_/g, ' ')}
                                </SelectItem>
                            ))}
                    </SelectContent>
                </Select>
            </div>
        </div>
    )
}
