'use client'

import { Button } from '@/components/ui/button'
import { Plus, ListPlus } from 'lucide-react'
import { BulkAddDialog } from './bulk-add-dialog'
import { InventoryItemDialog } from './inventory-item-dialog'
import { InventoryPrintCatalog } from './inventory-print-catalog'
import { InventoryItem } from '@/lib/supabase'

interface InventoryHeaderProps {
    lastUpdated: Date
    isLoading: boolean
    onRefresh: () => void
    items?: InventoryItem[]
}

export function InventoryHeader({ lastUpdated, isLoading, onRefresh, items = [] }: InventoryHeaderProps) {
    return (
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between bg-white/95 backdrop-blur-xl border border-zinc-200/60 p-3 14in:p-4 rounded-2xl shadow-[0_8px_40px_rgb(0,0,0,0.03),inset_0_1px_0_rgba(255,255,255,0.8)]">
            <div className="relative z-10">
                <div className="flex items-center gap-2 mb-1">
                    <div className="h-2 w-2 rounded-full bg-blue-500 animate-pulse" />
                </div>
                <h1 className="text-2xl 14in:text-3xl font-black tracking-tight text-slate-900 font-heading uppercase italic leading-none">
                    Inventory
                </h1>
            </div>
            <div className="flex items-center gap-2">
                <InventoryPrintCatalog items={items} />
                <BulkAddDialog
                    onSuccess={onRefresh}
                    trigger={
                        <Button variant="ghost" size="sm" className="h-9 text-gray-600 hover:text-gray-900 hover:bg-gray-100 text-[13px] font-medium transition-colors rounded-lg px-3">
                            <ListPlus className="h-4 w-4 mr-1.5" />
                            Bulk Add
                        </Button>
                    }
                />
                <InventoryItemDialog
                    onSuccess={onRefresh}
                    trigger={
                        <Button size="sm" className="h-9 bg-blue-600 hover:bg-blue-700 text-white text-[13px] font-semibold transition-all rounded-xl px-4 shadow-lg shadow-blue-600/20 hover:shadow-xl hover:shadow-blue-600/30 hover:-translate-y-0.5 active:scale-95">
                            <Plus className="h-4 w-4 mr-1.5" />
                            Add Item
                        </Button>
                    }
                />
            </div>
        </div>
    )
}
