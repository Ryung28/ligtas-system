'use client'

import { Package, X } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import { isLowStock } from '@/src/features/inventory/utils'
import type { InventoryPickerItem } from '../types'

interface ManifestItemRowProps {
    item: InventoryPickerItem
    onRemove: (id: number) => void
}

export function ManifestItemRow({ item, onRemove }: ManifestItemRowProps) {
    return (
        <div className="h-10 flex items-center px-4 hover:bg-slate-50 transition-all group">
            <Package className="h-3.5 w-3.5 text-blue-500 mr-3 shrink-0" />
            <div className="flex-1 flex flex-col min-w-0 pr-3">
                <div className="flex items-center gap-2">
                    <span className="text-[12px] font-black text-slate-900 truncate">
                        {item.base_name || item.item_name}
                    </span>
                    {item.variant_label && (
                        <Badge variant="outline" className="h-4 px-1.5 text-[8px] font-black bg-slate-50 text-slate-400 border-slate-200">
                            {item.variant_label}
                        </Badge>
                    )}
                </div>
            </div>
            <div className="flex items-center gap-2 tabular-nums">
                <span className={cn(
                    "text-[10px] font-black px-1.5 py-0.5 rounded",
                    isLowStock(item) ? "bg-rose-50 text-rose-600" : "text-slate-900"
                )}>
                    {item.stock_available}
                    <span className="text-slate-300 font-medium mx-0.5">/</span>
                    {item.target_stock > 0 ? item.target_stock : item.stock_total}
                </span>
                <span className="text-[10px] font-black text-slate-400 uppercase w-14 text-right shrink-0">
                    {item.category}
                </span>
            </div>
            <button
                onClick={() => onRemove(item.id)}
                className="ml-3 p-1 text-slate-200 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-all"
            >
                <X className="h-3.5 w-3.5" />
            </button>
        </div>
    )
}
