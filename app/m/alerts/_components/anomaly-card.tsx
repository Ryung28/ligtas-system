'use client'

import { ArrowRight, MapPin, Info } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { cn } from '@/lib/utils'
import { AggregatedInventoryItem } from '@/src/features/inventory/types'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'

interface AnomalyCardProps {
    item: AggregatedInventoryItem
    onImageClick?: (url: string, name: string) => void
}

export function AnomalyCard({ item, onImageClick }: AnomalyCardProps) {
    const router = useRouter()
    const isCritical = item.stock_available === 0
    const isDamaged = item.qty_damaged > 0

    // 🛡️ EXPIRY LOGIC
    let isExpiring = false
    let isExpired = false
    const expiry = (item as any).expiry_date
    if (expiry) {
        const diff = (new Date(expiry).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
        isExpired = diff < 0
        isExpiring = diff <= 30
    }

    return (
        <div
            onClick={() => router.push(`/m/inventory/${item.id}?action=restock`)}
            className="bg-white p-4 rounded-[24px] border border-slate-100 shadow-sm flex items-center justify-between group active:scale-[0.98] transition-all duration-200 cursor-pointer"
        >
            <div className="flex items-center gap-4 min-w-0">
                <div
                    onClick={(e) => {
                        e.stopPropagation()
                        if (item.image_url && onImageClick) onImageClick(item.image_url, item.item_name)
                    }}
                    className="relative shrink-0 active:scale-95 transition-transform"
                >
                    <TacticalAssetImage
                        url={item.image_url}
                        alt={item.item_name}
                        size="md"
                        className="rounded-2xl shadow-sm overflow-hidden bg-slate-50 border-none shrink-0"
                    />
                </div>
                <div className="flex flex-col min-w-0 gap-0.5">
                    <div
                        className={cn(
                            "flex items-center gap-1 text-[10px] font-black uppercase tracking-[0.1em] leading-none mb-0.5 w-fit",
                            (isCritical || isExpired) ? "text-rose-600" :
                                (isDamaged || isExpiring) ? "text-amber-600" : "text-blue-600"
                        )}
                    >
                        {isExpired ? 'Expired' :
                            isExpiring ? 'Expiring Soon' :
                                isCritical ? 'Critical Deficiency' :
                                    isDamaged ? 'Hardware Damage' : 'Low Inventory'}
                        <Info className="w-2.5 h-2.5" />
                    </div>

                    <h4 className="font-bold text-slate-900 text-[15px] truncate tracking-tight leading-tight">
                        {item.item_name}
                    </h4>
                    <div className="flex items-center gap-1 text-slate-400 mt-0.5">
                        <MapPin className="w-3 h-3 shrink-0" />
                        <span className="text-[11px] font-bold uppercase tracking-tight truncate">
                            {item.primary_location?.replace(/_/g, ' ') || 'Unassigned'}
                        </span>
                    </div>
                </div>
            </div>

            <div className="flex items-center gap-4 shrink-0 pl-4 border-l border-slate-50">
                <div className="flex flex-col items-end">
                    <span className={cn(
                        "text-[16px] font-black tabular-nums tracking-tighter leading-none",
                        isCritical ? "text-rose-600" : "text-slate-900"
                    )}>
                        {item.stock_available}
                    </span>
                    <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-1">
                        Units
                    </span>
                </div>
                <div className="bg-slate-50 p-2 rounded-full group-hover:bg-slate-100 transition-colors">
                    <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-slate-900 transition-colors" />
                </div>
            </div>
        </div>
    )
}
