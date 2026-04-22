'use client'

import { useState } from 'react'
import { cn } from '@/lib/utils'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Badge } from '@/components/ui/badge'
import { Warehouse } from 'lucide-react'

interface DistributionPipsProps {
    primaryLocation: string
    primaryStock: number
    variants: any[]
    onToggleExpand: () => void
    resolveLocationName: (name: string) => string
}

export function DistributionPips({ 
    primaryLocation, 
    primaryStock, 
    variants, 
    onToggleExpand,
    resolveLocationName
}: DistributionPipsProps) {
    const [isHovering, setIsHovering] = useState(false)

    if (!variants || variants.length === 0) return null

    return (
        <Popover open={isHovering} onOpenChange={setIsHovering}>
            <PopoverTrigger asChild>
                <button 
                    onMouseEnter={() => setIsHovering(true)}
                    onMouseLeave={() => setIsHovering(false)}
                    onClick={(e) => {
                        e.stopPropagation();
                        onToggleExpand();
                    }}
                    className="flex items-center gap-0.5 px-1.5 py-0.5 bg-slate-50 hover:bg-blue-50 rounded-md border border-slate-200/50 transition-colors group/pips shadow-sm"
                >
                    <div className="flex gap-0.5">
                        <div className="w-1.5 h-1.5 rounded-full bg-blue-600 shadow-[0_0_4px_rgba(37,99,235,0.4)]" />
                        {variants.slice(0, 3).map((v: any) => (
                            <div 
                                key={v.id} 
                                className={cn(
                                    "w-1.5 h-1.5 rounded-full transition-all",
                                    v.stock_available > 0 ? "bg-blue-400" : "bg-slate-300"
                                )} 
                            />
                        ))}
                    </div>
                    <span className="text-[9px] font-black text-blue-600 ml-1">+{variants.length}</span>
                </button>
            </PopoverTrigger>
            <PopoverContent 
                side="right" 
                align="start" 
                className="w-64 p-0 rounded-xl shadow-2xl border-blue-100 bg-white/95 backdrop-blur-sm z-[110] overflow-hidden animate-in fade-in zoom-in-95 duration-200"
                onMouseEnter={() => setIsHovering(true)}
                onMouseLeave={() => setIsHovering(false)}
            >
                <div className="p-3 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                    <h4 className="text-[9px] font-black text-slate-900 uppercase tracking-widest">Stock Locations</h4>
                    <div className="flex items-center gap-1 text-[9px] font-bold text-blue-600">
                        {variants.length + 1} PLACES
                    </div>
                </div>
                <div className="p-3 space-y-2">
                    <div className="flex justify-between items-center group/site">
                        <div className="flex items-center gap-2">
                            <div className="w-1 h-1 rounded-full bg-blue-600" />
                            <span className="text-[11px] font-bold text-slate-700 uppercase tracking-tight">
                                {resolveLocationName(primaryLocation)}
                            </span>
                        </div>
                        <span className="text-[11px] font-black text-blue-600 tabular-nums">{primaryStock}</span>
                    </div>
                    {variants.map((v: any) => (
                        <div key={v.id} className="flex justify-between items-center opacity-80 pl-3">
                            <span className="text-[10px] font-medium text-slate-500 uppercase tracking-tight">
                                {resolveLocationName(v.location)}
                            </span>
                            <span className="text-[10px] font-bold text-slate-700 tabular-nums">{v.stock_available}</span>
                        </div>
                    ))}
                </div>
                <div className="p-2 bg-blue-50/50 text-center">
                    <p className="text-[8px] font-black text-blue-400 uppercase tracking-tighter">Click pips to expand details</p>
                </div>
            </PopoverContent>
        </Popover>
    )
}
