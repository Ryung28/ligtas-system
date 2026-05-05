'use client'

import { useState, useTransition } from 'react'
import { useRouter, useSearchParams, usePathname } from 'next/navigation'
import { toast } from 'sonner'
import { deleteItem, bulkDeleteItem } from '@/src/features/catalog'
import { InventoryHeader } from '@/components/inventory/inventory-header'
import { InventoryTable } from '@/components/inventory/inventory-table'
import { useInventory } from '@/hooks/use-inventory'
import { InventoryItem } from '@/lib/supabase'
import { CatalogItemDialog } from '@/src/features/catalog/components/catalog-item-dialog'
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
    const [deletingIds, setDeletingIds] = useState<number[]>([])
    
    const router = useRouter()
    const searchParams = useSearchParams()
    const pathname = usePathname()
    const activeStatus = searchParams.get('status')

    const handleStatusChange = (status: string | null) => {
        const params = new URLSearchParams(searchParams.toString())
        if (status) {
            params.set('status', status)
        } else {
            params.delete('status')
        }
        router.push(`${pathname}?${params.toString()}`)
    }
    
    // Use server data during initial load, then switch to live data
    // 🏛️ DATA FLOW FIX: Stop redundant aggregation here. 
    // 🎯 OPTIMISTIC UI: Filter out deleting items immediately.
    const displayInventory = ((isLoading && inventory.length === 0) ? initialInventory : inventory)
        .filter(item => !deletingIds.includes(item.id))

    const handleDeleteClick = (id: number, name: string) => {
        setItemToDelete({ id, name })
        setDeleteDialogOpen(true)
    }

    const handleDeleteConfirm = async () => {
        if (!itemToDelete) return
        const id = itemToDelete.id
        // 🎯 OPTIMISTIC FEEDBACK: Add to list immediately
        setDeletingIds(prev => [...prev, id])
        setDeleteDialogOpen(false)

        try {
            const result = await deleteItem(id)
            if (result.success) {
                toast.success(result.message)
                // Refresh still happens in background but UI is already updated
                refresh()
            } else {
                toast.error(result.error)
                // Rollback if failed
                setDeletingIds(prev => prev.filter(itemId => itemId !== id))
            }
        } catch (error) {
            toast.error('An unexpected error occurred while deleting the item.')
            setDeletingIds(prev => prev.filter(itemId => itemId !== id))
        } finally {
            setItemToDelete(null)
        }
    }

    const handleBulkDelete = async () => {
        if (selectedItems.length === 0) {
            toast.error('No items selected')
            return
        }

        const idsToClear = [...selectedItems]
        setDeletingIds(prev => [...prev, ...idsToClear])
        setSelectedItems([])
        setSelectionMode(false)

        try {
            const result = await bulkDeleteItem(idsToClear)
            if (result.success) {
                toast.success(result.message || `Successfully deleted ${idsToClear.length} item(s)`)
                refresh()
            } else {
                toast.error(result.error)
                setDeletingIds(prev => prev.filter(id => !idsToClear.includes(id)))
            }
        } catch (error) {
            toast.error('An unexpected error occurred during bulk delete.')
            setDeletingIds(prev => prev.filter(id => !idsToClear.includes(id)))
        }
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
                    activeStatus={activeStatus}
                    onStatusChange={handleStatusChange}
                />

                <InventoryTable
                    items={displayInventory}
                    onDelete={handleDeleteClick}
                    deletingIds={deletingIds}
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
                            Delete Item?
                        </AlertDialogTitle>
                        <AlertDialogDescription className="text-sm text-gray-600">
                            Are you sure you want to delete <span className="font-semibold text-gray-900">&quot;{itemToDelete?.name}&quot;</span>? 
                            This action cannot be undone and will remove the item from active service.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel className="rounded-lg">Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDeleteConfirm}
                            className="rounded-lg bg-red-600 hover:bg-red-700 text-white"
                        >
                            Delete Item
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
            <CatalogItemDialog
                key={activeItem === 'new' ? 'inv_v3_new' : `inv_v3_edit_${(activeItem as any)?.id || 'idle'}`}
                isOpen={!!activeItem}
                item={activeItem === 'new' ? undefined : activeItem || undefined}
                onOpenChange={(open: boolean) => !open && setActiveItem(null)}
                onSuccess={refresh}
            />
        </>
    )
}
