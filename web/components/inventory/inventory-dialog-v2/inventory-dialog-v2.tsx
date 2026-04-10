"use client"

import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Loader2, Package } from 'lucide-react'
import { V2IdentityFields } from './_components/v2-identity-fields'
import { V2MetadataFields } from './_components/v2-metadata-fields'
import { V2ConsumableFields } from './_components/v2-consumable-fields'
import { V2StatusFields } from './_components/v2-status-fields'
import { V2LogisticsLedger } from './_components/v2-logistics-ledger'
import { useInventoryDataV2 } from './use-inventory-data-v2'
import { useInventoryStateV2 } from './use-inventory-state-v2'
import { useInventoryImageV2 } from './use-inventory-image-v2'
import { useInventorySubmitV2 } from './use-inventory-submit-v2'

interface InventoryDialogV2Props {
    isOpen: boolean
    onOpenChange: (open: boolean) => void
    existingItem?: any
    onSuccess?: () => void
}

export function InventoryDialogV2({ isOpen, onOpenChange, existingItem, onSuccess }: InventoryDialogV2Props) {
    const { categories, locations, parents, isLoading: isDataLoading } = useInventoryDataV2(isOpen)
    const state = useInventoryStateV2(existingItem)
    const img = useInventoryImageV2(existingItem?.image_url)
    const { submit, isPending } = useInventorySubmitV2(() => {
        onOpenChange(false)
        if (onSuccess) onSuccess()
    })

    const handleFormSubmit = () => {
        const formData = new FormData()
        if (existingItem?.id) formData.append('id', existingItem.id.toString())

        // 1. Classification Match
        formData.append('name', state.name)
        formData.append('description', state.description || '')
        formData.append('category', state.categoryId)
        formData.append('item_type', state.itemType)
        formData.append('image_url', img.storedPath || existingItem?.image_url || '')

        // 2. Metadata (Equipment vs Consumable) Match
        formData.append('serial_number', state.serialNumber)
        formData.append('model_number', state.modelNumber)
        formData.append('brand', state.brand)
        if (state.expiryDate) formData.append('expiry_date', state.expiryDate)

        // 3. Variant Reconciliation (Legacy Line 346)
        if (state.isSpecial) {
            formData.append('parent_id', state.parentId)
            formData.set('variant_label', state.variantLabel === 'custom' ? state.customVariant : state.variantLabel)
        }

        // 4. Heavy-Duty Health Mapping
        formData.set('qty_good', state.totals.qtyGood.toString())
        formData.set('qty_damaged', state.totals.qtyDamaged.toString())
        formData.set('qty_maintenance', state.totals.qtyMaintenance.toString())
        formData.set('qty_lost', state.totals.qtyLost.toString())
        formData.set('stock_total', state.totals.total.toString())
        formData.set('stock_available', state.totals.qtyGood.toString())
        formData.set('target_stock', state.targetStock.toString())
        formData.set('low_stock_threshold', state.lowStockThreshold.toString())

        // 5. Geographic Resolution (Legacy Line 328)
        formData.set('site_distributions', JSON.stringify(state.distributions))
        const first = state.distributions[0]
        if (first?.locationId) formData.append('location_id', first.locationId.toString())
        if (first?.locationName) formData.append('storage_location', first.locationName)

        submit(formData, !!existingItem)
    }

    return (
        <Dialog open={isOpen} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-xl h-[94vh] p-0 overflow-hidden bg-white border-none shadow-2xl rounded-[48px] animate-in zoom-in-95 flex flex-col">
                <DialogHeader className="bg-white px-6 pt-6 pb-2 border-b border-slate-50">
                    <div className="flex items-center gap-4">
                        <div className="h-12 w-12 bg-blue-600 rounded-3xl flex items-center justify-center shadow-lg shadow-blue-200 shrink-0">
                            <Package className="h-6 w-6 text-white" />
                        </div>
                        <div className="flex-1">
                            <DialogTitle className="text-xl font-black text-slate-900 tracking-tight">
                                {existingItem ? `Edit ${state.name}` : 'Add New Item'}
                            </DialogTitle>
                            <p className="text-[13px] font-semibold text-slate-600">
                                {existingItem ? 'Update inventory details' : 'Add a new asset to the list'}
                            </p>
                        </div>
                        <div className="pr-4">
                            <Package className="h-5 w-5 text-slate-400" />
                        </div>
                    </div>
                </DialogHeader>

                <ScrollArea className="flex-1 px-6 py-2">
                    <div className="space-y-8 pb-10">
                        <V2IdentityFields
                            {...state} onNameChange={state.setName} onCategoryChange={state.setCategoryId}
                            categories={categories} isLoadingCategories={isDataLoading}
                            onToggleSpecial={state.setIsSpecial} onParentChange={state.setParentId}
                            parentItems={parents} onTypeChange={state.setItemType}
                            previewUrl={img.previewUrl} isUploading={img.isUploading}
                            onImageUpload={img.handleUpload} onRemoveImage={img.removeImage}
                            fileInputRef={img.fileInputRef} isSpecialVersion={state.isSpecial}
                            onVariantLabelChange={state.setVariantLabel} onCustomVariantChange={state.setCustomVariant}
                        />

                        {state.itemType === 'equipment' ? (
                            <V2MetadataFields serialNumber={state.serialNumber} onSerialChange={state.setSerialNumber} modelNumber={state.modelNumber} onModelChange={state.setModelNumber} />
                        ) : (
                            <V2ConsumableFields brand={state.brand} onBrandChange={state.setBrand} expiryDate={state.expiryDate} onExpiryChange={state.setExpiryDate} />
                        )}

                        <V2StatusFields
                            qtyGood={state.distributions[0]?.qtyGood} setQtyGood={(val) => state.updateSiteQty(0, 'qtyGood', val)}
                            qtyDamaged={state.distributions[0]?.qtyDamaged} setQtyDamaged={(val) => state.updateSiteQty(0, 'qtyDamaged', val)}
                            qtyMaintenance={state.distributions[0]?.qtyMaintenance} setQtyMaintenance={(val) => state.updateSiteQty(0, 'qtyMaintenance', val)}
                            qtyLost={state.distributions[0]?.qtyLost} setQtyLost={(val) => state.updateSiteQty(0, 'qtyLost', val)}
                            targetStock={state.targetStock} setTargetStock={state.setTargetStock} lowStockThreshold={state.lowStockThreshold} setLowStockThreshold={state.setLowStockThreshold}
                        />

                        <V2LogisticsLedger
                            distributions={state.distributions}
                            onUpdateQty={(idx, bucket, val) => state.updateSiteQty(idx, bucket, val)}
                            onAdd={state.addDistribution}
                            onRemove={state.removeDistribution}
                            savedLocations={locations}
                        />
                    </div>
                </ScrollArea>

                <DialogFooter className="bg-slate-50/80 p-3 border-t border-slate-100 flex items-center justify-between rounded-b-[48px] shrink-0">
                    <Button variant="ghost" onClick={() => onOpenChange(false)} className="font-extrabold text-slate-500 h-10">Cancel</Button>
                    <Button onClick={handleFormSubmit} disabled={isPending || img.isUploading} className="bg-slate-900 text-white rounded-3xl px-10 h-11 font-black shadow-lg">
                        {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : 'Save Changes'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
