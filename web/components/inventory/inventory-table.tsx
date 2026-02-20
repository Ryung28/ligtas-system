'use client'

import { useState, useMemo } from 'react'
import {
    Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import { Card, CardContent, CardHeader, CardFooter } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
    Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import { Search, Edit2, Trash2, AlertCircle, Package, ChevronLeft, ChevronRight, Maximize2 } from 'lucide-react'
import {
    Dialog as ShadinDialog,
    DialogContent as ShadinDialogContent,
    DialogHeader as ShadinDialogHeader,
    DialogTitle as ShadinDialogTitle
} from '@/components/ui/dialog'
import { InventoryItem } from '@/lib/supabase'
import { InventoryItemDialog } from './inventory-item-dialog'
import { QRDialog } from './qr-dialog'

interface InventoryTableProps {
    items: InventoryItem[]
    onDelete: (id: number, name: string) => void
    isDeleting: boolean
    onRefresh?: () => void
}

const ITEMS_PER_PAGE = 10

export function InventoryTable({ items, onDelete, isDeleting, onRefresh }: InventoryTableProps) {
    const [searchQuery, setSearchQuery] = useState('')
    const [statusFilter, setStatusFilter] = useState<'all' | 'low' | 'out' | 'good'>('all')
    const [conditionFilter, setConditionFilter] = useState<string>('all')
    const [currentPage, setCurrentPage] = useState(1)
    const [expandedImage, setExpandedImage] = useState<{ url: string, name: string } | null>(null)

    // Filter Items
    const filteredItems = useMemo(() => {
        return items.filter((item) => {
            const matchesSearch = item.item_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                item.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (item.description?.toLowerCase().includes(searchQuery.toLowerCase()) ?? false)

            let matchesFilter = true
            if (statusFilter === 'low') matchesFilter = item.stock_available > 0 && item.stock_available < 5
            if (statusFilter === 'out') matchesFilter = matchesFilter && item.stock_available === 0
            if (statusFilter === 'good') matchesFilter = matchesFilter && item.stock_available >= 5

            if (conditionFilter !== 'all') {
                matchesFilter = matchesFilter && item.status === conditionFilter
            }

            return matchesSearch && matchesFilter
        })
    }, [items, searchQuery, statusFilter, conditionFilter])

    // Paginate Items
    const totalPages = Math.ceil(filteredItems.length / ITEMS_PER_PAGE)
    const paginatedItems = useMemo(() => {
        const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
        return filteredItems.slice(startIndex, startIndex + ITEMS_PER_PAGE)
    }, [filteredItems, currentPage])

    // Reset page on filter change
    useMemo(() => {
        setCurrentPage(1)
    }, [searchQuery, statusFilter, conditionFilter])

    const getStockDisplay = (item: InventoryItem) => {
        if (item.stock_available === 0) return {
            label: 'Out of Stock',
            color: 'bg-red-50 text-red-700 ring-1 ring-red-600/10'
        }
        if (item.stock_available < 5) return {
            label: 'Low Stock',
            color: 'bg-amber-50 text-amber-700 ring-1 ring-amber-600/10'
        }
        return {
            label: 'In Stock',
            color: 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-600/10'
        }
    }

    const getConditionDot = (status: string) => {
        const s = (status || 'Good').toLowerCase()
        if (s.includes('damaged') || s.includes('repair')) return { color: 'bg-red-500', label: 'Needs Repair' }
        if (s.includes('maintenance')) return { color: 'bg-amber-500', label: 'Maintenance' }
        if (s.includes('lost')) return { color: 'bg-slate-400', label: 'Lost' }
        return { color: 'bg-emerald-500', label: 'Operational' }
    }

    return (
        <Card className="bg-white border border-gray-200/60 rounded-xl overflow-hidden flex flex-col shadow-sm">
            <CardHeader className="border-b border-gray-100 p-3 14in:p-4">
                <div className="flex flex-col md:flex-row gap-3 justify-between items-center">
                    <div className="flex items-center gap-3 w-full md:w-auto">
                        <h2 className="text-[13px] font-semibold text-gray-900">All Items</h2>
                        <span className="text-[11px] text-gray-400 font-medium">{filteredItems.length} results</span>
                    </div>

                    <div className="flex flex-wrap gap-2 w-full md:w-auto">
                        <div className="relative flex-1 md:w-64">
                            <Search className="absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-gray-400" />
                            <Input
                                placeholder="Search items..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-9 h-9 text-[13px] bg-white border-gray-200 rounded-lg focus-visible:ring-1 focus-visible:ring-gray-300 focus-visible:border-gray-300 placeholder:text-gray-400"
                            />
                        </div>

                        <Select value={conditionFilter} onValueChange={setConditionFilter}>
                            <SelectTrigger className="w-[140px] h-9 bg-white border-gray-200 rounded-lg text-[13px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                                <SelectValue placeholder="Condition" />
                            </SelectTrigger>
                            <SelectContent className="rounded-lg border-gray-200 shadow-lg p-1">
                                <SelectItem value="all" className="text-[13px] rounded-md">All Conditions</SelectItem>
                                <SelectItem value="Good" className="text-[13px] rounded-md">Operational</SelectItem>
                                <SelectItem value="Maintenance" className="text-[13px] rounded-md">Maintenance</SelectItem>
                                <SelectItem value="Damaged" className="text-[13px] rounded-md">Damaged</SelectItem>
                                <SelectItem value="Lost" className="text-[13px] rounded-md">Lost</SelectItem>
                            </SelectContent>
                        </Select>

                        <Select value={statusFilter} onValueChange={(v: any) => setStatusFilter(v)}>
                            <SelectTrigger className="w-[140px] h-9 bg-white border-gray-200 rounded-lg text-[13px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                                <SelectValue placeholder="Stock" />
                            </SelectTrigger>
                            <SelectContent className="rounded-lg border-gray-200 shadow-lg p-1">
                                <SelectItem value="all" className="text-[13px] rounded-md">All Stock</SelectItem>
                                <SelectItem value="good" className="text-[13px] rounded-md">In Stock</SelectItem>
                                <SelectItem value="low" className="text-[13px] rounded-md">Low Stock</SelectItem>
                                <SelectItem value="out" className="text-[13px] rounded-md">Out of Stock</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>
            </CardHeader>

            <CardContent className="p-0 flex-1">
                <div className="overflow-x-auto">
                    <Table>
                        <TableHeader>
                            <TableRow className="bg-gray-50/80 hover:bg-gray-50/80 border-b border-gray-100">
                                <TableHead className="pl-4 14in:pl-6 pr-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Item</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Category</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Condition</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-right">Stock</TableHead>
                                <TableHead className="px-3 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider">Status</TableHead>
                                <TableHead className="pl-3 pr-4 14in:pr-6 py-3 font-medium text-gray-500 text-[11px] uppercase tracking-wider text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {paginatedItems.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={6} className="h-72 text-center">
                                        <div className="flex flex-col items-center justify-center p-10">
                                            <div className="bg-gray-50 h-12 w-12 rounded-xl flex items-center justify-center mb-4">
                                                <Package className="h-6 w-6 text-gray-300" />
                                            </div>
                                            <p className="text-gray-900 font-semibold text-sm">No items found</p>
                                            <p className="text-[13px] text-gray-400 mt-1 max-w-[280px]">
                                                Try adjusting your search or filter criteria.
                                            </p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                paginatedItems.map((item) => {
                                    const stock = getStockDisplay(item)
                                    const condition = getConditionDot(item.status)
                                    return (
                                        <TableRow key={item.id} className="hover:bg-gray-50/60 group transition-colors border-b border-gray-100/80">
                                            <TableCell className="pl-4 14in:pl-6 pr-3 py-3">
                                                <div className="flex items-center gap-3">
                                                    <div
                                                        className="h-9 w-9 rounded-lg bg-gray-50 border border-gray-100 overflow-hidden flex-shrink-0 flex items-center justify-center relative group/img cursor-pointer transition-all hover:border-gray-200"
                                                        onClick={() => item.image_url && setExpandedImage({ url: item.image_url, name: item.item_name })}
                                                    >
                                                        {item.image_url ? (
                                                            <>
                                                                <img src={item.image_url} alt={item.item_name} className="w-full h-full object-contain p-1" />
                                                                <div className="absolute inset-0 bg-black/30 opacity-0 group-hover/img:opacity-100 transition-opacity flex items-center justify-center">
                                                                    <Maximize2 className="h-3 w-3 text-white" />
                                                                </div>
                                                            </>
                                                        ) : (
                                                            <Package className="h-4 w-4 text-gray-300" />
                                                        )}
                                                    </div>
                                                    <div className="flex flex-col min-w-0">
                                                        <div className="flex items-center gap-1.5">
                                                            {item.status !== 'Good' && <AlertCircle className="h-3 w-3 text-rose-500 flex-shrink-0" />}
                                                            <span className="text-[13px] font-semibold text-gray-900 truncate">{item.item_name}</span>
                                                        </div>
                                                        {item.description && (
                                                            <span className="text-[12px] text-gray-400 truncate max-w-[200px] mt-0.5">
                                                                {item.description}
                                                            </span>
                                                        )}
                                                    </div>
                                                </div>
                                            </TableCell>

                                            <TableCell className="px-3 py-3">
                                                <span className="text-[12px] font-medium text-gray-600">
                                                    {item.category}
                                                </span>
                                            </TableCell>

                                            <TableCell className="px-3 py-3">
                                                <div className="flex items-center gap-2">
                                                    <div className={`h-1.5 w-1.5 rounded-full ${condition.color}`} />
                                                    <span className="text-[12px] text-gray-600">{condition.label}</span>
                                                </div>
                                            </TableCell>

                                            <TableCell className="px-3 py-3 text-right">
                                                <div className="flex flex-col items-end">
                                                    <span className="text-[13px] font-semibold text-gray-900 tabular-nums">
                                                        {item.stock_available}
                                                        <span className="text-gray-400 font-normal"> / {item.stock_total}</span>
                                                    </span>
                                                    {(item as any).active_borrows?.length > 0 && (
                                                        <span className="text-[10px] text-blue-600 font-medium mt-0.5">
                                                            {(item as any).active_borrows.length} borrowed
                                                        </span>
                                                    )}
                                                </div>
                                            </TableCell>

                                            <TableCell className="px-3 py-3">
                                                <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium ${stock.color}`}>
                                                    {stock.label}
                                                </span>
                                            </TableCell>

                                            <TableCell className="pl-3 pr-4 14in:pr-6 py-3 text-right">
                                                <div className="flex items-center justify-end gap-1 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity duration-200">
                                                    <QRDialog item={item} />
                                                    <InventoryItemDialog
                                                        existingItem={item}
                                                        onSuccess={onRefresh}
                                                        trigger={
                                                            <Button variant="ghost" size="icon" className="h-8 w-8 rounded-md text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors">
                                                                <Edit2 className="h-3.5 w-3.5" />
                                                            </Button>
                                                        }
                                                    />
                                                    <Button
                                                        variant="ghost"
                                                        size="icon"
                                                        className="h-8 w-8 rounded-md text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                                                        onClick={() => onDelete(item.id, item.item_name)}
                                                        disabled={isDeleting}
                                                    >
                                                        <Trash2 className="h-3.5 w-3.5" />
                                                    </Button>
                                                </div>
                                            </TableCell>
                                        </TableRow>
                                    )
                                })
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>

            {totalPages > 1 && (
                <CardFooter className="border-t border-gray-100 bg-white px-4 14in:px-6 py-3 flex items-center justify-between">
                    <p className="text-[12px] text-gray-500">
                        Page <span className="font-semibold text-gray-900">{currentPage}</span> of <span className="font-semibold text-gray-900">{totalPages}</span>
                        <span className="text-gray-400 ml-2">·</span>
                        <span className="ml-2 text-gray-400">{filteredItems.length} items</span>
                    </p>
                    <div className="flex gap-1.5">
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                            disabled={currentPage === 1}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200 hover:bg-gray-50 text-gray-600"
                        >
                            <ChevronLeft className="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                            disabled={currentPage === totalPages}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200 hover:bg-gray-50 text-gray-600"
                        >
                            <ChevronRight className="h-4 w-4" />
                        </Button>
                    </div>
                </CardFooter>
            )}

            <ShadinDialog open={!!expandedImage} onOpenChange={(open) => !open && setExpandedImage(null)}>
                <ShadinDialogContent className="max-w-3xl border-none bg-black/95 p-0 overflow-hidden rounded-2xl shadow-2xl [&>button]:text-white [&>button]:opacity-100">
                    <ShadinDialogHeader className="absolute top-4 left-4 z-50 pointer-events-none">
                        <ShadinDialogTitle className="text-white text-sm font-medium bg-black/60 backdrop-blur-md px-3 py-1.5 rounded-lg">
                            {expandedImage?.name}
                        </ShadinDialogTitle>
                    </ShadinDialogHeader>
                    <div className="relative w-full aspect-square md:aspect-video flex items-center justify-center p-8">
                        {expandedImage && (
                            <img
                                src={expandedImage.url}
                                alt={expandedImage.name}
                                className="max-w-full max-h-full object-contain rounded-lg animate-in zoom-in-95 duration-300"
                            />
                        )}
                    </div>
                </ShadinDialogContent>
            </ShadinDialog>
        </Card>
    )
}
