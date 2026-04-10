'use client'

import React, { useState, useMemo } from 'react'
import { useInventory } from '@/hooks/use-inventory'
import { InventoryCard } from '@/components/mobile/inventory-card'
import { Search, SlidersHorizontal, PackageX, Loader2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { GridSkeleton } from '@/components/mobile/skeletons/grid-skeleton'

import { MobileHeader } from '@/components/mobile/mobile-header'

/**
 * 📱 LIGTAS Mobile Inventory Browse
 * 🏛️ ARCHITECTURE: "The Field Explorer"
 * Provides rapid discovery and status auditing of all logistical assets.
 */
export default function MobileInventoryPage() {
    const { inventory, isLoading, error, refresh } = useInventory()
    const [searchQuery, setSearchQuery] = useState('')
    const [selectedCategory, setSelectedCategory] = useState('All')

    // 1. Extract Unique Categories
    const categories = useMemo(() => {
        const unique = new Set(inventory.map(item => item.category).filter(Boolean))
        return ['All', ...Array.from(unique)].sort()
    }, [inventory])

    // 2. Multi-Criteria Filtering Logic
    const filteredInventory = useMemo(() => {
        return inventory.filter(item => {
            const matchesSearch = item.item_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                                 item.category?.toLowerCase().includes(searchQuery.toLowerCase())
            const matchesCategory = selectedCategory === 'All' || item.category === selectedCategory
            return matchesSearch && matchesCategory
        })
    }, [inventory, searchQuery, selectedCategory])

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center p-12 text-center space-y-4">
                <div className="bg-red-50 p-4 rounded-full text-red-500">
                    <PackageX className="w-12 h-12" />
                </div>
                <h2 className="font-bold text-gray-900">Sync Failure</h2>
                <p className="text-sm text-gray-500">We couldn&apos;t reach the tactical ledger. Please check your connection.</p>
            </div>
        )
    }

    return (
        <div className="space-y-6 pb-12">
            <MobileHeader 
                title="Inventory" 
                onRefresh={() => refresh()} 
                isLoading={isLoading} 
            />
            {/* 🎯 Strategic Controls: Search & Category Filter */}
            <div className="sticky top-[56px] bg-gray-50/95 backdrop-blur-md pt-2 pb-4 z-40 space-y-4 -mx-4 px-4 border-b border-gray-100">
                <div className="relative group">
                    <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
                        <Search className="w-5 h-5 text-gray-400 group-focus-within:text-red-500 transition-colors" />
                    </div>
                    <input 
                        type="text"
                        placeholder="Search tactical inventory..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full h-12 bg-white border border-gray-200 rounded-2xl pl-12 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500 transition-all shadow-sm"
                    />
                </div>

                <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar -mx-4 px-4">
                    <div className="flex-shrink-0 p-2 bg-white border border-gray-200 rounded-xl">
                        <SlidersHorizontal className="w-4 h-4 text-gray-500" />
                    </div>
                    {categories.map((category) => (
                        <button
                            key={category}
                            onClick={() => setSelectedCategory(category)}
                            className={cn(
                                "flex-shrink-0 px-4 py-2 rounded-xl text-xs font-bold transition-all border",
                                selectedCategory === category 
                                    ? "bg-red-600 text-white border-red-600 shadow-md shadow-red-200" 
                                    : "bg-white text-gray-600 border-gray-200 hover:border-gray-300"
                            )}
                        >
                            {category}
                        </button>
                    ))}
                </div>
            </div>

            {/* 📦 Tactical Grid: The Asset List */}
            {isLoading ? (
                <GridSkeleton />
            ) : filteredInventory.length > 0 ? (
                <div className="grid grid-cols-2 gap-4">
                    {filteredInventory.map((item) => (
                        <InventoryCard key={item.id} item={item as any} />
                    ))}
                </div>
            ) : (
                <div className="flex flex-col items-center justify-center py-20 text-center">
                    <div className="w-16 h-16 bg-gray-100 rounded-3xl flex items-center justify-center mb-4">
                        <Search className="w-8 h-8 text-gray-300" />
                    </div>
                    <h3 className="font-bold text-gray-900">Zero Matches</h3>
                    <p className="text-sm text-gray-500">No assets found matching your criteria.</p>
                </div>
            )}
        </div>
    )
}
