"use client"

import React, { useState, useMemo, useEffect, useCallback } from 'react'
import { useSearchParams } from 'next/navigation'
import { useInventory } from '@/hooks/use-inventory'
import { Search, PackageX, Plus } from 'lucide-react'
import { cn } from '@/lib/utils'
import { GridSkeleton } from '@/components/mobile/skeletons/grid-skeleton'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { useUser } from '@/providers/auth-provider'
import { roleCan, mFocus } from '@/lib/mobile/tokens'
import { InventoryFormSheet } from './inventory-form-sheet'

// Feature Components & Logic
import { getStorageLocations } from '@/app/actions/storage-locations'
import { aggregateInventory } from '@/src/features/inventory/utils'
import { useInventoryFilters } from '@/src/features/inventory/hooks/use-inventory-filters'
import { MobileInventoryFilters } from '@/src/features/inventory/components/mobile-inventory-filters'
import { MobileInventoryCard } from '@/src/features/inventory/components/mobile-inventory-card'
import { InventoryImagePreviewDialog } from '@/components/ui/inventory-image-preview-dialog'
import { ManagerCommandHub } from '@/src/features/inventory/components/manager-command-hub'
import { ManagerBatchActionBar } from '@/src/features/inventory/components/manager-batch-action-bar'
import { ManagerBatchReviewSheet } from '@/src/features/inventory/components/manager-batch-review-sheet'
import { BatchMode, BatchLine } from '@/src/features/inventory/types'
import { useInventoryIntents } from '@/src/features/inventory/hooks/use-inventory-intents'

import { toast } from 'sonner'

/**
 * 📦 InventoryClient
 * Encapsulated client-side logic for the tactical inventory view.
 */
export function InventoryClient() {
    const { inventory, isLoading, error, refresh } = useInventory()
    const { user } = useUser()
    const canManage = roleCan.manageInventory(user?.role)
    const [formOpen, setFormOpen] = useState(false)
    const [masterLocations, setMasterLocations] = useState<string[]>([])
    const [previewImage, setPreviewImage] = useState<{ url: string; name: string } | null>(null)

    // 🏗️ LOGISTICS BATCH STATE
    const [batchMode, setBatchMode] = useState<BatchMode>('none')
    const [selectedItems, setSelectedItems] = useState<BatchLine[]>([])
    const [reviewOpen, setReviewOpen] = useState(false)

    const searchParams = useSearchParams()
    const isFlatMode = searchParams.get('flat') === 'true'

    // 🛰️ INTENT SWITCHBOARD: Handle Direct Borrow from QR Scanner
    useInventoryIntents({
        inventory,
        isLoading,
        setBatchMode,
        setSelectedItems,
        setReviewOpen
    })

    const aggregatedItems = useMemo(() => {
        if (isFlatMode) {
            return inventory.map(item => ({
                ...item,
                variants: [{
                    id: item.id,
                    location: item.storage_location || 'unknown',
                    qty_good: item.qty_good,
                    qty_damaged: item.qty_damaged,
                    qty_maintenance: item.qty_maintenance,
                    qty_lost: item.qty_lost,
                    stock_available: item.stock_available,
                    stock_total: item.stock_total,
                    status: item.status,
                    ids: [item.id]
                }],
                is_multi_location: false,
                primary_location: item.storage_location || 'unknown'
            })) as unknown as AggregatedInventoryItem[]
        }
        return aggregateInventory(inventory)
    }, [inventory, isFlatMode])

    const filter = useInventoryFilters(aggregatedItems, inventory)

    // 🎯 MASTER DATA SYNC
    useEffect(() => {
        getStorageLocations().then(res => {
            if (res.success) {
                setMasterLocations(res.data.map((l: any) => l.location_name))
            }
        })
    }, [])

    // 🚀 PERFORMANCE OPTIMIZATION: Memoized selection set for O(1) lookup during render loop
    const selectedIds = useMemo(() => new Set(selectedItems.map(i => String(i.id))), [selectedItems])

    const handleImageClick = useCallback((url: string, name: string) => {
        setPreviewImage({ url, name })
    }, [])

    // 📋 BATCH LOGIC: Stable callback to prevent card re-renders
    const handleToggleSelection = useCallback((item: any) => {
        setSelectedItems(prev => {
            const isSelected = prev.some(i => i.id === item.id)
            
            if (!isSelected && (item.stock_available || 0) <= 0) {
                setTimeout(() => toast.error('Tactical Block', { 
                    description: `${item.item_name} has zero available stock.` 
                }), 0)
                return prev
            }

            if (isSelected) {
                return prev.filter(i => i.id !== item.id)
            }
            return [...prev, {
                id: item.id,
                item_name: item.item_name,
                quantity: 1,
                variant_id: item.variants?.[0]?.id || item.id,
                location: item.primary_location,
                item_type: item.item_type,
                image_url: item.image_url
            }]
        })
    }, [])

    const resetBatch = useCallback(() => {
        setBatchMode('none')
        setSelectedItems([])
        setReviewOpen(false)
        refresh()
    }, [refresh])

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center p-12 text-center space-y-4">
                <div className="bg-red-50 p-4 rounded-full text-red-500"><PackageX className="w-12 h-12" /></div>
                <h2 className="font-bold text-gray-900">Connection Error</h2>
                <p className="text-sm text-gray-500">We can't reach the gear list right now.</p>
            </div>
        )
    }

    return (
        <div className="space-y-6 pb-24">
            <MobileHeader title="Equipment" onRefresh={refresh} isLoading={isLoading} />

            <div className="px-4 space-y-6">
                <MobileInventoryFilters 
                    searchQuery={filter.searchQuery}
                    onSearchChange={filter.setSearchQuery}
                    selectedCategory={filter.selectedCategory}
                    onCategoryChange={filter.setSelectedCategory}
                    categories={filter.categories}
                    selectedLocation={filter.selectedLocation}
                    onLocationChange={filter.setSelectedLocation}
                    locations={masterLocations.length > 0 ? Array.from(new Set(['All', ...masterLocations])) : filter.locations}
                    selectedCondition={filter.selectedCondition}
                    onConditionChange={filter.setSelectedCondition}
                    isFlatMode={isFlatMode}
                    onFlatModeToggle={filter.setIsFlatMode}
                    showAlertsOnly={filter.showAlertsOnly}
                    onAlertsToggle={filter.setShowAlertsOnly}
                />

                {isLoading ? (
                    <GridSkeleton />
                ) : filter.filteredItems.length > 0 ? (
                    <div className="grid grid-cols-2 gap-4 pb-12">
                        {filter.filteredItems.map(item => (
                            <MobileInventoryCard 
                                key={item.id} 
                                item={item} 
                                onImageClick={handleImageClick}
                                selectionMode={batchMode !== 'none'}
                                isSelected={selectedIds.has(String(item.id))}
                                onSelect={handleToggleSelection}
                            />
                        ))}
                    </div>
                ) : (
                    <div className="flex flex-col items-center justify-center py-24 text-center">
                        <Search className="w-12 h-12 text-gray-200 mb-4" />
                        <h3 className="font-bold text-gray-900">Nothing Found</h3>
                    </div>
                )}
            </div>

            {/* 🛡️ LOGISTICS COMMAND CENTER */}
            {canManage && (
                <>
                    <ManagerCommandHub 
                        mode={batchMode}
                        onModeChange={setBatchMode}
                        onAdd={() => setFormOpen(true)}
                    />

                    {batchMode !== 'none' && (
                        <ManagerBatchActionBar 
                            count={selectedItems.length}
                            mode={batchMode}
                            onCancel={() => {
                                setBatchMode('none')
                                setSelectedItems([])
                            }}
                            onClear={() => setSelectedItems([])}
                            onReview={() => setReviewOpen(true)}
                        />
                    )}

                    <ManagerBatchReviewSheet 
                        open={reviewOpen}
                        onOpenChange={setReviewOpen}
                        mode={batchMode}
                        items={selectedItems}
                        onComplete={resetBatch}
                        onImagePreview={handleImageClick}
                    />

                    <InventoryFormSheet
                        open={formOpen}
                        onOpenChange={setFormOpen}
                        knownCategories={filter.categories.filter(c => c !== 'All')}
                        knownLocations={Array.from(new Set([
                            ...(masterLocations.length > 0 ? masterLocations : []),
                            ...filter.locations.filter((l) => l !== 'All')
                        ]))}
                        onSuccess={refresh}
                    />
                </>
            )}

            <InventoryImagePreviewDialog 
                image={previewImage}
                onOpenChange={(open) => !open && setPreviewImage(null)}
            />
        </div>
    )
}
