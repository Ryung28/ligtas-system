'use client'

import { Warehouse, ArrowRight, Activity } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { InventoryItem } from '@/lib/supabase'
import { cn } from '@/lib/utils'

interface RegionalMatrixProps {
    item: InventoryItem
    variants: any[]
    resolveLocationName: (name: string | null | undefined) => string
    StockTransferPopover: React.ComponentType<any>
}

export function RegionalMatrix({ 
    item, 
    variants, 
    resolveLocationName, 
    StockTransferPopover 
}: RegionalMatrixProps) {
    const primaryLocationName = resolveLocationName(item.primary_location || item.storage_location);
    
    // THE RUTHLESS FIX: Deduplicate based on ID, not name. 
    // Co-located sites (same name, different ID) are legitimate and MUST both be visible.
    const filteredVariants = (variants || []).filter(v => v.id !== item.id);

    const allLocations = [
        { id: item.id, name: primaryLocationName },
        ...filteredVariants.map((v: any) => ({
            id: v.id,
            name: resolveLocationName(v.location)
        }))
    ];

    return (
        <div className="px-14 py-6 bg-slate-50/50 border-y border-slate-200/60 shadow-inner relative overflow-hidden animate-in slide-in-from-top-4 duration-500">
            <div className="flex items-center justify-between border-b border-slate-200/60 pb-3 mb-4">
                <div className="flex items-center gap-2">
                    <span className="text-[10px] font-black text-slate-900 uppercase tracking-widest">Stock Locations</span>
                </div>
            </div>
            
            <div className="space-y-2 relative">
                {/* Main Location Row - Highlighted as the Anchor */}
                <div className="relative flex items-center justify-between py-2.5 px-4 rounded-xl bg-blue-50/40 border border-blue-100 shadow-sm transition-all group/item hover:border-blue-300 hover:shadow-md">
                    <div className="flex items-center gap-4 flex-1">
                        <div className="w-1.5 h-1.5 rounded-full bg-blue-600 shadow-[0_0_5px_rgba(37,99,235,0.4)] ring-4 ring-blue-50" />
                        <span className="text-[13px] font-black text-slate-900 uppercase tracking-tight">
                            {primaryLocationName}
                        </span>
                        <Badge className="bg-blue-600/10 text-blue-700 border-none text-[8px] tracking-widest font-black uppercase h-4 px-1.5 shadow-sm">Main Site</Badge>
                    </div>

                    <div className="flex items-center gap-12">
                        <div className="flex flex-col items-end">
                            <div className="flex items-baseline gap-1.5">
                                <span className="text-base font-mono font-black text-slate-900 tabular-nums leading-none">
                                    {String(item.stock_available).padStart(2, '0')}
                                </span>
                                <span className="text-[10px] font-mono font-bold text-slate-300">/ {String(item.stock_total).padStart(2, '0')}</span>
                            </div>
                            <span className="text-[8px] font-black text-slate-400 uppercase tracking-widest mt-0.5">Ready</span>
                        </div>
                        <div className="w-16 flex justify-end">
                            <StockTransferPopover 
                                item={item} 
                                sourceId={item.id}
                                sourceLocationName={primaryLocationName} 
                                availableStock={item.stock_available}
                                allLocations={allLocations}
                            />
                        </div>
                    </div>
                </div>

                {/* Sub-Locations / Variants - Restored and uniquely labeled */}
                {filteredVariants.map((variant, idx) => {
                    const variantName = resolveLocationName(variant.location);
                    return (
                        <div key={variant.id} className="relative flex items-center justify-between py-2 px-4 rounded-xl bg-white border border-slate-200 shadow-sm transition-all group/item hover:bg-white hover:border-blue-200 hover:shadow-md">
                            <div className="flex items-center gap-4 flex-1">
                                <div className="w-1.5 h-1.5 rounded-full bg-slate-200 group-hover/item:bg-blue-500 group-hover/item:ring-blue-100 transition-all" />
                                <div className="flex items-center gap-2">
                                    <span className="text-[12px] font-bold text-slate-600 uppercase tracking-tight group-hover/item:text-slate-900 transition-colors">
                                        {variantName}
                                    </span>
                                    {/* Senior Move: Add a Site # if multiple sites match the same name for better warehouse distinguishability */}
                                    <span className="text-[9px] font-bold text-slate-400 uppercase tracking-widest bg-slate-100/50 px-1.5 py-0.5 rounded">Site {idx + 2}</span>
                                </div>
                            </div>

                            <div className="flex items-center gap-12">
                                <div className="flex flex-col items-end">
                                    <div className="flex items-baseline gap-1.5 opacity-70 group-hover/item:opacity-100 transition-opacity">
                                        <span className="text-[14px] font-mono font-black text-slate-700 tabular-nums leading-none">
                                            {String(variant.stock_available).padStart(2, '0')}
                                        </span>
                                        <span className="text-[10px] font-mono font-bold text-slate-300">/ {String(variant.stock_total).padStart(2, '0')}</span>
                                    </div>
                                    <span className="text-[8px] font-black text-slate-400 uppercase tracking-widest mt-0.5">Ready</span>
                                </div>
                                <div className="w-16 flex justify-end">
                                    <StockTransferPopover 
                                        item={item} 
                                        sourceId={variant.id}
                                        sourceLocationName={variantName} 
                                        availableStock={variant.stock_available}
                                        allLocations={allLocations}
                                    />
                                </div>
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    )
}
