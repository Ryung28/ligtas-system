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
    const totals = siteDistributions.reduce(
        (acc, dist) => ({
            qtyGood: acc.qtyGood + (Number(dist.qtyGood) || 0),
            qtyDamaged: acc.qtyDamaged + (Number(dist.qtyDamaged) || 0),
            qtyMaintenance: acc.qtyMaintenance + (Number(dist.qtyMaintenance) || 0),
            qtyLost: acc.qtyLost + (Number(dist.qtyLost) || 0),
        }),
        { qtyGood: 0, qtyDamaged: 0, qtyMaintenance: 0, qtyLost: 0 }
    )

    return (
        <div className="space-y-4">
            {/* LEDGER HEADER */}
            {siteDistributions.length > 0 && (
                <div className="flex items-center px-2 gap-2">
                    <p className="flex-1 text-[10px] font-black text-slate-400 uppercase tracking-widest">Facility / Site</p>
                    <p className="w-20 text-[10px] font-black text-emerald-600 uppercase tracking-widest text-center">Ready</p>
                    <p className="w-20 text-[10px] font-black text-rose-500 uppercase tracking-widest text-center">Dmg</p>
                    <p className="w-20 text-[10px] font-black text-amber-600 uppercase tracking-widest text-center">Repr</p>
                    <p className="w-20 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Lost</p>
                    <div className="w-8" />
                </div>
            )}

            {/* SITE ROWS */}
            <div className="space-y-1.5">
                {siteDistributions.map((dist, idx) => (
                    <div
                        key={`${dist.locationName}-${idx}`}
                        className="flex items-center gap-2 p-2 min-h-14 rounded-xl border border-slate-100 bg-slate-50/30 group transition-all hover:bg-white hover:border-slate-200 hover:shadow-sm"
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
                                className="h-9 w-20 font-black text-sm bg-white border-emerald-100 text-emerald-700 rounded-lg text-center focus:ring-4 focus:ring-emerald-500/10 focus:border-emerald-500 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                            />
                        </div>
                        <div className="relative">
                            <Input
                                type="number"
                                value={dist.qtyDamaged}
                                onChange={(e) => onUpdateQty(idx, 'qtyDamaged', e.target.value)}
                                className="h-9 w-20 font-black text-sm bg-white border-rose-100 text-rose-600 rounded-lg text-center focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                            />
                        </div>
                        <div className="relative">
                            <Input
                                type="number"
                                value={dist.qtyMaintenance}
                                onChange={(e) => onUpdateQty(idx, 'qtyMaintenance', e.target.value)}
                                className="h-9 w-20 font-black text-sm bg-white border-amber-100 text-amber-700 rounded-lg text-center focus:ring-4 focus:ring-amber-500/10 focus:border-amber-400 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                            />
                        </div>
                        <div className="relative">
                            <Input
                                type="number"
                                value={dist.qtyLost}
                                onChange={(e) => onUpdateQty(idx, 'qtyLost', e.target.value)}
                                className="h-9 w-20 font-black text-sm bg-white border-slate-200 text-slate-600 rounded-lg text-center focus:ring-4 focus:ring-slate-500/10 focus:border-slate-400 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
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

            {siteDistributions.length > 0 && (
                <div className="flex items-center justify-end gap-2 text-[11px] font-black uppercase tracking-wide pr-12">
                    <span className="px-2 py-1 rounded-md bg-emerald-50 text-emerald-700">Ready {totals.qtyGood}</span>
                    <span className="px-2 py-1 rounded-md bg-rose-50 text-rose-600">Dmg {totals.qtyDamaged}</span>
                    <span className="px-2 py-1 rounded-md bg-amber-50 text-amber-700">Repr {totals.qtyMaintenance}</span>
                    <span className="px-2 py-1 rounded-md bg-slate-100 text-slate-600">Lost {totals.qtyLost}</span>
                </div>
            )}

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
                    <SelectContent
                        className="rounded-xl shadow-2xl border-slate-200 max-h-56 overflow-y-auto p-1"
                        position="popper"
                        sideOffset={6}
                    >
                        {savedLocations
                            .filter(loc => !siteDistributions.some(d => d.locationId === loc.id?.toString() || d.locationName === loc.location_name))
                            .map(loc => (
                                <SelectItem
                                    key={loc.id || loc.location_name}
                                    value={loc.id?.toString() || loc.location_name}
                                    className="font-semibold text-[12px] py-1.5 leading-tight"
                                >
                                    {loc.location_name.replace(/_/g, ' ')}
                                </SelectItem>
                            ))}
                    </SelectContent>
                </Select>
            </div>
        </div>
    )
}
