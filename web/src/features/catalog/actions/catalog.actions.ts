'use server'

import { revalidatePath } from 'next/cache'
import { supabase } from '@/lib/supabase'
import { createSupabaseServer } from '@/lib/supabase-server'
import { z } from 'zod'
import { addItemSchema, siteDistributionSchema } from '../schemas/catalog.schema'

/**
 * Helper to partition a bulk packaging manifest for a specific location.
 * Ensures that a location's inventory record only contains its own allocated boxes.
 */
function partitionPackagingJson(globalPackaging: any, locationId: number | string | null, isPrimary: boolean = false) {
    if (!globalPackaging || !globalPackaging.enabled || !globalPackaging.batches) return globalPackaging

    // 🛡️ TYPE COERCION SAFEGUARD: Convert all IDs to strings for robust comparison
    const targetLocId = locationId ? String(locationId) : null
    
    const filteredBatches = globalPackaging.batches.filter((b: any) => {
        const batchLocId = b.locationId ? String(b.locationId) : null
        
        // 1. Exact match (Explicitly assigned to this warehouse)
        if (batchLocId === targetLocId) return true

        // 2. Default/Orphan rescue (If box is "Default", it lives on the Primary Record)
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

/**
 * CATALOG DOMAIN - Mutation Actions
 */

export async function addItem(formData: FormData) {
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
        // 🏛️ SINGULAR AUTHORITY: Find the distribution explicitly marked as master
        const masterDist = hasDistributions 
            ? (distributions.find((d: any) => d._isMaster) || distributions[0]) 
            : null

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

        const isBulkItem = rawData.packaging_json?.enabled === true

        // 🏛️ SINGULAR AUTHORITY: For bulk items, derive stock from the manifest.
        // For non-bulk, use distribution totals or raw qty fields.
        const stockFromManifest = isBulkItem
            ? (rawData.packaging_json?.batches || []).reduce((s: number, b: any) => s + (Number(b.units) || 0), 0)
            : null

        const masterPayload = {
            ...basePayload,
            // Location: first distribution or the form field
            storage_location: masterDist ? masterDist.locationName : validatedData.storage_location,
            location_registry_id: masterDist ? masterDist.locationId : validatedData.location_id,
            // Stock: manifest-derived for bulk, distribution-based for non-bulk
            qty_good: stockFromManifest ?? (masterDist ? masterDist.qtyGood : rawData.qty_good),
            qty_damaged: isBulkItem ? 0 : (masterDist ? masterDist.qtyDamaged : rawData.qty_damaged),
            qty_maintenance: isBulkItem ? 0 : (masterDist ? masterDist.qtyMaintenance : rawData.qty_maintenance),
            qty_lost: isBulkItem ? 0 : (masterDist ? masterDist.qtyLost : rawData.qty_lost),
            stock_total: stockFromManifest ?? (masterDist
                ? (masterDist.qtyGood + masterDist.qtyDamaged + masterDist.qtyMaintenance + masterDist.qtyLost)
                : finalStockTotal),
            stock_available: stockFromManifest ?? (masterDist ? masterDist.qtyGood : rawData.qty_good),
            // 🏛️ SINGULAR AUTHORITY: Full manifest always lives on the one parent row.
            packaging_json: rawData.packaging_json,
        }

        const { data: newItem, error } = await supabase.from('inventory').insert([masterPayload]).select().single()
        if (error || !newItem) throw new Error('Failed to add master item')

        // 🏛️ SINGULAR AUTHORITY: Never create child rows for bulk items.
        // Location data lives in the manifest batches (batch.locationId), not in sibling rows.
        if (!isBulkItem && hasDistributions && distributions.length > 1) {
            const siblings = distributions.slice(1).map((dist: any) => ({
                ...basePayload,
                parent_id: newItem.id,
                storage_location: dist.locationName,
                location_registry_id: dist.locationId,
                qty_good: dist.qtyGood,
                qty_damaged: dist.qtyDamaged,
                qty_maintenance: dist.qtyMaintenance,
                qty_lost: dist.qtyLost,
                stock_total: dist.qtyGood + dist.qtyDamaged + dist.qtyMaintenance + dist.qtyLost,
                stock_available: dist.qtyGood,
                packaging_json: null,
            }))
            const { error: siblingError } = await supabase.from('inventory').insert(siblings)
            if (siblingError) throw siblingError
        }

        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')
        return { success: true, data: newItem }
    } catch (error: any) {
        return { success: false, error: error.message || 'An unexpected error occurred' }
    }
}

export async function updateItem(formData: FormData) {
    try {
        const supabase = await createSupabaseServer()
        const id = formData.get('id')
        if (!id) throw new Error('Item ID is required')
        
        const thresholdRaw = formData.get('low_stock_threshold')
        const parsedThreshold = thresholdRaw === null || `${thresholdRaw}`.trim() === '' ? 20 : Number(thresholdRaw)
        const restockAlertEnabledRaw = formData.get('restock_alert_enabled')
        const restockAlertEnabled = restockAlertEnabledRaw === null ? true : `${restockAlertEnabledRaw}` === 'true'

        const rawData = {
            name: String(formData.get('name') || ''),
            description: formData.get('description') ? String(formData.get('description')) : null,
            category: String(formData.get('category') || ''),
            storage_location: formData.get('storage_location') ? String(formData.get('storage_location')) : null,
            image_url: formData.get('image_url') ? String(formData.get('image_url')) : null,
            serial_number: formData.get('serial_number') ? String(formData.get('serial_number')) : null,
            model_number: formData.get('model_number') ? String(formData.get('model_number')) : null,
            equipment_type: formData.get('equipment_type') ? String(formData.get('equipment_type')) : null,
            brand: formData.get('brand') ? String(formData.get('brand')) : null,
            expiry_date: formData.get('expiry_date') ? String(formData.get('expiry_date')) : null,
            expiry_alert_days: formData.get('expiry_alert_days') ? Number(formData.get('expiry_alert_days')) : null,
            low_stock_threshold: parsedThreshold,
            target_stock: Number(formData.get('target_stock') ?? 0) || 0,
            restock_alert_enabled: restockAlertEnabled,
            item_type: String(formData.get('item_type') || 'equipment'),
            qty_good: Number(formData.get('qty_good')) || 0,
            qty_damaged: Number(formData.get('qty_damaged')) || 0,
            qty_maintenance: Number(formData.get('qty_maintenance')) || 0,
            qty_lost: Number(formData.get('qty_lost')) || 0,
            packaging_json: formData.get('packaging_json') ? JSON.parse(formData.get('packaging_json') as string) : null,
            location_registry_id: formData.get('location_id') ? String(formData.get('location_id')) : null,
        }

        const siteDistRaw = formData.get('site_distributions')
        const distributions = siteDistRaw ? JSON.parse(siteDistRaw as string) as any[] : []
        const masterDist = distributions.find((d: any) => d._isMaster) || distributions[0] || null

        const { data: itemBefore, error: fetchError } = await supabase
            .from('inventory')
            .select('id, item_name, category, parent_id')
            .eq('id', id)
            .single()

        if (fetchError || !itemBefore) throw new Error('Could not find item to update')

        const isBulkItem = rawData.packaging_json?.enabled === true
        const clusterParentId = itemBefore.parent_id || itemBefore.id

        if (isBulkItem) {
            // 🏛️ SINGULAR AUTHORITY: Bulk item — one row, one manifest.
            // Derive all stock from the manifest. Soft-delete any existing children.
            const manifestBatches = rawData.packaging_json?.batches || []
            const stockFromManifest = manifestBatches.reduce((s: number, b: any) => s + (Number(b.units) || 0), 0)

            const { error: updateError } = await supabase
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
                    // 🛰️ Location Authority
                    storage_location: masterDist ? masterDist.locationName : rawData.storage_location,
                    location_registry_id: masterDist ? masterDist.locationId : rawData.location_id,
                    // Stock is manifest-derived, not from distribution fields
                    qty_good: stockFromManifest,
                    qty_damaged: 0,
                    qty_maintenance: 0,
                    qty_lost: 0,
                    stock_total: stockFromManifest,
                    stock_available: stockFromManifest,
                    // Full manifest always on the parent
                    packaging_json: rawData.packaging_json,
                    // Ensure this is the root row
                    parent_id: null,
                    status: 'Good',
                })
                .eq('id', clusterParentId)
            if (updateError) throw updateError

            // Purge all child rows — they are no longer part of the model
            await supabase
                .from('inventory')
                .update({ deleted_at: new Date().toISOString() })
                .eq('parent_id', clusterParentId)
                .is('deleted_at', null)

        } else {
            if (distributions.length > 0) {
                // 🏛️ SINGULAR AUTHORITY: Identify the master distribution
                const activeIds = distributions.filter((d: any) => d.id).map((d: any) => d.id) as number[]
                
                const { data: siblings } = await supabase
                    .from('inventory')
                    .select('id')
                    .or(`id.eq.${clusterParentId},parent_id.eq.${clusterParentId}`)

                const existingIds = siblings?.map(s => s.id) || []
                const idsToDelete = existingIds.filter(eid => !activeIds.includes(eid))

                // ── 1. Update the Master (Root) Row ──
                // The master row is always the one with id === clusterParentId
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
                    status: 'Good',
                    packaging_json: rawData.packaging_json,
                    parent_id: null
                }
                const { error: masterError } = await supabase.from('inventory').update(masterPayload).eq('id', clusterParentId)
                if (masterError) throw masterError

                // ── 2. Sync Sibling Rows ──
                // All other distributions are children of the root row
                const otherDists = distributions.filter(d => d !== masterDist)
                for (const dist of otherDists) {
                    if (dist.id && idsToDelete.includes(dist.id)) continue
                    
                    // If the master we just set was previously a sibling, we need to delete its old row 
                    // because its data is now merged into the master root row.
                    if (dist.id === clusterParentId) {
                        // This case handles when the old master is now a sibling.
                        // It needs a NEW row because the old row ID is taken by the new master data.
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
                        const { error: insertError } = await supabase.from('inventory').insert([payload])
                        if (insertError) throw insertError
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

                    const { error: dbError } = dist.id
                        ? await supabase.from('inventory').update(payload).eq('id', dist.id)
                        : await supabase.from('inventory').insert([payload])
                    if (dbError) throw dbError
                }

                // ── 3. Cleanup ──
                // If the new master was previously a sibling, delete its old sibling row
                if (masterDist.id && masterDist.id !== clusterParentId) {
                    idsToDelete.push(masterDist.id)
                }

                if (idsToDelete.length > 0) {
                    await supabase.from('inventory')
                        .update({ deleted_at: new Date().toISOString() })
                        .in('id', idsToDelete)
                }
            } else {
                const { error: updateError } = await supabase
                    .from('inventory')
                    .update({
                        ...rawData,
                        stock_total: rawData.qty_good + rawData.qty_damaged + rawData.qty_maintenance + rawData.qty_lost,
                        stock_available: rawData.qty_good,
                    })
                    .eq('id', id)
                if (updateError) throw updateError
            }
        }

        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')
        return { success: true, message: 'Inventory updated' }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to save changes' }
    }
}

export async function updateItemLocation(itemId: number, newLocation: string) {
    try {
        const supabase = await createSupabaseServer()
        const { error } = await supabase.from('inventory').update({ storage_location: newLocation }).eq('id', itemId)
        if (error) throw error
        revalidatePath('/dashboard/inventory')
        return { success: true }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to update location' }
    }
}

export async function deleteItem(id: number) {
    try {
        const supabase = await createSupabaseServer()
        const { data: activeBorrows } = await supabase.from('borrow_logs').select('id').eq('inventory_id', id).eq('status', 'borrowed')
        if (activeBorrows && activeBorrows.length > 0) return { success: false, error: 'Active checkouts exist' }
        
        const { error } = await supabase.from('inventory').update({ deleted_at: new Date().toISOString() }).eq('id', id)
        if (error) throw error
        
        revalidatePath('/dashboard/inventory')
        return { success: true, message: 'Item deleted successfully' }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to delete item' }
    }
}

export async function bulkDeleteItem(ids: number[]) {
    try {
        if (!ids.length) return { success: true }
        const supabase = await createSupabaseServer()
        
        // 🛡️ BATCH VALIDATION: Check for active borrows across all items
        const { data: activeBorrows } = await supabase
            .from('borrow_logs')
            .select('inventory_id')
            .in('inventory_id', ids)
            .eq('status', 'borrowed')
            
        if (activeBorrows && activeBorrows.length > 0) {
            return { success: false, error: 'Some items have active checkouts and cannot be deleted.' }
        }

        const { error } = await supabase
            .from('inventory')
            .update({ deleted_at: new Date().toISOString() })
            .in('id', ids)
            
        if (error) throw error
        
        revalidatePath('/dashboard/inventory')
        return { success: true, message: `Successfully deleted ${ids.length} item(s)` }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to perform bulk delete' }
    }
}

export async function splitInventoryItem(id: number, _splitQty: number, _targetStatus: string) {
    return { success: false, error: "Deprecated." }
}

export async function getInventoryAlerts() {
    try {
        const { data, error } = await supabase.from('v_inventory_actionable_alerts').select('*').eq('needs_action', true)
        if (error) throw error
        const alerts = data || []
        const summary = {
            out_of_stock: alerts.filter(i => i.is_out_of_stock).length,
            low_stock: alerts.filter(i => i.is_low_stock).length,
            expiring_soon: alerts.filter(i => i.is_expiring).length,
            expired: alerts.filter(i => i.is_expired).length,
            damaged: alerts.filter(i => i.is_damaged).length,
            maintenance: alerts.filter(i => i.is_maintenance).length,
            missing: alerts.filter(i => i.is_missing).length,
            total_active_alerts: alerts.length
        }
        return { success: true, data: summary, items: alerts.slice(0, 10) }
    } catch (error) {
        return { success: false, error: 'An unexpected error occurred.' }
    }
}
