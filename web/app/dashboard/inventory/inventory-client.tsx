'use client'

import { useTransition } from 'react'
import { toast } from 'sonner'
import { deleteItem } from '@/app/actions/inventory'
import { InventoryHeader } from '@/components/inventory/inventory-header'
import { InventoryStats } from '@/components/inventory/inventory-stats'
import { InventoryTable } from '@/components/inventory/inventory-table'
import { useInventory } from '@/hooks/use-inventory'

export function InventoryClient() {
    const { inventory, refresh, isLoading, lastUpdated } = useInventory()
    const [isDeleting, startDeleteTransition] = useTransition()

    const handleDelete = async (id: number, name: string) => {
        if (!confirm(`Are you sure you want to archive "${name}"? It will be removed from active service but kept in historical records.`)) return

        startDeleteTransition(async () => {
            try {
                const result = await deleteItem(id)
                if (result.success) {
                    toast.success(result.message)
                    refresh()
                } else {
                    toast.error(result.error, {
                        className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
                    })
                }
            } catch (error) {
                toast.error('An unexpected error occurred while removing the item.', {
                    className: 'rounded-tl-none rounded-tr-2xl rounded-bl-2xl rounded-br-2xl bg-white border-red-200 text-red-900 shadow-[0_12px_24px_-12px_rgba(239,68,68,0.06)] ring-1 ring-red-50'
                })
            }
        })
    }

    return (
        <div className="space-y-4 animate-in fade-in duration-500 relative">
            <InventoryHeader
                lastUpdated={lastUpdated}
                isLoading={isLoading}
                onRefresh={refresh}
                items={inventory}
            />

            <InventoryStats items={inventory} />

            <InventoryTable
                items={inventory}
                onDelete={handleDelete}
                isDeleting={isDeleting}
                onRefresh={refresh}
            />
        </div>
    )
}
