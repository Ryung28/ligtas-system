'use client'

import { Button } from '@/components/ui/button'
import { Plus, ListPlus } from 'lucide-react'
import { BulkAddDialog } from './bulk-add-dialog'
import { InventoryItemDialog } from './inventory-item-dialog'

interface InventoryHeaderProps {
    lastUpdated: Date
    isLoading: boolean
    onRefresh: () => void
}

export function InventoryHeader({ lastUpdated, isLoading, onRefresh }: InventoryHeaderProps) {
    return (
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between bg-white border border-gray-200/60 p-3 14in:p-4 rounded-xl shadow-sm">
            <div>
                <h1 className="text-xl 14in:text-2xl font-bold tracking-tight text-gray-900 font-heading">
                    Inventory
                </h1>
            </div>
            <div className="flex items-center gap-2">
                <BulkAddDialog
                    onSuccess={onRefresh}
                    trigger={
                        <Button variant="outline" size="sm" className="h-9 border-gray-200 text-gray-700 hover:bg-gray-50 text-[13px] font-medium transition-colors rounded-lg px-3">
                            <ListPlus className="h-3.5 w-3.5 mr-1.5" />
                            Bulk Add
                        </Button>
                    }
                />
                <InventoryItemDialog
                    onSuccess={onRefresh}
                    trigger={
                        <Button size="sm" className="h-9 bg-gray-900 hover:bg-gray-800 text-white text-[13px] font-medium transition-colors rounded-lg px-3.5">
                            <Plus className="h-3.5 w-3.5 mr-1.5" />
                            Add Item
                        </Button>
                    }
                />
            </div>
        </div>
    )
}
