'use client'

import { Plus, Cpu, Camera, Package, Warehouse, Box, X, Save, LayoutGrid } from 'lucide-react'
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
import { StockDistributionGrid } from './sections/stock-distribution-grid'
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
    onSuccess,
}: InventoryItemDialogProps) {
    const isControlled = controlledOpen !== undefined
    const isOpen = isControlled ? controlledOpen : undefined
    
    const {
        isPending,
        isUploading,
        previewUrl,
        categories,
        isLoadingCategories,
        categoryId,
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
        stockTotalValue,
        targetStock,
        lowStockThreshold,
        restockAlertEnabled,
        qtyGood,
        qtyDamaged,
        qtyMaintenance,
        qtyLost,
        setQtyGood,
        setQtyDamaged,
        setQtyMaintenance,
        setQtyLost,
        fileInputRef,
        formRef,
        handleImageChange,
        removeImage,
        handleSubmit,
        handleSaveLocation,
        handleDeleteLocation,
        setItemNameValue,
        siteDistributions,
        addSiteDistribution,
        removeSiteDistribution,
        updateSiteQty,
        setItemType,
        setCategoryId,
        setHasVariants,
        setParentId,
        setVariantLabel,
        setCustomVariant,
        setTargetStock,
        setLowStockThreshold,
        setRestockAlertEnabled,
    } = useInventoryForm({
        existingItem,
        isOpen: isOpen ?? false,
        onClose: () => onOpenChange?.(false),
        onSuccess
    })

    return (
        <Dialog open={isOpen} onOpenChange={onOpenChange}>
            {trigger && <DialogTrigger asChild>{trigger}</DialogTrigger>}
            <DialogContent className="sm:max-w-xl max-h-[92vh] p-0 overflow-hidden bg-white border-none shadow-[0_32px_80px_-20px_rgba(0,0,0,0.35)] rounded-2xl animate-in zoom-in-95 duration-200">
                <form 
                    ref={formRef} 
                    onSubmit={handleSubmit}
                    className="flex flex-col h-full max-h-[92vh] overflow-hidden"
                >
                    {/* 🏗️ LIGTAS PRIME HEADER: Clean, High-Contrast, Professional */}
                    <div className="px-6 py-6 bg-white border-b border-slate-50 flex items-center justify-between shrink-0">
                        <div className="flex items-center gap-5">
                            {/* Iconic Highlight (Matching Reference) */}
                            <div className="h-12 w-12 rounded-[18px] bg-blue-600 flex items-center justify-center shadow-lg shadow-blue-500/20 shrink-0">
                                <Box className="h-6 w-6 text-white" strokeWidth={2.5} />
                            </div>
                            
                            <div className="space-y-0.5">
                                <DialogTitle className="text-[20px] font-bold tracking-tight text-slate-900 leading-tight">
                                    {isEditMode ? 'Edit Item' : 'New Item'}
                                </DialogTitle>
                                <DialogDescription className="text-slate-500 text-[14px] font-medium leading-none">
                                    {isEditMode ? 'Update details below' : 'Fill in the details below'}
                                </DialogDescription>
                            </div>
                        </div>

                        {/* Right-Side Package Accent (As requested) */}
                        <div className="flex items-center gap-2 pr-6">
                            <div className="h-10 w-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-300">
                                <Package className="h-5 w-5" strokeWidth={2} />
                            </div>
                        </div>
                    </div>

                    {/* SCROLLABLE BODY */}
                    <div className="flex-1 overflow-y-auto bg-white divide-y divide-slate-100">

                        {/* Section 1: Item Type */}
                        <div className="px-5 py-4">
                            <ItemTypeSelector
                                itemType={itemType}
                                onItemTypeChange={setItemType}
                            />
                        </div>

                        {/* Section 2: Main Info */}
                        <div className="px-5 py-4">
                            <BasicInfoFields 
                                itemNameValue={itemNameValue}
                                onItemNameChange={setItemNameValue}
                                existingItem={existingItem}
                                categories={categories}
                                isLoadingCategories={isLoadingCategories}
                                categoryId={categoryId}
                                onCategoryIdChange={setCategoryId}
                                hasVariants={hasVariants}
                                parentId={parentId}
                                parentItems={parentItems}
                                isLoadingParents={isLoadingParents}
                                variantLabel={variantLabel}
                                customVariant={customVariant}
                                onToggleVariants={setHasVariants}
                                onVariantLabelChange={setVariantLabel}
                                onCustomVariantChange={setCustomVariant}
                                itemType={itemType}
                            />
                        </div>

                        {/* Section 3: Global Stock Counts (Health Dashboard) */}
                        <div className="px-5 py-2">
                            <div className="bg-slate-50/50 rounded-2xl p-4 border border-slate-100">
                                <StockManagementFields
                                    qtyGood={qtyGood}
                                    setQtyGood={setQtyGood}
                                    qtyDamaged={qtyDamaged}
                                    setQtyDamaged={setQtyDamaged}
                                    qtyMaintenance={qtyMaintenance}
                                    setQtyMaintenance={setQtyMaintenance}
                                    qtyLost={qtyLost}
                                    setQtyLost={setQtyLost}
                                    stockTotalValue={stockTotalValue}
                                    targetStock={targetStock}
                                    onTargetStockChange={setTargetStock}
                                    lowStockThreshold={lowStockThreshold}
                                    onThresholdChange={setLowStockThreshold}
                                    restockAlertEnabled={restockAlertEnabled}
                                    onRestockAlertEnabledChange={setRestockAlertEnabled}
                                />
                            </div>
                        </div>

                        {/* Section 4: Storage & Locations */}
                        <div className="px-5 py-4">
                            <CollapsibleSection
                                title="Storage & Locations"
                                subtitle="Manage where items are kept"
                                icon={<Warehouse className="h-4 w-4" />}
                                defaultOpen={isEditMode}
                            >
                                <StockDistributionGrid
                                    siteDistributions={siteDistributions}
                                    onUpdateQty={updateSiteQty}
                                    onAddSite={addSiteDistribution}
                                    onRemoveSite={removeSiteDistribution}
                                    savedLocations={savedLocations}
                                />
                            </CollapsibleSection>
                        </div>

                        {/* Section 4: Specific Details */}
                        <div className="px-5 py-4">
                            <CollapsibleSection
                                title={itemType === 'equipment' ? 'Serial & Model' : 'Brand & Expiry'}
                                subtitle="Specific details for this item"
                                icon={<Cpu className="h-4 w-4" />}
                                defaultOpen={false}
                            >
                                {itemType === 'equipment' ? (
                                    <AdditionalDetailsFields existingItem={existingItem} />
                                ) : (
                                    <ConsumableFields existingItem={existingItem} />
                                )}
                            </CollapsibleSection>
                        </div>

                        {/* Section 5: Photo — always collapsed */}
                        <div className="px-5 py-4">
                            <CollapsibleSection
                                title="Add Photo"
                                subtitle="Optional — upload an image"
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

                    {/* DOCKED FOOTER — minimal gutter above */}
                    <DialogFooter className="bg-white px-5 py-3 border-t-2 border-slate-100 flex items-center justify-between shrink-0">
                        <Button 
                            type="button" 
                            variant="ghost" 
                            onClick={() => onOpenChange?.(false)} 
                            disabled={isPending || isUploading} 
                            className="text-slate-400 text-xs font-bold hover:text-slate-700 hover:bg-slate-100 transition-all rounded-lg px-3 h-8"
                        >
                            Cancel
                        </Button>
                        <Button 
                            type="submit" 
                            disabled={isPending || isUploading} 
                            className="rounded-lg h-8 px-5 font-bold text-xs shadow-md transition-all duration-200 hover:shadow-lg hover:scale-[1.02] active:scale-95 bg-blue-600 hover:bg-blue-700 text-white border-0"
                        >
                            {isPending ? (
                                <div className="flex items-center gap-2">
                                    <div className="h-3.5 w-3.5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                                    <span>Saving...</span>
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
