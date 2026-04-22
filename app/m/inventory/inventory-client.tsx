'use client'

import React, { useState, useMemo } from 'react'
import { useInventory } from '@/hooks/use-inventory'
import { Search, PackageX, Plus } from 'lucide-react'
import { cn } from '@/lib/utils'
import { GridSkeleton } from '@/components/mobile/skeletons/grid-skeleton'
import { MobileHeader } from '@/components/mobile/mobile-header'
import { useUser } from '@/providers/auth-provider'
import { roleCan, mFocus } from '@/lib/mobile/tokens'
import { InventoryFormSheet } from './inventory-form-sheet'

// Feature Components & Logic
import { aggregateInventory } from '@/src/features/inventory/utils'
import { useInventoryFilters } from '@/src/features/inventory/hooks/use-inventory-filters'
import { MobileInventoryFilters } from '@/src/features/inventory/components/mobile-inventory-filters'
import { MobileInventoryCard } from '@/src/features/inventory/components/mobile-inventory-card'

/**
 * 📦 InventoryClient
 * Encapsulated client-side logic for the tactical inventory view.
 */
export function InventoryClient() {
    const { inventory, isLoading, error, refresh } = useInventory()
    const { user } = useUser()
    const canManage = roleCan.manageInventory(user?.role)
    const [formOpen, setFormOpen] = useState(false)

    const aggregatedItems = useMemo(() => aggregateInventory(inventory), [inventory])
    const filter = useInventoryFilters(aggregatedItems, inventory)

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center p-12 text-center space-y-4">
                <div className="bg-red-50 p-4 rounded-full text-red-500"><PackageX className="w-12 h-12" /></div>
                <h2 className="font-bold text-gray-900">Sync Failure</h2>
                <p className="text-sm text-gray-500">Logistical ledger connection lost.</p>
            </div>
        )
    }

    return (
        <div className="space-y-6 pb-24 px-4 pt-4">
            <MobileHeader title="Inventory" onRefresh={refresh} isLoading={isLoading} />

            <MobileInventoryFilters 
                searchQuery={filter.searchQuery}
                onSearchChange={filter.setSearchQuery}
                selectedCategory={filter.selectedCategory}
                onCategoryChange={filter.setSelectedCategory}
                categories={filter.categories}
                selectedLocation={filter.selectedLocation}
                onLocationChange={filter.setSelectedLocation}
                locations={filter.locations}
                showAlertsOnly={filter.showAlertsOnly}
                onAlertsToggle={filter.setShowAlertsOnly}
            />

            {isLoading ? (
                <GridSkeleton />
            ) : filter.filteredItems.length > 0 ? (
                <div className="grid grid-cols-2 gap-4">
                    {filter.filteredItems.map(item => (
                        <MobileInventoryCard key={item.id} item={item} />
                    ))}
                </div>
            ) : (
                <div className="flex flex-col items-center justify-center py-24 text-center">
                    <Search className="w-12 h-12 text-gray-200 mb-4" />
                    <h3 className="font-bold text-gray-900">Zero Matches</h3>
                </div>
            )}

            {canManage && (
                <>
                    <button
                        onClick={() => setFormOpen(true)}
                        className={cn('fixed right-4 z-40 bottom-[calc(80px+env(safe-area-inset-bottom))] h-14 w-14 rounded-full bg-red-600 text-white shadow-xl', mFocus)}
                    >
                        <Plus className="w-6 h-6" />
                    </button>
                    <InventoryFormSheet open={formOpen} onOpenChange={setFormOpen} knownCategories={filter.categories.filter(c => c !== 'All')} onSuccess={refresh} />
                </>
            )}
        </div>
    )
}
