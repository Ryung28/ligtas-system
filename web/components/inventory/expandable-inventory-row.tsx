'use client'

import { useState, useRef, useEffect } from 'react'
import { cn } from '@/lib/utils'
import Image from 'next/image'
import { TableCell, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Edit2, Trash2, Maximize2, Package, ChevronDown, Warehouse, ArrowRightLeft } from 'lucide-react'
import { InventoryItem, InventoryVariant } from '@/lib/supabase'
import { TacticalAssetImage } from '@/src/shared/ui/tactical-asset-image'
import { QRDialog } from './qr-dialog'
import { EditableStorageLocation } from './editable-storage-location'
import { getPendingRequestsByItemId, type PendingRequest } from '@/src/features/transactions'
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { rebalanceStockAction } from '@/actions/inventory-transfer'
import { getStorageLocations } from '@/app/actions/storage-locations'
import { toast } from 'sonner'
import { useStorageLocations } from '@/hooks/use-storage-locations'

// Sub-components
import { CompositeStockBar } from './_components/composite-stock-bar'

function SiteHealthFootnote({ variant }: { variant: InventoryVariant | undefined }) {
    if (!variant) return null
    const d = variant.qty_damaged ?? 0
    const m = variant.qty_maintenance ?? 0
    const l = variant.qty_lost ?? 0
    if (!d && !m && !l) {
        return (
            <p className="mt-3 text-[9px] font-bold uppercase tracking-widest text-emerald-700/90">
                All units serviceable at this site
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

    // 🏛️ SENIOR GEOGRAPHIC DETECTOR: Consolidated variants list (one row per physical site).
    const allSites = item.variants || []
    const primaryLocKey = ((item.primary_location || item.storage_location || '') as string).trim()
    const primaryVariant =
        allSites.find((v) => (v.location || '').trim() === primaryLocKey) ?? allSites[0]
    const satelliteVariants = allSites.filter((v) => (v.location || '').trim() !== primaryLocKey)
    const isDistributed = satelliteVariants.length > 0
    
    // Header represents the TRUE AGGREGATE of all unique sites.
    // Since InventoryTable now pre-calculates the sum for the group, we display it directly.
    const displayTotal = item.stock_total
    const displayAvailable = item.stock_available
    const totalSiteCount = allSites.length
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

    const stockStatus = getStockDisplay(item)
    const isProblematic = stockStatus.label === 'OUT OF STOCK' || stockStatus.label === 'LOW STOCK'

    return (
        <>
            <TableRow 
                ref={rowRef} 
                onClick={() => isDistributed && setIsDetailsOpen(!isDetailsOpen)} 
                className={cn(
                    "hover:bg-gray-50/50 group transition-all duration-200 border-b border-gray-100 odd:bg-gray-50/20 animate-in fade-in slide-in-from-bottom-2", 
                    isHighlighted && "animate-highlight-pulse border-l-[4px] z-10", 
                    isDistributed && "cursor-pointer"
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

                <TableCell className="px-3 py-5 text-right">
                    <div className="flex items-center justify-end gap-6 14in:gap-8">
                         {/* HEALTH MATRIX */}
                         <div className="flex flex-col gap-2 flex-1 max-w-[160px] 14in:max-w-[180px]">
                            <CompositeStockBar 
                                item={item} 
                                pendingCount={pendingCount} 
                                pendingRequests={pendingRequests} 
                                isLoadingPending={isLoadingPending} 
                                isInternalOpen={isInternalOpen} 
                                setIsInternalOpen={setIsInternalOpen} 
                                fetchPending={fetchPending} 
                            />
                         </div>

                         {/* STOCK CONTEXT */}
                         <div className="flex flex-col items-end gap-1 min-w-[80px] 14in:min-w-[90px]">
                              <div className="flex items-center gap-2">
                                 {isProblematic && (
                                     <Badge className={cn(
                                         "text-[8px] font-black tracking-tighter px-1 h-4",
                                         stockStatus.label === 'OUT OF STOCK' ? "bg-rose-500 text-white" : "bg-amber-500 text-white"
                                     )}>
                                         {stockStatus.label}
                                     </Badge>
                                 )}
                                 <span className="text-[18px] font-black text-gray-950 tabular-nums tracking-tighter">
                                     {displayAvailable}
                                 </span>
                              </div>
                              <span className="text-[9px] font-black text-gray-400 uppercase tracking-[0.1em]">
                                 IN STOCK / {displayTotal} TOTAL
                              </span>
                         </div>
                    </div>
                </TableCell>

                <TableCell className="pl-2 pr-3 14in:pr-4 py-5 text-right">
                    <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-all duration-200">

                        <QRDialog item={item} />
                        <Button variant="ghost" size="icon" onClick={(e) => { e.stopPropagation(); onEdit?.(item); }} className="h-8 w-8 rounded-md text-slate-400 hover:text-gray-900 hover:bg-gray-100"><Edit2 className="h-3.5 w-3.5" /></Button>
                        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-md text-slate-400 hover:text-rose-600 hover:bg-rose-50" onClick={(e) => { e.stopPropagation(); onDelete(item.id, item.item_name); }} disabled={isDeleting}><Trash2 className="h-3.5 w-3.5" /></Button>
                    </div>
                </TableCell>
            </TableRow>
            
            {/* 🏛️ DISTRIBUTION LEDGER: Expanded View for Multi-Site Scrutiny */}
            {isDistributed && isDetailsOpen && (
                <TableRow className="bg-white border-b border-gray-100 animate-in slide-in-from-top-1 duration-200">
                    <TableCell colSpan={showCheckbox ? 5 : 4} className="p-0">
                        <div className="py-8 px-12 14in:px-16 flex flex-col gap-8 bg-gray-50/20">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-4">
                                    <div className="h-10 w-10 rounded-xl bg-white border border-gray-200 shadow-sm flex items-center justify-center">
                                        <Warehouse className="h-5 w-5 text-gray-900" />
                                    </div>
                                    <div className="flex flex-col">
                                        <h4 className="text-[16px] font-black text-gray-950 leading-tight tracking-tight">Facility Distribution</h4>
                                        <p className="text-[11px] font-bold text-gray-500 uppercase tracking-[0.15em]">Shared across {totalSiteCount} active sites</p>
                                    </div>
                                </div>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                                {/* Primary Record Site Card */}
                                <div className="bg-white border border-gray-200 rounded-2xl p-5 shadow-[0_4px_12px_-2px_rgba(0,0,0,0.05)] hover:shadow-[0_12px_24px_-8px_rgba(0,0,0,0.1)] transition-all duration-300 group/site border-t-4 border-t-gray-900">
                                    <div className="flex justify-between items-start mb-4">
                                        <div className="flex items-center gap-2.5 min-w-0">
                                            <div className="h-5 w-5 rounded-lg bg-gray-900 flex items-center justify-center flex-shrink-0">
                                                <Warehouse className="h-3 w-3 text-white" />
                                            </div>
                                            <span className="text-[13px] font-bold text-gray-800 uppercase tracking-tight truncate">
                                                {resolveLocationName(item.primary_location || item.storage_location).replace(/_/g, ' ')}
                                            </span>
                                        </div>
                                        <Badge variant="outline" className="text-[8px] font-black bg-gray-50 text-gray-900 border-gray-200 uppercase px-2.5 h-5 flex-shrink-0 whitespace-nowrap tracking-widest">Main Location</Badge>
                                    </div>
                                    
                                    <div className="flex items-end justify-between">
                                        <div className="flex flex-col">
                                            <span className="text-[24px] font-black text-gray-950 tabular-nums tracking-tighter leading-none">
                                                {primaryVariant?.stock_available ?? 0}
                                            </span>
                                            <div className="flex items-center gap-1.5 mt-2">
                                                <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                                                    IN STOCK / {primaryVariant?.stock_total ?? 0} TOTAL
                                                </span>
                                            </div>
                                            <SiteHealthFootnote variant={primaryVariant} />
                                        </div>
                                    </div>
                                </div>

                                {/* Satellite Site Cards */}
                                {satelliteVariants.map((v) => (
                                    <div key={v.id} className="bg-white border border-gray-200 rounded-2xl p-5 shadow-[0_4px_12px_-2px_rgba(0,0,0,0.02)] hover:shadow-[0_12px_24px_-8px_rgba(0,0,0,0.1)] transition-all duration-300 group/site">
                                        <div className="flex justify-between items-start mb-4">
                                            <div className="flex items-center gap-2.5">
                                                <div className="h-5 w-5 rounded-lg bg-gray-50 flex items-center justify-center border border-gray-200">
                                                    <Package className="h-3 w-3 text-gray-400" />
                                                </div>
                                                <span className="text-[13px] font-bold text-gray-800 uppercase tracking-tight">
                                                    {resolveLocationName(v.location).replace(/_/g, ' ')}
                                                </span>
                                            </div>
                                        </div>
                                        
                                        <div className="flex items-end justify-between">
                                            <div className="flex flex-col">
                                                <span className="text-[24px] font-black text-gray-950 tabular-nums tracking-tighter leading-none">
                                                    {v.stock_available}
                                                </span>
                                                <div className="flex items-center gap-1.5 mt-2">
                                                    <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                                                        IN STOCK / {v.stock_total ?? 0} TOTAL
                                                    </span>
                                                </div>
                                                <SiteHealthFootnote variant={v} />
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </TableCell>
                </TableRow>
            )}
        </>
    )
}
