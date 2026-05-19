'use client'

import { useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { addItem, updateItem } from '@/src/features/catalog'
import type { CatalogPackaging, CatalogDistribution, CatalogTotals } from '../types'

interface SubmitPayload {
    itemId?: number
    identity: {
        name: string
        description: string
        categoryId: string
        itemType: string
        serialNumber: string
        modelNumber: string
        brand: string
        expiryDate: string
        expiryAlertDays: number | string
    }
    thresholds: {
        targetStock: number | string
        lowStockThreshold: number | string
        restockAlertEnabled: boolean
    }
    packaging: CatalogPackaging
    distributions: CatalogDistribution[]
    totals: CatalogTotals
    imageUrl: string
}

/**
 * CATALOG ITEM DIALOG V3 — Submit Hook
 * Builds FormData from domain state and dispatches to the correct Server Action.
 * add mode  → itemId is undefined → calls addItem
 * edit mode → itemId is present  → calls updateItem
 */
export function useCatalogSubmit(onSuccess: () => void) {
    const [isPending, startTransition] = useTransition()
    const router = useRouter()

    const submit = (payload: SubmitPayload) => {
        // 🎯 Final Safety: Resolve the actual Main Location by flag
        const primarySite = payload.distributions.find(d => d._isMaster) || payload.distributions[0]
        
        if (!primarySite?.locationId) {
            toast.error('Please select a storage location.')
            return
        }

        startTransition(async () => {
            try {
                const fd = new FormData()

                // Mode flag
                const isEdit = !!payload.itemId
                if (isEdit) fd.append('id', String(payload.itemId))

                // Identity
                fd.append('name', payload.identity.name)
                fd.append('description', payload.identity.description || '')
                fd.append('category', payload.identity.categoryId)
                fd.append('item_type', payload.identity.itemType)
                fd.append('serial_number', payload.identity.serialNumber)
                fd.append('model_number', payload.identity.modelNumber)
                fd.append('brand', payload.identity.brand)
                fd.append('image_url', payload.imageUrl || '')

                // Expiry — prefer packaging group dates if present
                const packagingExpiryDates = (payload.packaging.expiry_groups || [])
                    .map(g => g.expiry_date)
                    .filter(Boolean)
                    .sort()
                const resolvedExpiry = packagingExpiryDates[0] || payload.identity.expiryDate
                if (resolvedExpiry) fd.append('expiry_date', resolvedExpiry)
                if (resolvedExpiry && payload.identity.expiryAlertDays) {
                    fd.append('expiry_alert_days', String(payload.identity.expiryAlertDays))
                }

                // Stock buckets (from totals — source of truth)
                fd.set('qty_good', String(payload.totals.qtyGood))
                fd.set('qty_damaged', String(payload.totals.qtyDamaged))
                fd.set('qty_maintenance', String(payload.totals.qtyMaintenance))
                fd.set('qty_lost', String(payload.totals.qtyLost))
                fd.set('stock_total', String(payload.totals.total))
                fd.set('stock_available', String(payload.totals.qtyGood))

                // Thresholds
                fd.set('target_stock', String(payload.thresholds.targetStock))
                fd.set('low_stock_threshold', String(payload.thresholds.lowStockThreshold))
                fd.set('restock_alert_enabled', String(payload.thresholds.restockAlertEnabled))

                // Packaging manifest
                fd.set('packaging_json', JSON.stringify(payload.packaging))

                // 🎯 Resolve the actual Main Location by flag, not index
                const masterIdx = payload.distributions.findIndex(d => d._isMaster)
                const finalMasterIdx = masterIdx !== -1 ? masterIdx : 0
                
                const finalDistributions = payload.distributions.map((d, i) => ({
                    ...d,
                    _isMaster: i === finalMasterIdx
                }))

                const primarySite = finalDistributions[finalMasterIdx]
                
                // Site distributions
                fd.set('site_distributions', JSON.stringify(finalDistributions))
                
                if (primarySite?.locationId) fd.append('location_id', String(primarySite.locationId))
                if (primarySite?.locationName) fd.append('storage_location', primarySite.locationName)

                const result = isEdit 
                    ? await updateItem(Number(payload.itemId), fd) 
                    : await addItem(fd)

                if (result.error === null) {
                    toast.success(isEdit ? 'Item updated' : 'Item added')
                    onSuccess()
                    router.refresh()
                } else {
                    toast.error(result.error || 'Check inventory permissions')
                }
            } catch (err) {
                console.error('[CatalogSubmit] Fatal:', err)
                toast.error('System failure during sync')
            }
        })
    }

    return { submit, isPending }
}
