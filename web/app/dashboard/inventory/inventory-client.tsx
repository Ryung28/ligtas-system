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
        if (!confirm(`Are you sure you want to delete "${name}"? This cannot be undone.`)) return

        startDeleteTransition(async () => {
            try {
                const result = await deleteItem(id)
                if (result.success) {
                    toast.success(result.message)
                    refresh()
                } else {
                    toast.error(result.error)
                }
            } catch (error) {
                toast.error('An unexpected error occurred during tactical deletion.')
            }
        })
    }

    return (
        <div className="space-y-4 animate-in fade-in duration-500 relative">
            <InventoryHeader
                lastUpdated={lastUpdated}
                isLoading={isLoading}
                onRefresh={refresh}
            />

            <InventoryStats items={inventory} />

            <InventoryTable
                items={inventory}
                onDelete={handleDelete}
                isDeleting={isDeleting}
            />
        </div>
    )
}
