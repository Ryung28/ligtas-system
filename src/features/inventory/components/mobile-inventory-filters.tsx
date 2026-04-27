'use client'

import React from 'react'
import { Search, SlidersHorizontal, MapPin, AlertCircle, Layers, ListFilter } from 'lucide-react'
import { cn } from '@/lib/utils'
import {
    Sheet,
    SheetContent,
    SheetHeader,
    SheetTitle,
    SheetTrigger,
} from "@/components/ui/sheet"
import { Badge } from "@/components/ui/badge"

interface MobileInventoryFiltersProps {
    searchQuery: string
    onSearchChange: (val: string) => void
    selectedCategory: string
    onCategoryChange: (val: string) => void
    categories: string[]
    selectedLocation: string
    onLocationChange: (val: string) => void
    locations: string[]
    selectedCondition: string
    onConditionChange: (val: string) => void
    isFlatMode: boolean
    onFlatModeToggle: (val: boolean) => void
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
    selectedCondition,
    onConditionChange,
    isFlatMode,
    onFlatModeToggle,
    showAlertsOnly,
    onAlertsToggle
}: MobileInventoryFiltersProps) {
    const activeFilterCount = [
        selectedCategory !== 'All',
        selectedLocation !== 'All',
        selectedCondition !== 'all',
        showAlertsOnly,
        isFlatMode
    ].filter(Boolean).length

    return (
        <div className="sticky top-[56px] bg-gray-50/95 backdrop-blur-md py-2 z-40 -mx-4 px-4 border-b border-gray-100 shadow-sm flex items-center gap-2">
            <div className="relative flex-1 group">
                <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
                    <Search className="w-5 h-5 text-gray-400 group-focus-within:text-red-500 transition-colors" />
                </div>
                <input 
                    type="text"
                    placeholder="Search inventory..."
                    value={searchQuery}
                    onChange={(e) => onSearchChange(e.target.value)}
                    className="w-full h-11 bg-white border border-gray-200 rounded-2xl pl-12 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-red-500/20 focus:border-red-500 transition-all shadow-sm"
                />
            </div>

            <Sheet>
                <SheetTrigger asChild>
                    <button className="relative p-3 bg-white border border-gray-200 rounded-2xl shadow-sm active:scale-95 transition-all">
                        <ListFilter className={cn("w-5 h-5", activeFilterCount > 0 ? "text-red-600" : "text-gray-500")} />
                        {activeFilterCount > 0 && (
                            <Badge className="absolute -top-1 -right-1 w-5 h-5 flex items-center justify-center p-0 bg-red-600 border-2 border-white text-[10px]">
                                {activeFilterCount}
                            </Badge>
                        )}
                    </button>
                </SheetTrigger>
                <SheetContent side="bottom" className="rounded-t-[32px] p-6 max-h-[85vh] overflow-y-auto outline-none border-t-0 shadow-2xl">
                    <SheetHeader className="pb-6 border-b border-gray-100">
                        <SheetTitle className="text-xl font-black tracking-tight text-gray-900 flex items-center gap-2">
                            <SlidersHorizontal className="w-5 h-5 text-red-600" />
                            TACTICAL FILTERS
                        </SheetTitle>
                    </SheetHeader>

                    <div className="py-6 space-y-8">
                        {/* VIEW MODE TOGGLE */}
                        <section className="space-y-3">
                            <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest px-1">Display Mode</h3>
                            <div className="grid grid-cols-2 gap-2">
                                <button 
                                    onClick={() => onFlatModeToggle(false)}
                                    className={cn(
                                        "flex items-center justify-center gap-2 h-12 rounded-2xl border-2 transition-all font-bold text-sm",
                                        !isFlatMode ? "bg-red-50 border-red-600 text-red-700 shadow-sm" : "bg-white border-gray-100 text-gray-500"
                                    )}
                                >
                                    <Layers className="w-4 h-4" />
                                    Grouped
                                </button>
                                <button 
                                    onClick={() => onFlatModeToggle(true)}
                                    className={cn(
                                        "flex items-center justify-center gap-2 h-12 rounded-2xl border-2 transition-all font-bold text-sm",
                                        isFlatMode ? "bg-red-50 border-red-600 text-red-700 shadow-sm" : "bg-white border-gray-100 text-gray-500"
                                    )}
                                >
                                    <ListFilter className="w-4 h-4" />
                                    List All
                                </button>
                            </div>
                            <p className="text-[10px] text-gray-400 px-1 italic">
                                {isFlatMode ? "Showing every individual unit row from database." : "Consolidating identical units into single Master SKU cards."}
                            </p>
                        </section>

                        {/* ALERTS TOGGLE */}
                        <section className="flex items-center justify-between p-4 bg-amber-50/50 rounded-2xl border border-amber-100">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-amber-100 rounded-xl">
                                    <AlertCircle className="w-5 h-5 text-amber-600" />
                                </div>
                                <div>
                                    <h3 className="text-sm font-bold text-amber-900">Critical Alerts</h3>
                                    <p className="text-[10px] text-amber-700 font-medium">Show low stock & damaged only</p>
                                </div>
                            </div>
                            <button
                                onClick={() => onAlertsToggle(!showAlertsOnly)}
                                className={cn(
                                    "w-12 h-6 rounded-full relative transition-all duration-300",
                                    showAlertsOnly ? "bg-amber-500" : "bg-gray-200"
                                )}
                            >
                                <div className={cn(
                                    "absolute top-1 w-4 h-4 bg-white rounded-full transition-all duration-300",
                                    showAlertsOnly ? "left-7" : "left-1"
                                )} />
                            </button>
                        </section>

                        {/* CONDITION FILTER */}
                        <section className="space-y-3">
                            <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest px-1">Condition</h3>
                            <div className="flex flex-wrap gap-2">
                                {[
                                    { id: 'all', label: 'All' },
                                    { id: 'Operational', label: 'Operational' },
                                    { id: 'Maintenance', label: 'Maintenance' },
                                    { id: 'Damaged', label: 'Damaged' },
                                    { id: 'Lost', label: 'Lost' }
                                ].map((cond) => (
                                    <button
                                        key={cond.id}
                                        onClick={() => onConditionChange(cond.id)}
                                        className={cn(
                                            "px-4 py-2 rounded-xl text-[11px] font-black transition-all border uppercase",
                                            selectedCondition === cond.id 
                                                ? "bg-blue-600 text-white border-blue-600 shadow-md" 
                                                : "bg-white text-gray-500 border-gray-100 hover:border-gray-200"
                                        )}
                                    >
                                        {cond.label}
                                    </button>
                                ))}
                            </div>
                        </section>

                        {/* LOCATION FILTER */}
                        <section className="space-y-3">
                            <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest px-1 flex items-center gap-1">
                                <MapPin className="w-3 h-3" /> Locations
                            </h3>
                            <div className="flex flex-wrap gap-2">
                                {locations.map((loc) => (
                                    <button
                                        key={loc}
                                        onClick={() => onLocationChange(loc)}
                                        className={cn(
                                            "px-4 py-2 rounded-xl text-[11px] font-black transition-all border uppercase",
                                            selectedLocation === loc 
                                                ? "bg-gray-900 text-white border-gray-900 shadow-md" 
                                                : "bg-white text-gray-600 border-gray-200"
                                        )}
                                    >
                                        {loc}
                                    </button>
                                ))}
                            </div>
                        </section>

                        {/* CATEGORY FILTER */}
                        <section className="space-y-3 pb-8">
                            <h3 className="text-xs font-black text-gray-400 uppercase tracking-widest px-1">Category</h3>
                            <div className="flex flex-wrap gap-2">
                                {categories.map((category) => (
                                    <button
                                        key={category}
                                        onClick={() => onCategoryChange(category)}
                                        className={cn(
                                            "px-4 py-2 rounded-xl text-[11px] font-black transition-all border uppercase",
                                            selectedCategory === category 
                                                ? "bg-red-600 text-white border-red-600 shadow-md" 
                                                : "bg-white text-gray-600 border-gray-200"
                                        )}
                                    >
                                        {category}
                                    </button>
                                ))}
                            </div>
                        </section>
                    </div>
                </SheetContent>
            </Sheet>
        </div>
    )
}
