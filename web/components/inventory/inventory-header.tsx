'use client'

import { Button } from '@/components/ui/button'
import { RefreshCw, Plus } from 'lucide-react'
import { BulkAddDialog } from './bulk-add-dialog'
import { InventoryItemDialog } from './inventory-item-dialog'

interface InventoryHeaderProps {
    lastUpdated: Date
    isLoading: boolean
    onRefresh: () => void
}

export function InventoryHeader({ lastUpdated, isLoading, onRefresh }: InventoryHeaderProps) {
    return (
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between bg-white/80 backdrop-blur-md p-3 14in:p-4 rounded-xl border border-gray-100 shadow-sm">
            <div>
                <h1 className="text-xl 14in:text-2xl font-bold text-gray-900 flex items-center gap-2 font-heading tracking-tight">
                    📦 Inventory Management
                </h1>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-[0.15em] mt-1" suppressHydrationWarning>
                    Last updated: {lastUpdated.toLocaleTimeString()}
                </p>
            </div>
            <div className="flex items-center gap-2">
                <Button
                    variant="outline"
                    size="sm"
                    onClick={onRefresh}
                    disabled={isLoading}
                    className="h-8 14in:h-9 text-[10px] 14in:text-xs uppercase tracking-wide font-medium bg-white border-slate-200 hover:bg-slate-50 transition-all active:scale-95"
                >
                    <RefreshCw className={`h-3 w-3 14in:h-3.5 14in:w-3.5 mr-1.5 ${isLoading ? 'animate-spin' : ''}`} />
                    Refresh
                </Button>
                <BulkAddDialog />
                <InventoryItemDialog
                    trigger={
                        <Button size="sm" className="h-8 14in:h-9 bg-blue-600 hover:bg-blue-700 text-white shadow-sm text-[10px] 14in:text-xs uppercase tracking-wide font-semibold transition-all active:scale-95">
                            <Plus className="h-3.5 w-3.5 mr-1" /> Add Item
                        </Button>
                    }
                />
            </div>
        </div>
    )
}
