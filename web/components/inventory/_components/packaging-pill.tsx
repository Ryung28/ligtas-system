"use client"

import { Boxes, Info } from 'lucide-react'
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { cn } from '@/lib/utils'

interface PackagingPillProps {
    packaging: {
        enabled: boolean;
        containerType: string;
        containerCount: number | string;
        containerCount: number | string;
        unitsPerContainer: number | string;
        batches: Array<{ id: string, label: string, units: number, max_units?: number }>;
    }
    className?: string
}

export function PackagingPill({ packaging, className }: PackagingPillProps) {
    if (!packaging?.enabled || !packaging.batches?.length) return null

    const totalContainers = packaging.batches.length
    const type = packaging.containerType || 'Unit'

    return (
        <Popover>
            <PopoverTrigger asChild>
                <button 
                    className={cn(
                        "inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-white border border-slate-200 shadow-sm hover:bg-slate-50 hover:border-blue-300 transition-all group",
                        className
                    )}
                >
                    <div className="w-1.5 h-1.5 rounded-full bg-blue-500 animate-pulse" />
                    <span className="text-[10px] font-black text-slate-700 uppercase tracking-tight">
                        {totalContainers} {type}{totalContainers !== 1 ? 's' : ''}
                    </span>
                </button>
            </PopoverTrigger>
            <PopoverContent 
                side="bottom" 
                align="start" 
                className="w-72 p-0 rounded-2xl border-slate-200 bg-white shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200"
            >
                {/* Header */}
                <div className="bg-slate-50/80 px-4 py-3 border-b border-slate-100 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <div className="h-6 w-6 rounded-lg bg-white flex items-center justify-center border border-slate-200 shadow-sm">
                             <Boxes className="h-3.5 w-3.5 text-blue-600" />
                        </div>
                        <span className="text-[11px] font-black text-slate-800 uppercase tracking-tight">Cargo Distribution</span>
                    </div>
                </div>

                {/* Content Matrix */}
                <div className="p-2.5 max-h-[300px] overflow-y-auto custom-scrollbar">
                    <div className="grid grid-cols-1 gap-1.5">
                        {packaging.batches.map((batch, idx) => (
                            <div 
                                key={batch.id} 
                                className="flex items-center justify-between px-3 py-2.5 rounded-xl bg-slate-50/50 border border-transparent hover:border-slate-200 hover:bg-white transition-all group"
                            >
                                <div className="flex items-center gap-3">
                                    <div className="h-2 w-2 rounded-full bg-blue-500 shadow-[0_0_8px_rgba(59,130,246,0.5)]" />
                                    <span className="text-[11px] font-bold text-slate-600 uppercase tracking-tight group-hover:text-slate-900 transition-colors truncate max-w-[140px]">
                                        {batch.label}
                                    </span>
                                </div>
                                <div className="flex items-baseline gap-1.5 shrink-0">
                                     <span className={cn(
                                         "text-[13px] font-black tabular-nums",
                                         batch.units > 0 ? "text-slate-900" : "text-slate-400"
                                     )}>
                                         {batch.units}
                                     </span>
                                     {batch.max_units && (
                                         <span className="text-[10px] font-bold text-slate-400">
                                             / {batch.max_units}
                                         </span>
                                     )}
                                     <span className="text-[9px] font-black text-slate-300 uppercase tracking-widest ml-0.5">Units</span>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Footnote */}
                <div className="bg-gray-50/80 p-2 text-center border-t border-gray-100">
                     <p className="text-[9px] font-black text-gray-400 flex items-center justify-center gap-1.5 opacity-80">
                        <Info className="h-3 w-3" />
                        Inventory Distribution Summary
                     </p>
                </div>
            </PopoverContent>
        </Popover>
    )
}
