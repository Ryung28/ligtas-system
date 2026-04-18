'use client'

export const dynamic = 'force-dynamic'

import React, { useMemo } from 'react'
import Image from 'next/image'
import { useParams, useRouter } from 'next/navigation'
import { useInventory } from '@/hooks/use-inventory'
import { getInventoryImageUrl } from '@/lib/supabase'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { 
    Package, 
    ShieldCheck, 
    AlertTriangle, 
    Info, 
    MapPin, 
    Layers,
    ArrowLeft,
    Share2,
    CheckCircle2,
    XCircle,
    QrCode
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { QRCodeCanvas } from 'qrcode.react'

/**
 * 📱 LIGTAS Mobile Item Details
 * 🏛️ ARCHITECTURE: "The Asset Intelligence Sheet"
 * Full detailed view of a specific tactical asset for on-site auditing.
 */
export default function MobileItemDetailsPage() {
    const { id } = useParams()
    const router = useRouter()
    const { inventory, isLoading } = useInventory()

    // 1. Data Identification
    const item = useMemo(() => {
        return inventory.find(i => String(i.id) === String(id))
    }, [inventory, id])

    // 🏛️ SENIOR ASSET RESOLUTION: Hydrate path to bucket URL
    const imageUrl = item?.image_url ? getInventoryImageUrl(item.image_url) : null;

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
    const ratio = available / total
    
    let statusLabel = 'In Stock'
    let statusColor = 'bg-green-50 text-green-700 border-green-100'
    let StatusIcon = CheckCircle2

    if (available === 0) {
        statusLabel = 'Out of Stock'
        statusColor = 'bg-red-50 text-red-700 border-red-100'
        StatusIcon = XCircle
    } else if (ratio < 0.5) {
        statusLabel = 'Low Stock'
        statusColor = 'bg-amber-50 text-amber-700 border-amber-100'
        StatusIcon = AlertTriangle
    }

    const qrValue = JSON.stringify({
        protocol: 'ligtas',
        version: '1.0',
        action: 'borrow',
        itemId: item.id,
        itemName: item.item_name
    })

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
                    <h1 className="text-2xl font-black text-white leading-tight">
                        {item.item_name}
                    </h1>
                </div>
            </div>

            {/* 2. Operational Metrics */}
            <section className="grid grid-cols-2 gap-4">
                <div className="p-4 bg-white border border-gray-100 rounded-3xl space-y-1 shadow-sm">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Available Units</p>
                    <p className="text-2xl font-black text-gray-900 tabular-nums">
                        {available} <span className="text-gray-300 text-sm font-medium">/ {total}</span>
                    </p>
                </div>
                <div className="p-4 bg-white border border-gray-100 rounded-3xl space-y-1 shadow-sm">
                    <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Category</p>
                    <p className="text-lg font-bold text-gray-900 truncate">
                        {item.category || 'General'}
                    </p>
                </div>
            </section>

            {/* 3. Detail Specifications */}
            <div className="bg-white rounded-[2rem] border border-gray-100 overflow-hidden shadow-sm divide-y divide-gray-50">
                <div className="p-6 space-y-4">
                    <h2 className="text-sm font-black text-gray-900 uppercase tracking-tighter flex items-center gap-2">
                        <Info className="w-4 h-4 text-red-600" />
                        Tactical Description
                    </h2>
                    <p className="text-gray-600 text-sm leading-relaxed">
                        {item.description || 'No detailed tactical description available for this asset record.'}
                    </p>
                </div>

                <div className="p-6 grid grid-cols-2 gap-y-4 gap-x-8">
                    <div className="space-y-1">
                        <div className="flex items-center gap-1.5 text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            <MapPin className="w-3 h-3" />
                            Storage Area
                        </div>
                        <p className="text-sm font-bold text-gray-900">{item.storage_location || 'Central Depot'}</p>
                    </div>
                    <div className="space-y-1">
                        <div className="flex items-center gap-1.5 text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            <Layers className="w-3 h-3" />
                            Storage Bin
                        </div>
                        <p className="text-sm font-bold text-gray-900">{(item as any).storage_bin || 'Unassigned'}</p>
                    </div>
                </div>

                {/* 4. Asset Identification (QR) */}
                <div className="p-8 flex flex-col items-center gap-6 bg-gray-50/50">
                    <div className="p-4 bg-white rounded-3xl shadow-xl border border-gray-100">
                        <QRCodeCanvas 
                            value={qrValue} 
                            size={160} 
                            level="H"
                            includeMargin={false}
                        />
                    </div>
                    <div className="text-center space-y-1">
                        <h3 className="text-xs font-black text-gray-900 uppercase tracking-[0.2em] flex items-center justify-center gap-2">
                            <QrCode className="w-4 h-4" />
                            Unified Asset ID
                        </h3>
                        <p className="text-[10px] font-mono text-gray-400 uppercase tracking-widest">{item.id}</p>
                    </div>
                </div>
            </div>

            {/* 5. Strategy Actions */}
            <div className="flex gap-3">
                <button 
                    className="flex-1 py-4 bg-gray-900 text-white rounded-2xl font-bold flex items-center justify-center gap-2 shadow-lg active:scale-95 transition-all"
                >
                    <Share2 className="w-4 h-4" />
                    Report Issue
                </button>
            </div>
        </div>
    )
}
