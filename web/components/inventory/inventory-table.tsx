'use client'

import { useState, useMemo, useEffect } from 'react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { useSearchParams } from 'next/navigation'
import { Card, CardContent, CardHeader, CardFooter } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
    Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import { Search, Edit2, Trash2, AlertCircle, Package, ChevronLeft, ChevronRight, Maximize2, Wrench, Cross, Shield, Box, Warehouse, Plus } from 'lucide-react'
import { InventoryItem, STORAGE_LOCATION_LABELS, StorageLocation } from '@/lib/supabase'
import { isLowStock, getStockStatusLabel } from '@/lib/inventory-utils'
import { QRDialog } from './qr-dialog'
import { FilterTabs } from '@/components/ui/filter-tabs'
import { ExpandableInventoryRow } from './expandable-inventory-row'
import { CategoryManager } from './advanced-query-builder'
import { InventoryImagePreviewDialog } from '@/components/ui/inventory-image-preview-dialog'
import { useStorageLocations } from '@/hooks/use-storage-locations'

interface InventoryTableProps {
    items: InventoryItem[]
    onDelete: (id: number, name: string) => void
    isDeleting: boolean
    onRefresh?: () => void
    selectedItems?: number[]
    onSelectionChange?: (selected: number[]) => void
    onEdit?: (item: InventoryItem) => void
    isLoading?: boolean
}

interface AggregatedInventoryItem extends InventoryItem {
    variants: any[] 
    primary_location?: string
    primary_stock_available?: number
    primary_stock_total?: number
    is_multi_location?: boolean
}

const ITEMS_PER_PAGE = 10

export function InventoryTable({ items, onDelete, isDeleting, onRefresh, selectedItems = [], onSelectionChange, onEdit, isLoading }: InventoryTableProps) {
    const { locations: registryLocations } = useStorageLocations()
    const [searchQuery, setSearchQuery] = useState('')
    const [categoryFilter, setCategoryFilter] = useState<string>('all')
    const [conditionFilter, setConditionFilter] = useState<string>('all')
    const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'low_stock' | 'out_of_stock'>('all')
    const [locationFilter, setLocationFilter] = useState<string>('all')
    const [currentPage, setCurrentPage] = useState(1)
    const [expandedImage, setExpandedImage] = useState<{ url: string, name: string } | null>(null)
    const [localCategories, setLocalCategories] = useState<string[]>([])
    const [highlightId, setHighlightId] = useState<number | null>(null)
    const [triageItem, setTriageItem] = useState<InventoryItem | null>(null)
    const searchParams = useSearchParams()
    const triageId = searchParams.get('id')

    // 🛡️ ATOMIC RESOLUTION ENGINE: Listen for Deep-Links
    useEffect(() => {
        const id = searchParams.get('id')
        const search = searchParams.get('search')
        const status = searchParams.get('status')

        if (status) {
            setStatusFilter(status as any)
        }

        if (id) {
            setSearchQuery('') 
            setHighlightId(parseInt(id))
            
            // 🏎️ EXTENDED SEARCH: Check variants and aggregated groups
            const item = items.find(i => 
                i.id.toString() === id || 
                (i as any).parent_id?.toString() === id
            )
            
            if (item) {
                setTriageItem(item)
            } else if (search) {
                // TACTICAL FALLBACK: If ID doesn't match a currently loaded item, use the search query
                setSearchQuery(search)
                setTriageItem(null)
            }
            
            // Auto-clear focus after 10s
            const timer = setTimeout(() => setHighlightId(null), 10000)
            return () => clearTimeout(timer)
        } else if (search) {
            setSearchQuery(search)
            setHighlightId(null)
            setTriageItem(null)
        } else {
            setHighlightId(null)
            setTriageItem(null)
        }
    }, [searchParams, items])

    const handleCategoryCreate = (name: string) => {
        if (!name) return
        const sanitized = name.trim()
        if (!localCategories.includes(sanitized)) {
            setLocalCategories(prev => [...prev, sanitized])
        }
    }

    const handleCategoryDelete = (name: string) => {
        setLocalCategories(prev => prev.filter(c => c !== name))
        // If the user was filtering by this category, reset the filter
        if (categoryFilter === name) {
            setCategoryFilter('all')
        }
    }

    // 🏎️ SINGLE-PASS SCANNER: Replaces 5 separate useMemo loops
    // Computes uniqueLocations, filterCounts, categoryTabs, and finalCategories in one O(n) pass
    const derivedData = useMemo(() => {
        const locations = new Set<string>()
        const categoryCounts: Record<string, number> = {}
        let pendingCount = 0
        const now = Date.now()

        for (const item of items) {
            // 1. Locations
            if (item.storage_location) locations.add(item.storage_location)

            // 2. Category counts
            const category = (item.category || 'Uncategorized').trim()
            categoryCounts[category] = (categoryCounts[category] || 0) + 1

            // 3. Pending/Alert count
            const hasPending = (item as any).stock_pending > 0
            const isLowStockItem = isLowStock(item)
            const hasHealthIssues = item.qty_damaged > 0 || item.qty_maintenance > 0 || item.qty_lost > 0
            const expiry = (item as any).expiry_date
            const isExpiring = expiry
                ? (new Date(expiry).getTime() - now) / (1000 * 60 * 60 * 24) <= 30
                : false

            if (hasPending || isLowStockItem || hasHealthIssues || isExpiring) pendingCount++
        }

        const sortedCategories = [...Object.keys(categoryCounts)]
            .concat(localCategories.filter(c => !categoryCounts[c]))
            .filter(Boolean)
            .sort((a, b) => a.localeCompare(b))

        const filterCounts: Record<string, number> = {
            all: items.length,
            pending: pendingCount,
            ...categoryCounts,
        }

        const filterTabs = [
            { value: 'all', label: 'All Items', count: items.length },
            { value: 'pending', label: 'Alerts', count: pendingCount, color: 'amber' },
            ...(statusFilter === 'low_stock' ? [{ value: 'low_stock', label: 'Low Stock', count: items.filter(i => isLowStock(i)).length, color: 'amber' as const }] : []),
            ...(statusFilter === 'out_of_stock' ? [{ value: 'out_of_stock', label: 'Out of Stock', count: items.filter(i => i.stock_available === 0).length, color: 'rose' as const }] : []),
        ]

        const categoryFilterTabs = [
            { value: 'all', label: 'All Categories', count: items.length },
            ...sortedCategories.map(cat => ({
                value: cat,
                label: cat,
                count: categoryCounts[cat] || 0,
            })),
        ]

        return {
            uniqueLocations: Array.from(locations).sort(),
            filterCounts,
            filterTabs,
            categoryFilterTabs,
            finalCategories: sortedCategories,
        }
    }, [items, localCategories, statusFilter])

    const { uniqueLocations, filterCounts, filterTabs, categoryFilterTabs, finalCategories } = derivedData

    // 🏎️ REGISTRY SYNC: Ensure all rooms (even empty ones) are visible in the filter
    const displayLocations = useMemo(() => {
        const registryNames = registryLocations.map(l => l.location_name)
        // Combine Registry + any existing strings on items not yet in Registry
        return Array.from(new Set([...registryNames, ...uniqueLocations])).sort()
    }, [registryLocations, uniqueLocations])

    // Filter Items
    const filteredItems = useMemo(() => {
        // 🎯 TARGETED RECORD ISOLATION: If we have an ID-lock, we suppress the global ledger
        if (triageItem) {
            return [triageItem]
        }

        const filtered = items.filter((item) => {
            const matchesSearch = item.item_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                item.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (item.description?.toLowerCase().includes(searchQuery.toLowerCase()) ?? false)

            let matchesCategory = true
            if (categoryFilter !== 'all') {
                matchesCategory = item.category === categoryFilter
            }

            let matchesCondition = true
            if (conditionFilter !== 'all') {
                if (conditionFilter === 'Good') matchesCondition = item.qty_good > 0
                else if (conditionFilter === 'Damaged') matchesCondition = item.qty_damaged > 0
                else if (conditionFilter === 'Maintenance') matchesCondition = item.qty_maintenance > 0
                else if (conditionFilter === 'Lost') matchesCondition = item.qty_lost > 0
            }

            let matchesStatus = true
            if (statusFilter === 'pending') {
                const hasPending = (item as any).stock_pending > 0
                const isLowStockItem = isLowStock(item)
                const hasHealthIssues = item.qty_damaged > 0 || item.qty_maintenance > 0 || item.qty_lost > 0
                
                let isExpiring = false
                const expiry = (item as any).expiry_date
                if (expiry) {
                    const diff = (new Date(expiry).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
                    isExpiring = diff <= 30
                }

                matchesStatus = hasPending || isLowStockItem || hasHealthIssues || isExpiring
            } else if (statusFilter === 'low_stock') {
                matchesStatus = isLowStock(item)
            } else if (statusFilter === 'out_of_stock') {
                matchesStatus = item.stock_available === 0
            }

            let matchesLocation = true
            if (locationFilter !== 'all') {
                matchesLocation = item.storage_location === locationFilter
            }

            return matchesSearch && matchesCategory && matchesCondition && matchesStatus && matchesLocation
        })

        // 🛡️ HOISTING ENGINE: Move highlighted item to the absolute top
        if (highlightId) {
            const highlightIndex = filtered.findIndex(i => i.id === highlightId)
            if (highlightIndex > -1) {
                const [item] = filtered.splice(highlightIndex, 1)
                return [item, ...filtered]
            }
        }

        return filtered
    }, [items, searchQuery, categoryFilter, conditionFilter, statusFilter, locationFilter, highlightId, triageItem])

    // 🏛️ SENIOR AGGREGATION ENGINE: Group by Name + Category to prevent Card Proliferation
    const aggregatedItems = useMemo(() => {
        const itemMap = new Map<string, AggregatedInventoryItem>()
        
        filteredItems.forEach(item => {
            const groupKey = `${item.item_name.toLowerCase().trim()}-${(item.category || '').toLowerCase().trim()}`
            const itemLocation = item.storage_location || 'unknown'
            
            if (!itemMap.has(groupKey)) {
                // Initialize Master SKU with neutral balances then add first record
                itemMap.set(groupKey, { 
                    ...item, 
                    // Reset balances to zero initially so we can sum them safely
                    stock_total: 0,
                    stock_available: 0,
                    qty_good: 0,
                    qty_damaged: 0,
                    qty_maintenance: 0,
                    qty_lost: 0,
                    variants: [], 
                    is_multi_location: false,
                    primary_location: itemLocation,
                } as any)
            }
            
            const group = itemMap.get(groupKey)!
            
            // 🏛️ ATOMIC REDUCTION: Sum Global SKU metadata
            group.stock_total += (item.stock_total || 0)
            group.stock_available += (item.stock_available || 0)
            group.qty_good += (item.qty_good || 0)
            group.qty_damaged += (item.qty_damaged || 0)
            group.qty_maintenance += (item.qty_maintenance || 0)
            group.qty_lost += (item.qty_lost || 0)

            // 🏛️ GEOGRAPHIC CONSOLIDATOR: Track unique sites
            const existingVariant = group.variants.find(v => v.location === itemLocation)
            
            if (existingVariant) {
                // MELD: Combine data if multiple rows exist for same location (edge case)
                existingVariant.stock_available += item.stock_available
                existingVariant.stock_total += item.stock_total
                existingVariant.qty_good += item.qty_good
                existingVariant.qty_damaged += item.qty_damaged
                existingVariant.qty_maintenance += item.qty_maintenance
                existingVariant.qty_lost += item.qty_lost
                existingVariant.ids.push(item.id)
            } else {
                // REGISTER: New physical site for this SKU
                if (group.variants.length > 0) group.is_multi_location = true
                group.variants.push({
                    id: item.id,
                    location: itemLocation,
                    location_id: (item as any).location_registry_id,
                    qty_good: item.qty_good,
                    qty_damaged: item.qty_damaged,
                    qty_maintenance: item.qty_maintenance,
                    qty_lost: item.qty_lost,
                    stock_available: item.stock_available,
                    stock_total: item.stock_total,
                    status: item.status,
                    ids: [item.id]
                })
            }
        })
        
        return Array.from(itemMap.values())
    }, [filteredItems])

    // Paginate Items
    const totalPages = Math.ceil(aggregatedItems.length / ITEMS_PER_PAGE)
    const paginatedItems = useMemo(() => {
        const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
        return aggregatedItems.slice(startIndex, startIndex + ITEMS_PER_PAGE)
    }, [aggregatedItems, currentPage])

    // Reset page on filter change
    useEffect(() => {
        setCurrentPage(1)
    }, [searchQuery, categoryFilter, conditionFilter, locationFilter, statusFilter])

    const handleSelectAll = () => {
        if (selectedItems.length === paginatedItems.length) {
            onSelectionChange?.([])
        } else {
            onSelectionChange?.(paginatedItems.map(item => item.id))
        }
    }

    const handleSelectItem = (id: number) => {
        if (selectedItems.includes(id)) {
            onSelectionChange?.(selectedItems.filter(itemId => itemId !== id))
        } else {
            onSelectionChange?.([...selectedItems, id])
        }
    }

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
        return { label: getStockStatusLabel(item) }
    }

    const getConditionDot = (status: string) => {
        const s = status.toLowerCase()
        if (s.includes('damaged') || s.includes('repair')) return { color: 'bg-rose-500', label: 'Needs Repair' }
        if (s.includes('maintenance')) return { color: 'bg-amber-500', label: 'In Maintenance' }
        if (s.includes('lost')) return { color: 'bg-slate-400', label: 'Missing' }
        return { color: 'bg-emerald-500', label: 'Operational' }
    }

    return (
        <Card className="bg-white border-none rounded-xl overflow-hidden flex flex-col shadow-sm">
            <CardHeader className="border-b border-gray-200 p-3 14in:p-4 bg-white">
                <div className="flex flex-col gap-4">
                    {/* Top Row: Title + Search + Condition Filter */}
                    <div className="flex flex-col md:flex-row gap-3 justify-between items-center">
                        <div className="flex flex-col gap-1">
                            <h2 className="text-base font-semibold text-gray-900">Inventory</h2>
                            <div className="flex items-center gap-2">
                                <span className="text-[12px] text-gray-500 font-medium">
                                    {filteredItems.length} results found
                                </span>
                            </div>
                        </div>

                        <div className="flex flex-wrap gap-2 w-full md:w-auto">
                            <div className="relative flex-1 md:w-64">
                                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
                                <Input
                                    placeholder="Search items..."
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    className="pl-10 h-10 text-[14px] bg-white border-gray-200 rounded-lg focus-visible:ring-2 focus-visible:ring-gray-900 focus-visible:border-gray-900 placeholder:text-gray-400"
                                />
                            </div>

                            <Select value={locationFilter} onValueChange={setLocationFilter}>
                                <SelectTrigger className="w-[180px] h-10 bg-white border-gray-200 rounded-lg text-[14px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                                    <SelectValue placeholder="Location" />
                                </SelectTrigger>
                                <SelectContent className="rounded-lg border-gray-200 shadow-lg p-1">
                                    <SelectItem value="all" className="text-[14px] rounded-md">All Locations</SelectItem>
                                    {displayLocations.map(location => (
                                        <SelectItem key={location} value={location} className="text-[14px] rounded-md">
                                            {STORAGE_LOCATION_LABELS[location as StorageLocation] || location}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>

                            <Select value={conditionFilter} onValueChange={setConditionFilter}>
                                <SelectTrigger className="w-[150px] h-10 bg-white border-gray-200 rounded-lg text-[14px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                                    <SelectValue placeholder="Condition" />
                                </SelectTrigger>
                                <SelectContent className="rounded-lg border-gray-200 shadow-lg p-1">
                                    <SelectItem value="all" className="text-[14px] rounded-md">All Conditions</SelectItem>
                                    <SelectItem value="Good" className="text-[14px] rounded-md">On Hand</SelectItem>
                                    <SelectItem value="Maintenance" className="text-[14px] rounded-md">Maintenance</SelectItem>
                                    <SelectItem value="Damaged" className="text-[14px] rounded-md">Damaged</SelectItem>
                                    <SelectItem value="Lost" className="text-[14px] rounded-md">Lost</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>

                    {/* Middle Row: View Filter (All vs Needs Action) + Advanced Query Engine */}
                    <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-3 border-b border-gray-100 pb-2">
                        <FilterTabs 
                            tabs={filterTabs}
                            activeTab={statusFilter}
                            onTabChange={(val) => setStatusFilter(val as any)}
                        />
                        
                        <CategoryManager 
                            onCategoryCreate={handleCategoryCreate}
                            onCategoryDelete={handleCategoryDelete}
                            allCategories={finalCategories}
                            items={items}
                        />
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
                                {onSelectionChange && (
                                    <TableHead className="pl-3 14in:pl-4 pr-2 py-4 w-12">
                                        <input
                                            type="checkbox"
                                            checked={selectedItems.length === paginatedItems.length && paginatedItems.length > 0}
                                            onChange={handleSelectAll}
                                            className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                                        />
                                    </TableHead>
                                )}
                                <TableHead className="pl-3 14in:pl-4 pr-2 py-4 font-black text-slate-500 text-[10px] uppercase tracking-[0.2em]">Item Name</TableHead>
                                <TableHead className="px-3 py-4 font-black text-slate-500 text-[10px] uppercase tracking-[0.2em]">Location</TableHead>
                                <TableHead className="px-3 py-4 font-black text-slate-500 text-[10px] uppercase tracking-[0.2em] text-right">Status / Condition</TableHead>
                                <TableHead className="pl-2 pr-3 14in:pr-4 py-4 font-black text-slate-500 text-[10px] uppercase tracking-[0.2em] text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {isLoading ? (
                                Array.from({ length: 5 }).map((_, i) => (
                                    <TableRow key={i} className="animate-pulse">
                                        <TableCell colSpan={6} className="p-4">
                                            <div className="h-12 bg-gray-100/30 rounded-xl" />
                                        </TableCell>
                                    </TableRow>
                                ))
                            ) : paginatedItems.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={6} className="h-96 text-center">
                                        <div className="flex flex-col items-center justify-center p-12 animate-in fade-in duration-200">
                                            <div className="relative mb-6">
                                                <div className="absolute inset-0 bg-gradient-to-br from-blue-100 to-purple-100 rounded-full blur-2xl opacity-50" />
                                                <div className="relative bg-slate-50 h-20 w-20 rounded-2xl flex items-center justify-center border border-slate-100">
                                                    <Package className="h-10 w-10 text-slate-200" strokeWidth={1} />
                                                </div>
                                            </div>
                                            <p className="text-gray-900 font-semibold text-base mb-2">No items found</p>
                                            <p className="text-[14px] text-gray-500 mb-6 max-w-[320px]">
                                                Try adjusting your search or filter criteria, or add your first item to get started.
                                            </p>
                                            {onEdit && (
                                                <Button 
                                                    onClick={() => onEdit({} as any)}
                                                    size="sm" 
                                                    className="bg-gray-900 hover:bg-gray-800 text-white shadow-sm"
                                                >
                                                    <Plus className="h-3.5 w-3.5 mr-2" />
                                                    Add First Item
                                                </Button>
                                            )}
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                paginatedItems.map((item, index) => (
                                    <ExpandableInventoryRow
                                        key={item.id}
                                        item={item}
                                        index={index}
                                        onDelete={onDelete}
                                        isDeleting={isDeleting}
                                        onRefresh={onRefresh}
                                        onImageClick={(url, name) => setExpandedImage({ url, name })}
                                        getCategoryIcon={getCategoryIcon}
                                        getStockDisplay={getStockDisplay}
                                        getConditionDot={getConditionDot}
                                        getStockPercentage={getStockPercentage}
                                        isSelected={selectedItems.includes(item.id)}
                                        isHighlighted={highlightId === item.id}
                                        onSelect={() => handleSelectItem(item.id)}
                                        showCheckbox={!!onSelectionChange}
                                        onEdit={onEdit}
                                    />
                                ))
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>

            {totalPages > 1 && (
                <CardFooter className="border-t border-gray-200 bg-white px-3 14in:px-4 py-3 flex items-center justify-between">
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

            <InventoryImagePreviewDialog
                image={expandedImage}
                onOpenChange={(open) => !open && setExpandedImage(null)}
            />
        </Card>
    )
}
