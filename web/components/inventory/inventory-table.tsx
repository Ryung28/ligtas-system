'use client'

import { useState, useMemo, useEffect } from 'react'
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
import { Search, Edit2, Trash2, AlertCircle, Package, ChevronLeft, ChevronRight, Maximize2, Wrench, Cross, Shield, Box } from 'lucide-react'
import {
    Dialog as ShadinDialog,
    DialogContent as ShadinDialogContent,
    DialogHeader as ShadinDialogHeader,
    DialogTitle as ShadinDialogTitle
} from '@/components/ui/dialog'
import { InventoryItem } from '@/lib/supabase'
import { InventoryItemDialog } from './inventory-item-dialog'
import { QRDialog } from './qr-dialog'
import { FilterTabs } from '@/components/ui/filter-tabs'

interface InventoryTableProps {
    items: InventoryItem[]
    onDelete: (id: number, name: string) => void
    isDeleting: boolean
    onRefresh?: () => void
}

const ITEMS_PER_PAGE = 10

export function InventoryTable({ items, onDelete, isDeleting, onRefresh }: InventoryTableProps) {
    const [searchQuery, setSearchQuery] = useState('')
    const [categoryFilter, setCategoryFilter] = useState<string>('all')
    const [conditionFilter, setConditionFilter] = useState<string>('all')
    const [currentPage, setCurrentPage] = useState(1)
    const [expandedImage, setExpandedImage] = useState<{ url: string, name: string } | null>(null)

    // Calculate counts for category filter tabs
    const categoryCounts = useMemo(() => {
        const counts: Record<string, number> = { all: items.length }
        
        items.forEach(item => {
            const category = item.category || 'Uncategorized'
            counts[category] = (counts[category] || 0) + 1
        })
        
        return counts
    }, [items])

    const categoryFilterTabs = useMemo(() => {
        const tabs = [{ value: 'all', label: 'All', count: categoryCounts.all }]
        
        // Predefined categories to always show
        const predefinedCategories = ['Medical', 'Tools', 'Rescue', 'PPE', 'Logistics', 'Goods']
        
        // Get unique categories from items
        const uniqueCategories = Array.from(new Set(items.map(i => i.category || 'Uncategorized')))
        
        // Merge predefined with existing categories
        const allCategories = Array.from(new Set([...predefinedCategories, ...uniqueCategories]))
        
        allCategories.sort().forEach(category => {
            tabs.push({
                value: category,
                label: category,
                count: categoryCounts[category] || 0
            })
        })
        
        return tabs
    }, [items, categoryCounts])

    // Filter Items
    const filteredItems = useMemo(() => {
        return items.filter((item) => {
            const matchesSearch = item.item_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                item.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (item.description?.toLowerCase().includes(searchQuery.toLowerCase()) ?? false)

            let matchesCategory = true
            if (categoryFilter !== 'all') {
                matchesCategory = item.category === categoryFilter
            }

            let matchesCondition = true
            if (conditionFilter !== 'all') {
                matchesCondition = item.status === conditionFilter
            }

            return matchesSearch && matchesCategory && matchesCondition
        })
    }, [items, searchQuery, categoryFilter, conditionFilter])

    // Paginate Items
    const totalPages = Math.ceil(filteredItems.length / ITEMS_PER_PAGE)
    const paginatedItems = useMemo(() => {
        const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
        return filteredItems.slice(startIndex, startIndex + ITEMS_PER_PAGE)
    }, [filteredItems, currentPage])

    // Reset page on filter change
    useEffect(() => {
        setCurrentPage(1)
    }, [searchQuery, categoryFilter, conditionFilter])

    const getCategoryIcon = (category: string) => {
        const cat = category.toLowerCase()
        if (cat.includes('medical')) return Cross
        if (cat.includes('tool')) return Wrench
        if (cat.includes('rescue')) return Shield
        if (cat.includes('ppe')) return Shield
        return Box
    }

    const getStockPercentage = (available: number, total: number) => {
        return total > 0 ? (available / total) * 100 : 0
    }

    const getStockDisplay = (item: InventoryItem) => {
        if (item.stock_available === 0) return { label: 'OUT OF STOCK' }
        const lowStockThreshold = item.stock_total * 0.5
        if (item.stock_available < lowStockThreshold) return { label: 'LOW STOCK' }
        return { label: 'IN STOCK' }
    }

    const getConditionDot = (status: string) => {
        const s = (status || 'Good').toLowerCase()
        if (s.includes('damaged') || s.includes('repair')) return { color: 'bg-rose-500', label: 'Needs Repair' }
        if (s.includes('maintenance')) return { color: 'bg-amber-500', label: 'In Maintenance' }
        if (s.includes('lost')) return { color: 'bg-slate-400', label: 'Missing' }
        return { color: 'bg-emerald-500', label: 'Operational' }
    }

    return (
        <Card className="bg-white border-none rounded-xl overflow-hidden flex flex-col shadow-sm">
            <CardHeader className="border-b border-gray-200 p-4 14in:p-5 bg-white">
                <div className="flex flex-col gap-4">
                    {/* Top Row: Title + Search + Condition Filter */}
                    <div className="flex flex-col md:flex-row gap-3 justify-between items-center">
                        <div className="flex items-center gap-3">
                            <h2 className="text-base font-semibold text-gray-900">All Items</h2>
                            <span className="text-[12px] text-gray-500 font-medium">{filteredItems.length} results</span>
                        </div>

                        <div className="flex flex-wrap gap-2 w-full md:w-auto">
                            <div className="relative flex-1 md:w-72">
                                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
                                <Input
                                    placeholder="Search items..."
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    className="pl-10 h-10 text-[14px] bg-white border-gray-200 rounded-lg focus-visible:ring-2 focus-visible:ring-gray-900 focus-visible:border-gray-900 placeholder:text-gray-400"
                                />
                            </div>

                            <Select value={conditionFilter} onValueChange={setConditionFilter}>
                                <SelectTrigger className="w-[160px] h-10 bg-white border-gray-200 rounded-lg text-[14px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                                    <SelectValue placeholder="Condition" />
                                </SelectTrigger>
                                <SelectContent className="rounded-lg border-gray-200 shadow-lg p-1">
                                    <SelectItem value="all" className="text-[14px] rounded-md">All Conditions</SelectItem>
                                    <SelectItem value="Good" className="text-[14px] rounded-md">Operational</SelectItem>
                                    <SelectItem value="Maintenance" className="text-[14px] rounded-md">Maintenance</SelectItem>
                                    <SelectItem value="Damaged" className="text-[14px] rounded-md">Damaged</SelectItem>
                                    <SelectItem value="Lost" className="text-[14px] rounded-md">Lost</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                    
                    {/* Bottom Row: Category Filter Tabs */}
                    <FilterTabs 
                        tabs={categoryFilterTabs}
                        activeTab={categoryFilter}
                        onTabChange={setCategoryFilter}
                    />
                </div>
            </CardHeader>

            <CardContent className="p-0 flex-1">
                <div className="overflow-x-auto">
                    <Table>
                        <TableHeader>
                            <TableRow className="border-b border-gray-200 hover:bg-transparent">
                                <TableHead className="pl-4 14in:pl-6 pr-3 py-4 font-medium text-gray-500 text-[11px] uppercase tracking-wide">Item</TableHead>
                                <TableHead className="px-3 py-4 font-medium text-gray-500 text-[11px] uppercase tracking-wide">Category</TableHead>
                                <TableHead className="px-3 py-4 font-medium text-gray-500 text-[11px] uppercase tracking-wide">Condition</TableHead>
                                <TableHead className="px-3 py-4 font-medium text-gray-500 text-[11px] uppercase tracking-wide">Status</TableHead>
                                <TableHead className="px-3 py-4 font-medium text-gray-500 text-[11px] uppercase tracking-wide text-right">Stock</TableHead>
                                <TableHead className="pl-3 pr-4 14in:pr-6 py-4 font-medium text-gray-500 text-[11px] uppercase tracking-wide text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {paginatedItems.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={6} className="h-96 text-center">
                                        <div className="flex flex-col items-center justify-center p-12 animate-in fade-in duration-500">
                                            <div className="relative mb-6">
                                                <div className="absolute inset-0 bg-gradient-to-br from-blue-100 to-purple-100 rounded-full blur-2xl opacity-50" />
                                                <div className="relative bg-gradient-to-br from-gray-50 to-gray-100 h-20 w-20 rounded-2xl flex items-center justify-center shadow-lg">
                                                    <Package className="h-10 w-10 text-gray-400" />
                                                </div>
                                            </div>
                                            <p className="text-gray-900 font-semibold text-base mb-2">No items found</p>
                                            <p className="text-[14px] text-gray-500 mb-6 max-w-[320px]">
                                                Try adjusting your search or filter criteria, or add your first item to get started.
                                            </p>
                                            {onRefresh && (
                                                <Button 
                                                    onClick={onRefresh}
                                                    size="sm" 
                                                    className="bg-gray-900 hover:bg-gray-800 text-white shadow-sm"
                                                >
                                                    <Package className="h-3.5 w-3.5 mr-2" />
                                                    Add First Item
                                                </Button>
                                            )}
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                paginatedItems.map((item, index) => {
                                    const stock = getStockDisplay(item)
                                    const condition = getConditionDot(item.status)
                                    const CategoryIcon = getCategoryIcon(item.category)
                                    const stockPercentage = getStockPercentage(item.stock_available, item.stock_total)
                                    
                                    return (
                                        <TableRow 
                                            key={item.id} 
                                            className="hover:bg-gray-50/50 group transition-all duration-200 border-b border-gray-100 odd:bg-gray-50/20 animate-in fade-in slide-in-from-bottom-2"
                                            style={{ animationDelay: `${index * 30}ms`, animationFillMode: 'backwards' }}
                                        >
                                            <TableCell className="pl-4 14in:pl-6 pr-3 py-5">
                                                <div className="flex items-center gap-3">
                                                    <div
                                                        className="h-14 w-14 rounded-lg bg-white border border-gray-200 overflow-hidden flex-shrink-0 flex items-center justify-center relative group/img cursor-pointer transition-all hover:border-gray-300 hover:shadow-sm"
                                                        onClick={() => item.image_url && setExpandedImage({ url: item.image_url, name: item.item_name })}
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
                                            </TableCell>

                                            <TableCell className="px-3 py-5 text-right">
                                                <div className="flex flex-col items-end gap-1">
                                                    <span className="text-[16px] font-semibold text-gray-900 tabular-nums leading-none tracking-tight">
                                                        {item.stock_available}
                                                    </span>
                                                    <span className="text-[12px] text-gray-500 leading-none">
                                                        of {item.stock_total} total
                                                    </span>
                                                    {/* Progress bar */}
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
                                    )
                                })
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>

            {totalPages > 1 && (
                <CardFooter className="border-t border-gray-200 bg-white px-4 14in:px-6 py-3.5 flex items-center justify-between">
                    <div className="flex items-center gap-4">
                        <p className="text-[12px] text-gray-500">
                            Showing <span className="font-semibold text-gray-900">{((currentPage - 1) * ITEMS_PER_PAGE) + 1}</span> to <span className="font-semibold text-gray-900">{Math.min(currentPage * ITEMS_PER_PAGE, filteredItems.length)}</span> of <span className="font-semibold text-gray-900">{filteredItems.length}</span> items
                        </p>
                    </div>
                    <div className="flex items-center gap-2">
                        <span className="text-[12px] text-gray-500 mr-2">
                            Page {currentPage} of {totalPages}
                        </span>
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                            disabled={currentPage === 1}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200 hover:bg-gray-50 text-gray-600 disabled:opacity-30"
                        >
                            <ChevronLeft className="h-4 w-4" />
                        </Button>
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                            disabled={currentPage === totalPages}
                            className="h-8 w-8 p-0 rounded-lg border-gray-200 hover:bg-gray-50 text-gray-600 disabled:opacity-30"
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
