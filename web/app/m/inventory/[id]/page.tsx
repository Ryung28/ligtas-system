'use client'

export const dynamic = 'force-dynamic'

import React, { useMemo, useState, useTransition } from 'react'
import Image from 'next/image'
import { useParams, useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { useInventory } from '@/hooks/use-inventory'
import { getInventoryImageUrl } from '@/lib/supabase'
import { deleteItem } from '@/src/features/catalog'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { ConfirmDialog } from '@/components/mobile/primitives'
import { InventoryFormSheet } from '../inventory-form-sheet'
import { useUser } from '@/providers/auth-provider'
import { roleCan, mFocus } from '@/lib/mobile/tokens'
import { aggregateInventory, isLowStock } from '@/src/features/inventory/utils'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { 
    Package, 
    AlertTriangle, 
    Info, 
    MapPin, 
    Layers,
    ArrowLeft,
    Share2,
    CheckCircle2,
    XCircle,
    Pencil,
    Archive,
    Wrench,
    ShieldAlert,
    TrendingDown,
    Fingerprint,
    Calendar,
    Tag
} from 'lucide-react'

/**
 * 📱 LIGTAS Mobile Item Details
 * 🏛️ ARCHITECTURE: "The Asset Intelligence Sheet"
 * Full detailed view of a specific tactical asset for on-site auditing.
 */
export default function MobileItemDetailsPage() {
    const { id } = useParams()
    const router = useRouter()
    const { inventory, isLoading, refresh } = useInventory()
    const { user } = useUser()
    const canManage = roleCan.manageInventory(user?.role)
    const [editOpen, setEditOpen] = useState(false)
    const [archiveOpen, setArchiveOpen] = useState(false)
    const [isArchiving, startArchive] = useTransition()

    // 1. 🏛️ MASTER ASSET RESOLUTION (Aggregation Aware)
    const item = useMemo(() => {
        if (!inventory.length) return null
        
        // Find the raw row first
        const rawItem = inventory.find(i => String(i.id) === String(id))
        if (!rawItem) return null

        // Aggregate full inventory to find the 'Master SKU' this item belongs to
        const aggregated = aggregateInventory(inventory)
        return aggregated.find(a => 
            a.item_name.toLowerCase().trim() === rawItem.item_name.toLowerCase().trim() &&
            a.category?.toLowerCase().trim() === rawItem.category?.toLowerCase().trim()
        )
    }, [inventory, id])

    // 🏛️ SENIOR ASSET RESOLUTION: Hydrate path to bucket URL
    const imageUrl = item?.image_url ? getInventoryImageUrl(item.image_url) : null;

    const knownCategories = useMemo(
        () => Array.from(new Set(inventory.map((i) => i.category).filter(Boolean))) as string[],
        [inventory],
    )

    const handleArchive = () => {
        if (!item) return
        startArchive(async () => {
            try {
                const result = await deleteItem(item.id)
                if (result.success) {
                    toast.success('Item archived', { description: `${item.item_name} removed from active registry.` })
                    refresh()
                    setArchiveOpen(false)
                    router.push('/m/inventory')
                } else {
                    toast.error('Archive blocked', { description: (result as any).error })
                }
            } catch (err: any) {
                toast.error('Archive failed', { description: err?.message || 'Please retry.' })
            }
        })
    }

    if (isLoading) {
        return (
            <div className="flex flex-col items-center justify-center p-20 space-y-4">
                <div className="w-12 h-12 border-4 border-gray-100 border-t-red-600 rounded-full animate-spin" />
                <p className="text-sm font-bold text-gray-500 uppercase tracking-widest">Loading Intel...</p>
            </div>
        )
    }

    if (!item) {
        return (
            <div className="flex flex-col items-center justify-center p-12 text-center space-y-6">
                <div className="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center mb-4">
                    <Package className="w-10 h-10 text-gray-300" />
                </div>
                <div className="space-y-2">
                    <h2 className="text-xl font-bold text-gray-900">Asset Not Located</h2>
                    <p className="text-sm text-gray-500">The requested Item ID does not exist in the tactical ledger.</p>
                </div>
                <button 
                    onClick={() => router.push('/m/inventory')}
                    className="px-6 py-3 bg-red-600 text-white rounded-2xl font-bold flex items-center gap-2"
                >
                    <ArrowLeft className="w-4 h-4" />
                    Back to Registry
                </button>
            </div>
        )
    }

    // Status Calculations
    const available = item.stock_available || 0
    const total = item.stock_total || 1
    const isAlert = isLowStock(item)
    
    let statusLabel = 'In Stock'
    let statusColor = 'bg-green-50 text-green-700 border-green-100'
    let StatusIcon = CheckCircle2

    if (available === 0) {
        statusLabel = 'Out of Stock'
        statusColor = 'bg-red-50 text-red-700 border-red-100'
        StatusIcon = XCircle
    } else if (item.qty_damaged > 0 || item.qty_maintenance > 0) {
        statusLabel = 'Needs Maintenance'
        statusColor = 'bg-amber-50 text-amber-700 border-amber-100'
        StatusIcon = AlertTriangle
    } else if (isAlert) {
        statusLabel = 'Low Stock'
        statusColor = 'bg-amber-50 text-amber-700 border-amber-100'
        StatusIcon = AlertTriangle
    }

    const ratio = total > 0 ? available / total : 0
    const stockPercent = Math.min(100, Math.round(ratio * 100))

    return (
        <div className="space-y-8 pb-12">
            <MobileHeader title="Asset Intel" />
            {/* 1. Hero Aspect (Image & Key Stats) */}
            <div className="relative h-64 bg-gray-900 rounded-3xl overflow-hidden shadow-xl mt-2">
                {imageUrl ? (
                    <Image 
                        src={imageUrl} 
                        alt={item.item_name} 
                        fill
                        className="object-cover opacity-90"
                    />
                ) : (
                    <div className="flex items-center justify-center h-full text-gray-700">
                        <Package className="w-20 h-20 opacity-20" />
                    </div>
                )}
                <div className="absolute inset-0 bg-gradient-to-t from-gray-900 via-transparent to-transparent" />
                
                <div className="absolute bottom-6 left-6 right-6">
                    <div className={cn(
                        "inline-flex items-center gap-1.5 px-3 py-1 rounded-lg text-xs font-black uppercase tracking-wider mb-2",
                        statusColor
                    )}>
                        <StatusIcon className="w-3.5 h-3.5" />
                        {statusLabel}
                    </div>
                    <div className="flex items-center gap-2 mb-1">
                        <Badge variant="outline" className="text-[9px] font-black bg-white/10 text-white border-white/20 uppercase tracking-tighter h-5 px-2">
                            {item.category || 'General'}
                        </Badge>
                        <Badge variant="outline" className="text-[9px] font-black bg-white/10 text-white border-white/20 uppercase tracking-tighter h-5 px-2">
                             BIN: {(item as any).storage_bin || 'NA'}
                        </Badge>
                    </div>
                    <h1 className="text-2xl font-black text-white leading-tight">
                        {item.item_name}
                    </h1>
                    {/* Visual Stock Saturation Bar */}
                    <div className="mt-4 w-full h-1.5 bg-white/20 rounded-full overflow-hidden">
                        <div 
                            className={cn(
                                "h-full transition-all duration-700",
                                available === 0 ? "bg-red-500" : isAlert ? "bg-amber-500" : "bg-emerald-500"
                            )}
                            style={{ width: `${stockPercent}%` }}
                        />
                    </div>
                </div>
            </div>

            {/* 2. 📊 MISSION-CRITICAL HEALTH MATRIX */}
            <section className="grid grid-cols-3 gap-3">
                <div className="p-4 bg-white border border-gray-100 rounded-3xl space-y-1 shadow-sm flex flex-col items-center text-center">
                    <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest">Operational</p>
                    <p className="text-xl font-black text-emerald-600 tabular-nums">
                        {available}
                    </p>
                </div>
                <div className="p-4 bg-white border border-gray-100 rounded-3xl space-y-1 shadow-sm flex flex-col items-center text-center">
                    <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest">Damaged</p>
                    <p className={cn(
                        "text-xl font-black tabular-nums",
                        (item.qty_damaged ?? 0) > 0 ? "text-rose-600" : "text-gray-300"
                    )}>
                        {item.qty_damaged ?? 0}
                    </p>
                </div>
                <div className="p-4 bg-white border border-gray-100 rounded-3xl space-y-1 shadow-sm flex flex-col items-center text-center">
                    <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest">Repair</p>
                    <p className={cn(
                        "text-xl font-black tabular-nums",
                        (item.qty_maintenance ?? 0) > 0 ? "text-amber-600" : "text-gray-300"
                    )}>
                        {item.qty_maintenance ?? 0}
                    </p>
                </div>
            </section>

            {/* 3. Detail Specifications */}
            <div className="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm divide-y divide-gray-50">
                <div className="p-6 space-y-4">
                    <h2 className="text-sm font-black text-gray-900 uppercase tracking-tighter flex items-center gap-2">
                        <Fingerprint className="w-4 h-4 text-red-600" />
                        Identification Specs
                    </h2>
                    
                    <div className="grid grid-cols-2 gap-3">
                        {((item as any).item_type === 'equipment' || !(item as any).item_type) ? (
                            <>
                                <div className="flex flex-col p-3 bg-gray-50/50 rounded-xl border border-gray-100 shadow-[inset_0_1px_3px_rgba(0,0,0,0.02)]">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest flex items-center gap-1.5 mb-1">
                                        <Tag className="w-2.5 h-2.5" /> Serial
                                    </span>
                                    <span className="text-sm font-black text-gray-900 truncate">
                                        {(item as any).serial_number || 'N/A'}
                                    </span>
                                </div>
                                <div className="flex flex-col p-3 bg-gray-50/50 rounded-xl border border-gray-100 shadow-[inset_0_1px_3px_rgba(0,0,0,0.02)]">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest flex items-center gap-1.5 mb-1">
                                        <Layers className="w-2.5 h-2.5" /> Model
                                    </span>
                                    <span className="text-sm font-black text-gray-900 truncate">
                                        {(item as any).model_number || 'N/A'}
                                    </span>
                                </div>
                            </>
                        ) : (
                            <>
                                <div className="flex flex-col p-3 bg-gray-50/50 rounded-xl border border-gray-100 shadow-[inset_0_1px_3px_rgba(0,0,0,0.02)]">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest flex items-center gap-1.5 mb-1">
                                        <Tag className="w-2.5 h-2.5" /> Brand
                                    </span>
                                    <span className="text-sm font-black text-gray-900 truncate">
                                        {(item as any).brand || 'N/A'}
                                    </span>
                                </div>
                                <div className="flex flex-col p-3 bg-gray-50/50 rounded-xl border border-gray-100 shadow-[inset_0_1px_3px_rgba(0,0,0,0.02)]">
                                    <span className="text-[9px] font-bold text-gray-400 uppercase tracking-widest flex items-center gap-1.5 mb-1">
                                        <Calendar className="w-2.5 h-2.5" /> Expiry
                                    </span>
                                    <span className="text-sm font-black text-gray-900 truncate">
                                        {(item as any).expiry_date ? new Date((item as any).expiry_date).toLocaleDateString(undefined, { year: 'numeric', month: 'short' }) : 'N/A'}
                                    </span>
                                </div>
                            </>
                        )}
                    </div>
                </div>

                <div className="p-6 space-y-4">
                    <h2 className="text-sm font-black text-gray-900 uppercase tracking-tighter flex items-center gap-2">
                        <Info className="w-4 h-4 text-red-600" />
                        Tactical Description
                    </h2>
                    <p className="text-gray-600 text-sm leading-relaxed">
                        {item.description || 'No detailed tactical description available for this asset record.'}
                    </p>
                </div>

                <div className="p-6 space-y-4">
                    <h2 className="text-sm font-black text-gray-900 uppercase tracking-tighter flex items-center gap-2">
                        <MapPin className="w-4 h-4 text-red-600" />
                        Tactical Distribution
                    </h2>
                    
                    <div className="space-y-3">
                        {item.variants.map((variant) => (
                            <div key={variant.id} className="flex flex-col p-4 bg-gray-50 rounded-2xl border border-gray-100 space-y-2">
                                <div className="flex items-center justify-between">
                                    <div className="space-y-0.5">
                                        <p className="text-xs font-black text-gray-900 uppercase tracking-tight">{variant.location}</p>
                                        <p className="text-[9px] text-gray-400 font-bold tracking-widest uppercase truncate max-w-[120px]">REF: {variant.id}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className={cn(
                                            "text-lg font-black tabular-nums leading-none",
                                            variant.stock_available === 0 ? "text-red-600" : "text-gray-900"
                                        )}>
                                            {variant.stock_available}
                                            <span className="text-[10px] text-gray-300 ml-1">/ {variant.stock_total}</span>
                                        </p>
                                    </div>
                                </div>
                                {(variant.qty_damaged > 0 || variant.qty_maintenance > 0) && (
                                    <div className="pt-2 border-t border-gray-200/50 flex gap-4">
                                        {variant.qty_damaged > 0 && (
                                            <span className="flex items-center gap-1 text-[9px] font-black uppercase text-rose-600">
                                                <ShieldAlert className="w-2.5 h-2.5" />
                                                {variant.qty_damaged} Damaged
                                            </span>
                                        )}
                                        {variant.qty_maintenance > 0 && (
                                            <span className="flex items-center gap-1 text-[9px] font-black uppercase text-amber-600">
                                                <Wrench className="w-2.5 h-2.5" />
                                                {variant.qty_maintenance} Maint
                                            </span>
                                        )}
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            {/* 5. Strategy Actions */}
            <div className="flex gap-3">
                {canManage && (
                    <button
                        type="button"
                        onClick={() => setEditOpen(true)}
                        className={cn(
                            'flex-1 h-12 bg-red-600 text-white rounded-2xl font-bold flex items-center justify-center gap-2',
                            'shadow-md shadow-red-200 motion-safe:transition-transform motion-safe:active:scale-[0.98]',
                            mFocus,
                        )}
                    >
                        <Pencil className="w-4 h-4" aria-hidden />
                        Edit
                    </button>
                )}
                <button
                    type="button"
                    className={cn(
                        'flex-1 h-12 bg-gray-900 text-white rounded-2xl font-bold flex items-center justify-center gap-2',
                        'motion-safe:transition-transform motion-safe:active:scale-[0.98]',
                        mFocus,
                    )}
                >
                    <Share2 className="w-4 h-4" aria-hidden />
                    Report issue
                </button>
            </div>

            {canManage && (
                <div>
                    <button
                        type="button"
                        onClick={() => setArchiveOpen(true)}
                        className={cn(
                            'w-full h-11 rounded-2xl border border-rose-200 bg-rose-50 text-rose-700',
                            'flex items-center justify-center gap-2 text-sm font-bold',
                            'hover:bg-rose-100 motion-safe:transition-colors',
                            mFocus,
                        )}
                    >
                        <Archive className="w-4 h-4" aria-hidden />
                        Archive this item
                    </button>
                </div>
            )}

            {canManage && (
                <>
                    <InventoryFormSheet
                        open={editOpen}
                        onOpenChange={setEditOpen}
                        item={item}
                        knownCategories={knownCategories}
                        onSuccess={refresh}
                    />
                    <ConfirmDialog
                        open={archiveOpen}
                        onOpenChange={setArchiveOpen}
                        title="Archive this item?"
                        description={`"${item.item_name}" will be removed from the active registry. Historical borrow records are preserved.`}
                        confirmLabel="Archive item"
                        tone="danger"
                        loading={isArchiving}
                        requireTypeToConfirm="ARCHIVE"
                        onConfirm={handleArchive}
                    />
                </>
            )}
        </div>
    )
}
