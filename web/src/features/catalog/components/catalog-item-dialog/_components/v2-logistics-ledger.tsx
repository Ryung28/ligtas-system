import { useState } from 'react'
import { MapPin, Plus, Trash2, Warehouse, CheckCircle2, AlertCircle, Wrench, HelpCircle, ArrowRightLeft, Home } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from "@/components/ui/alert-dialog"

import { CatalogDistribution, StorageLocation } from '../types'

interface LogisticsLedgerProps {
    distributions: CatalogDistribution[]
    onUpdateQty: (index: number, bucket: string, val: number | string) => void
    onRemove: (index: number) => void
    onAdd: (location: StorageLocation) => void
    onSetHome: (index: number) => void
    savedLocations: StorageLocation[]
}

export function V2LogisticsLedger({
    distributions, onUpdateQty, onRemove, onAdd, onSetHome, savedLocations
}: LogisticsLedgerProps) {
    const [pendingPromoteIndex, setPendingPromoteIndex] = useState<number | null>(null)

    const pendingSite = pendingPromoteIndex !== null ? distributions[pendingPromoteIndex] : null

    return (
        <div className="space-y-4">
            {/* ⚪ White Tactical Premium Modal */}
            <AlertDialog open={pendingPromoteIndex !== null} onOpenChange={(open) => !open && setPendingPromoteIndex(null)}>
                <AlertDialogContent className="bg-white border-none rounded-[48px] max-w-[360px] animate-in zoom-in-95 shadow-2xl">
                    <AlertDialogHeader className="items-center text-center">
                        <div className="h-20 w-20 bg-blue-50 rounded-[28px] flex items-center justify-center mb-4 shadow-sm">
                            <ArrowRightLeft className="h-8 w-8 text-blue-600" />
                        </div>
                        <AlertDialogTitle className="text-slate-950 text-2xl font-black tracking-tight">
                            Change Main Location?
                        </AlertDialogTitle>
                        <AlertDialogDescription className="text-slate-500 text-[13px] font-semibold leading-relaxed px-4">
                            Do you want to set <span className="text-blue-600 font-black">{pendingSite?.locationName?.replace(/_/g, ' ')}</span> as the main storage for this item?
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter className="flex-col sm:flex-col gap-3 mt-6">
                        <AlertDialogAction 
                            onClick={() => {
                                if (pendingPromoteIndex !== null) onSetHome(pendingPromoteIndex)
                                setPendingPromoteIndex(null)
                            }}
                            className="bg-blue-600 hover:bg-blue-700 text-white rounded-3xl h-14 font-black text-sm shadow-lg shadow-blue-200 transition-all active:scale-95 border-none"
                        >
                            Yes, change it
                        </AlertDialogAction>
                        <AlertDialogCancel className="bg-transparent text-slate-400 hover:text-slate-600 font-bold text-[13px] transition-all border-none">
                            Not now
                        </AlertDialogCancel>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
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
                        <p className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">No site records. Please select a location below.</p>
                    </div>
                )}
                {distributions.map((site, index) => (
                    <div 
                        key={index} 
                        className={cn(
                            "flex items-center gap-3 p-3 bg-white border rounded-2xl shadow-sm transition-all group",
                            site.locationId ? "border-slate-100 hover:border-slate-300" : "border-rose-200 bg-rose-50/20 animate-pulse"
                        )}
                    >
                        {/* 🏠 Primary / 🔄 Promote Button */}
                        <div className="shrink-0">
                            {site._isMaster ? (
                                <div 
                                    className="h-8 w-8 rounded-xl bg-blue-50 flex items-center justify-center border border-blue-100 cursor-default"
                                    title="Primary Home Location"
                                >
                                    <Home className="h-4 w-4 text-blue-600" fill="currentColor" />
                                </div>
                            ) : (
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    className="h-8 w-8 rounded-xl text-slate-300 hover:text-blue-600 hover:bg-blue-50 transition-all"
                                    title="Set as Main Location"
                                    onClick={() => setPendingPromoteIndex(index)}
                                >
                                    <ArrowRightLeft className="h-4 w-4" />
                                </Button>
                            )}
                        </div>

                        <div className="flex-1 min-w-0">
                            <p className={cn(
                                "text-[12px] font-bold truncate uppercase tracking-tight transition-colors",
                                !site.locationId 
                                    ? "text-rose-600 animate-pulse" 
                                    : (site._isMaster ? "text-slate-900" : "text-slate-500")
                            )}>
                                {site.locationId 
                                    ? (site.locationName?.replace(/_/g, ' ') || 'Unnamed Site')
                                    : 'SELECT LOCATION'}
                            </p>
                            {site._isMaster && (
                                <p className="text-[9px] font-black text-blue-600 uppercase tracking-widest mt-0.5">Main Location</p>
                            )}
                        </div>
                        
                        <div className="flex items-center gap-2">
                            {/* GOOD */}
                            <div className="w-12">
                                <Input 
                                    type="number" 
                                    value={site.qtyGood} 
                                    onChange={(e) => onUpdateQty(index, 'qtyGood', e.target.value)}
                                    readOnly={!!(site as any)._bulkManaged}
                                    className={cn(
                                        "h-8 rounded-lg border-slate-100 bg-emerald-50/30 text-emerald-700 font-black text-[12px] text-center p-0 focus:ring-emerald-500/20 focus:border-emerald-300 transition-all",
                                        (site as any)._bulkManaged && "opacity-60 cursor-not-allowed bg-slate-100 border-transparent"
                                    )}
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

                        {(() => {
                            const hasStock = (Number(site.qtyGood) || 0) + (Number(site.qtyDamaged) || 0) + (Number(site.qtyMaintenance) || 0) + (Number(site.qtyLost) || 0) > 0;
                            return (
                                <Button 
                                    variant="ghost" size="icon" onClick={() => onRemove(index)}
                                    className={cn(
                                        "h-8 w-8 text-slate-300 hover:text-rose-600 hover:bg-rose-50 rounded-lg shrink-0",
                                        (site._isMaster || hasStock) && "opacity-20 cursor-not-allowed hover:bg-transparent hover:text-slate-300"
                                    )}
                                    disabled={distributions.length === 1 || site._isMaster || hasStock}
                                    title={hasStock ? "Transfer stock before removing site" : "Remove Location"}
                                >
                                    <Trash2 className="h-3.5 w-3.5" />
                                </Button>
                            );
                        })()}
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
