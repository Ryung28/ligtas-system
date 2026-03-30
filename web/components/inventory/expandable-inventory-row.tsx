'use client'

import { useState } from 'react'
import Image from 'next/image'
import { TableCell, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
    Edit2, Trash2, Maximize2, Package, Clock, ChevronDown, User, Calendar, AlertTriangle
} from 'lucide-react'
import { InventoryItem } from '@/lib/supabase'
import { InventoryItemDialog } from './inventory-dialog'
import { QRDialog } from './qr-dialog'
import { EditableStorageLocation } from './editable-storage-location'
import { getPendingRequestsByItemId, type PendingRequest } from '@/src/features/transactions'
import { formatDistanceToNow } from 'date-fns'
import { 
    Popover,
    PopoverContent,
    PopoverTrigger,
} from "@/components/ui/popover"

interface ExpandableInventoryRowProps {
    item: InventoryItem
    index: number
    onDelete: (id: number, name: string) => void
    isDeleting: boolean
    onRefresh?: () => void
    onImageClick: (url: string, name: string) => void
    getCategoryIcon: (category: string) => any
    getStockDisplay: (item: InventoryItem) => { label: string }
    getConditionDot: (status: string) => { color: string; label: string }
    getStockPercentage: (available: number, total: number) => number
    isSelected?: boolean
    onSelect?: () => void
    showCheckbox?: boolean
}

export function ExpandableInventoryRow({
    item,
    index,
    onDelete,
    isDeleting,
    onRefresh,
    onImageClick,
    getCategoryIcon,
    getStockDisplay,
    getConditionDot,
    getStockPercentage,
    isSelected = false,
    onSelect,
    showCheckbox = false,
}: ExpandableInventoryRowProps) {
    const [isOpen, setIsOpen] = useState(false)
    const [pendingRequests, setPendingRequests] = useState<PendingRequest[]>([])
    const [isLoadingPending, setIsLoadingPending] = useState(false)

    const stock = getStockDisplay(item)
    const condition = getConditionDot(item.status)
    const CategoryIcon = getCategoryIcon(item.category)
    const stockPercentage = getStockPercentage(item.stock_available, item.stock_total)

    // Calculate pending count from inventory_availability view if available
    const pendingCount = (item as any).stock_pending || 0
    const hasPendingRequests = pendingCount > 0

    const getExpiryStatus = () => {
        const expiryDate = (item as any).expiry_date
        if (!expiryDate) return null
        const today = new Date()
        today.setHours(0, 0, 0, 0)
        const [year, month, day] = expiryDate.split('-').map(Number)
        const expiry = new Date(year, month - 1, day)
        expiry.setHours(0, 0, 0, 0)
        const daysUntilExpiry = Math.round((expiry.getTime() - today.getTime()) / (1000 * 60 * 60 * 24))
        if (daysUntilExpiry < 0) return { status: 'expired', days: Math.abs(daysUntilExpiry), color: 'bg-rose-50 border-rose-200 text-rose-700' }
        else if (daysUntilExpiry <= 7) return { status: 'critical', days: daysUntilExpiry, color: 'bg-red-50 border-red-200 text-red-700' }
        else if (daysUntilExpiry <= 30) return { status: 'warning', days: daysUntilExpiry, color: 'bg-amber-50 border-amber-200 text-amber-700' }
        else return { status: 'good', days: daysUntilExpiry, color: 'bg-emerald-50 border-emerald-200 text-emerald-700' }
    }
    const expiryStatus = getExpiryStatus()

    const fetchPending = async () => {
        if (hasPendingRequests && pendingRequests.length === 0) {
            setIsLoadingPending(true)
            try {
                const result = await getPendingRequestsByItemId(item.id)
                if (result.success && result.data) setPendingRequests(result.data)
            } finally {
                setIsLoadingPending(false)
            }
        }
    }

    return (
        <>
            <TableRow
                className="hover:bg-gray-50/50 group transition-all duration-200 border-b border-gray-100 odd:bg-gray-50/20 animate-in fade-in slide-in-from-bottom-2"
                style={{ animationDelay: `${index * 30}ms`, animationFillMode: 'backwards' }}
            >
                {showCheckbox && (
                    <TableCell className="pl-4 14in:pl-6 pr-3 py-5 w-12">
                        <input
                            type="checkbox"
                            checked={isSelected}
                            onChange={onSelect}
                            onClick={(e) => e.stopPropagation()}
                            className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                        />
                    </TableCell>
                )}
                <TableCell className="pl-4 14in:pl-6 pr-3 py-5">
                    <div className="flex items-center gap-3">
                        <div
                            className="h-14 w-14 rounded-lg bg-white border border-gray-200 overflow-hidden flex-shrink-0 flex items-center justify-center relative group/img cursor-pointer transition-all hover:border-gray-300 hover:shadow-sm"
                            onClick={() => item.image_url && onImageClick(item.image_url, item.item_name)}
                        >
                            {item.image_url ? (
                                <>
                                    <Image
                                        src={item.image_url}
                                        alt={item.item_name}
                                        fill
                                        unoptimized
                                        className="object-contain p-2"
                                    />
                                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover/img:opacity-100 transition-opacity flex items-center justify-center">
                                        <Maximize2 className="h-4 w-4 text-white" />
                                    </div>
                                </>
                            ) : (
                                <div className="absolute inset-0 bg-slate-50 flex items-center justify-center">
                                    <Package className="h-7 w-7 text-slate-200" strokeWidth={1} />
                                </div>
                            )}
                        </div>
                        <div className="flex flex-col min-w-0">
                            <span className="text-[15px] font-semibold text-gray-900 truncate leading-tight tracking-tight">{item.item_name}</span>
                            <div className="flex items-center gap-1.5 mt-1">
                                <CategoryIcon className="h-3 w-3 text-gray-400" />
                                <span className="text-[12px] text-gray-500 truncate font-medium">
                                    {item.category}
                                </span>
                            </div>
                        </div>
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5">
                    {item.storage_location ? (
                        <EditableStorageLocation
                            itemId={item.id}
                            itemName={item.item_name}
                            currentLocation={item.storage_location}
                            onUpdate={onRefresh}
                        />
                    ) : (
                        <span className="text-[13px] text-gray-400">—</span>
                    )}
                </TableCell>

                <TableCell className="px-3 py-5">
                    <div className="flex flex-wrap items-center gap-1.5 min-w-[140px]">
                        {/* PENDING REQUEST ALERT (Highest Action Priority) */}
                        {hasPendingRequests && (
                            <Popover open={isOpen} onOpenChange={(open) => {
                                setIsOpen(open)
                                if (open) fetchPending()
                            }}>
                                <PopoverTrigger asChild>
                                    <button
                                        className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[10px] font-bold bg-amber-50 border border-amber-200 text-amber-700 hover:bg-amber-100 transition-all duration-200 shadow-sm group/pending shrink-0"
                                    >
                                        <Clock className="h-3 w-3 text-amber-600" />
                                        {pendingCount} PENDING
                                        <ChevronDown className={`h-2.5 w-2.5 ml-0.5 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} />
                                    </button>
                                </PopoverTrigger>
                                <PopoverContent 
                                    side="bottom" 
                                    align="start" 
                                    className="w-[300px] p-0 rounded-xl overflow-hidden shadow-2xl border-amber-200 animate-in zoom-in-95 duration-200 z-[100]"
                                >
                                    <div className="flex items-center gap-2.5 px-4 py-3 bg-gradient-to-r from-amber-50 to-orange-50/50 border-b border-amber-100/60">
                                        <Clock className="h-3.5 w-3.5 text-amber-600" />
                                        <h4 className="text-xs font-bold text-amber-900 uppercase tracking-wide">Approval Queue</h4>
                                    </div>
                                    <div className="max-h-[250px] overflow-y-auto p-2 space-y-1">
                                        {isLoadingPending ? (
                                            <div className="flex items-center justify-center py-6 text-xs text-amber-700">
                                                <div className="h-4 w-4 animate-spin rounded-full border-2 border-amber-500 border-t-transparent mr-2" />
                                                Loading queue...
                                            </div>
                                        ) : pendingRequests.map((request) => (
                                            <div key={request.id} className="p-2.5 rounded-lg bg-white border border-amber-100/40 flex items-center justify-between">
                                                <div className="min-w-0">
                                                    <p className="text-[12px] font-bold text-gray-900 truncate">{request.borrower_name}</p>
                                                    <p className="text-[11px] text-gray-500 mt-0.5">{request.quantity} Units • {formatDistanceToNow(new Date(request.created_at), { addSuffix: true })}</p>
                                                </div>
                                                <Badge variant="outline" className="text-[9px] font-bold bg-amber-50 border-amber-200 text-amber-700">PENDING</Badge>
                                            </div>
                                        ))}
                                    </div>
                                </PopoverContent>
                            </Popover>
                        )}

                        {/* PHYSICAL STATUS ALERT (Reliability Hazard) */}
                        {item.status !== 'Good' && (
                            <Badge 
                                variant="outline" 
                                className="text-[10px] font-bold px-2 py-1 flex items-center gap-1 shadow-sm bg-rose-50 border-rose-200 text-rose-700 shrink-0"
                            >
                                <AlertTriangle className="h-3 w-3" />
                                {item.status.toUpperCase()}
                            </Badge>
                        )}

                        {/* STOCK SAFETY ALERT (Supply Hazard) */}
                        {stock.label !== 'IN STOCK' && (
                            <Badge 
                                variant="outline" 
                                className={`text-[10px] font-bold px-2 py-1 flex items-center gap-1 shadow-sm shrink-0 ${
                                    stock.label === 'OUT OF STOCK' 
                                        ? 'bg-rose-50 border-rose-200 text-rose-700' 
                                        : 'bg-amber-50 border-amber-200 text-amber-700'
                                }`}
                            >
                                <Package className="h-3 w-3" />
                                {stock.label}
                            </Badge>
                        )}

                        {/* EXPIRY COMPLIANCE ALERT (Compliance Risk) */}
                        {expiryStatus && (expiryStatus.status === 'expired' || expiryStatus.status === 'critical' || expiryStatus.status === 'warning') && (
                            <Badge 
                                variant="outline" 
                                className={`text-[10px] font-bold px-2 py-1 flex items-center gap-1 shadow-sm shrink-0 ${expiryStatus.color}`}
                            >
                                <Clock className="h-3 w-3" />
                                {expiryStatus.status === 'expired' ? 'EXPIRED' : `${expiryStatus.days}D REMAINING`}
                            </Badge>
                        )}

                        {/* ALL CLEAR - OPERATIONAL (Only shown if no hazards exist) */}
                        {!hasPendingRequests && 
                         item.status === 'Good' && 
                         stock.label === 'IN STOCK' && 
                         (!expiryStatus || (expiryStatus.status !== 'expired' && expiryStatus.status !== 'critical' && expiryStatus.status !== 'warning')) && (
                            <div className="flex items-center gap-1.5 text-[11px] text-gray-400 font-semibold ml-1">
                                <div className="h-1.5 w-1.5 rounded-full bg-emerald-400 shadow-[0_0_8px_rgba(52,211,153,0.4)]" />
                                Operational
                            </div>
                        )}
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5 text-right">
                    <div className="flex flex-col items-end gap-1">
                        <span className="text-[16px] font-semibold text-gray-900 tabular-nums leading-none tracking-tight">
                            {item.stock_available}
                        </span>
                        <span className="text-[12px] text-gray-500 leading-none">
                            of {item.stock_total} total
                        </span>
                        <div className="w-16 h-1 bg-gray-100 rounded-full overflow-hidden mt-0.5">
                            <div 
                                className={`h-full transition-all duration-500 ${
                                    stockPercentage === 0 ? 'bg-rose-500' :
                                    stockPercentage < 50 ? 'bg-amber-500' :
                                    'bg-emerald-500'
                                }`}
                                style={{ width: `${stockPercentage}%` }}
                            />
                        </div>
                        {(item as any).active_borrows?.length > 0 && (
                            <span className="text-[11px] text-blue-600 font-medium mt-0.5 cursor-pointer hover:underline leading-none">
                                {(item as any).active_borrows.length} borrowed
                            </span>
                        )}
                    </div>
                </TableCell>

                <TableCell className="pl-3 pr-4 14in:pr-6 py-5 text-right">
                    <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-all duration-200">
                        <div className="animate-in fade-in slide-in-from-right-2 duration-200" style={{ animationDelay: '50ms', animationFillMode: 'backwards' }}>
                            <QRDialog item={item} />
                        </div>
                        <div className="animate-in fade-in slide-in-from-right-2 duration-200" style={{ animationDelay: '100ms', animationFillMode: 'backwards' }}>
                            <InventoryItemDialog
                                existingItem={item}
                                onSuccess={onRefresh}
                                trigger={
                                    <Button variant="ghost" size="icon" className="h-8 w-8 rounded-md text-gray-400 hover:text-gray-900 hover:bg-gray-100 transition-colors">
                                        <Edit2 className="h-3.5 w-3.5" />
                                    </Button>
                                }
                            />
                        </div>
                        <div className="animate-in fade-in slide-in-from-right-2 duration-200" style={{ animationDelay: '150ms', animationFillMode: 'backwards' }}>
                            <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8 rounded-md text-gray-400 hover:text-gray-900 hover:bg-gray-100 transition-colors"
                                onClick={() => onDelete(item.id, item.item_name)}
                                disabled={isDeleting}
                            >
                                <Trash2 className="h-3.5 w-3.5" />
                            </Button>
                        </div>
                    </div>
                </TableCell>
            </TableRow>
        </>
    )
}
