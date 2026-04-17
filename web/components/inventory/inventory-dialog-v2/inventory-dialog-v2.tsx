"use client"

import { useEffect, useRef, useState } from 'react'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Loader2, Package } from 'lucide-react'
import { toast } from 'sonner'
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
    focusRestockPolicy?: boolean
    showRestockWarningOnOpen?: boolean
}

export function InventoryDialogV2({ isOpen, onOpenChange, existingItem, onSuccess, focusRestockPolicy = false, showRestockWarningOnOpen = false }: InventoryDialogV2Props) {
    const { categories, locations, parents, isLoading: isDataLoading } = useInventoryDataV2(isOpen)
    const state = useInventoryStateV2(existingItem)
    const img = useInventoryImageV2(existingItem?.image_url)
    const statusSectionRef = useRef<HTMLDivElement | null>(null)
    const [policyErrors, setPolicyErrors] = useState<{ ready: string; target: string; threshold: string }>({ ready: '', target: '', threshold: '' })
    const { submit, isPending } = useInventorySubmitV2(() => {
        onOpenChange(false)
        if (onSuccess) onSuccess()
    })
    const { setRestockAlertEnabled } = state

    useEffect(() => {
        if (!isOpen || !focusRestockPolicy) return
        const timer = setTimeout(() => {
            statusSectionRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' })
            const targetInput = statusSectionRef.current?.querySelector<HTMLInputElement>('[data-restock-input="target"]')
            targetInput?.focus()
        }, 120)
        // Strict triage mode: entering from "Make Restockable" means this path is intentional.
        setRestockAlertEnabled(true)
        return () => clearTimeout(timer)
    }, [isOpen, focusRestockPolicy, existingItem?.id, setRestockAlertEnabled])

    useEffect(() => {
        if (!isOpen || !showRestockWarningOnOpen) return
        toast.warning('To enable restock alerts, set Max Stock to 2 or more and Warn at (%) above 0.')
        const readyUnits = Number(state.totals.qtyGood) || 0
        const targetNum = Number(state.targetStock) || 0
        const thresholdNum = Number(state.lowStockThreshold) || 0
        setPolicyErrors({
            ready: readyUnits < 2 ? 'Set Ready to Use to at least 2' : '',
            target: targetNum < 2 ? 'Set Max Stock Goal to at least 2' : '',
            threshold: thresholdNum <= 0 ? 'Warn at (%) must be greater than 0' : '',
        })
    }, [
        isOpen,
        showRestockWarningOnOpen,
        existingItem?.id,
        state.totals.qtyGood,
        state.targetStock,
        state.lowStockThreshold,
    ])

    useEffect(() => {
        if (!state.restockAlertEnabled) {
            setPolicyErrors({ ready: '', target: '', threshold: '' })
            return
        }

        const readyUnits = Number(state.totals.qtyGood) || 0
        const targetNum = Number(state.targetStock) || 0
        const thresholdNum = Number(state.lowStockThreshold) || 0

        setPolicyErrors(prev => ({
            ready: prev.ready && readyUnits >= 2 ? '' : prev.ready,
            target: prev.target && targetNum >= 2 ? '' : prev.target,
            threshold: prev.threshold && thresholdNum > 0 ? '' : prev.threshold,
        }))
    }, [state.restockAlertEnabled, state.totals.qtyGood, state.targetStock, state.lowStockThreshold])

    const handleFormSubmit = () => {
        const targetNum = Number(state.targetStock) || 0
        const thresholdNum = Number(state.lowStockThreshold) || 0
        const readyUnits = Number(state.totals.qtyGood) || 0
        let nextErrors = { ready: '', target: '', threshold: '' }

        if (state.restockAlertEnabled && focusRestockPolicy && readyUnits < 2) {
            nextErrors.ready = 'Set Ready to Use to at least 2'
        }

        if (state.restockAlertEnabled && targetNum < 2) {
            nextErrors.target = 'Set Max Stock Goal to at least 2'
        }

        if (state.restockAlertEnabled && thresholdNum <= 0) {
            nextErrors.threshold = 'Warn at (%) must be greater than 0'
        }

        if (nextErrors.target || nextErrors.threshold) {
            setPolicyErrors(nextErrors)
            toast.error('Fix the highlighted restock policy fields before saving')
            statusSectionRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' })
            return
        }
        setPolicyErrors({ ready: '', target: '', threshold: '' })

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

        // Legacy variant and model fields have been structurally severed.

        // 4. Heavy-Duty Health Mapping
        formData.set('qty_good', state.totals.qtyGood.toString())
        formData.set('qty_damaged', state.totals.qtyDamaged.toString())
        formData.set('qty_maintenance', state.totals.qtyMaintenance.toString())
        formData.set('qty_lost', state.totals.qtyLost.toString())
        formData.set('stock_total', state.totals.total.toString())
        formData.set('stock_available', state.totals.qtyGood.toString())
        formData.set('target_stock', state.targetStock.toString())
        formData.set('low_stock_threshold', state.lowStockThreshold.toString())
        formData.set('restock_alert_enabled', String(state.restockAlertEnabled))

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
                            name={state.name} onNameChange={state.setName} 
                            categoryId={state.categoryId} onCategoryChange={state.setCategoryId}
                            categories={categories} isLoadingCategories={isDataLoading}
                            itemType={state.itemType} onTypeChange={state.setItemType}
                            previewUrl={img.previewUrl} isUploading={img.isUploading}
                            onImageUpload={img.handleUpload} onRemoveImage={img.removeImage}
                            fileInputRef={img.fileInputRef}
                        />

                        {state.itemType === 'equipment' ? (
                            <V2MetadataFields serialNumber={state.serialNumber} onSerialChange={state.setSerialNumber} modelNumber={state.modelNumber} onModelChange={state.setModelNumber} />
                        ) : (
                            <V2ConsumableFields brand={state.brand} onBrandChange={state.setBrand} expiryDate={state.expiryDate} onExpiryChange={state.setExpiryDate} />
                        )}

                        <div ref={statusSectionRef}>
                            <V2StatusFields
                                qtyGood={state.distributions[0]?.qtyGood} setQtyGood={(val) => state.updateSiteQty(0, 'qtyGood', val)}
                                qtyDamaged={state.distributions[0]?.qtyDamaged} setQtyDamaged={(val) => state.updateSiteQty(0, 'qtyDamaged', val)}
                                qtyMaintenance={state.distributions[0]?.qtyMaintenance} setQtyMaintenance={(val) => state.updateSiteQty(0, 'qtyMaintenance', val)}
                                qtyLost={state.distributions[0]?.qtyLost} setQtyLost={(val) => state.updateSiteQty(0, 'qtyLost', val)}
                                targetStock={state.targetStock} setTargetStock={state.setTargetStock} lowStockThreshold={state.lowStockThreshold} setLowStockThreshold={state.setLowStockThreshold}
                                restockAlertEnabled={state.restockAlertEnabled} setRestockAlertEnabled={state.setRestockAlertEnabled}
                                policyErrors={policyErrors}
                            />
                        </div>

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
