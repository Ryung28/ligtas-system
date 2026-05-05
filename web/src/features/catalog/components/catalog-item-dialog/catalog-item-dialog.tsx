'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Loader2, Package } from 'lucide-react'
import { toast } from 'sonner'

import { useInventoryDataV2 } from './_hooks/use-inventory-data-v2'
import { useInventoryImageV2 } from './_hooks/use-inventory-image-v2'

import { useItemIdentity } from './_hooks/use-item-identity'
import { useItemThresholds } from './_hooks/use-item-thresholds'
import { useBulkPackaging } from './_hooks/use-bulk-packaging'
import { useSiteLogistics } from './_hooks/use-site-logistics'
import { usePackagingSync } from './_hooks/use-packaging-sync'
import { useCatalogSubmit } from './_hooks/use-catalog-submit'
import type { PolicyErrors } from './types'

// Re-use existing V2 UI sections — no duplication, no re-write
import { V2IdentityFields } from './_components/v2-identity-fields'
import { V2MetadataFields } from './_components/v2-metadata-fields'
import { V2ConsumableFields } from './_components/v2-consumable-fields'
import { V2StatusFields } from './_components/v2-status-fields'
import { V2LogisticsLedger } from './_components/v2-logistics-ledger'

const BULK_CATEGORIES = ['Goods', 'Consumables', 'Materials', 'Medical']

interface CatalogItemDialogProps {
    isOpen: boolean
    onOpenChange: (open: boolean) => void
    /** Undefined = Add mode. Populated = Edit mode. */
    item?: any
    onSuccess?: () => void
    focusRestockPolicy?: boolean
    showRestockWarningOnOpen?: boolean
    forceDisableAlerts?: boolean
}

export function CatalogItemDialog({
    isOpen,
    onOpenChange,
    item,
    onSuccess,
    focusRestockPolicy = false,
    showRestockWarningOnOpen = false,
    forceDisableAlerts = false,
}: CatalogItemDialogProps) {
    const isEditMode = !!item

    // ─── External Data ─────────────────────────────────────────────────────────
    const { categories, locations, isLoading: isDataLoading } = useInventoryDataV2(isOpen)
    const img = useInventoryImageV2(item?.image_url)

    // ─── Domain Hooks ──────────────────────────────────────────────────────────
    const identity = useItemIdentity(item)
    const thresholds = useItemThresholds(item)
    const pkg = useBulkPackaging(item)
    const logistics = useSiteLogistics(item)

    // 🔗 SYNC BRIDGE: Expiry Mirroring
    // If bulk is enabled, the "Truth" is in the cartons. We mirror the earliest
    // date back to the identity hook so alerts and DB columns stay in sync.
    useEffect(() => {
        if (pkg.packaging.enabled && pkg.earliestExpiry && pkg.earliestExpiry !== identity.expiryDate) {
            identity.setExpiryDate(pkg.earliestExpiry)
        }
    }, [pkg.packaging.enabled, pkg.earliestExpiry, identity])

    // ─── One-Way Sync Bridge ───────────────────────────────────────────────────
    usePackagingSync(pkg.packaging, pkg.syncKey, logistics.setDistributions, locations)

    // ─── UI State ──────────────────────────────────────────────────────────────
    const statusSectionRef = useRef<HTMLDivElement | null>(null)
    const [policyErrors, setPolicyErrors] = useState<PolicyErrors>({ ready: '', target: '', threshold: '' })

    const selectedCategoryName = useMemo(() => {
        const row = categories.find((c: { id: string }) => c.id === identity.categoryId)
        if (row) return (row as { category_name?: string }).category_name ?? ''
        return String(identity.categoryId ?? '').trim()
    }, [categories, identity.categoryId])

    const isBulkCategory = BULK_CATEGORIES.includes(selectedCategoryName)
    const showGoodsExpiryFields = ['goods', 'medical'].includes(selectedCategoryName.trim().toLowerCase())

    // ─── Submit Hook ───────────────────────────────────────────────────────────
    const { submit, isPending } = useCatalogSubmit(() => {
        onOpenChange(false)
        onSuccess?.()
    })

    // ─── Side Effects ──────────────────────────────────────────────────────────
    useEffect(() => {
        if (!isOpen || !forceDisableAlerts) return
        thresholds.setRestockAlertEnabled(false)
        thresholds.setLowStockThreshold(0)
    }, [isOpen, forceDisableAlerts, thresholds.setRestockAlertEnabled, thresholds.setLowStockThreshold])

    useEffect(() => {
        if (!isOpen || !focusRestockPolicy) return
        const timer = setTimeout(() => {
            statusSectionRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' })
            statusSectionRef.current?.querySelector<HTMLInputElement>('[data-restock-input="target"]')?.focus()
        }, 120)
        thresholds.setRestockAlertEnabled(true)
        return () => clearTimeout(timer)
    }, [isOpen, focusRestockPolicy, item?.id, thresholds.setRestockAlertEnabled])

    useEffect(() => {
        if (!isOpen || !showRestockWarningOnOpen) return
        toast.warning('To enable restock alerts, set Max Stock to 2 or more and Warn at (%) above 0.')
        const ready = Number(logistics.totals.qtyGood) || 0
        const target = Number(thresholds.targetStock) || 0
        const threshold = Number(thresholds.lowStockThreshold) || 0
        setPolicyErrors({
            ready: ready < 2 ? 'Set Ready to Use to at least 2' : '',
            target: target < 2 ? 'Set Max Stock Goal to at least 2' : '',
            threshold: threshold <= 0 ? 'Warn at (%) must be greater than 0' : '',
        })
    }, [isOpen, showRestockWarningOnOpen, item?.id, logistics.totals.qtyGood, thresholds.targetStock, thresholds.lowStockThreshold])

    useEffect(() => {
        if (!thresholds.restockAlertEnabled) {
            setPolicyErrors({ ready: '', target: '', threshold: '' })
            return
        }
        const ready = Number(logistics.totals.qtyGood) || 0
        const target = Number(thresholds.targetStock) || 0
        const threshold = Number(thresholds.lowStockThreshold) || 0
        setPolicyErrors(prev => ({
            ready: prev.ready && ready >= 2 ? '' : prev.ready,
            target: prev.target && target >= 2 ? '' : prev.target,
            threshold: prev.threshold && threshold > 0 ? '' : prev.threshold,
        }))
    }, [thresholds.restockAlertEnabled, logistics.totals.qtyGood, thresholds.targetStock, thresholds.lowStockThreshold])

    // ─── Submission ────────────────────────────────────────────────────────────
    const handleSubmit = () => {
        // Packaging validation
        if (pkg.packaging.enabled) {
            const { batches, expiry_groups: groups, expiry_mode: mode } = pkg.packaging

            if (mode === 'single' && batches.some(b => !b.expiry_date)) {
                toast.error('Cannot save: please set a date for the packaging.')
                return
            }
            if ((mode === 'grouped' || mode === 'per_carton') && groups.some(g => !g.expiry_date)) {
                toast.error('Cannot save: please complete carton expiry assignments.')
                return
            }
            if (mode === 'grouped' || mode === 'per_carton') {
                const seen = new Set<string>()
                for (const g of groups) {
                    for (const batchId of g.batch_ids) {
                        if (seen.has(batchId)) { toast.error('Cannot save: duplicate carton assignment found.'); return }
                        seen.add(batchId)
                    }
                }
                if (batches.some(b => !seen.has(b.id))) {
                    toast.error('Cannot save: please complete carton expiry assignments.')
                    return
                }
            }
        }

        // Threshold validation (soft — warns but does not block)
        const target = Number(thresholds.targetStock) || 0
        const threshold = Number(thresholds.lowStockThreshold) || 0
        if (thresholds.restockAlertEnabled && (target > 0 && target < 2 || threshold <= 0)) {
            toast.warning('Restock threshold warning, but proceeding with save...')
        }
        setPolicyErrors({ ready: '', target: '', threshold: '' })

        // 🎯 Mandatory Location Validation
        const primarySite = logistics.distributions.find(d => d._isMaster)
        if (!primarySite || !primarySite.locationId) {
            toast.error('Cannot save: please select a storage location.')
            return
        }

        submit({
            itemId: isEditMode ? item.id : undefined,
            identity: {
                name: identity.name,
                description: identity.description,
                categoryId: identity.categoryId,
                itemType: identity.itemType,
                serialNumber: identity.serialNumber,
                modelNumber: identity.modelNumber,
                brand: identity.brand,
                expiryDate: identity.expiryDate,
                expiryAlertDays: identity.expiryAlertDays,
            },
            thresholds: {
                targetStock: thresholds.targetStock,
                lowStockThreshold: thresholds.lowStockThreshold,
                restockAlertEnabled: thresholds.restockAlertEnabled,
            },
            packaging: pkg.packaging,
            distributions: logistics.distributions,
            totals: logistics.totals,
            imageUrl: img.storedPath || item?.image_url || '',
        })
    }

    // ─── Render ────────────────────────────────────────────────────────────────
    return (
        <Dialog open={isOpen} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-xl h-[94vh] p-0 overflow-hidden bg-slate-50 border-none shadow-2xl rounded-[48px] animate-in zoom-in-95 flex flex-col">
                <DialogHeader className="bg-white px-8 pt-8 pb-6 border-b border-slate-100">
                    <div className="flex items-center gap-4">
                        <div className="h-12 w-12 bg-blue-600 rounded-3xl flex items-center justify-center shadow-lg shadow-blue-200 shrink-0">
                            <Package className="h-6 w-6 text-white" />
                        </div>
                        <div className="flex-1">
                            <DialogTitle className="text-xl font-black text-slate-900 tracking-tight">
                                {isEditMode ? `Edit ${identity.name}` : 'Add New Item'}
                            </DialogTitle>
                            <p className="text-[13px] font-semibold text-slate-600">
                                {isEditMode ? 'Update inventory details' : 'Add a new asset to the list'}
                            </p>
                        </div>
                    </div>
                </DialogHeader>

                <ScrollArea className="flex-1 px-8 py-2">
                    <div className="space-y-8 pb-10 w-full max-w-full overflow-x-hidden flex flex-col">
                        <V2IdentityFields
                            name={identity.name} onNameChange={identity.setName}
                            categoryId={identity.categoryId} onCategoryChange={identity.setCategoryId}
                            categories={categories} isLoadingCategories={isDataLoading}
                            itemType={identity.itemType} onTypeChange={identity.setItemType}
                            previewUrl={img.previewUrl} isUploading={img.isUploading}
                            onImageUpload={img.handleUpload} onRemoveImage={img.removeImage}
                            fileInputRef={img.fileInputRef}
                        />

                        {identity.itemType === 'equipment' ? (
                            <>
                                <V2MetadataFields
                                    serialNumber={identity.serialNumber} onSerialChange={identity.setSerialNumber}
                                    modelNumber={identity.modelNumber} onModelChange={identity.setModelNumber}
                                />
                                {showGoodsExpiryFields && (
                                    <V2ConsumableFields
                                        brand={identity.brand} onBrandChange={identity.setBrand}
                                        expiryDate={identity.expiryDate} onExpiryChange={identity.setExpiryDate}
                                        expiryAlertDays={identity.expiryAlertDays} onExpiryAlertDaysChange={identity.setExpiryAlertDays}
                                        isBulkEnabled={pkg.packaging.enabled}
                                    />

                                )}
                            </>
                        ) : (
                            <V2ConsumableFields
                                brand={identity.brand} onBrandChange={identity.setBrand}
                                expiryDate={identity.expiryDate} onExpiryChange={identity.setExpiryDate}
                                expiryAlertDays={identity.expiryAlertDays} onExpiryAlertDaysChange={identity.setExpiryAlertDays}
                                isBulkEnabled={pkg.packaging.enabled}
                            />

                        )}

                        <div ref={statusSectionRef}>
                            {(() => {
                                const masterIdx = logistics.distributions.findIndex(d => d._isMaster)
                                const safeIdx = masterIdx === -1 ? 0 : masterIdx
                                return (
                                    <V2StatusFields
                                        qtyGood={logistics.distributions[safeIdx]?.qtyGood ?? 0}
                                        setQtyGood={val => logistics.updateSiteQty(safeIdx, 'qtyGood', val)}
                                        qtyDamaged={logistics.distributions[safeIdx]?.qtyDamaged ?? 0}
                                        setQtyDamaged={val => logistics.updateSiteQty(safeIdx, 'qtyDamaged', val)}
                                        qtyMaintenance={logistics.distributions[safeIdx]?.qtyMaintenance ?? 0}
                                        setQtyMaintenance={val => logistics.updateSiteQty(safeIdx, 'qtyMaintenance', val)}
                                        qtyLost={logistics.distributions[safeIdx]?.qtyLost ?? 0}
                                        setQtyLost={val => logistics.updateSiteQty(safeIdx, 'qtyLost', val)}
                                        targetStock={thresholds.targetStock} setTargetStock={thresholds.setTargetStock}
                                        lowStockThreshold={thresholds.lowStockThreshold} setLowStockThreshold={thresholds.setLowStockThreshold}
                                        restockAlertEnabled={thresholds.restockAlertEnabled} setRestockAlertEnabled={thresholds.setRestockAlertEnabled}
                                        policyErrors={policyErrors}
                                        packaging={pkg.packaging}
                                        updatePackaging={pkg.updatePackaging}
                                        updateBatch={pkg.updateBatchUnits}
                                        updateBatchLabel={pkg.updateBatchLabel}
                                        updateBatchLocation={(idx, locId, locName) => {
                                            pkg.updateBatchLocation(idx, locId, locName)
                                            // Ensure the new location row exists in distributions
                                            if (locId && locName) logistics.addDistribution({ id: locId, location_name: locName })
                                        }}
                                        updateMultipleBatchLocations={(indices, locId, locName) => {
                                            pkg.updateMultipleBatchLocations(indices, locId, locName)
                                            if (locId && locName) logistics.addDistribution({ id: locId, location_name: locName })
                                        }}
                                        addExtraBatch={pkg.addExtraBatch}
                                        removeBatch={pkg.removeBatch}
                                        addExpiryGroup={pkg.addExpiryGroup}
                                        updateExpiryGroup={pkg.updateExpiryGroup}
                                        removeExpiryGroup={pkg.removeExpiryGroup}
                                        assignBatchToGroup={pkg.assignBatchToGroup}
                                        splitExpiryPerCarton={pkg.splitExpiryPerCarton}
                                        showPackaging={isBulkCategory}
                                        categoryName={selectedCategoryName}
                                        itemType={identity.itemType}
                                        locations={locations}
                                        globalTotal={logistics.totals.qtyGood}
                                    />
                                )
                            })()}
                        </div>

                        <V2LogisticsLedger
                            distributions={logistics.distributions}
                            onUpdateQty={logistics.updateSiteQty}
                            onRemove={logistics.removeDistribution}
                            onAdd={logistics.addDistribution}
                            onSetHome={(idx) => {
                                const newLocId = logistics.distributions[idx]?.locationId
                                logistics.setMaster(idx)
                                if (pkg.packaging.enabled && newLocId) {
                                    pkg.updatePackaging({ defaultLocationId: String(newLocId) })
                                }
                            }}
                            savedLocations={locations}
                        />
                    </div>
                </ScrollArea>

                <DialogFooter className="bg-slate-50/80 p-3 border-t border-slate-100 flex items-center justify-between rounded-b-[48px] shrink-0">
                    <Button variant="ghost" onClick={() => onOpenChange(false)} className="font-extrabold text-slate-500 h-10">
                        Cancel
                    </Button>
                    <Button
                        onClick={handleSubmit}
                        disabled={isPending || img.isUploading}
                        className="bg-slate-900 text-white rounded-3xl px-10 h-11 font-black shadow-lg"
                    >
                        {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : isEditMode ? 'Save Changes' : 'Add Item'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
