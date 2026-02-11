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
import { Search, Filter, Edit2, Trash2, AlertCircle, Package, ChevronLeft, ChevronRight, Activity, Maximize2 } from 'lucide-react'
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
}

const ITEMS_PER_PAGE = 10

const CATEGORY_STYLES: Record<string, string> = {
    'Rescue': 'bg-amber-500/10 text-amber-700 ring-1 ring-amber-500/20',
    'Medical': 'bg-rose-500/10 text-rose-700 ring-1 ring-rose-500/20',
    'Comms': 'bg-violet-500/10 text-violet-700 ring-1 ring-violet-500/20',
    'Vehicles': 'bg-teal-500/10 text-teal-700 ring-1 ring-teal-500/20',
    'Office': 'bg-slate-500/10 text-slate-700 ring-1 ring-slate-500/20',
    'Tools': 'bg-blue-500/10 text-blue-700 ring-1 ring-blue-500/20',
    'PPE': 'bg-orange-500/10 text-orange-700 ring-1 ring-orange-500/20',
    'Logistics': 'bg-indigo-500/10 text-indigo-700 ring-1 ring-indigo-500/20',
    'Default': 'bg-slate-500/10 text-slate-600 ring-1 ring-slate-500/20'
}

export function InventoryTable({ items, onDelete, isDeleting }: InventoryTableProps) {
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

    const getStatusBadge = (item: InventoryItem) => {
        if (item.stock_available === 0) return (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-rose-500/10 text-rose-700 ring-1 ring-rose-500/20">
                Out of Stock
            </span>
        )
        if (item.stock_available < 5) return (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-orange-500/10 text-orange-700 ring-1 ring-orange-500/20">
                Low Stock
            </span>
        )
        return (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-700 ring-1 ring-emerald-500/20">
                In Stock
            </span>
        )
    }

    const getConditionBadge = (status: string) => {
        const s = (status || 'Good').toLowerCase()
        if (s.includes('damaged') || s.includes('repair')) return (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-rose-500/10 text-rose-700 ring-1 ring-rose-500/20">
                Needs Repair
            </span>
        )
        if (s.includes('maintenance')) return (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-amber-500/10 text-amber-700 ring-1 ring-amber-500/20">
                Maintenance
            </span>
        )
        if (s.includes('lost')) return (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-slate-500/10 text-slate-700 ring-1 ring-slate-500/20">
                Lost
            </span>
        )
        return (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-blue-500/10 text-blue-700 ring-1 ring-blue-500/20">
                Operational
            </span>
        )
    }

    return (
        <Card className="bg-white/90 backdrop-blur-xl shadow-2xl shadow-slate-200/50 border-none rounded-[2rem] ring-1 ring-slate-100 overflow-hidden flex flex-col">
            <CardHeader className="bg-white/50 border-b border-slate-50 p-4 14in:p-5">
                <div className="flex flex-col md:flex-row gap-4 justify-between items-center">
                    <div className="flex items-center gap-3 w-full md:w-auto">
                        <h2 className="text-sm font-heading font-bold text-slate-900 uppercase tracking-wide">Inventory Registry</h2>
                        <Badge variant="secondary" className="bg-slate-50 text-slate-400 border-none font-bold text-[9px] uppercase tracking-widest px-2 py-0.5">{filteredItems.length} Assets</Badge>
                    </div>

                    <div className="flex flex-wrap gap-3 w-full md:w-auto">
                        {/* Search */}
                        <div className="relative flex-1 md:w-72">
                            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                            <Input
                                placeholder="Search by name, category..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-10 h-11 text-sm bg-slate-50/50 border-none rounded-xl focus-visible:ring-blue-500/20"
                            />
                        </div>

                        {/* Condition Filter */}
                        <Select value={conditionFilter} onValueChange={setConditionFilter}>
                            <SelectTrigger className="w-[160px] h-11 bg-slate-50/50 border-none rounded-xl text-[11px] font-bold uppercase tracking-wider text-slate-600">
                                <div className="flex items-center gap-2">
                                    <Activity className="h-3.5 w-3.5 text-blue-500" />
                                    <span className="truncate">
                                        {conditionFilter === 'all' ? 'All Conditions' : conditionFilter}
                                    </span>
                                </div>
                            </SelectTrigger>
                            <SelectContent className="rounded-xl border-slate-100 shadow-xl">
                                <SelectItem value="all" className="text-xs font-semibold">All Conditions</SelectItem>
                                <SelectItem value="Good" className="text-xs font-semibold">Operational</SelectItem>
                                <SelectItem value="Maintenance" className="text-xs font-semibold">Maintenance</SelectItem>
                                <SelectItem value="Damaged" className="text-xs font-semibold">Defective</SelectItem>
                                <SelectItem value="Lost" className="text-xs font-semibold">Lost</SelectItem>
                            </SelectContent>
                        </Select>

                        {/* Status Filter */}
                        <Select value={statusFilter} onValueChange={(v: any) => setStatusFilter(v)}>
                            <SelectTrigger className="w-[160px] h-11 bg-slate-50/50 border-none rounded-xl text-[11px] font-bold uppercase tracking-wider text-slate-600">
                                <div className="flex items-center gap-2">
                                    <Filter className="h-3.5 w-3.5 text-purple-500" />
                                    <span className="truncate">
                                        {statusFilter === 'all' ? 'All Status' :
                                            statusFilter === 'low' ? 'Low Stock' :
                                                statusFilter === 'out' ? 'Exhausted' : 'Good Stock'}
                                    </span>
                                </div>
                            </SelectTrigger>
                            <SelectContent className="rounded-xl border-slate-100 shadow-xl">
                                <SelectItem value="all" className="text-xs font-medium">All Items</SelectItem>
                                <SelectItem value="good" className="text-xs font-medium">In Stock</SelectItem>
                                <SelectItem value="low" className="text-xs font-medium">Low Stock</SelectItem>
                                <SelectItem value="out" className="text-xs font-medium">Exhausted</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>
            </CardHeader>

            <CardContent className="p-0 flex-1">
                <div className="overflow-x-auto min-h-[400px]">
                    <Table>
                        <TableHeader>
                            <TableRow className="bg-slate-50/30 hover:bg-slate-50/30 border-b border-slate-50">
                                <TableHead className="px-6 py-3 font-semibold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Asset Information</TableHead>
                                <TableHead className="py-3 font-semibold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Cluster</TableHead>
                                <TableHead className="py-3 font-semibold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Operational Status</TableHead>
                                <TableHead className="text-center py-3 font-semibold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Total</TableHead>
                                <TableHead className="text-center py-3 font-semibold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Available</TableHead>
                                <TableHead className="py-3 font-semibold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Stock Level</TableHead>
                                <TableHead className="text-right px-6 py-3 font-semibold text-slate-400 uppercase text-[9px] tracking-[0.15em]">Command</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {paginatedItems.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={7} className="h-80 text-center">
                                        <div className="flex flex-col items-center justify-center text-center p-10">
                                            <div className="bg-slate-50 h-20 w-20 rounded-[2rem] flex items-center justify-center mb-6 shadow-inner">
                                                <Package className="h-10 w-10 text-slate-200" />
                                            </div>
                                            <p className="text-slate-900 font-bold text-lg font-heading tracking-tight">Zero Results matching filters</p>
                                            <p className="text-sm text-slate-400 mt-2 max-w-xs mx-auto font-medium">
                                                Adjust your search parameters or cluster filters to locate specific inventory assets.
                                            </p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                paginatedItems.map((item) => (
                                    <TableRow key={item.id} className="hover:bg-slate-50/50 group transition-colors border-b border-slate-50">
                                        <TableCell className="px-6 py-4">
                                            <div className="flex flex-row items-center gap-4">
                                                <div
                                                    className="h-12 w-12 rounded-xl bg-slate-50 border border-slate-100 overflow-hidden flex-shrink-0 flex items-center justify-center relative group/img cursor-zoom-in transition-all hover:ring-2 hover:ring-blue-100"
                                                    onClick={() => item.image_url && setExpandedImage({ url: item.image_url, name: item.item_name })}
                                                >
                                                    {item.image_url ? (
                                                        <>
                                                            {/* eslint-disable-next-line @next/next/no-img-element */}
                                                            <img src={item.image_url} alt={item.item_name} className="w-full h-full object-contain p-1" />
                                                            <div className="absolute inset-0 bg-slate-900/40 opacity-0 group-hover/img:opacity-100 transition-opacity flex items-center justify-center">
                                                                <Maximize2 className="h-4 w-4 text-white" />
                                                            </div>
                                                        </>
                                                    ) : (
                                                        <Package className="h-5 w-5 text-slate-200" />
                                                    )}
                                                </div>
                                                <div className="flex flex-col">
                                                    <div className="flex items-center gap-2">
                                                        {item.status !== 'Good' && <AlertCircle className="h-3.5 w-3.5 text-rose-500" />}
                                                        <span className="font-heading font-semibold text-slate-900 tracking-tight text-sm 14in:text-base leading-tight">{item.item_name}</span>
                                                    </div>
                                                    {item.description && (
                                                        <span className="text-[10px] 14in:text-[11px] text-slate-500 font-medium mt-0.5 truncate max-w-[240px]">
                                                            {item.description}
                                                        </span>
                                                    )}
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell className="py-1.5 14in:py-2">
                                            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold ${CATEGORY_STYLES[item.category] || CATEGORY_STYLES['Default']}`}>
                                                {item.category}
                                            </span>
                                        </TableCell>
                                        <TableCell className="py-1.5 14in:py-2">{getConditionBadge(item.status)}</TableCell>
                                        <TableCell className="text-center py-1.5 14in:py-2 text-slate-600 text-xs 14in:text-sm font-medium">{item.stock_total}</TableCell>
                                        <TableCell className="text-center py-1.5 14in:py-2">
                                            <div className="flex flex-col items-center gap-0.5">
                                                <span className={`text-sm 14in:text-base font-heading font-semibold transition-all ${item.stock_available === 0 ? 'text-rose-600' : 'text-slate-900'}`}>
                                                    {item.stock_available}
                                                </span>
                                                {(item as any).active_borrows?.length > 0 && (
                                                    <div className="flex flex-col items-center">
                                                        <div className="flex -space-x-1.5 overflow-hidden mb-1">
                                                            {(item as any).active_borrows.slice(0, 3).map((b: any, i: number) => (
                                                                <div
                                                                    key={i}
                                                                    className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-blue-50 border-2 border-white text-[9px] font-bold text-blue-600 uppercase shadow-sm"
                                                                    title={`${b.name} (${b.quantity}x)`}
                                                                >
                                                                    {b.name.charAt(0)}
                                                                </div>
                                                            ))}
                                                            {(item as any).active_borrows.length > 3 && (
                                                                <div className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-slate-100 border-2 border-white text-[9px] font-bold text-slate-500 shadow-sm">
                                                                    +{(item as any).active_borrows.length - 3}
                                                                </div>
                                                            )}
                                                        </div>
                                                        <span className="text-[9px] text-slate-400 font-medium uppercase tracking-tight">
                                                            In Field
                                                        </span>
                                                    </div>
                                                )}
                                            </div>
                                        </TableCell>
                                        <TableCell className="py-2">{getStatusBadge(item)}</TableCell>
                                        <TableCell className="text-right px-6 py-2">
                                            <div className="flex items-center justify-end gap-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-all duration-300 transform sm:group-hover:translate-x-0 sm:translate-x-2">
                                                <QRDialog item={item} />
                                                <InventoryItemDialog
                                                    existingItem={item}
                                                    trigger={
                                                        <Button variant="ghost" size="icon" className="h-9 w-9 rounded-xl text-blue-600 hover:text-blue-700 hover:bg-blue-50 transition-colors">
                                                            <Edit2 className="h-4.5 w-4.5" />
                                                        </Button>
                                                    }
                                                />
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    className="h-9 w-9 rounded-xl text-rose-500 hover:text-rose-600 hover:bg-rose-50 transition-colors"
                                                    onClick={() => onDelete(item.id, item.item_name)}
                                                    disabled={isDeleting}
                                                >
                                                    <Trash2 className="h-4.5 w-4.5" />
                                                </Button>
                                            </div>
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>

            {/* Pagination Footer */}
            {totalPages > 1 && (
                <CardFooter className="bg-slate-50/50 border-t border-slate-50 p-4 flex items-center justify-between">
                    <div className="text-[11px] font-medium text-slate-400 uppercase tracking-widest">
                        Section <span className="text-slate-900 font-semibold">{currentPage}</span> of <span className="text-slate-900 font-semibold">{totalPages}</span>
                    </div>
                    <div className="flex gap-2">
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                            disabled={currentPage === 1}
                            className="h-9 w-9 rounded-xl border-slate-200 bg-white hover:bg-slate-50 text-slate-600 p-0"
                        >
                            <ChevronLeft className="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                            disabled={currentPage === totalPages}
                            className="h-9 w-9 rounded-xl border-slate-200 bg-white hover:bg-slate-50 text-slate-600 p-0"
                        >
                            <ChevronRight className="h-4 w-4" />
                        </Button>
                    </div>
                </CardFooter>
            )}

            {/* High-Fidelity Image Expansion Modal */}
            <ShadinDialog open={!!expandedImage} onOpenChange={(open) => !open && setExpandedImage(null)}>
                <ShadinDialogContent className="max-w-4xl border-none bg-black/95 p-0 overflow-hidden rounded-[2rem] shadow-2xl ring-1 ring-white/10">
                    <ShadinDialogHeader className="absolute top-6 left-6 z-50 pointer-events-none">
                        <ShadinDialogTitle className="text-white font-heading text-lg tracking-tight bg-black/50 backdrop-blur-md px-4 py-2 rounded-xl border border-white/10">
                            {expandedImage?.name}
                        </ShadinDialogTitle>
                    </ShadinDialogHeader>
                    <div className="relative w-full aspect-square md:aspect-video flex items-center justify-center p-8">
                        {expandedImage && (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img
                                src={expandedImage.url}
                                alt={expandedImage.name}
                                className="max-w-full max-h-full object-contain rounded-lg shadow-2xl animate-in zoom-in-95 duration-300"
                            />
                        )}
                    </div>
                </ShadinDialogContent>
            </ShadinDialog>
        </Card>
    )
}
