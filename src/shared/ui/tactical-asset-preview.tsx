import { Package } from 'lucide-react'
import { cn } from '@/lib/utils'
import { TacticalAssetImage } from './tactical-asset-image'

interface TacticalAssetPreviewProps {
    item: {
        item_name: string
        category: string
        image_url?: string
        item_type?: string
        storage_location?: string
        aggregate_available?: number
    } | null
    className?: string
    size?: 'sm' | 'md' | 'lg'
}

/**
 * TACTICAL ASSET PREVIEW (SSOT)
 * 
 * The Single Source of Truth for visualizing inventory assets.
 * Features:
 * - High-fidelity image thumbnail
 * - Click-to-zoom Lightbox (via TacticalAssetImage)
 * - Semantic metadata labels
 */
export function TacticalAssetPreview({ item, className, size = 'md' }: TacticalAssetPreviewProps) {
    if (!item) return null

    return (
        <div className={cn(
            "flex items-center gap-2.5 p-1.5 bg-white border border-slate-100 rounded-lg shadow-sm transition-all",
            className
        )}>
            {/* THUMBNAIL (via SSOT) */}
            <TacticalAssetImage 
                url={item.image_url} 
                alt={item.item_name} 
                size="sm"
                className="rounded-md border-slate-100"
            />

            {/* METADATA */}
            <div className="min-w-0 flex-1 flex flex-col justify-center">
                <div className="flex items-center justify-between gap-1 mb-0.5">
                    <h3 className="text-[11px] font-black text-slate-900 truncate uppercase tracking-tighter leading-none">
                        {item.item_name}
                    </h3>
                </div>
                <div className="flex items-center gap-1.5 opacity-80">
                    <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">
                        {item.category}
                    </span>
                    {item.aggregate_available !== undefined && (
                        <div className="flex items-center gap-1 pl-1.5 border-l border-slate-100">
                            <span className="text-[9px] font-black text-emerald-600 uppercase tracking-widest">
                                {item.aggregate_available} AT SITE
                            </span>
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}
