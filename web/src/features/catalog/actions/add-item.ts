'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'
import { addItemSchema } from '../schemas/catalog.schema'
import { ActionResult } from '@/src/shared/types'

export async function addItem(formData: FormData): Promise<ActionResult<void>> {
    try {
        const supabase = await createSupabaseServer()
        const thresholdRaw = formData.get('low_stock_threshold')
        const parsedThreshold = thresholdRaw === null || `${thresholdRaw}`.trim() === '' ? 20 : Number(thresholdRaw)
        const restockAlertEnabledRaw = formData.get('restock_alert_enabled')
        const restockAlertEnabled = restockAlertEnabledRaw === null ? true : `${restockAlertEnabledRaw}` === 'true'

        const rawData = {
            name: formData.get('name'),
            description: formData.get('description'),
            category: formData.get('category'),
            stock_total: formData.get('stock_total'),
            stock_available: formData.get('stock_available'),
            status: 'Good',
            image_url: formData.get('image_url'),
            serial_number: formData.get('serial_number'),
            model_number: formData.get('model_number'),
            equipment_type: formData.get('equipment_type'),
            item_type: formData.get('item_type') || 'equipment',
            storage_location: formData.get('storage_location'),
            location_registry_id: formData.get('location_id'),
            brand: formData.get('brand'),
            expiry_date: formData.get('expiry_date'),
            expiry_alert_days: formData.get('expiry_alert_days') ? Number(formData.get('expiry_alert_days')) : null,
            parent_id: formData.get('parent_id'),
            variant_label: formData.get('variant_label'),
            low_stock_threshold: parsedThreshold,
            target_stock: Number(formData.get('target_stock') ?? 0) || 0,
            restock_alert_enabled: restockAlertEnabled,
            qty_good: Number(formData.get('qty_good')) || Number(formData.get('stock_total')) || 0,
            qty_damaged: Number(formData.get('qty_damaged')) || 0,
            qty_maintenance: Number(formData.get('qty_maintenance')) || 0,
            qty_lost: Number(formData.get('qty_lost')) || 0,
            packaging_json: formData.get('packaging_json') ? JSON.parse(formData.get('packaging_json') as string) : null,
        }

        const calculatedTotal = Number(rawData.qty_good) + Number(rawData.qty_damaged) + Number(rawData.qty_maintenance) + Number(rawData.qty_lost)
        const finalStockTotal = Math.max(Number(rawData.stock_total) || 0, calculatedTotal)
        
        const finalRawData = {
            ...rawData,
            stock_total: finalStockTotal,
            stock_available: Number(rawData.qty_good)
        }

        const validatedData = addItemSchema.parse(finalRawData)

        let baseName = validatedData.name
        let finalParentId = null
        let finalVariantLabel = validatedData.variant_label

        if (finalVariantLabel) {
            const { data: existingParent } = await supabase
                .from('inventory')
                .select('id')
                .eq('base_name', baseName)
                .is('parent_id', null)
                .is('variant_label', null)
                .single()

            if (existingParent) {
                finalParentId = existingParent.id
            } else {
                const { data: newParent, error: parentError } = await supabase
                    .from('inventory')
                    .insert([{
                        item_name: baseName,
                        base_name: baseName,
                        parent_id: null,
                        variant_label: null,
                        description: validatedData.description,
                        model_number: validatedData.model_number,
                        category: validatedData.category,
                        stock_total: 0,
                        stock_available: 0,
                        qty_good: 0,
                        qty_damaged: 0,
                        qty_maintenance: 0,
                        qty_lost: 0,
                        status: 'Good',
                        image_url: validatedData.image_url,
                        serial_number: validatedData.serial_number,
                        equipment_type: validatedData.equipment_type,
                        item_type: validatedData.item_type,
                        storage_location: validatedData.storage_location,
                        brand: validatedData.brand,
                        expiry_date: validatedData.expiry_date,
                        expiry_alert_days: validatedData.expiry_alert_days ?? null,
                        low_stock_threshold: validatedData.low_stock_threshold,
                        target_stock: validatedData.target_stock,
                        restock_alert_enabled: restockAlertEnabled,
                        packaging_json: rawData.packaging_json,
                    }])
                    .select()
                    .single()

                if (parentError || !newParent) throw new Error('Failed to create parent item')
                finalParentId = newParent.id
            }
        }

        const siteDistRaw = formData.get('site_distributions')
        const distributions = siteDistRaw ? JSON.parse(siteDistRaw as string) : []
        const hasDistributions = distributions.length > 0
        const masterDist = hasDistributions 
            ? (distributions.find((d: any) => d._isMaster) || distributions[0]) 
            : null

        const isBulkItem = rawData.packaging_json?.enabled === true

        if (!isBulkItem && hasDistributions) {
            const sumBucket = (key: string) =>
                distributions.reduce((s: number, d: any) => s + (Number(d[key]) || 0), 0)
            const g = sumBucket('qtyGood')
            const d = sumBucket('qtyDamaged')
            const m = sumBucket('qtyMaintenance')
            const l = sumBucket('qtyLost')
            if (
                g !== (Number(rawData.qty_good) || 0) ||
                d !== (Number(rawData.qty_damaged) || 0) ||
                m !== (Number(rawData.qty_maintenance) || 0) ||
                l !== (Number(rawData.qty_lost) || 0)
            ) {
                return {
                    data: null,
                    error:
                        'Stock totals do not match the per-site breakdown. Refresh the item and try again, or adjust site rows so they add up to the totals.',
                }
            }
        }

        const basePayload = {
            item_name: validatedData.name,
            base_name: baseName,
            parent_id: finalParentId,
            variant_label: finalVariantLabel,
            description: validatedData.description,
            model_number: validatedData.model_number,
            category: validatedData.category,
            status: 'Good',
            image_url: validatedData.image_url,
            serial_number: validatedData.serial_number,
            equipment_type: validatedData.equipment_type,
            item_type: validatedData.item_type,
            brand: validatedData.brand,
            expiry_date: validatedData.expiry_date,
            expiry_alert_days: validatedData.expiry_alert_days ?? null,
            low_stock_threshold: validatedData.low_stock_threshold,
            target_stock: validatedData.target_stock,
            restock_alert_enabled: restockAlertEnabled,
        }

        const stockFromManifest = isBulkItem
            ? (rawData.packaging_json?.batches || []).reduce((s: number, b: any) => s + (Number(b.units) || 0), 0)
            : null

        const masterPayload = {
            ...basePayload,
            storage_location: masterDist ? masterDist.locationName : validatedData.storage_location,
            location_registry_id: masterDist ? masterDist.locationId : validatedData.location_id,
            qty_good: stockFromManifest ?? (masterDist ? masterDist.qtyGood : rawData.qty_good),
            qty_damaged: masterDist ? masterDist.qtyDamaged : rawData.qty_damaged,
            qty_maintenance: masterDist ? masterDist.qtyMaintenance : rawData.qty_maintenance,
            qty_lost: masterDist ? masterDist.qtyLost : rawData.qty_lost,
            packaging_json: isBulkItem ? partitionPackagingJson(rawData.packaging_json, masterDist?.locationId, true) : null,
        }

        const { data: mainItem, error: mainError } = await supabase
            .from('inventory')
            .insert([{
                ...masterPayload,
                stock_total: Number(masterPayload.qty_good) + Number(masterPayload.qty_damaged) + Number(masterPayload.qty_maintenance) + Number(masterPayload.qty_lost),
                stock_available: Number(masterPayload.qty_good)
            }])
            .select()
            .single()

        if (mainError) throw mainError

        if (hasDistributions) {
            const otherDists = distributions.filter((d: any) => d !== masterDist)
            for (const dist of otherDists) {
                const childPayload = {
                    ...basePayload,
                    parent_id: mainItem.id,
                    storage_location: dist.locationName,
                    location_registry_id: dist.locationId,
                    qty_good: dist.qtyGood,
                    qty_damaged: dist.qtyDamaged,
                    qty_maintenance: dist.qtyMaintenance,
                    qty_lost: dist.qtyLost,
                    stock_total: Number(dist.qtyGood) + Number(dist.qtyDamaged) + Number(dist.qtyMaintenance) + Number(dist.qtyLost),
                    stock_available: Number(dist.qtyGood),
                    packaging_json: isBulkItem ? partitionPackagingJson(rawData.packaging_json, dist.locationId) : null,
                }
                await supabase.from('inventory').insert([childPayload])
            }
        }

        revalidatePath('/dashboard/inventory')
        return { data: undefined, error: null }
    } catch (error: any) {
        return { data: null, error: error.message || 'Failed to add item' }
    }
}

function partitionPackagingJson(globalPackaging: any, locationId: number | string | null, isPrimary: boolean = false) {
    if (!globalPackaging || !globalPackaging.enabled || !globalPackaging.batches) return globalPackaging
    const targetLocId = locationId ? String(locationId) : null
    const filteredBatches = globalPackaging.batches.filter((b: any) => {
        const batchLocId = b.locationId ? String(b.locationId) : null
        if (batchLocId === targetLocId) return true
        if (isPrimary && batchLocId === null) return true
        return false
    })
    const filteredBatchIds = new Set(filteredBatches.map((b: any) => b.id))
    let filteredGroups = globalPackaging.expiry_groups
    if (filteredGroups) {
        filteredGroups = filteredGroups
            .map((g: any) => ({
                ...g,
                batch_ids: g.batch_ids.filter((id: string) => filteredBatchIds.has(id))
            }))
            .filter((g: any) => g.batch_ids.length > 0)
    }
    return {
        ...globalPackaging,
        batches: filteredBatches,
        containerCount: filteredBatches.length,
        expiry_groups: filteredGroups
    }
}
