'use client'

import { Warehouse } from 'lucide-react'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'

interface Batch {
    id: string
    label: string
    units: number
    max_units?: number
}

interface BatchSelectorProps {
    packagingJson: {
        enabled: boolean
        batches: Batch[]
    } | null
    selectedBatchId: string | null
    onSelectBatch: (batchId: string | null) => void
    unitLabel?: string
}

export function BatchSelector({ 
    packagingJson, 
    selectedBatchId, 
    onSelectBatch,
    unitLabel = 'QTY'
}: BatchSelectorProps) {
    if (!packagingJson?.enabled || !packagingJson.batches || packagingJson.batches.length === 0) {
        return null
    }

    return (
        <div className="space-y-3 animate-in slide-in-from-top-2 duration-300">
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                    <Warehouse className="h-3.5 w-3.5 text-slate-400" />
                    <Label className="text-[10px] font-black uppercase tracking-widest text-slate-500 font-heading">
                        Cargo Distribution
                    </Label>
                </div>
                <div className="px-2 py-0.5 bg-slate-100 rounded text-[9px] font-black text-slate-500 uppercase tracking-tighter">
                    {packagingJson.batches.length} Total {packagingJson.batches.length > 1 ? 'Cartons' : 'Carton'}
                </div>
            </div>
            <div className="grid grid-cols-1 gap-1.5">
                {packagingJson.batches.map((batch) => (
                    <button
                        key={batch.id}
                        type="button"
                        disabled={batch.units <= 0}
                        onClick={() => onSelectBatch(selectedBatchId === batch.id ? null : batch.id)}
                        className={cn(
                            "px-4 py-3 rounded-xl border transition-all relative overflow-hidden group flex items-center justify-between",
                            selectedBatchId === batch.id
                                ? "bg-blue-50 border-blue-500 ring-4 ring-blue-500/10 shadow-sm"
                                : batch.units <= 0
                                    ? "bg-slate-50 border-slate-100 opacity-40 cursor-not-allowed"
                                    : "bg-white border-slate-200 hover:border-slate-300 hover:bg-slate-50/50"
                        )}
                    >
                        <div className="flex items-center gap-3 min-w-0 pr-4">
                            <div className={cn(
                                "w-2 h-2 rounded-full",
                                selectedBatchId === batch.id ? "bg-blue-500" : "bg-slate-200"
                            )} />
                            <span className={cn(
                                "text-[12px] font-bold truncate transition-colors uppercase tracking-tight", 
                                selectedBatchId === batch.id ? "text-blue-900" : "text-slate-600 group-hover:text-slate-900"
                            )}>
                                {batch.label}
                            </span>
                        </div>
                        <div className="flex items-baseline gap-1.5 shrink-0">
                            <span className={cn(
                                "text-[13px] font-black tabular-nums transition-colors",
                                selectedBatchId === batch.id ? "text-blue-600" : "text-slate-900"
                            )}>
                                {batch.units}
                            </span>
                            {batch.max_units && (
                                <span className="text-[10px] font-bold text-slate-400">
                                    / {batch.max_units}
                                </span>
                            )}
                            <span className="text-[10px] font-black text-slate-300 uppercase tracking-widest ml-1">
                                {unitLabel}
                            </span>
                        </div>
                        {selectedBatchId === batch.id && (
                            <div className="absolute top-0 right-0 p-1">
                                <div className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse shadow-sm shadow-emerald-500/50" />
                            </div>
                        )}
                    </button>
                ))}
            </div>
            <div className="text-[10px] text-slate-400 font-medium italic flex items-center gap-2">
                <div className="w-1 h-1 bg-slate-300 rounded-full" />
                Inventory will be automatically deducted from the selected batch for forensic logging.
            </div>
        </div>
    )
}
