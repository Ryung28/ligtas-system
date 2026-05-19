'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'
import { addItemSchema } from '../schemas/catalog.schema'
import { ActionResult } from '@/src/shared/types'

export async function updateItem(id: number, formData: FormData): Promise<ActionResult<void>> {
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
            stock_total: Number(formData.get('stock_total')) || 0,
            stock_available: Number(formData.get('stock_available')) || 0,
            image_url: formData.get('image_url'),
            serial_number: formData.get('serial_number'),
            model_number: formData.get('model_number'),
            equipment_type: formData.get('equipment_type'),
            item_type: formData.get('item_type') || 'equipment',
            storage_location: formData.get('storage_location'),
            location_id: formData.get('location_id'),
            brand: formData.get('brand'),
            expiry_date: formData.get('expiry_date'),
            expiry_alert_days: formData.get('expiry_alert_days') ? Number(formData.get('expiry_alert_days')) : null,
            low_stock_threshold: parsedThreshold,
            target_stock: Number(formData.get('target_stock') ?? 0) || 0,
            restock_alert_enabled: restockAlertEnabled,
            qty_good: Number(formData.get('qty_good')) || 0,
            qty_damaged: Number(formData.get('qty_damaged')) || 0,
            qty_maintenance: Number(formData.get('qty_maintenance')) || 0,
            qty_lost: Number(formData.get('qty_lost')) || 0,
            packaging_json: formData.get('packaging_json') ? JSON.parse(formData.get('packaging_json') as string) : null,
        }

        const isBulkPackaging = rawData.packaging_json?.enabled === true
        const siteDistRaw = formData.get('site_distributions')
        const distributions = siteDistRaw ? JSON.parse(siteDistRaw as string) : []
        const hasDistributions = distributions.length > 0
        const masterDist = hasDistributions 
            ? (distributions.find((d: any) => d._isMaster) || distributions[0]) 
            : null

        // Guard: client totals (sum of all sites) must match sum of per-site rows (non-bulk only).
        if (!isBulkPackaging && hasDistributions) {
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

        const { data: currentItem } = await supabase.from('inventory').select('id, parent_id').eq('id', id).single()
        const clusterParentId = currentItem?.parent_id || id

        if (isBulkPackaging) {
            const stockFromManifest = (rawData.packaging_json?.batches || []).reduce((s: number, b: any) => s + (Number(b.units) || 0), 0)
            
            await supabase
                .from('inventory')
                .update({
                    item_name: rawData.name,
                    description: rawData.description,
                    category: rawData.category,
                    image_url: rawData.image_url,
                    brand: rawData.brand,
                    equipment_type: rawData.equipment_type,
                    item_type: rawData.item_type,
                    serial_number: rawData.serial_number,
                    model_number: rawData.model_number,
                    expiry_date: rawData.expiry_date,
                    expiry_alert_days: rawData.expiry_alert_days ?? null,
                    low_stock_threshold: rawData.low_stock_threshold,
                    target_stock: rawData.target_stock,
                    restock_alert_enabled: rawData.restock_alert_enabled,
                    storage_location: masterDist ? masterDist.locationName : rawData.storage_location,
                    location_registry_id: masterDist ? masterDist.locationId : rawData.location_id,
                    qty_good: stockFromManifest,
                    stock_total: stockFromManifest,
                    stock_available: stockFromManifest,
                    packaging_json: rawData.packaging_json,
                    parent_id: null,
                })
                .eq('id', clusterParentId)

            await supabase
                .from('inventory')
                .update({ deleted_at: new Date().toISOString() })
                .eq('parent_id', clusterParentId)
                .is('deleted_at', null)

        } else {
            // 🏛️ SINGULAR AUTHORITY: Protect root and implement Stock Guard
            const activeIds = [
                clusterParentId, 
                ...distributions.filter((d: any) => d.id && d.id !== clusterParentId).map((d: any) => d.id)
            ] as number[]
            
            const { data: siblings } = await supabase
                .from('inventory')
                .select('id, stock_total, storage_location')
                .or(`id.eq.${clusterParentId},parent_id.eq.${clusterParentId}`)
                .is('deleted_at', null)

            const existingIds = siblings?.map(s => s.id) || []
            const idsToDelete = existingIds.filter(eid => !activeIds.includes(eid))

            const recordsToPurge = siblings?.filter(s => idsToDelete.includes(s.id)) || []
            const blocked = recordsToPurge.find(s => (s.stock_total || 0) > 0)
            if (blocked) {
                return { 
                    data: null, 
                    error: `Cannot remove location "${blocked.storage_location}". It still contains ${blocked.stock_total} units. Transfer the stock to another location first.` 
                }
            }

            const masterPayload = {
                item_name: rawData.name,
                description: rawData.description,
                category: rawData.category,
                image_url: rawData.image_url,
                brand: rawData.brand,
                equipment_type: rawData.equipment_type,
                item_type: rawData.item_type,
                serial_number: rawData.serial_number,
                model_number: rawData.model_number,
                expiry_date: rawData.expiry_date,
                expiry_alert_days: rawData.expiry_alert_days ?? null,
                low_stock_threshold: rawData.low_stock_threshold,
                target_stock: rawData.target_stock,
                restock_alert_enabled: rawData.restock_alert_enabled,
                storage_location: masterDist.locationName,
                location_registry_id: masterDist.locationId,
                qty_good: masterDist.qtyGood,
                qty_damaged: masterDist.qtyDamaged,
                qty_maintenance: masterDist.qtyMaintenance,
                qty_lost: masterDist.qtyLost,
                stock_total: masterDist.qtyGood + masterDist.qtyDamaged + masterDist.qtyMaintenance + masterDist.qtyLost,
                stock_available: masterDist.qtyGood,
                packaging_json: null,
                parent_id: null
            }
            await supabase.from('inventory').update(masterPayload).eq('id', clusterParentId)

            const otherDists = distributions.filter((d: any) => d !== masterDist)
            for (const dist of otherDists) {
                if (dist.id && idsToDelete.includes(dist.id)) continue
                
                if (dist.id === clusterParentId) {
                    const payload = {
                        ...masterPayload,
                        storage_location: dist.locationName,
                        location_registry_id: dist.locationId,
                        qty_good: dist.qtyGood,
                        qty_damaged: dist.qtyDamaged,
                        qty_maintenance: dist.qtyMaintenance,
                        qty_lost: dist.qtyLost,
                        stock_total: dist.qtyGood + dist.qtyDamaged + dist.qtyMaintenance + dist.qtyLost,
                        stock_available: dist.qtyGood,
                        packaging_json: null,
                        parent_id: clusterParentId
                    }
                    await supabase.from('inventory').insert([payload])
                    continue
                }

                const payload = {
                    ...masterPayload,
                    storage_location: dist.locationName,
                    location_registry_id: dist.locationId,
                    qty_good: dist.qtyGood,
                    qty_damaged: dist.qtyDamaged,
                    qty_maintenance: dist.qtyMaintenance,
                    qty_lost: dist.qtyLost,
                    stock_total: dist.qtyGood + dist.qtyDamaged + dist.qtyMaintenance + dist.qtyLost,
                    stock_available: dist.qtyGood,
                    packaging_json: null,
                    parent_id: clusterParentId
                }

                if (dist.id) {
                    await supabase.from('inventory').update(payload).eq('id', dist.id)
                } else {
                    await supabase.from('inventory').insert([payload])
                }
            }

            if (masterDist.id && masterDist.id !== clusterParentId) {
                idsToDelete.push(masterDist.id)
            }

            if (idsToDelete.length > 0) {
                await supabase.from('inventory')
                    .update({ deleted_at: new Date().toISOString() })
                    .in('id', idsToDelete)
            }
        }

        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')
        return { data: undefined, error: null }
    } catch (error: any) {
        return { data: null, error: error.message || 'Failed to update item' }
    }
}

export async function updateItemLocation(itemId: number, newLocation: string): Promise<ActionResult<void>> {
    try {
        const supabase = await createSupabaseServer()
        const { error } = await supabase.from('inventory').update({ storage_location: newLocation }).eq('id', itemId)
        if (error) throw error
        revalidatePath('/dashboard/inventory')
        return { data: undefined, error: null }
    } catch (error: any) {
        return { data: null, error: error.message || 'Failed to update location' }
    }
}
