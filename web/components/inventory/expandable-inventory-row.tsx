'use client'

import { useState, useRef, useEffect, useCallback } from 'react'
import { cn } from '@/lib/utils'
import Image from 'next/image'
import { TableCell, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Edit2, Trash2, Maximize2, Package, ChevronDown, Warehouse, ArrowRightLeft, Clock, PackagePlus, Loader2 } from 'lucide-react'
import { InventoryItem, InventoryVariant } from '@/lib/supabase'
import { getExpiryInfo } from '@/lib/expiry-utils'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { QRDialog } from './qr-dialog'
import { EditableStorageLocation } from './editable-storage-location'
import { getPendingRequestsByItemId, type PendingRequest, getActiveLoansByIds, type ActiveLoan } from '@/src/features/transactions'
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { rebalanceStockAction } from '@/actions/inventory-transfer'
import { getStorageLocations } from '@/app/actions/storage-locations'
import { restockInventoryAction } from '@/app/actions/notifications'
import { toast } from 'sonner'
import { useStorageLocations } from '@/hooks/use-storage-locations'
import { pluralizeContainerType } from '@/lib/container-type'

function BatchRow({ batch, onRestockBatch }: { batch: any, onRestockBatch?: (id: string, qty: number) => Promise<void> }) {
    const [isRestocking, setIsRestocking] = useState(false)
    const [qty, setQty] = useState('')
    const [isSubmitting, setIsSubmitting] = useState(false)

    return (
        <div className="flex flex-col gap-2 p-2.5 rounded-lg bg-white border border-gray-100 shadow-sm">
            <div className="flex items-center justify-between">
                <div className="flex flex-col gap-0.5">
                    <span className="text-[11px] font-black text-gray-950 uppercase tracking-tight">{batch.label || 'Unlabeled'}</span>
                    {batch.expiry_date && (
                        <div className="flex items-center gap-1">
                            <Clock className="h-2.5 w-2.5 text-gray-400" />
                            <span className="text-[8px] font-bold text-gray-500 uppercase tracking-tighter">Exp: {new Date(batch.expiry_date).toLocaleDateString()}</span>
                        </div>
                    )}
                </div>
                <div className="flex items-center gap-3">
                    <div className="flex flex-col items-end">
                        <span className="text-[13px] font-black text-blue-600 tabular-nums">{batch.units}</span>
                        <span className="text-[8px] font-extrabold text-gray-400 uppercase tracking-widest">Units</span>
                    </div>
                    {onRestockBatch && (
                        <Button
                            variant="ghost"
                            size="icon"
                            className={cn("h-7 w-7 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors", isRestocking && "bg-blue-50 text-blue-600")}
                            onClick={(e) => {
                                e.stopPropagation()
                                setIsRestocking(!isRestocking)
                            }}
                        >
                            <PackagePlus className="h-3.5 w-3.5" />
                        </Button>
                    )}
                </div>
            </div>
            {isRestocking && (
                <div className="flex items-center gap-2 pt-2 border-t border-gray-50 mt-1" onClick={(e) => e.stopPropagation()}>
                    <Input 
                        type="number" 
                        placeholder="Qty" 
                        value={qty}
                        onChange={(e) => setQty(e.target.value)}
                        className="h-7 text-xs bg-gray-50/50 border-gray-200" 
                    />
                    <Button 
                        size="sm" 
                        className="h-7 text-[10px] uppercase font-bold bg-blue-600 hover:bg-blue-700 text-white min-w-[60px]"
                        disabled={isSubmitting || !qty}
                        onClick={async () => {
                            const val = parseInt(qty)
                            if (val > 0) {
                                setIsSubmitting(true)
                                try {
                                    await onRestockBatch?.(batch.id, val)
                                    setIsRestocking(false)
                                    setQty('')
                                } finally {
                                    setIsSubmitting(false)
                                }
                            }
                        }}
                    >
                        {isSubmitting ? <Loader2 className="h-3 w-3 animate-spin" /> : 'Add'}
                    </Button>
                </div>
            )}
        </div>
    )
}

// Sub-components
import { CompositeStockBar } from './_components/composite-stock-bar'
import { UnifiedStatusHub } from './_components/unified-status-hub'

function SiteHealthFootnote({ variant }: { variant: any | undefined }) {
    if (!variant) return null
    const d = variant.qty_damaged ?? 0
    const m = variant.qty_maintenance ?? 0
    const l = variant.qty_lost ?? 0
    if (!d && !m && !l) {
        return (
            <p className="mt-3 text-[9px] font-bold uppercase tracking-widest text-emerald-700/90">
                All units ready for use
            </p>
        )
    }
    return (
        <div className="mt-3 flex flex-wrap gap-x-3 gap-y-1 text-[9px] font-black uppercase tracking-widest">
            {d > 0 && <span className="text-rose-600">{d} damaged</span>}
            {m > 0 && <span className="text-amber-600">{m} maintenance</span>}
            {l > 0 && <span className="text-slate-500">{l} lost</span>}
        </div>
    )
}

function SiteDistributionCard({ 
    itemId,
    variant, 
    isMain, 
    showBulkDisplay, 
    containerCount, 
    containerTypePlural, 
    resolveLocationName,
    onRestockBatch
}: {
    itemId: number
    variant: any | undefined
    isMain?: boolean
    showBulkDisplay: boolean
    containerCount: number
    containerTypePlural: string
    resolveLocationName: (loc: string) => string
    onRestockBatch?: (batchId: string, qty: number) => Promise<void>
}) {
    if (!variant) return null
    const batches = variant.batches || []
    const hasBatches = batches.length > 0

    const cardContent = (
        <div 
            onClick={(e) => e.stopPropagation()}
            className={cn(
                "bg-white border border-gray-200 rounded-2xl p-5 shadow-[0_4px_12px_-2px_rgba(0,0,0,0.05)] hover:shadow-[0_12px_24px_-8px_rgba(0,0,0,0.1)] transition-all duration-300 group/site relative overflow-hidden",
                isMain && "border-t-4 border-t-gray-900",
                hasBatches && "cursor-pointer active:scale-[0.98]"
            )}
        >
            {hasBatches && (
                <div className="absolute top-0 right-0 p-1.5 opacity-0 group-hover/site:opacity-100 transition-opacity">
                    <Maximize2 className="h-3 w-3 text-gray-400" />
                </div>
            )}
            
            <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-2.5 min-w-0">
                    <div className={cn(
                        "h-5 w-5 rounded-lg flex items-center justify-center flex-shrink-0",
                        isMain ? "bg-gray-900" : "bg-gray-50 border border-gray-200"
                    )}>
                        <Warehouse className={cn("h-3 w-3", isMain ? "text-white" : "text-gray-400")} />
                    </div>
                    <span className="text-[13px] font-bold text-gray-800 uppercase tracking-tight truncate">
                        {resolveLocationName(variant.location).replace(/_/g, ' ')}
                    </span>
                </div>
                {isMain && (
                    <Badge variant="outline" className="text-[8px] font-black bg-gray-50 text-gray-900 border-gray-200 uppercase px-2.5 h-5 flex-shrink-0 whitespace-nowrap tracking-widest">Main Location</Badge>
                )}
            </div>
            
            <div className="flex items-end justify-between">
                <div className="flex flex-col">
                    <span className="text-[24px] font-black text-gray-950 tabular-nums tracking-tighter leading-none">
                        {showBulkDisplay ? (
                            <span className="flex items-baseline gap-1">
                                <span className="text-blue-600 font-black">{batches.length}</span>
                                <span className="text-[16px] text-gray-400 font-bold">/</span>
                                <span>{variant.stock_available ?? 0}</span>
                            </span>
                        ) : (variant.stock_available ?? 0)}
                    </span>
                    <div className="flex items-center gap-1.5 mt-2">
                        <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                            {showBulkDisplay ? containerTypePlural : 'IN STOCK'} / {variant.stock_total ?? 0} TOTAL
                        </span>
                    </div>
                    <SiteHealthFootnote variant={variant} />
                </div>
            </div>
        </div>
    )

    if (!hasBatches) return cardContent

    return (
        <Popover>
            <PopoverTrigger asChild>
                {cardContent}
            </PopoverTrigger>
            <PopoverContent side="top" align="center" className="w-72 p-0 rounded-xl overflow-hidden shadow-2xl border-gray-200 bg-white z-[120]">
                <div className="p-3 bg-gray-900 flex items-center justify-between">
                    <span className="text-[10px] font-black text-white uppercase tracking-[0.15em]">Cargo Manifest</span>
                    <Badge variant="outline" className="text-[9px] font-bold border-white/20 text-white uppercase px-1.5 h-5">{batches.length} {containerTypePlural}</Badge>
                </div>
                <div className="p-2 bg-gray-50/50 border-b border-gray-100 flex items-center gap-2">
                    <div className="h-1.5 w-1.5 rounded-full bg-blue-500 animate-pulse" />
                    <span className="text-[9px] font-bold text-gray-500 uppercase tracking-tight">Active Inventory at {resolveLocationName(variant.location)}</span>
                </div>
                <div className="max-h-[280px] overflow-y-auto p-2 space-y-1.5">
                    {batches.map((batch: any, idx: number) => (
                        <BatchRow key={`ledger_batch_${itemId}_${batch.id}_${idx}`} batch={batch} onRestockBatch={onRestockBatch} />
                    ))}
                </div>
                <div className="p-2.5 bg-gray-50 border-t border-gray-100 text-center">
                    <p className="text-[8px] font-bold text-gray-400 uppercase tracking-[0.2em]">End of Site Manifest</p>
                </div>
            </PopoverContent>
        </Popover>
    )
}

interface ExpandableInventoryRowProps {
    item: InventoryItem
    index: number
    onDelete: (id: number, name: string) => void
    isDeleting: boolean
    onRefresh?: () => void
    onImageClick: (url: string, name: string) => void
    getCategoryIcon: (category: string) => any
    getStockDisplay: (item: InventoryItem) => any
    getConditionDot: (status: string) => any
    getStockPercentage: (available: number, total: number) => number
    isSelected?: boolean
    onSelect?: () => void
    showCheckbox?: boolean
    onEdit?: (item: InventoryItem) => void
    isHighlighted?: boolean
}



export function ExpandableInventoryRow({
    item, index, onDelete, isDeleting, onRefresh, onImageClick, getCategoryIcon, getStockDisplay, getConditionDot, getStockPercentage, isSelected = false, onSelect, showCheckbox = false, onEdit, isHighlighted = false
}: ExpandableInventoryRowProps) {
    const rowRef = useRef<HTMLTableRowElement>(null)
    const [isInternalOpen, setIsInternalOpen] = useState(false)
    const [isDetailsOpen, setIsDetailsOpen] = useState(false)
    const { resolveLocationName } = useStorageLocations()

    useEffect(() => {
        if (isHighlighted && rowRef.current) rowRef.current.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }, [isHighlighted])
    
    const [pendingRequests, setPendingRequests] = useState<PendingRequest[]>([])
    const [isLoadingPending, setIsLoadingPending] = useState(false)
    const [activeLoans, setActiveLoans] = useState<ActiveLoan[]>([])
    const [isLoadingActiveLoans, setIsLoadingActiveLoans] = useState(false)
    const [isBorrowedPopoverOpen, setIsBorrowedPopoverOpen] = useState(false)

    // 🏛️ SENIOR GEOGRAPHIC DETECTOR: Consolidated variants list (one row per physical site).
    const allSites = item.variants || []
    const primaryLocKey = ((item.primary_location || item.storage_location || '') as string).trim()
    const primaryVariant =
        allSites.find((v) => (v.location || '').trim() === primaryLocKey) ?? allSites[0]

    // 🛡️ DEDUPLICATION: Exclude the primary variant by reference to prevent duplicate cards
    // when the fallback mechanism selects a satellite site as the primary.
    const satelliteVariants = allSites.filter((v) => v !== primaryVariant)
    const isDistributed = satelliteVariants.length > 0
    
    // Header represents the TRUE AGGREGATE of all unique sites.
    const displayTotal = item.stock_total
    const displayAvailable = item.stock_available
    const planStock = Number(item.target_stock ?? 0)
    const planDelta = planStock > 0 ? (displayTotal - planStock) : 0
    const planDeltaLabel = planDelta > 0 ? `+${planDelta}` : `${planDelta}`
    
    // We count only sites that either have active batches or have non-zero total stock.
    const activeSitesCount = allSites.filter(v => (v.batches?.length || 0) > 0 || v.stock_total > 0).length
    const totalSiteCount = activeSitesCount

    const pendingCount = (item as any).stock_pending || 0

    const fetchPending = async () => {
        if (pendingCount > 0 && pendingRequests.length === 0) {
            setIsLoadingPending(true)
            try {
                const result = await getPendingRequestsByItemId(item.id)
                if (result.success && result.data) setPendingRequests(result.data)
            } finally {
                setIsLoadingPending(false)
            }
        }
    }

    const fetchActiveLoans = useCallback(async () => {
        const allIds = item.variants?.flatMap(v => v.ids) || [item.id]
        if (allIds.length > 0 && activeLoans.length === 0) {
            setIsLoadingActiveLoans(true)
            try {
                const result = await getActiveLoansByIds(allIds)
                if (result.success && result.data) setActiveLoans(result.data)
            } finally {
                setIsLoadingActiveLoans(false)
            }
        }
    }, [item.variants, item.id, activeLoans.length])

    const stockStatus = getStockDisplay(item)
    const isProblematic = stockStatus.label === 'OUT OF STOCK' || stockStatus.label === 'LOW STOCK'
    const expiry = getExpiryInfo((item as any).expiry_date, (item as any).expiry_alert_days)
    const isBulkCategory = item.item_type === 'consumable' || (item.category || '').toLowerCase().includes('medical')
    const packaging = (item as any).packaging_json
    const showBulkDisplay = isBulkCategory && packaging?.enabled && packaging?.batches?.length > 0
    const containerCount = packaging?.batches?.length || 0
    const containerTypePlural = pluralizeContainerType(packaging?.containerType, { uppercase: true, fallback: 'UNIT' })

    const expiryDateText = (item as any).expiry_date
        ? new Date((item as any).expiry_date).toLocaleDateString('en-PH', {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
        })
        : 'Not set'

    // Prefetch dispensed/loan rows for consumables so badge details are ready
    // before the user opens the popover.
    useEffect(() => {
        if (isBulkCategory && activeLoans.length === 0) {
            fetchActiveLoans()
        }
    }, [isBulkCategory, activeLoans.length, fetchActiveLoans])

    const handleRestockBatch = async (batchId: string, qty: number) => {
        const result = await restockInventoryAction(item.id, qty, batchId)
        if (result.success) {
            toast.success(`Restocked ${qty} units to the container`)
            onRefresh?.()
        } else {
            toast.error(result.message || 'Failed to restock container')
        }
    }

    return (
        <>
            <TableRow 
                ref={rowRef} 
                onClick={() => isDistributed && setIsDetailsOpen(!isDetailsOpen)} 
                className={cn(
                    "hover:bg-gray-50/50 group transition-all duration-200 border-b border-gray-100 odd:bg-gray-50/20 animate-in fade-in slide-in-from-bottom-2", 
                    isHighlighted && "animate-highlight-pulse border-l-[4px] z-10", 
                    isDistributed && "cursor-pointer",
                    !isHighlighted && expiry.rowStripeClass,
                )} 
                style={{ animationDelay: `${index * 30}ms`, animationFillMode: 'backwards' }}
            >
                {showCheckbox && (
                    <TableCell className="pl-3 14in:pl-4 pr-2 py-5 w-12">
                        <input type="checkbox" checked={isSelected} onChange={onSelect} onClick={(e) => e.stopPropagation()} className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500" />
                    </TableCell>
                )}
                <TableCell className="pl-3 14in:pl-4 pr-2 py-5">
                    <div className="flex items-center gap-3">
                        <TacticalAssetImage 
                            url={item.image_url} 
                            alt={item.item_name}
                            size="md"
                            className="rounded-lg shadow-sm"
                        />
                        <div className="flex flex-col min-w-0">
                            <span className="text-[14px] 14in:text-[15px] font-black text-gray-950 truncate leading-tight tracking-tight mb-1">{item.item_name}</span>
                            <div className="flex items-center gap-1.5 ml-0.5">
                                {(() => {
                                    const CategoryIcon = getCategoryIcon(item.category)
                                    return <CategoryIcon className="h-3.5 w-3.5 text-gray-400" strokeWidth={2.5} />
                                })()}
                                 <span className="text-[12px] font-bold text-gray-500 truncate max-w-[120px] uppercase tracking-wide">{item.category}</span>
                             </div>
                        </div>
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5">
                    <div className="flex flex-col gap-0.5">
                        <div className="flex items-center gap-1.5 group/loc">
                             <div className="h-6 w-6 rounded-lg bg-gray-50 flex items-center justify-center border border-gray-100 group-hover/loc:border-gray-900 transition-all">
                                <Warehouse className="h-3.5 w-3.5 text-gray-400 group-hover/loc:text-gray-900 transition-colors" />
                             </div>
                             <div className="flex flex-col min-w-0">
                                <span className="text-[13px] font-bold text-gray-800 leading-none truncate uppercase tracking-tight">
                                    {resolveLocationName(item.primary_location || item.storage_location).replace(/_/g, ' ')}
                                </span>
                             </div>
                        </div>
                        
                        {isDistributed && (
                            <div className="flex items-center gap-2 mt-2 ml-1">
                                <div className="h-1.5 w-1.5 rounded-full bg-gray-950" />
                                <span className="text-[9px] font-black text-gray-950 uppercase tracking-[0.15em]">
                                    Found in {totalSiteCount} locations
                                </span>
                            </div>
                        )}
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5">
                    <div className="flex flex-col">
                        <span className="text-[13px] font-bold text-gray-800 leading-none">
                            {isBulkCategory ? expiryDateText : ''}
                        </span>
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5 w-[180px]" onClick={(e) => e.stopPropagation()}>
                    <div className="flex flex-col gap-2">
                        <CompositeStockBar 
                            item={item} 
                            pendingCount={pendingCount} 
                            pendingRequests={pendingRequests} 
                            isLoadingPending={isLoadingPending} 
                            isInternalOpen={isInternalOpen} 
                            setIsInternalOpen={setIsInternalOpen} 
                            fetchPending={fetchPending}
                            activeLoans={activeLoans}
                            isLoadingActiveLoans={isLoadingActiveLoans}
                            isBorrowedPopoverOpen={isBorrowedPopoverOpen}
                            setIsBorrowedPopoverOpen={setIsBorrowedPopoverOpen}
                            fetchActiveLoans={fetchActiveLoans} 
                        />
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5 text-right w-[150px]" onClick={(e) => e.stopPropagation()}>
                    <div className="flex flex-col items-end gap-1">
                        <div className="flex items-center 14in:flex-col 14in:items-end gap-2 14in:gap-1">
                            <UnifiedStatusHub 
                                item={item} 
                                expiry={expiry} 
                                stockStatus={{ label: stockStatus.label, isProblematic }} 
                                className="shrink-0"
                            />
                            <span className="text-[18px] font-black text-gray-950 tabular-nums tracking-tighter">
                                {showBulkDisplay ? (
                                    <span className="flex items-baseline gap-1">
                                        <span className="text-blue-600">{containerCount}</span>
                                        <span className="text-[14px] text-gray-400 font-bold">/</span>
                                        <span>{displayAvailable}</span>
                                    </span>
                                ) : displayAvailable}
                            </span>
                        </div>
                        <span className="text-[9px] font-black text-gray-400 uppercase tracking-[0.1em]">
                            {planStock > 0 
                                ? `${displayAvailable} IN STOCK / ${planStock} FIXED` 
                                : `IN STOCK / ${displayTotal} TOTAL`
                            }
                        </span>
                    </div>
                </TableCell>

                <TableCell className="pl-2 pr-3 14in:pr-4 py-5 text-right" onClick={(e) => e.stopPropagation()}>
                    <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-all duration-200">

                        <QRDialog item={item} />
                        <Button variant="ghost" size="icon" onClick={(e) => { e.stopPropagation(); onEdit?.(item); }} className="h-8 w-8 rounded-md text-slate-400 hover:text-gray-900 hover:bg-gray-100" title="Edit Item"><Edit2 className="h-3.5 w-3.5" /></Button>
                        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-md text-slate-400 hover:text-rose-600 hover:bg-rose-50" onClick={(e) => { e.stopPropagation(); onDelete(item.id, item.item_name); }} disabled={isDeleting} title="Delete Item">
                            {isDeleting ? (
                                <Loader2 className="h-3.5 w-3.5 animate-spin text-rose-600" />
                            ) : (
                                <Trash2 className="h-3.5 w-3.5" />
                            )}
                        </Button>
                    </div>
                </TableCell>
            </TableRow>
            
            {/* 🏛️ DISTRIBUTION LEDGER: Expanded View for Multi-Site Scrutiny */}
            {isDistributed && isDetailsOpen && (
                <TableRow className="bg-white border-b border-gray-100 animate-in slide-in-from-top-1 duration-200">
                    <TableCell colSpan={showCheckbox ? 6 : 5} className="p-0">
                        <div className="py-8 px-12 14in:px-16 flex flex-col gap-8 bg-gray-50/20">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-4">
                                    <div className="h-10 w-10 rounded-xl bg-white border border-gray-200 shadow-sm flex items-center justify-center">
                                        <Warehouse className="h-5 w-5 text-gray-900" />
                                    </div>
                                    <div className="flex flex-col">
                                        <h4 className="text-[16px] font-black text-gray-950 leading-tight tracking-tight">Site Distribution</h4>
                                        <p className="text-[11px] font-bold text-gray-500 uppercase tracking-[0.15em]">Found in {totalSiteCount} locations</p>
                                    </div>
                                </div>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                                {/* Primary Record Site Card */}
                                <SiteDistributionCard 
                                    itemId={item.id}
                                    variant={primaryVariant}
                                    isMain={true}
                                    showBulkDisplay={showBulkDisplay}
                                    containerCount={containerCount}
                                    containerTypePlural={containerTypePlural}
                                    resolveLocationName={resolveLocationName}
                                    onRestockBatch={handleRestockBatch}
                                />

                                {/* Satellite Site Cards */}
                                {satelliteVariants.map((v, idx) => (
                                    <SiteDistributionCard 
                                        key={`${v.id}-${idx}`}
                                        itemId={item.id}
                                        variant={v}
                                        showBulkDisplay={showBulkDisplay}
                                        containerCount={containerCount}
                                        containerTypePlural={containerTypePlural}
                                        resolveLocationName={resolveLocationName}
                                        onRestockBatch={handleRestockBatch}
                                    />
                                ))}
                            </div>
                        </div>
                    </TableCell>
                </TableRow>
            )}
        </>
    )
}
