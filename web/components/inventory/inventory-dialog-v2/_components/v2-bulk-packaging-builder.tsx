"use client"

import { Box, Package, ChevronRight, ChevronDown, Info, Calculator, Boxes, Plus, Trash2 } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { cn } from '@/lib/utils'
import { useState } from 'react'

interface BulkPackagingBuilderProps {
    packaging: {
        enabled: boolean;
        containerType: string;
        containerCount: number | string;
        unitsPerContainer: number | string;
        batches: Array<{ id: string, label: string, units: number, expiry_date?: string | null }>;
        expiry_mode?: 'none' | 'single' | 'grouped' | 'per_carton';
        expiry_groups?: Array<{ id: string; label: string; expiry_date: string; batch_ids: string[] }>;
    }
    onUpdate: (updates: any) => void
    onUpdateBatch: (index: number, val: number) => void
    onUpdateLabel: (index: number, label: string) => void
    onAddExtra: () => void
    onRemoveBatch: (batchId: string) => void
    onAddExpiryGroup: () => void
    onUpdateExpiryGroup: (groupId: string, updates: Partial<{ label: string; expiry_date: string; batch_ids: string[] }>) => void
    onRemoveExpiryGroup: (groupId: string) => void
    onAssignBatchToGroup: (groupId: string, batchId: string, assigned: boolean) => void
    onSplitExpiryPerCarton: () => void
}

const CONTAINER_TYPES = ['Carton', 'Box', 'Case', 'Bag', 'Pallet', 'Pack', 'Custom']

export function V2BulkPackagingBuilder({ 
    packaging, onUpdate, onUpdateBatch, onUpdateLabel, onAddExtra,
    onRemoveBatch, onAddExpiryGroup, onUpdateExpiryGroup, onRemoveExpiryGroup, onAssignBatchToGroup, onSplitExpiryPerCarton,
}: BulkPackagingBuilderProps) {
    const [isExpanded, setIsExpanded] = useState(true)
    const totalUnitsTotal = packaging.batches.reduce((s, b) => s + b.units, 0)
    const expiryMode = packaging.expiry_mode || 'none'
    const expiryGroups = packaging.expiry_groups || []
    const assignedBatchIds = new Set(expiryGroups.flatMap((g) => g.batch_ids || []))
    const unassignedBatches = packaging.batches.filter((b) => !assignedBatchIds.has(b.id))
    
    const isCustom = !['Carton', 'Box', 'Case', 'Bag', 'Pallet', 'Pack'].includes(packaging.containerType)
    const displayValue = isCustom ? 'Custom' : packaging.containerType
    
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
                    {/* Setup Story */}
                    <div className="space-y-4">
                        <div className="flex items-center gap-2">
                             <div className="h-1.5 w-1.5 rounded-full bg-zinc-900" />
                             <p className="text-[11px] font-black text-zinc-900 uppercase tracking-tight">1. Standard Configuration</p>
                        </div>
                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-5 pl-3.5">
                            <div className="space-y-2">
                                <Label className="text-[9px] font-black text-slate-400 uppercase tracking-widest ml-1">Type</Label>
                                <Select 
                                    value={displayValue} 
                                    onValueChange={(val) => onUpdate({ containerType: val })}
                                >
                                    <SelectTrigger className="h-10 rounded-xl border-slate-200 bg-slate-50 text-zinc-900 text-[12px] font-black shadow-sm focus:ring-zinc-900/10">
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent className="rounded-xl border-slate-200">
                                        {CONTAINER_TYPES.map(t => (
                                            <SelectItem key={t} value={t} className="text-[12px] font-bold py-2.5">{t}</SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                                {isCustom && (
                                    <div className="mt-2 animate-in fade-in slide-in-from-top-1">
                                        <Input 
                                            placeholder="Specify Name..."
                                            value={packaging.containerType === 'Custom' ? '' : packaging.containerType}
                                            onChange={(e) => onUpdate({ containerType: e.target.value })}
                                            className="h-8 rounded-lg border-slate-200 text-[11px] font-black bg-white shadow-sm focus-visible:ring-zinc-900/10"
                                        />
                                    </div>
                                )}
                            </div>
                            <div className="space-y-2">
                                <Label className="text-[9px] font-black text-slate-400 uppercase tracking-widest ml-1">Quantity</Label>
                                <div className="relative group/input">
                                    <Input 
                                        type="number" 
                                        value={packaging.containerCount} 
                                        onChange={(e) => onUpdate({ containerCount: e.target.value })}
                                        className="h-10 rounded-xl border-slate-200 text-[14px] font-black shadow-inner pl-9 bg-slate-50 text-zinc-900 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none focus-visible:ring-zinc-900/10"
                                    />
                                    <Calculator className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 group-focus-within/input:text-zinc-900 transition-colors" />
                                </div>
                            </div>
                            <div className="space-y-2">
                                <Label className="text-[9px] font-black text-slate-400 uppercase tracking-widest ml-1">Units/Container</Label>
                                <Input 
                                    type="number" 
                                    value={packaging.unitsPerContainer} 
                                    onChange={(e) => onUpdate({ unitsPerContainer: e.target.value })}
                                    className="h-10 rounded-xl border-slate-200 text-[14px] font-black shadow-inner bg-slate-50 text-zinc-900 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none focus-visible:ring-zinc-900/10"
                                />
                            </div>
                        </div>
                    </div>

                    {/* Physical Layout */}
                    <div className="space-y-4 pt-2 border-t border-slate-100">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                                <div className="h-1.5 w-1.5 rounded-full bg-zinc-900" />
                                <p className="text-[11px] font-black text-zinc-900 uppercase tracking-tight">2. Physical Unit Ledger</p>
                            </div>
                            <button 
                                onClick={onAddExtra}
                                className="flex items-center gap-1.5 text-[9px] font-black text-zinc-600 hover:text-zinc-900 border border-slate-200 px-3 py-1.5 rounded-lg bg-slate-50 hover:bg-slate-100 transition-all shadow-sm"
                            >
                                <Plus className="h-3 w-3" />
                                Custom Item
                            </button>
                        </div>

                        <div className="bg-slate-50 p-5 rounded-2xl border-2 border-dashed border-slate-200 min-h-[140px]">
                            {packaging.batches.length > 0 ? (
                                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                                    {packaging.batches.map((batch, idx) => (
                                        <div key={batch.id} className="bg-white border border-slate-100 rounded-xl p-3 shadow-sm hover:border-zinc-300 transition-all group relative">
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
                                            <button
                                                type="button"
                                                onClick={() => onRemoveBatch(batch.id)}
                                                className="mt-2 w-full h-7 rounded-md border border-slate-200 text-[9px] font-black uppercase tracking-wider text-slate-500 hover:text-rose-600 hover:border-rose-200 transition-colors flex items-center justify-center gap-1"
                                            >
                                                <Trash2 className="h-3 w-3" />
                                                Remove
                                            </button>
                                        </div>
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
                                <Label className="text-[9px] font-black text-slate-500 uppercase tracking-widest">Expiry Date (All Cartons)</Label>
                                <Input
                                    type="date"
                                    value={expiryGroups[0]?.expiry_date || ''}
                                    onChange={(e) => onUpdateExpiryGroup(expiryGroups[0]?.id || '', { expiry_date: e.target.value })}
                                    className="h-9 mt-2"
                                />
                            </div>
                        )}

                        {(expiryMode === 'grouped' || expiryMode === 'per_carton') && (
                            <div className="space-y-3">
                                {expiryMode === 'grouped' && (
                                    <button
                                        type="button"
                                        onClick={onAddExpiryGroup}
                                        className="h-8 px-3 rounded-lg bg-slate-100 border border-slate-200 text-[10px] font-black uppercase tracking-wider text-slate-700 hover:bg-slate-200 transition-colors"
                                    >
                                        + Add Expiry Group
                                    </button>
                                )}
                                {expiryGroups.map((group) => (
                                    <div key={group.id} className="bg-slate-50 border border-slate-200 rounded-xl p-3 space-y-2">
                                        <div className="flex items-center gap-2">
                                            <Input
                                                value={group.label}
                                                onChange={(e) => onUpdateExpiryGroup(group.id, { label: e.target.value })}
                                                className="h-8 text-[11px] font-bold"
                                            />
                                            <Input
                                                type="date"
                                                value={group.expiry_date}
                                                onChange={(e) => onUpdateExpiryGroup(group.id, { expiry_date: e.target.value })}
                                                className="h-8"
                                            />
                                            {expiryMode === 'grouped' && (
                                                <button
                                                    type="button"
                                                    onClick={() => onRemoveExpiryGroup(group.id)}
                                                    className="h-8 w-8 rounded-md border border-slate-200 text-slate-500 hover:text-rose-600 hover:border-rose-200 flex items-center justify-center"
                                                >
                                                    <Trash2 className="h-3.5 w-3.5" />
                                                </button>
                                            )}
                                        </div>
                                        {expiryMode === 'grouped' && (
                                            <>
                                            <div className="grid grid-cols-2 sm:grid-cols-3 gap-1.5">
                                                {packaging.batches
                                                    .filter((batch) => {
                                                        // In grouped mode, show unassigned cartons and cartons
                                                        // already assigned to this group. Hide cartons assigned
                                                        // to other groups.
                                                        const ownerGroup = expiryGroups.find((g) => (g.batch_ids || []).includes(batch.id))
                                                        return !ownerGroup || ownerGroup.id === group.id
                                                    })
                                                    .map((batch) => {
                                                    const isAssigned = group.batch_ids.includes(batch.id)
                                                    return (
                                                        <label key={batch.id} className={cn("px-2 py-1.5 rounded-md border text-[10px] font-bold cursor-pointer", isAssigned ? 'bg-blue-50 border-blue-200 text-blue-700' : 'bg-white border-slate-200 text-slate-600')}>
                                                            <input
                                                                type="checkbox"
                                                                checked={isAssigned}
                                                                onChange={(e) => onAssignBatchToGroup(group.id, batch.id, e.target.checked)}
                                                                className="mr-1.5"
                                                            />
                                                            {batch.label}
                                                        </label>
                                                    )
                                                })}
                                            </div>
                                            </>
                                        )}
                                    </div>
                                ))}
                                {expiryMode === 'grouped' && unassignedBatches.length > 0 && (
                                    <p className="text-[10px] font-bold text-amber-700 bg-amber-50 border border-amber-200 rounded-lg px-2 py-1.5">
                                        Some cartons are not assigned to an expiry group.
                                    </p>
                                )}
                            </div>
                        )}
                    </div>

                    <div className="flex items-center justify-between pt-2">
                        <p className="text-[10px] font-bold text-slate-400 flex items-center gap-2">
                            <Info className="h-3.5 w-3.5 text-zinc-900" />
                            Click the unit name (e.g. Box 1) to rename it for tracking.
                        </p>
                        <button 
                            type="button" 
                            onClick={() => onUpdate({ enabled: false })}
                            className="text-[9px] font-black text-slate-400 hover:text-rose-600 uppercase tracking-widest transition-colors"
                        >
                            Disable Bulk Mode
                        </button>
                    </div>
                </div>
            )}
        </div>
    )
}
