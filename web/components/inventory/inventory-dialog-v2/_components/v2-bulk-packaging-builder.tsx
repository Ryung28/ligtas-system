"use client"

import { Box, Package, ChevronRight, ChevronDown, Info, Calculator, Boxes, Plus, Trash2 } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { cn } from '@/lib/utils'
import { useState, memo } from 'react'

interface BulkPackagingBuilderProps {
    packaging: {
        enabled: boolean;
        containerType: string;
        containerCount: number | string;
        unitsPerContainer: number | string;
        defaultLocationId: string | null;
        batches: Array<{ id: string, label: string, units: number, locationId?: string | null, expiry_date?: string | null }>;
        expiry_mode?: 'none' | 'single' | 'grouped' | 'per_carton';
        expiry_groups?: Array<{ id: string; label: string; expiry_date: string; batch_ids: string[] }>;
    }
    locations: Array<{ id: string | number; location_name: string }>
    onUpdate: (updates: any) => void
    onUpdateBatch: (index: number, val: number) => void
    onUpdateLabel: (index: number, label: string) => void
    onUpdateBatchLocation: (index: number, locationId: string | null, locationName: string) => void
    onAddExtra: () => void
    onRemoveBatch: (batchId: string) => void
    onAddExpiryGroup: () => void
    onUpdateExpiryGroup: (groupId: string, updates: Partial<{ label: string; expiry_date: string; batch_ids: string[] }>) => void
    onRemoveExpiryGroup: (groupId: string) => void
    onAssignBatchToGroup: (groupId: string, batchId: string, assigned: boolean) => void
    onSplitExpiryPerCarton: () => void
    onUpdateMultipleLocations: (indices: number[], locationId: string | null, locationName: string) => void
}

const CONTAINER_TYPES = ['Carton', 'Box', 'Case', 'Bag', 'Pallet', 'Pack', 'Custom']

const CartonCard = memo(({ 
    batch, 
    idx, 
    packaging, 
    locations, 
    onUpdateLabel, 
    onUpdateBatch, 
    onUpdateBatchLocation, 
    onRemoveBatch 
}: { 
    batch: any, 
    idx: number, 
    packaging: any, 
    locations: any[], 
    onUpdateLabel: (idx: number, val: string) => void, 
    onUpdateBatch: (idx: number, val: number) => void, 
    onUpdateBatchLocation: (idx: number, locId: string | null, locName: string) => void, 
    onRemoveBatch: (id: string) => void 
}) => {
    return (
        <div className="bg-white border border-slate-100 rounded-xl p-3 shadow-sm hover:border-zinc-300 transition-all group relative">
            {/* GHOST LABEL (ID / NAME) */}
            <div className="mb-2">
                <input 
                    value={batch.label} 
                    onChange={(e) => onUpdateLabel(idx, e.target.value)}
                    placeholder="Unit Name..."
                    className="w-full text-[10px] font-extrabold text-slate-400 uppercase tracking-tighter bg-transparent border border-transparent hover:border-slate-100 hover:bg-slate-50 focus:bg-white focus:border-zinc-200 focus:text-zinc-900 rounded-md px-1.5 py-0.5 transition-all outline-none cursor-text placeholder:text-slate-300"
                />
            </div>
            
            {/* UNIT QUANTITY */}
            <div className="relative">
                <Input 
                    type="number"
                    value={batch.units}
                    onChange={(e) => onUpdateBatch(idx, Number(e.target.value))}
                    className={cn(
                        "h-10 text-center text-[15px] font-black rounded-lg border-2 transition-all tabular-nums [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none",
                        batch.units === Number(packaging.unitsPerContainer) 
                            ? "border-slate-100 bg-white text-zinc-900" 
                            : "border-orange-200 bg-orange-50/50 text-orange-700"
                    )}
                />
            </div>

            {/* LOCATION BADGE */}
            <div className="mt-2">
                <Select
                    value={batch.locationId?.toString() ?? packaging.defaultLocationId?.toString() ?? '__none__'}
                    onValueChange={(val) => {
                        const locId = val === '__none__' ? null : val
                        const locName = locations.find(l => String(l.id) === val)?.location_name ?? 'Unknown'
                        onUpdateBatchLocation(idx, locId, locName)
                    }}
                >
                    <SelectTrigger className={cn(
                        "h-6 rounded-md text-[9px] font-black uppercase tracking-wider border px-2 w-full",
                        batch.locationId && batch.locationId !== packaging.defaultLocationId
                            ? "border-blue-200 bg-blue-50 text-blue-700"
                            : "border-slate-100 bg-slate-50 text-slate-500"
                    )}>
                        <SelectValue placeholder="Location" />
                    </SelectTrigger>
                    <SelectContent className="rounded-xl border-slate-200">
                        <SelectItem value="__none__" className="text-[11px] font-bold py-2 text-slate-400">— Default</SelectItem>
                        {locations.map(loc => (
                            <SelectItem key={loc.id} value={String(loc.id)} className="text-[11px] font-bold py-2">{loc.location_name}</SelectItem>
                        ))}
                    </SelectContent>
                </Select>
            </div>

            <button
                type="button"
                onClick={() => onRemoveBatch(batch.id)}
                className="mt-2 w-full h-7 rounded-md border border-slate-200 text-[9px] font-black uppercase tracking-wider text-slate-500 hover:text-rose-600 hover:border-rose-200 transition-colors flex items-center justify-center gap-1"
            >
                <Trash2 className="h-3 w-3" />
                Remove
            </button>
        </div>
    );
});
CartonCard.displayName = 'CartonCard';

export function V2BulkPackagingBuilder({ 
    packaging, locations, onUpdate, onUpdateBatch, onUpdateLabel, onUpdateBatchLocation, onUpdateMultipleLocations, onAddExtra,
    onRemoveBatch, onAddExpiryGroup, onUpdateExpiryGroup, onRemoveExpiryGroup, onAssignBatchToGroup, onSplitExpiryPerCarton,
}: BulkPackagingBuilderProps) {
    const [isExpanded, setIsExpanded] = useState(true)
    const totalUnitsTotal = packaging.batches.reduce((s, b) => s + b.units, 0)
    const expiryMode = packaging.expiry_mode || 'none'
    const expiryGroups = packaging.expiry_groups || []
    const assignedBatchIds = new Set(expiryGroups.flatMap((g) => g.batch_ids || []))
    
    const isCustom = !['Carton', 'Box', 'Case', 'Bag', 'Pallet', 'Pack'].includes(packaging.containerType)
    
    if (!packaging.enabled) {
        return (
            <div className="flex items-center justify-end mb-2">
                <button 
                    type="button"
                    onClick={() => onUpdate({ enabled: true })}
                    className="flex items-center gap-1.5 text-[9px] font-black text-slate-400 hover:text-blue-600 border border-slate-100 px-3 py-1.5 rounded-full bg-slate-50/50 hover:bg-blue-50 transition-all shadow-sm uppercase tracking-widest"
                >
                    <Package className="h-3 w-3" />
                    Bulk Options
                </button>
            </div>
        )
    }

    return (
        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-xl transition-all duration-300 mb-4 animate-in fade-in slide-in-from-top-4">
            {/* 🛡️ TACTICAL HEADER */}
            <div 
                className="bg-zinc-900 px-5 py-4 flex items-center justify-between cursor-pointer group"
                onClick={() => setIsExpanded(!isExpanded)}
            >
                <div className="flex items-center gap-4">
                    <div className="h-10 w-10 bg-zinc-800 rounded-xl flex items-center justify-center border border-zinc-700 shadow-inner group-hover:scale-105 transition-transform">
                        <Boxes className="h-5 w-5 text-white" />
                    </div>
                    <div>
                        <h4 className="text-[14px] font-black text-white leading-tight uppercase tracking-tight">
                             Cargo Fleet: {packaging.batches.length || '0'} Containers
                        </h4>
                        <p className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest">
                            Volume: <span className="text-white font-black tabular-nums">{totalUnitsTotal} Units Total</span>
                        </p>
                    </div>
                </div>
                <div className="flex items-center gap-3">
                    <div className="h-8 w-8 rounded-xl bg-zinc-800 flex items-center justify-center text-white transition-colors group-hover:bg-zinc-700">
                        {isExpanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
                    </div>
                </div>
            </div>

            {isExpanded && (
                <div className="p-5 space-y-6 animate-in slide-in-from-top-2 bg-white">
                    {/* Distribution Logic */}
                    <div className="space-y-4">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                                <div className="h-1.5 w-1.5 rounded-full bg-zinc-900" />
                                <p className="text-[11px] font-black text-zinc-900 uppercase tracking-tight">1. Distribution Logic</p>
                            </div>
                        </div>

                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 bg-slate-50 p-4 rounded-xl border border-slate-100">
                            <div className="space-y-1.5">
                                <Label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Container Type</Label>
                                <Select
                                    value={packaging.containerType}
                                    onValueChange={(val) => onUpdate({ containerType: val })}
                                >
                                    <SelectTrigger className="h-11 rounded-lg border-slate-200 bg-white font-bold text-zinc-900 shadow-sm">
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent className="rounded-xl border-slate-200">
                                        {CONTAINER_TYPES.map(type => (
                                            <SelectItem key={type} value={type} className="font-bold py-2.5 text-[13px]">{type}</SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>

                            <div className="space-y-1.5">
                                <Label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Quantity</Label>
                                <Input 
                                    type="number"
                                    value={packaging.containerCount}
                                    onChange={(e) => onUpdate({ containerCount: e.target.value })}
                                    className="h-11 rounded-lg border-slate-200 bg-white font-black text-zinc-900 text-lg shadow-sm"
                                />
                            </div>

                            <div className="space-y-1.5">
                                <Label className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Units Per {packaging.containerType}</Label>
                                <Input 
                                    type="number"
                                    value={packaging.unitsPerContainer}
                                    onChange={(e) => onUpdate({ unitsPerContainer: e.target.value })}
                                    className="h-11 rounded-lg border-slate-200 bg-white font-black text-zinc-900 text-lg shadow-sm"
                                />
                            </div>
                        </div>
                    </div>

                    {/* Ledger Generation */}
                    <div className="space-y-4 pt-2 border-t border-slate-100">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                                <div className="h-1.5 w-1.5 rounded-full bg-zinc-900" />
                                <p className="text-[11px] font-black text-zinc-900 uppercase tracking-tight">2. Container Ledger</p>
                            </div>
                            <button
                                type="button"
                                onClick={onAddExtra}
                                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[10px] font-black bg-zinc-900 text-white hover:bg-zinc-800 transition-all shadow-md uppercase tracking-wider active:scale-95"
                            >
                                <Plus className="h-3 w-3" />
                                Custom Item
                            </button>
                        </div>

                        <div className="bg-slate-50 p-5 rounded-2xl border-2 border-dashed border-slate-200 min-h-[140px]">
                            {packaging.batches.length > 0 ? (
                                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                                    {packaging.batches.map((batch, idx) => (
                                        <CartonCard 
                                            key={batch.id}
                                            batch={batch}
                                            idx={idx}
                                            packaging={packaging}
                                            locations={locations}
                                            onUpdateLabel={onUpdateLabel}
                                            onUpdateBatch={onUpdateBatch}
                                            onUpdateBatchLocation={onUpdateBatchLocation}
                                            onRemoveBatch={onRemoveBatch}
                                        />
                                    ))}
                                </div>
                            ) : (
                                <div className="py-10 text-center">
                                    <p className="text-[10px] font-bold text-slate-400 uppercase italic tracking-widest leading-relaxed">
                                        Configure Step 1 to generate ledger
                                    </p>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Expiry Assignment */}
                    <div className="space-y-4 pt-2 border-t border-slate-100">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                                <div className="h-1.5 w-1.5 rounded-full bg-zinc-900" />
                                <p className="text-[11px] font-black text-zinc-900 uppercase tracking-tight">3. Expiry Assignment</p>
                            </div>
                            <div className="flex items-center gap-1">
                                <button type="button" onClick={() => onUpdate({ expiry_mode: 'none' })} className={cn("px-2 py-1 rounded-md text-[9px] font-black uppercase", expiryMode === 'none' ? 'bg-zinc-900 text-white' : 'bg-slate-100 text-slate-500')}>No Expiry</button>
                                <button type="button" onClick={() => onUpdate({ expiry_mode: 'single' })} className={cn("px-2 py-1 rounded-md text-[9px] font-black uppercase", expiryMode === 'single' ? 'bg-zinc-900 text-white' : 'bg-slate-100 text-slate-500')}>One Date</button>
                                <button type="button" onClick={() => onUpdate({ expiry_mode: 'grouped' })} className={cn("px-2 py-1 rounded-md text-[9px] font-black uppercase", expiryMode === 'grouped' ? 'bg-zinc-900 text-white' : 'bg-slate-100 text-slate-500')}>Grouped</button>
                                <button type="button" onClick={onSplitExpiryPerCarton} className={cn("px-2 py-1 rounded-md text-[9px] font-black uppercase", expiryMode === 'per_carton' ? 'bg-zinc-900 text-white' : 'bg-slate-100 text-slate-500')}>Per Carton</button>
                            </div>
                        </div>

                        {expiryMode === 'single' && (
                            <div className="bg-slate-50 p-3 rounded-xl border border-slate-200">
                                <div className="flex items-center gap-3">
                                    <Input 
                                        type="date"
                                        value={packaging.batches[0]?.expiry_date || ''}
                                        onChange={(e) => {
                                            const date = e.target.value;
                                            onUpdate({ batches: packaging.batches.map(b => ({ ...b, expiry_date: date })) });
                                        }}
                                        className="h-10 rounded-lg border-slate-200 bg-white font-bold"
                                    />
                                    <p className="text-[10px] font-bold text-slate-500 uppercase tracking-tight">Applied to all {packaging.batches.length} items</p>
                                </div>
                            </div>
                        )}

                        {expiryMode === 'grouped' && (
                            <div className="space-y-4">
                                <button 
                                    onClick={onAddExpiryGroup}
                                    className="w-full py-3 rounded-xl border-2 border-dashed border-slate-200 text-[10px] font-black uppercase text-slate-400 hover:text-blue-600 hover:border-blue-200 hover:bg-blue-50 transition-all flex items-center justify-center gap-2"
                                >
                                    <Plus className="h-3 w-3" />
                                    Add Expiry Group
                                </button>

                                {expiryGroups.map((group) => (
                                    <div key={group.id} className="bg-slate-50 rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
                                        <div className="bg-white px-4 py-3 border-b border-slate-200 flex items-center justify-between">
                                            <div className="flex items-center gap-4 flex-1">
                                                <Input 
                                                    value={group.label}
                                                    onChange={(e) => onUpdateExpiryGroup(group.id, { label: e.target.value })}
                                                    className="h-8 w-40 text-[11px] font-black uppercase tracking-tight bg-transparent border-transparent hover:border-slate-200 focus:bg-white"
                                                />
                                                <Input 
                                                    type="date"
                                                    value={group.expiry_date}
                                                    onChange={(e) => onUpdateExpiryGroup(group.id, { expiry_date: e.target.value })}
                                                    className="h-8 w-40 text-[11px] font-bold"
                                                />
                                                
                                                <div className="h-8 border-l border-slate-200 mx-1" />
                                                
                                                <div className="flex-1">
                                                    <Select
                                                        value={(() => {
                                                            const assignedBatches = packaging.batches.filter(b => (group.batch_ids || []).includes(b.id));
                                                            if (assignedBatches.length === 0) return '__none__';
                                                            
                                                            const getEffectiveLoc = (b: any) => {
                                                                const id = b?.locationId ?? packaging.defaultLocationId ?? null;
                                                                return id ? String(id) : '__none__';
                                                            };

                                                            const firstLoc = getEffectiveLoc(assignedBatches[0]);
                                                            const allSame = assignedBatches.every(b => getEffectiveLoc(b) === firstLoc);
                                                            return allSame ? firstLoc : '__mixed__';
                                                        })()}
                                                        onValueChange={(val) => {
                                                            if (val === '__mixed__') return;
                                                            const locId = val === '__none__' ? null : val;
                                                            const locName = locations.find(l => String(l.id) === val)?.location_name ?? 'Default';
                                                            const batchIndices = packaging.batches
                                                                .map((b, i) => group.batch_ids.includes(b.id) ? i : -1)
                                                                .filter(i => i !== -1);
                                                            onUpdateMultipleLocations(batchIndices, locId, locName);
                                                        }}
                                                    >
                                                        <SelectTrigger className="h-8 rounded-lg border-slate-200 bg-white font-black text-[10px] uppercase tracking-wider w-[180px]">
                                                            <SelectValue placeholder="Warehouse 📍" />
                                                        </SelectTrigger>
                                                        <SelectContent className="rounded-xl border-slate-200">
                                                            <SelectItem value="__none__" className="text-[11px] font-bold py-2 text-slate-400">Default Warehouse</SelectItem>
                                                            {(() => {
                                                                const assignedBatches = packaging.batches.filter(b => (group.batch_ids || []).includes(b.id));
                                                                const getEffectiveLoc = (b: any) => {
                                                                    const id = b?.locationId ?? packaging.defaultLocationId ?? null;
                                                                    return id ? String(id) : '__none__';
                                                                };
                                                                const firstLoc = getEffectiveLoc(assignedBatches[0]);
                                                                const allSame = assignedBatches.every(b => getEffectiveLoc(b) === firstLoc);
                                                                
                                                                if (!allSame) {
                                                                    return <SelectItem value="__mixed__" disabled className="text-[11px] font-bold py-2 text-blue-600">Multiple Locations</SelectItem>
                                                                }
                                                                return null;
                                                            })()}
                                                            {locations.map(loc => (
                                                                <SelectItem key={loc.id} value={String(loc.id)} className="text-[11px] font-bold py-2">{loc.location_name}</SelectItem>
                                                            ))}
                                                        </SelectContent>
                                                    </Select>
                                                </div>
                                            </div>
                                            <button 
                                                onClick={() => onRemoveExpiryGroup(group.id)}
                                                className="p-2 text-slate-300 hover:text-rose-500 transition-colors"
                                            >
                                                <Trash2 className="h-4 w-4" />
                                            </button>
                                        </div>
                                        <div className="p-4 grid grid-cols-5 gap-2">
                                            {packaging.batches.map((batch) => {
                                                const isAssigned = (group.batch_ids || []).includes(batch.id)
                                                const isAssignedElsewhere = assignedBatchIds.has(batch.id) && !isAssigned
                                                return (
                                                    <button
                                                        key={batch.id}
                                                        disabled={isAssignedElsewhere}
                                                        onClick={() => onAssignBatchToGroup(group.id, batch.id, !isAssigned)}
                                                        className={cn(
                                                            "px-2 py-2 rounded-lg text-[10px] font-black uppercase tracking-tighter border-2 transition-all",
                                                            isAssigned 
                                                                ? "bg-zinc-900 border-zinc-900 text-white shadow-md" 
                                                                : isAssignedElsewhere
                                                                    ? "bg-slate-100 border-slate-100 text-slate-300 cursor-not-allowed opacity-50"
                                                                    : "bg-white border-slate-200 text-slate-500 hover:border-zinc-300"
                                                        )}
                                                    >
                                                        {batch.label}
                                                    </button>
                                                )
                                            })}
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    )
}
