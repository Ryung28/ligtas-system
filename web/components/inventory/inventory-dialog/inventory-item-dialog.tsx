'use client'

import { Plus, Cpu, Camera } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog'
import { InventoryItem } from '@/lib/supabase'
import { useInventoryForm } from './use-inventory-form'
import { ItemTypeSelector } from './sections/item-type-selector'
import { BasicInfoFields } from './sections/basic-info-fields'
import { StockManagementFields } from './sections/stock-management-fields'
import { StorageLocationSelect } from './sections/storage-location-select'
import { ConsumableFields } from './sections/consumable-fields'
import { AdditionalDetailsFields } from './sections/additional-details-fields'
import { ImageUploadZone } from './sections/image-upload-zone'
import { CollapsibleSection } from './sections/collapsible-section'

interface InventoryItemDialogProps {
    existingItem?: InventoryItem
    trigger?: React.ReactNode
    open?: boolean
    onOpenChange?: (open: boolean) => void
    onSuccess?: () => void
}

export function InventoryItemDialog({ 
    existingItem, 
    trigger, 
    open: controlledOpen, 
    onOpenChange, 
    onSuccess 
}: InventoryItemDialogProps) {
    // Determine if dialog is controlled or uncontrolled
    const isControlled = controlledOpen !== undefined
    const isOpen = isControlled ? controlledOpen : undefined
    
    // Use the custom hook to manage all state and logic
    const {
        // State
        isPending,
        isUploading,
        previewUrl,
        categories,
        isLoadingCategories,
        itemType,
        storageLocation,
        customLocation,
        savedLocations,
        isLoadingLocations,
        isSavingLocation,
        hasVariants,
        parentId,
        variantLabel,
        customVariant,
        parentItems,
        isLoadingParents,
        itemNameValue,
        isEditMode,
        
        // Refs
        fileInputRef,
        formRef,
        
        // Handlers
        handleImageChange,
        removeImage,
        handleSubmit,
        handleSaveLocation,
        
        // Setters
        setItemType,
        setStorageLocation,
        setCustomLocation,
        setHasVariants,
        setParentId,
        setVariantLabel,
        setCustomVariant,
        setItemNameValue,
    } = useInventoryForm({
        existingItem,
        isOpen: isOpen ?? false,
        onClose: () => onOpenChange?.(false),
        onSuccess
    })

    return (
        <Dialog open={isOpen} onOpenChange={onOpenChange}>
            {trigger && <DialogTrigger asChild>{trigger}</DialogTrigger>}
            <DialogContent className="sm:max-w-[600px] max-h-[95vh] overflow-y-auto rounded-2xl p-0 border-none shadow-[0_20px_60px_-15px_rgba(0,0,0,0.3)] bg-white">
                <form ref={formRef} onSubmit={handleSubmit}>
                    {/* Header Section */}
                    <div className="relative p-6 pb-4 bg-gradient-to-br from-blue-50 via-white to-indigo-50">
                        <div className="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-blue-500/10 to-indigo-500/10 rounded-full blur-3xl" />
                        <DialogHeader className="relative">
                            <div className="flex items-center gap-3 mb-2">
                                <div className={`p-2.5 rounded-xl ${isEditMode ? 'bg-gradient-to-br from-blue-500 to-blue-600' : 'bg-gradient-to-br from-blue-500 to-indigo-600'} shadow-lg`}>
                                    {isEditMode ? <Cpu className="h-5 w-5 text-white" /> : <Plus className="h-5 w-5 text-white" />}
                                </div>
                                <div>
                                    <DialogTitle className="text-xl font-bold text-gray-900 tracking-tight">
                                        {isEditMode ? 'Edit Item' : 'Add New Item'}
                                    </DialogTitle>
                                    <DialogDescription className="text-gray-600 text-xs font-medium mt-0.5">
                                        {isEditMode ? 'Update inventory details' : 'Register new equipment or supplies'}
                                    </DialogDescription>
                                </div>
                            </div>
                        </DialogHeader>
                    </div>

                    {/* Form Content */}
                    <div className="px-6 space-y-5 pb-6">
                        {/* Item Type Selector - FIRST */}
                        <ItemTypeSelector
                            itemType={itemType}
                            onItemTypeChange={setItemType}
                        />

                        {/* Divider */}
                        <div className="border-t border-gray-200" />

                        {/* Essential Details Section */}
                        <div className="space-y-4">
                            <div className="flex items-center gap-2">
                                <div className="h-1 w-1 rounded-full bg-blue-500" />
                                <h3 className="text-xs font-bold text-gray-700 uppercase tracking-wide">Essential Details</h3>
                            </div>
                            <BasicInfoFields
                                itemNameValue={itemNameValue}
                                onItemNameChange={setItemNameValue}
                                existingItem={existingItem}
                                categories={categories}
                                isLoadingCategories={isLoadingCategories}
                                hasVariants={hasVariants}
                                variantLabel={variantLabel}
                                customVariant={customVariant}
                                onToggleVariants={setHasVariants}
                                onVariantLabelChange={setVariantLabel}
                                onCustomVariantChange={setCustomVariant}
                                itemType={itemType}
                            />
                        </div>

                        {/* Divider */}
                        <div className="border-t border-gray-200" />

                        {/* Stock & Location Section */}
                        <div className="space-y-4">
                            <div className="flex items-center gap-2">
                                <div className="h-1 w-1 rounded-full bg-blue-500" />
                                <h3 className="text-xs font-bold text-gray-700 uppercase tracking-wide">Stock & Location</h3>
                            </div>
                            <StockManagementFields existingItem={existingItem} />
                            <StorageLocationSelect
                                storageLocation={storageLocation}
                                onStorageLocationChange={setStorageLocation}
                                customLocation={customLocation}
                                onCustomLocationChange={setCustomLocation}
                                savedLocations={savedLocations}
                                isLoadingLocations={isLoadingLocations}
                                isSavingLocation={isSavingLocation}
                                onSaveLocation={handleSaveLocation}
                            />
                        </div>

                        {/* Divider */}
                        <div className="border-t border-gray-200" />

                        {/* Type-Specific Details (Conditional) */}
                        <div className="space-y-4">
                            <div className="flex items-center gap-2">
                                <div className="h-1 w-1 rounded-full bg-blue-500" />
                                <h3 className="text-xs font-bold text-gray-700 uppercase tracking-wide">
                                    {itemType === 'equipment' ? 'Equipment Details' : 'Consumable Details'}
                                </h3>
                            </div>
                            {itemType === 'equipment' ? (
                                <AdditionalDetailsFields existingItem={existingItem} />
                            ) : (
                                <ConsumableFields existingItem={existingItem} />
                            )}
                        </div>

                        {/* Divider */}
                        <div className="border-t border-gray-200" />

                        {/* Optional Sections - Collapsed by Default */}
                        <div className="space-y-3">
                            <CollapsibleSection
                                title="Add Photo"
                                subtitle="Optional - Upload item image"
                                icon={<Camera className="h-4 w-4" />}
                                defaultOpen={false}
                            >
                                <ImageUploadZone
                                    previewUrl={previewUrl}
                                    isUploading={isUploading}
                                    fileInputRef={fileInputRef}
                                    onImageChange={handleImageChange}
                                    onRemoveImage={removeImage}
                                />
                            </CollapsibleSection>
                        </div>
                    </div>

                    {/* Footer Section */}
                    <DialogFooter className="bg-gradient-to-br from-gray-50 to-gray-100/50 p-6 border-t border-gray-200 flex items-center justify-between">
                        <Button 
                            type="button" 
                            variant="ghost" 
                            onClick={() => onOpenChange?.(false)} 
                            disabled={isPending || isUploading} 
                            className="text-gray-600 text-sm font-semibold hover:text-gray-900 hover:bg-white transition-all rounded-lg px-4"
                        >
                            Cancel
                        </Button>
                        <Button 
                            type="submit" 
                            disabled={isPending || isUploading} 
                            className="rounded-lg h-10 px-6 font-bold text-sm shadow-lg transition-all duration-200 hover:shadow-xl hover:scale-105 active:scale-95 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white border-0"
                        >
                            {isPending ? (
                                <div className="flex items-center gap-2">
                                    <div className="h-4 w-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                                </div>
                            ) : (
                                isEditMode ? 'Save Changes' : 'Add Item'
                            )}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
}
