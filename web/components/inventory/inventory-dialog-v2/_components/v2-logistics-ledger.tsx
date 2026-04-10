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

const MODES = [
    { id: 'qtyGood', label: 'Ready', icon: CheckCircle2, color: 'text-emerald-600', bg: 'bg-emerald-50', border: 'border-emerald-100' },
    { id: 'qtyDamaged', label: 'Damaged', icon: AlertCircle, color: 'text-rose-600', bg: 'bg-rose-50', border: 'border-rose-100' },
    { id: 'qtyMaintenance', label: 'Repair', icon: Wrench, color: 'text-amber-600', bg: 'bg-amber-50', border: 'border-amber-100' },
    { id: 'qtyLost', label: 'Lost', icon: HelpCircle, color: 'text-slate-600', bg: 'bg-slate-100', border: 'border-slate-200' },
]

export function V2LogisticsLedger({
    distributions, onUpdateQty, onRemove, onAdd, savedLocations
}: LogisticsLedgerProps) {
    const [activeMode, setActiveMode] = useState('qtyGood')
    const currentMode = MODES.find(m => m.id === activeMode) || MODES[0]

    return (
        <div className="space-y-4">
            <div className="flex flex-col gap-3 px-1">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <MapPin className="h-3.5 w-3.5 text-slate-500" strokeWidth={2.5} />
                        <p className="text-[10px] font-black text-slate-600 uppercase tracking-widest">Where is this item?</p>
                    </div>
                </div>

                {/* Status Selection Tabs */}
                <div className="flex gap-1 bg-slate-100 p-1 rounded-2xl border border-slate-200 shadow-inner">
                    {MODES.map((mode) => {
                        const Icon = mode.icon
                        const isActive = activeMode === mode.id
                        return (
                            <button
                                key={mode.id}
                                onClick={() => setActiveMode(mode.id)}
                                className={cn(
                                    "flex-1 flex items-center justify-center gap-1.5 py-1.5 rounded-xl transition-all",
                                    isActive ? cn("bg-white shadow-sm ring-1 ring-slate-200", mode.color) : "text-slate-500 hover:bg-white/50"
                                )}
                            >
                                <Icon className="h-3 w-3" />
                                <span className={cn("text-[10px] font-black uppercase tracking-tight", isActive ? "opacity-100" : "opacity-60")}>
                                    {mode.label}
                                </span>
                            </button>
                        )
                    })}
                </div>

                {/* Deployment Notice */}
                <div className={cn("flex items-center gap-2 p-2 rounded-xl border transition-colors", currentMode.bg, currentMode.border)}>
                    <ArrowRightLeft className={cn("h-3 w-3", currentMode.color)} />
                    <p className={cn("text-[9px] font-bold uppercase tracking-tight", currentMode.color)}>
                        Editing <span className="underline underline-offset-2">{currentMode.label}</span> stock across sites
                    </p>
                </div>
            </div>

            <div className="space-y-2 max-h-[220px] overflow-y-auto pr-2 scrollbar-thin scrollbar-thumb-slate-200">
                {distributions.length === 0 && (
                    <div className="p-4 border-2 border-dashed border-slate-100 rounded-xl text-center">
                        <p className="text-[11px] font-bold text-slate-400 uppercase">Click a location below to add stock</p>
                    </div>
                )}
                {distributions.map((site, index) => (
                    <div 
                        key={index} 
                        className="flex items-center gap-3 p-3 bg-white border border-slate-100 rounded-xl shadow-sm hover:border-slate-200 transition-all group"
                    >
                        <Warehouse className="h-4 w-4 text-slate-400 group-hover:text-slate-600" />
                        <div className="flex-1">
                            <p className="text-[12px] font-bold text-slate-700 truncate uppercase tracking-tight">
                                {site.locationName.replace(/_/g, ' ')}
                            </p>
                        </div>
                        <div className="w-20">
                            <Input 
                                type="number" 
                                value={activeMode === 'qtyGood' ? site.qtyGood : 
                                       activeMode === 'qtyDamaged' ? site.qtyDamaged : 
                                       activeMode === 'qtyMaintenance' ? site.qtyMaintenance : 
                                       site.qtyLost} 
                                onChange={(e) => onUpdateQty(index, activeMode, e.target.value)}
                                className={cn(
                                    "h-8 rounded-lg border-slate-200 font-black text-[13px] text-center p-0 transition-colors",
                                    activeMode !== 'qtyGood' ? "bg-white ring-2" : "bg-slate-50",
                                    activeMode === 'qtyDamaged' ? "ring-rose-100 text-rose-600" :
                                    activeMode === 'qtyMaintenance' ? "ring-amber-100 text-amber-600" :
                                    activeMode === 'qtyLost' ? "ring-slate-100 text-slate-600" : "text-slate-900"
                                )}
                            />
                        </div>
                        <Button 
                            variant="ghost" size="icon" onClick={() => onRemove(index)}
                            className="h-8 w-8 text-slate-400 hover:text-rose-500 hover:bg-rose-50"
                        >
                            <Trash2 className="h-3.5 w-3.5" />
                        </Button>
                    </div>
                ))}
            </div>

            {/* Quick Add Buttons */}
            <div className="flex flex-wrap gap-2 pt-1 px-1">
                {savedLocations.slice(0, 3).map((loc) => (
                    <Button
                        key={loc.id} variant="outline" size="sm"
                        onClick={() => onAdd(loc)}
                        className="h-7 px-3 rounded-full border-slate-200 text-[10px] font-bold text-slate-600 hover:bg-slate-50 hover:border-slate-300 transition-all"
                    >
                        <Plus className="h-3 w-3 mr-1" />
                        Add {loc.location_name}
                    </Button>
                ))}
            </div>
        </div>
    )
}
