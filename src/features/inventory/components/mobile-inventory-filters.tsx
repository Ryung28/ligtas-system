'use client'

import React from 'react'
import { Search, SlidersHorizontal, MapPin, AlertCircle } from 'lucide-react'
import { cn } from '@/lib/utils'

interface MobileInventoryFiltersProps {
    searchQuery: string
    onSearchChange: (val: string) => void
    selectedCategory: string
    onCategoryChange: (val: string) => void
    categories: string[]
    selectedLocation: string
    onLocationChange: (val: string) => void
    locations: string[]
    showAlertsOnly: boolean
    onAlertsToggle: (val: boolean) => void
}

export function MobileInventoryFilters({
    searchQuery,
    onSearchChange,
    selectedCategory,
    onCategoryChange,
    categories,
    selectedLocation,
    onLocationChange,
    locations,
    showAlertsOnly,
    onAlertsToggle
}: MobileInventoryFiltersProps) {
    return (
        <div className="sticky top-[56px] bg-gray-50/95 backdrop-blur-md pt-2 pb-4 z-40 space-y-4 -mx-4 px-4 border-b border-gray-100 shadow-sm">
            <div className="relative group">
                <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
                    <Search className="w-5 h-5 text-gray-400 group-focus-within:text-red-500 transition-colors" />
                </div>
                <input 
                    type="text"
                    placeholder="Search tactical inventory..."
                    value={searchQuery}
                    onChange={(e) => onSearchChange(e.target.value)}
                    className="w-full h-12 bg-white border border-gray-200 rounded-2xl pl-12 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500 transition-all shadow-sm"
                />
            </div>

            <div className="flex flex-col gap-3">
                <div className="flex items-center gap-2 overflow-x-auto no-scrollbar pb-1">
                    <button
                        onClick={() => onAlertsToggle(!showAlertsOnly)}
                        className={cn(
                            "flex-shrink-0 flex items-center gap-1.5 px-4 py-2 rounded-xl text-[11px] font-black transition-all border",
                            showAlertsOnly 
                                ? "bg-amber-100 text-amber-700 border-amber-200 shadow-sm" 
                                : "bg-white text-gray-600 border-gray-200"
                        )}
                    >
                        <AlertCircle className="w-3.5 h-3.5" />
                        {showAlertsOnly ? "ALERTS ACTIVE" : "ALL ASSETS"}
                    </button>

                    <div className="h-4 w-[1px] bg-gray-200 mx-1 shrink-0" />

                    {locations.map((loc) => (
                        <button
                            key={loc}
                            onClick={() => onLocationChange(loc)}
                            className={cn(
                                "flex-shrink-0 flex items-center gap-1.5 px-4 py-2 rounded-xl text-[11px] font-black transition-all border uppercase tracking-tighter",
                                selectedLocation === loc 
                                    ? "bg-gray-900 text-white border-gray-900" 
                                    : "bg-white text-gray-600 border-gray-200"
                                )}
                            >
                                <MapPin className="w-3 h-3 opacity-70" />
                                {loc}
                            </button>
                        ))}
                    </div>

                    <div className="flex items-center gap-2 overflow-x-auto no-scrollbar pb-1">
                        <div className="flex-shrink-0 p-2 bg-white border border-gray-200 rounded-xl">
                            <SlidersHorizontal className="w-4 h-4 text-gray-500" />
                        </div>
                        {categories.map((category) => (
                            <button
                                key={category}
                                onClick={() => onCategoryChange(category)}
                                className={cn(
                                    "flex-shrink-0 px-4 py-2 rounded-xl text-[11px] font-black transition-all border uppercase",
                                    selectedCategory === category 
                                        ? "bg-red-600 text-white border-red-600 shadow-sm" 
                                        : "bg-white text-gray-600 border-gray-200 hover:border-gray-300"
                                )}
                            >
                                {category}
                            </button>
                        ))}
                    </div>
                </div>
            </div>
    )
}
