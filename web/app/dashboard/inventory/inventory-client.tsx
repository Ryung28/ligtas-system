'use client'

import { useState, useTransition } from 'react'
import { toast } from 'sonner'
import { deleteItem } from '@/src/features/catalog'
import { InventoryHeader } from '@/components/inventory/inventory-header'
import { InventoryTable } from '@/components/inventory/inventory-table'
import { useInventory } from '@/hooks/use-inventory'
import { InventoryItem } from '@/lib/supabase'
import { InventoryDialogV2 } from '@/components/inventory/inventory-dialog-v2'
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog'

interface InventoryClientProps {
    initialInventory: InventoryItem[]
}

export function InventoryClient({ initialInventory }: InventoryClientProps) {
    const { inventory, refresh, isLoading, lastUpdated } = useInventory()
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [itemToDelete, setItemToDelete] = useState<{ id: number; name: string } | null>(null)
    const [selectedItems, setSelectedItems] = useState<number[]>([])
    const [selectionMode, setSelectionMode] = useState(false)
    const [activeItem, setActiveItem] = useState<InventoryItem | null | 'new'>(null)
    
    // Use server data during initial load, then switch to live data
    // 🏛️ DATA FLOW FIX: Stop redundant aggregation here. 
    // InventoryTable is the designated Master SKU Engine.
    const displayInventory = (isLoading && inventory.length === 0) ? initialInventory : inventory 
    

    const [isDeleting, startDeleteTransition] = useTransition()

    const handleDeleteClick = (id: number, name: string) => {
        setItemToDelete({ id, name })
        setDeleteDialogOpen(true)
    }

    const handleDeleteConfirm = async () => {
        if (!itemToDelete) return

        startDeleteTransition(async () => {
            try {
                const result = await deleteItem(itemToDelete.id)
                if (result.success) {
                    toast.success(result.message)
                    refresh()
                } else {
                    toast.error(result.error)
                }
            } catch (error) {
                toast.error('An unexpected error occurred while removing the item.')
            } finally {
                setDeleteDialogOpen(false)
                setItemToDelete(null)
            }
        })
    }

    const handleBulkDelete = async () => {
        if (selectedItems.length === 0) {
            toast.error('No items selected')
            return
        }

        startDeleteTransition(async () => {
            try {
                let successCount = 0
                let failCount = 0

                for (const id of selectedItems) {
                    const result = await deleteItem(id)
                    if (result.success) successCount++
                    else failCount++
                }

                if (successCount > 0) {
                    toast.success(`Successfully archived ${successCount} item(s)`)
                }
                if (failCount > 0) {
                    toast.error(`Failed to archive ${failCount} item(s)`)
                }

                setSelectedItems([])
                setSelectionMode(false)
                refresh()
            } catch (error) {
                toast.error('An unexpected error occurred during bulk delete.')
            }
        })
    }

    const toggleSelectionMode = () => {
        setSelectionMode(!selectionMode)
        setSelectedItems([])
    }

    return (
        <>
            <div className="space-y-4 animate-in fade-in duration-200 relative">
                <InventoryHeader
                    lastUpdated={lastUpdated}
                    isLoading={isLoading}
                    onRefresh={refresh}
                    items={displayInventory}
                    selectedCount={selectedItems.length}
                    onBulkDelete={handleBulkDelete}
                    selectionMode={selectionMode}
                    onToggleSelectionMode={toggleSelectionMode}
                    onAddItem={() => setActiveItem('new')}
                />

                <InventoryTable
                    items={displayInventory}
                    onDelete={handleDeleteClick}
                    isDeleting={isDeleting}
                    onRefresh={refresh}
                    selectedItems={selectedItems}
                    onSelectionChange={selectionMode ? setSelectedItems : undefined}
                    onEdit={(item) => setActiveItem(item)}
                    isLoading={isLoading}
                />
            </div>

            <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <AlertDialogContent className="rounded-2xl border-none shadow-2xl">
                    <AlertDialogHeader>
                        <AlertDialogTitle className="text-xl font-bold text-gray-900">
                            Archive Item?
                        </AlertDialogTitle>
                        <AlertDialogDescription className="text-sm text-gray-600">
                            Are you sure you want to archive <span className="font-semibold text-gray-900">&quot;{itemToDelete?.name}&quot;</span>? 
                            It will be removed from active service but kept in historical records.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel className="rounded-lg">Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDeleteConfirm}
                            className="rounded-lg bg-red-600 hover:bg-red-700 text-white"
                        >
                            Archive Item
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
            <InventoryDialogV2
                key={activeItem === 'new' ? 'new_asset' : activeItem?.id || 'idle'}
                isOpen={!!activeItem}
                existingItem={activeItem === 'new' ? undefined : activeItem || undefined}
                onOpenChange={(open: boolean) => !open && setActiveItem(null)}
                onSuccess={refresh}
            />
        </>
    )
}
