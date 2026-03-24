'use client'

import { useState, useEffect } from 'react'
import { TableCell, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
    Edit2, Trash2, Maximize2, Package, Clock, ChevronDown, ChevronUp, User, Calendar, Warehouse
} from 'lucide-react'
import { InventoryItem, STORAGE_LOCATION_LABELS } from '@/lib/supabase'
import { InventoryItemDialog } from './inventory-item-dialog'
import { QRDialog } from './qr-dialog'
import { getPendingRequestsByItemId, PendingRequest } from '@/app/actions/inventory'
import { formatDistanceToNow } from 'date-fns'

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
}: ExpandableInventoryRowProps) {
    const [isExpanded, setIsExpanded] = useState(false)
    const [pendingRequests, setPendingRequests] = useState<PendingRequest[]>([])
    const [isLoadingPending, setIsLoadingPending] = useState(false)

    const stock = getStockDisplay(item)
    const condition = getConditionDot(item.status)
    const CategoryIcon = getCategoryIcon(item.category)
    const stockPercentage = getStockPercentage(item.stock_available, item.stock_total)

    // Calculate pending count from inventory_availability view if available
    const pendingCount = (item as any).stock_pending || 0
    const hasPendingRequests = pendingCount > 0

    // Fetch pending requests when expanded
    useEffect(() => {
        if (isExpanded && hasPendingRequests && pendingRequests.length === 0) {
            setIsLoadingPending(true)
            getPendingRequestsByItemId(item.id)
                .then((result) => {
                    if (result.success && result.data) {
                        setPendingRequests(result.data)
                    }
                })
                .catch((error) => {
                    console.error('Failed to load pending requests:', error)
                })
                .finally(() => {
                    setIsLoadingPending(false)
                })
        }
    }, [isExpanded, item.id, hasPendingRequests, pendingRequests.length])

    return (
        <>
            <TableRow
                className="hover:bg-gray-50/50 group transition-all duration-200 border-b border-gray-100 odd:bg-gray-50/20 animate-in fade-in slide-in-from-bottom-2"
                style={{ animationDelay: `${index * 30}ms`, animationFillMode: 'backwards' }}
            >
                <TableCell className="pl-4 14in:pl-6 pr-3 py-5">
                    <div className="flex items-center gap-3">
                        <div
                            className="h-14 w-14 rounded-lg bg-white border border-gray-200 overflow-hidden flex-shrink-0 flex items-center justify-center relative group/img cursor-pointer transition-all hover:border-gray-300 hover:shadow-sm"
                            onClick={() => item.image_url && onImageClick(item.image_url, item.item_name)}
                        >
                            {item.image_url ? (
                                <>
                                    <img src={item.image_url} alt={item.item_name} className="w-full h-full object-contain p-2" />
                                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover/img:opacity-100 transition-opacity flex items-center justify-center">
                                        <Maximize2 className="h-4 w-4 text-white" />
                                    </div>
                                </>
                            ) : (
                                <Package className="h-6 w-6 text-gray-300" />
                            )}
                        </div>
                        <div className="flex flex-col min-w-0">
                            <span className="text-[15px] font-semibold text-gray-900 truncate leading-tight tracking-tight">{item.item_name}</span>
                            {item.description && (
                                <span className="text-[13px] text-gray-500 truncate max-w-[200px] mt-1 leading-tight">
                                    {item.description}
                                </span>
                            )}
                        </div>
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5">
                    <div className="flex items-center gap-2">
                        <div className="h-7 w-7 rounded-md bg-gray-50 flex items-center justify-center flex-shrink-0">
                            <CategoryIcon className="h-3.5 w-3.5 text-gray-500" />
                        </div>
                        <span className="text-[13px] font-medium text-gray-700">
                            {item.category}
                        </span>
                    </div>
                </TableCell>

                <TableCell className="px-3 py-5">
                    {item.storage_location ? (
                        <Badge 
                            variant="outline" 
                            className={`text-[11px] font-semibold whitespace-nowrap ${
                                item.storage_location === 'lower_warehouse' ? 'bg-blue-50 border-blue-200 text-blue-700' :
                                item.storage_location === '2nd_floor_warehouse' ? 'bg-purple-50 border-purple-200 text-purple-700' :
                                item.storage_location === 'office' ? 'bg-gray-50 border-gray-200 text-gray-700' :
                                'bg-green-50 border-green-200 text-green-700'
                            }`}
                        >
                            <Warehouse className="h-3 w-3 mr-1" />
                            {STORAGE_LOCATION_LABELS[item.storage_location]}
                        </Badge>
                    ) : (
                        <span className="text-[13px] text-gray-400">—</span>
                    )}
                </TableCell>

                <TableCell className="px-3 py-5">
                    {item.status !== 'Good' ? (
                        <div className="flex items-center gap-2">
                            <div className={`h-1.5 w-1.5 rounded-full ${condition.color}`} />
                            <span className="text-[13px] text-gray-600">{condition.label}</span>
                        </div>
                    ) : (
                        <span className="text-[13px] text-gray-400">—</span>
                    )}
                </TableCell>

                <TableCell className="px-3 py-5">
                    <div className="flex items-center gap-2">
                        {stock.label !== 'IN STOCK' ? (
                            <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-semibold whitespace-nowrap bg-white/80 backdrop-blur-sm shadow-sm ${
                                stock.label === 'OUT OF STOCK' 
                                    ? 'border border-rose-200/60 text-rose-700' 
                                    : 'border border-amber-200/60 text-amber-700'
                            }`}>
                                {stock.label}
                            </span>
                        ) : (
                            <span className="text-[13px] text-gray-400">—</span>
                        )}
                        
                        {hasPendingRequests && (
                            <button
                                onClick={() => setIsExpanded(!isExpanded)}
                                className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-semibold bg-amber-50 border border-amber-200/60 text-amber-700 hover:bg-amber-100 transition-all duration-200 shadow-sm hover:shadow-md active:scale-95"
                            >
                                <Clock className="h-3 w-3" />
                                {pendingCount} pending
                                {isExpanded ? (
                                    <ChevronUp className="h-3 w-3 ml-0.5" />
                                ) : (
                                    <ChevronDown className="h-3 w-3 ml-0.5" />
                                )}
                            </button>
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

            {/* Expanded Row - Pending Requests Detail */}
            {isExpanded && hasPendingRequests && (
                <TableRow className="bg-gradient-to-br from-amber-50/40 via-orange-50/20 to-amber-50/30 border-b border-amber-100/50 animate-in fade-in slide-in-from-top-2 duration-300">
                    <TableCell colSpan={7} className="px-4 14in:px-6 py-4">
                        <div className="relative overflow-hidden rounded-xl border border-amber-200/60 bg-white/80 backdrop-blur-sm shadow-[0_8px_16px_-8px_rgba(251,191,36,0.08)]">
                            {/* Header */}
                            <div className="flex items-center gap-2.5 px-4 py-3 bg-gradient-to-r from-amber-50 to-orange-50/50 border-b border-amber-100/60">
                                <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-amber-500 shadow-sm">
                                    <Clock className="h-3.5 w-3.5 text-white" />
                                </div>
                                <div>
                                    <h4 className="text-xs font-bold text-amber-900 uppercase tracking-wide">Pending Approval Queue</h4>
                                    <p className="text-[10px] text-amber-700 mt-0.5">
                                        {pendingCount} {pendingCount === 1 ? 'request' : 'requests'} awaiting authorization
                                    </p>
                                </div>
                            </div>

                            {/* Content */}
                            <div className="p-4">
                                {isLoadingPending ? (
                                    <div className="flex items-center justify-center py-6">
                                        <div className="h-5 w-5 animate-spin rounded-full border-2 border-amber-500 border-t-transparent" />
                                        <span className="ml-2 text-xs text-amber-700">Loading requests...</span>
                                    </div>
                                ) : pendingRequests.length === 0 ? (
                                    <div className="text-center py-6">
                                        <p className="text-xs text-amber-600">No pending requests found</p>
                                    </div>
                                ) : (
                                    <div className="space-y-2">
                                        {pendingRequests.map((request, idx) => (
                                            <div
                                                key={request.id}
                                                className="flex items-center justify-between p-3 rounded-lg bg-white border border-amber-100/60 hover:border-amber-200 hover:shadow-sm transition-all duration-200 animate-in fade-in slide-in-from-left-2"
                                                style={{
                                                    animationDelay: `${idx * 50}ms`,
                                                    animationFillMode: 'backwards',
                                                    borderTopLeftRadius: idx === 0 ? '0.75rem' : '0.5rem',
                                                    borderBottomRightRadius: idx === pendingRequests.length - 1 ? '0.75rem' : '0.5rem',
                                                }}
                                            >
                                                <div className="flex items-center gap-3 flex-1 min-w-0">
                                                    <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-gradient-to-br from-amber-100 to-orange-100 flex-shrink-0">
                                                        <User className="h-4 w-4 text-amber-700" />
                                                    </div>
                                                    <div className="flex-1 min-w-0">
                                                        <p className="text-sm font-semibold text-gray-900 truncate">
                                                            {request.borrower_name}
                                                        </p>
                                                        <div className="flex items-center gap-2 mt-0.5">
                                                            <span className="inline-flex items-center gap-1 text-[11px] text-amber-700 font-medium">
                                                                <Package className="h-3 w-3" />
                                                                {request.quantity} {request.quantity === 1 ? 'unit' : 'units'}
                                                            </span>
                                                            <span className="text-gray-300">•</span>
                                                            <span className="inline-flex items-center gap-1 text-[11px] text-gray-500">
                                                                <Calendar className="h-3 w-3" />
                                                                {formatDistanceToNow(new Date(request.created_at), { addSuffix: true })}
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <Badge
                                                    variant="outline"
                                                    className="ml-2 text-[10px] font-bold bg-amber-50 border-amber-300 text-amber-800 shadow-sm"
                                                >
                                                    PENDING
                                                </Badge>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </div>
                        </div>
                    </TableCell>
                </TableRow>
            )}
        </>
    )
}
