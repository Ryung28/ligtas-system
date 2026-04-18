import { useState } from 'react'
import { MapPin, Plus, Trash2, Warehouse, CheckCircle2, AlertCircle, Wrench, HelpCircle, ArrowRightLeft } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'

interface SiteDistribution {
    id?: number
    locationId?: string | null
    locationName: string
    qtyGood: number | string
    qtyDamaged: number | string
    qtyMaintenance: number | string
    qtyLost: number | string
}

interface LogisticsLedgerProps {
    distributions: SiteDistribution[]
    onUpdateQty: (index: number, bucket: string, val: number | string) => void
    onRemove: (index: number) => void
    onAdd: (location: any) => void
    savedLocations: any[]
}

export function V2LogisticsLedger({
    distributions, onUpdateQty, onRemove, onAdd, savedLocations
}: LogisticsLedgerProps) {
    return (
        <div className="space-y-4">
            <div className="flex items-center justify-between px-1">
                <div className="flex items-center gap-2">
                    <div className="h-5 w-5 rounded-lg bg-slate-900 flex items-center justify-center">
                        <ArrowRightLeft className="h-3 w-3 text-white" />
                    </div>
                    <p className="text-[11px] font-black text-slate-900 uppercase tracking-widest">Stock across Locations</p>
                </div>
                <div className="flex items-center gap-4 text-[9px] font-black text-slate-400 uppercase tracking-widest mr-12">
                   <div className="flex items-center gap-1 w-12 justify-center"><CheckCircle2 className="h-3 w-3 text-emerald-500" /><span>Ready</span></div>
                   <div className="flex items-center gap-1 w-12 justify-center"><AlertCircle className="h-3 w-3 text-rose-500" /><span>Dmg</span></div>
                   <div className="flex items-center gap-1 w-12 justify-center"><Wrench className="h-3 w-3 text-amber-500" /><span>Repr</span></div>
                   <div className="flex items-center gap-1 w-12 justify-center"><HelpCircle className="h-3 w-3 text-slate-400" /><span>Lost</span></div>
                </div>
            </div>

            <div className="space-y-2 max-h-[280px] overflow-y-auto pr-2 scrollbar-thin scrollbar-thumb-slate-200">
                {distributions.length === 0 && (
                    <div className="p-8 border-2 border-dashed border-slate-100 rounded-[24px] text-center bg-slate-50/30">
                        <Warehouse className="h-8 w-8 text-slate-200 mx-auto mb-3" />
                        <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">No site records. Select a location below.</p>
                    </div>
                )}
                {distributions.map((site, index) => (
                    <div 
                        key={index} 
                        className="flex items-center gap-3 p-3 bg-white border border-slate-100 rounded-2xl shadow-sm hover:border-slate-300 transition-all group"
                    >
                        <Warehouse className="h-4 w-4 text-slate-400 group-hover:text-slate-900 transition-colors" />
                        <div className="flex-1 min-w-0">
                            <p className="text-[12px] font-bold text-slate-700 truncate uppercase tracking-tight">
                                {site.locationName?.replace(/_/g, ' ') || 'Unnamed Site'}
                            </p>
                        </div>
                        
                        <div className="flex items-center gap-2">
                            {/* GOOD */}
                            <div className="w-12">
                                <Input 
                                    type="number" 
                                    value={site.qtyGood} 
                                    onChange={(e) => onUpdateQty(index, 'qtyGood', e.target.value)}
                                    className="h-8 rounded-lg border-slate-100 bg-emerald-50/30 text-emerald-700 font-black text-[12px] text-center p-0 focus:ring-emerald-500/20 focus:border-emerald-300 transition-all"
                                />
                            </div>
                            {/* DAMAGED */}
                            <div className="w-12">
                                <Input 
                                    type="number" 
                                    value={site.qtyDamaged} 
                                    onChange={(e) => onUpdateQty(index, 'qtyDamaged', e.target.value)}
                                    className="h-8 rounded-lg border-slate-100 bg-rose-50/30 text-rose-700 font-black text-[12px] text-center p-0 focus:ring-rose-500/20 focus:border-rose-300 transition-all"
                                />
                            </div>
                            {/* MAINTENANCE */}
                            <div className="w-12">
                                <Input 
                                    type="number" 
                                    value={site.qtyMaintenance} 
                                    onChange={(e) => onUpdateQty(index, 'qtyMaintenance', e.target.value)}
                                    className="h-8 rounded-lg border-slate-100 bg-amber-50/30 text-amber-700 font-black text-[12px] text-center p-0 focus:ring-amber-500/20 focus:border-amber-300 transition-all"
                                />
                            </div>
                            {/* LOST */}
                            <div className="w-12">
                                <Input 
                                    type="number" 
                                    value={site.qtyLost} 
                                    onChange={(e) => onUpdateQty(index, 'qtyLost', e.target.value)}
                                    className="h-8 rounded-lg border-slate-100 bg-slate-50 text-slate-600 font-black text-[12px] text-center p-0 focus:ring-slate-500/20 focus:border-slate-300 transition-all"
                                />
                            </div>
                        </div>

                        <Button 
                            variant="ghost" size="icon" onClick={() => onRemove(index)}
                            className="h-8 w-8 text-slate-300 hover:text-rose-600 hover:bg-rose-50 rounded-lg shrink-0"
                            disabled={distributions.length === 1}
                        >
                            <Trash2 className="h-3.5 w-3.5" />
                        </Button>
                    </div>
                ))}
            </div>

            {/* Quick Add Buttons */}
            <div className="space-y-2">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Available Sites</p>
                <div className="flex flex-wrap gap-2 pt-1 px-1">
                    {savedLocations
                        .filter(loc => !distributions.some(dist => 
                            String(dist.locationId) === String(loc.id) || 
                            dist.locationName?.toLowerCase() === loc.location_name?.toLowerCase()
                        ))
                        .map((loc) => (
                            <Button
                                key={loc.id} variant="outline" size="sm"
                                onClick={() => onAdd(loc)}
                                className="h-8 px-4 rounded-xl border-slate-200 bg-white text-[10px] font-black text-slate-600 hover:bg-slate-50 hover:border-slate-400 hover:text-slate-900 transition-all shadow-sm flex items-center gap-2"
                            >
                                <Plus className="h-3 w-3" />
                                {loc.location_name}
                            </Button>
                        ))}
                </div>
            </div>
        </div>
    )
}
