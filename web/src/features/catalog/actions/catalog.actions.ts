'use server'

import { revalidatePath } from 'next/cache'
import { supabase } from '@/lib/supabase'
import { createSupabaseServer } from '@/lib/supabase-server'
import { z } from 'zod'
import { addItemSchema } from '../schemas/catalog.schema'

/**
 * CATALOG DOMAIN - Mutation Actions
 * 
 * Create, Update, Delete operations for inventory items.
 * Includes variant logic and tactical safeguards.
 */

export async function addItem(formData: FormData) {
    try {
        // 🔐 SESSION-AWARE CLIENT: Required for RLS to pass auth.uid() checks
        const supabase = await createSupabaseServer()
        const thresholdRaw = formData.get('low_stock_threshold')
        const parsedThreshold =
            thresholdRaw === null || `${thresholdRaw}`.trim() === '' ? 20 : Number(thresholdRaw)
        const restockAlertEnabledRaw = formData.get('restock_alert_enabled')
        const restockAlertEnabled =
            restockAlertEnabledRaw === null ? true : `${restockAlertEnabledRaw}` === 'true'

        // Parse and validate form data
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
            location_id: formData.get('location_id'),
            brand: formData.get('brand'),
            expiry_date: formData.get('expiry_date'),
            expiry_alert_days: formData.get('expiry_alert_days') ? Number(formData.get('expiry_alert_days')) : null,
            parent_id: formData.get('parent_id'),
            variant_label: formData.get('variant_label'),
            low_stock_threshold: parsedThreshold,
            target_stock: Number(formData.get('target_stock') ?? 0) || 0,
            restock_alert_enabled: restockAlertEnabled,
            // Enterprise Sub-Buckets
            qty_good: Number(formData.get('qty_good')) || Number(formData.get('stock_total')) || 0,
            qty_damaged: Number(formData.get('qty_damaged')) || 0,
            qty_maintenance: Number(formData.get('qty_maintenance')) || 0,
            qty_lost: Number(formData.get('qty_lost')) || 0,
            packaging_json: formData.get('packaging_json') ? JSON.parse(formData.get('packaging_json') as string) : null,
        }

        // 🛡️ RECONCILIATION: Ensure stock_total matches the sum of buckets
        const calculatedTotal = Number(rawData.qty_good) + Number(rawData.qty_damaged) + Number(rawData.qty_maintenance) + Number(rawData.qty_lost)
        const finalStockTotal = Math.max(Number(rawData.stock_total) || 0, calculatedTotal)
        
        // Finalize rawData for validation
        const finalRawData = {
            ...rawData,
            stock_total: finalStockTotal,
            stock_available: Number(rawData.qty_good)
        }

        const validatedData = addItemSchema.parse(finalRawData)

        // Validate that current stock doesn't exceed total stock
        if (validatedData.stock_available > finalStockTotal) {
            return {
                success: false,
                error: 'Current stock cannot exceed fixed total stock',
            }
        }

        // Handle variant logic - Auto-create parent if variant specified
        let baseName = validatedData.name
        let finalParentId = null
        let finalVariantLabel = validatedData.variant_label

        if (finalVariantLabel) {
            // User wants to create a variant - auto-create parent
            baseName = validatedData.name // Use item name as base
            
            // Check if parent already exists with this base_name
            const { data: existingParent } = await supabase
                .from('inventory')
                .select('id')
                .eq('base_name', baseName)
                .is('parent_id', null)
                .is('variant_label', null)
                .single()

            if (existingParent) {
                // Parent exists, use it
                finalParentId = existingParent.id
            } else {
                // Create new parent
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

                if (parentError || !newParent) {
                    console.error('Failed to create parent:', parentError)
                    return {
                        success: false,
                        error: 'Failed to create parent item',
                    }
                }

                finalParentId = newParent.id
            }
        }

        // Insert into Supabase
        const { data, error } = await supabase.from('inventory').insert([
            {
                item_name: validatedData.name,
                base_name: baseName,
                parent_id: finalParentId,
                variant_label: finalVariantLabel,
                description: validatedData.description,
                model_number: validatedData.model_number,
                category: validatedData.category,
                stock_total: finalStockTotal,
                stock_available: rawData.qty_good, // Available is strictly Ready for Deployment
                qty_good: rawData.qty_good,
                qty_damaged: rawData.qty_damaged,
                qty_maintenance: rawData.qty_maintenance,
                qty_lost: rawData.qty_lost,
                status: 'Good', // Base status is Good; sub-buckets handle triage
                packaging_json: (rawData as any).packaging_json,
                image_url: validatedData.image_url,
                serial_number: validatedData.serial_number,
                equipment_type: validatedData.equipment_type,
                item_type: validatedData.item_type,
                storage_location: validatedData.storage_location,
                location_registry_id: validatedData.location_id,
                brand: validatedData.brand,
                expiry_date: validatedData.expiry_date,
                expiry_alert_days: validatedData.expiry_alert_days ?? null,
                low_stock_threshold: validatedData.low_stock_threshold,
                target_stock: validatedData.target_stock,
                restock_alert_enabled: restockAlertEnabled,
            },
        ]).select()

        if (error) {
            console.error('Supabase error:', error)
            return {
                success: false,
                error: 'Failed to add item to database',
            }
        }

        const newItem = data[0]

        // 🏛️ Handle Initial Distribution if provided
        const siteDistRaw = formData.get('site_distributions')
        if (siteDistRaw) {
            try {
                const distributions = JSON.parse(siteDistRaw as string)
                if (distributions.length > 1) {
                    // Create siblings for other sites (skip the first one as it's the primary just created)
                    const siblings = distributions.slice(1).map((dist: any) => ({
                        ...newItem,
                        id: undefined, // Let DB generate ID
                        storage_location: dist.locationName,
                        location_registry_id: dist.locationId,
                        qty_good: dist.qtyGood,
                        qty_damaged: dist.qtyDamaged,
                        qty_maintenance: dist.qtyMaintenance,
                        qty_lost: dist.qtyLost,
                        stock_total: dist.qtyGood + dist.qtyDamaged + dist.qtyMaintenance + dist.qtyLost,
                        stock_available: dist.qtyGood
                    }))
                    
                    await supabase.from('inventory').insert(siblings)
                }
            } catch (e) {
                console.error('Error processing initial distribution:', e)
            }
        }

        if (error) {
            console.error('Supabase error:', error)
            return {
                success: false,
                error: 'Failed to add item to database',
            }
        }

        // Revalidate the inventory page to show new data
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        return {
            success: true,
            data: data[0],
            message: finalVariantLabel ? `Variant "${baseName} (${finalVariantLabel})" added successfully` : 'Item added successfully',
        }
    } catch (error) {
        if (error instanceof z.ZodError) {
            return {
                success: false,
                error: error.errors[0].message,
            }
        }

        console.error('Unexpected error:', error)
        return {
            success: false,
            error: 'An unexpected error occurred',
        }
    }
}

export async function bulkAddItems(items: Array<{
    name: string
    category: string
    item_type?: string
    stock_total: number
    stock_available?: number
    qty_good?: number
    qty_damaged?: number
    qty_maintenance?: number
    qty_lost?: number
    status: string
    storage_location?: string
    serial_number?: string
    model_number?: string
    brand?: string
    expiry_date?: string
    expiry_alert_days?: number
    description?: string
}>) {
    try {
        const supabase = await createSupabaseServer()
        const validatedItems = z.array(addItemSchema).parse(items)

        const insertData = validatedItems.map(item => ({
            item_name: item.name,
            description: item.description ?? null,
            category: item.category,
            item_type: item.item_type ?? 'equipment',
            stock_total: item.stock_total,
            stock_available: item.qty_good ?? item.stock_available ?? item.stock_total,
            qty_good: item.qty_good ?? item.stock_available ?? item.stock_total,
            qty_damaged: item.qty_damaged ?? 0,
            qty_maintenance: item.qty_maintenance ?? 0,
            qty_lost: item.qty_lost ?? 0,
            status: item.status,
            storage_location: item.storage_location ?? null,
            serial_number: item.serial_number ?? null,
            model_number: item.model_number ?? null,
            brand: item.brand ?? null,
            expiry_date: item.expiry_date ?? null,
            expiry_alert_days: item.expiry_alert_days ?? null,
        }))

        const { data, error } = await supabase.from('inventory').insert(insertData).select()

        if (error) {
            console.error('Supabase bulk insert error:', error)
            return { success: false, error: 'Failed to insert items. Please check your data.' }
        }

        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        return {
            success: true,
            count: data.length,
            message: `Successfully added ${data.length} items`,
        }
    } catch (error: any) {
        if (error instanceof z.ZodError) {
            return { success: false, error: 'Validation failed: ' + error.errors[0].message }
        }
        return { success: false, error: 'An unexpected error occurred' }
    }
}

import { siteDistributionSchema } from '../schemas/catalog.schema'

export async function updateItem(formData: FormData) {
    try {
        // 🔐 SESSION-AWARE CLIENT: Required for RLS to pass auth.uid() checks
        const supabase = await createSupabaseServer()
        const id = formData.get('id')
        if (!id) throw new Error('Item ID is required')
        const thresholdRaw = formData.get('low_stock_threshold')
        const parsedThreshold =
            thresholdRaw === null || `${thresholdRaw}`.trim() === '' ? 20 : Number(thresholdRaw)
        const restockAlertEnabledRaw = formData.get('restock_alert_enabled')
        const restockAlertEnabled =
            restockAlertEnabledRaw === null ? true : `${restockAlertEnabledRaw}` === 'true'

        // 1. Data Extraction & Coercion
        const rawData = {
            name: String(formData.get('name') || ''),
            description: formData.get('description') ? String(formData.get('description')) : null,
            category: String(formData.get('category') || ''),
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
        }

        // 🔒 IDENTITY LOCK: Get current name/category for targeting siblings
        const { data: itemBefore, error: fetchError } = await supabase
            .from('inventory')
            .select('id, item_name, category, parent_id')
            .eq('id', id)
            .single()

        if (fetchError || !itemBefore) throw new Error('Could not find item to update')

        const siteDistRaw = formData.get('site_distributions')
        
        if (siteDistRaw) {
            // 🛡️ ZOD VALIDATION (Rule 21)
            const distributions = z.array(siteDistributionSchema).parse(JSON.parse(siteDistRaw as string))
            const activeIds = distributions.filter(d => d.id).map(d => d.id) as number[]

            // 1. Identify Deletions
            const { data: siblings } = await supabase
                .from('inventory')
                .select('id')
                .eq('item_name', itemBefore.item_name)
                .eq('category', itemBefore.category)

            const existingIds = siblings?.map(s => s.id) || []
            const idsToDelete = existingIds.filter(eid => !activeIds.includes(eid))

            // 2. Verified Sequential Sync (Rule 62)
            const parentIdToUse = itemBefore.parent_id || itemBefore.id
            for (const dist of distributions) {
                const payload = {
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
                    storage_location: dist.locationName,
                    location_registry_id: dist.locationId,
                    qty_good: dist.qtyGood,
                    qty_damaged: dist.qtyDamaged,
                    qty_maintenance: dist.qtyMaintenance,
                    qty_lost: dist.qtyLost,
                    stock_total: dist.qtyGood + dist.qtyDamaged + dist.qtyMaintenance + dist.qtyLost,
                    stock_available: dist.qtyGood,
                    status: 'Good',
                    packaging_json: rawData.packaging_json,
                    // If inserting a news distribution, link it to the current item's parent cluster
                    parent_id: dist.id === itemBefore.id ? itemBefore.parent_id : parentIdToUse
                }

                const { error: dbError } = dist.id 
                    ? await supabase.from('inventory').update(payload).eq('id', dist.id)
                    : await supabase.from('inventory').insert([payload])

                if (dbError) throw new Error(`Sync Error: ${dbError.message}`)
            }

            // 3. Handle Deletions
            if (idsToDelete.length > 0) {
                const { error: delError } = await supabase.from('inventory').delete().in('id', idsToDelete)
                if (delError) throw delError
            }
        } else {
            // Standard Single-Site Update
            const { error: updateError } = await supabase
                .from('inventory')
                .update({
                    item_name: rawData.name,
                    description: rawData.description,
                    category: rawData.category,
                    stock_total: rawData.qty_good + rawData.qty_damaged + rawData.qty_maintenance + rawData.qty_lost,
                    stock_available: rawData.qty_good,
                    qty_good: rawData.qty_good,
                    qty_damaged: rawData.qty_damaged,
                    qty_maintenance: rawData.qty_maintenance,
                    qty_lost: rawData.qty_lost,
                    image_url: rawData.image_url,
                    serial_number: rawData.serial_number,
                    model_number: rawData.model_number,
                    equipment_type: rawData.equipment_type,
                    brand: rawData.brand,
                    expiry_date: rawData.expiry_date,
                    expiry_alert_days: rawData.expiry_alert_days ?? null,
                    low_stock_threshold: rawData.low_stock_threshold,
                    target_stock: rawData.target_stock,
                    restock_alert_enabled: rawData.restock_alert_enabled,
                    packaging_json: rawData.packaging_json,
                })
                .eq('id', id)
            
            if (updateError) throw updateError
        }

        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')
        
        return { 
            success: true, 
            message: 'Inventory updated' 
        }
    } catch (error: any) {
        console.error('ResQTrack_UPDATE_CRITICAL:', error)
        return { 
            success: false, 
            message: 'Failed to save changes', 
            error: error.message || 'Check connection' 
        }
    }
}

export async function updateItemLocation(itemId: number, newLocation: string) {
    try {
        const supabase = await createSupabaseServer()
        const { error } = await supabase
            .from('inventory')
            .update({ storage_location: newLocation })
            .eq('id', itemId)

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
        // 🚨 STRICT PROTOCOL: Check for active borrows before archiving
        const { data: activeBorrows, error: checkError } = await supabase
            .from('borrow_logs')
            .select('id')
            .eq('inventory_id', id)
            .eq('status', 'borrowed')

        if (checkError) throw checkError

        if (activeBorrows && activeBorrows.length > 0) {
            return { 
                success: false, 
                error: `⚠️ STRATEGIC BLOCK: Cannot archive resource. Resolve active borrows (Mark as Returned or Lost) first.` 
            }
        }

        // 🛡️ LOGISTICAL LIQUIDATION: Hard Delete
        // The user has requested to remove soft-delete logic. 
        // Items are permanently removed from the database.
        const { error } = await supabase
            .from('inventory')
            .delete()
            .eq('id', id)

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { success: true, message: 'Item archived successfully' }
    } catch (error: any) {
        console.error('Archive Error:', error)
        return { success: false, error: error.message || 'Failed to archive item' }
    }
}

/**
 * TACTICAL STOCK SPLIT (LIQUIDATED)
 * This function is now deprecated in favor of the Single-Row Bucket model.
 * Status distribution is now handled directly in updateItem.
 */
export async function splitInventoryItem(id: number, _splitQty: number, _targetStatus: string) {
    return {
        success: false,
        message: "Split Mode is deprecated.",
        error: "Split Mode is deprecated. Use the 'Status Distribution' ledger in the Edit dialog instead. 🟢"
    }
}
/**
 * GET INVENTORY ALERTS
 * Unified retrieval of mission-critical intelligence from v_inventory_actionable_alerts view.
 * Used for Overview Page Action Center.
 */
export async function getInventoryAlerts() {
    try {
        // Query the intelligence view
        const { data, error } = await supabase
            .from('v_inventory_actionable_alerts')
            .select('*')
            .eq('needs_action', true);

        if (error) {
            console.error('Error fetching inventory alerts:', error);
            return { success: false, error: 'Database intelligence fetch failed.' };
        }

        const alerts = data || [];
        
        const summary = {
            out_of_stock: alerts.filter(i => i.is_out_of_stock).length,
            low_stock: alerts.filter(i => i.is_low_stock).length,
            expiring_soon: alerts.filter(i => i.is_expiring).length,
            expired: alerts.filter(i => i.is_expired).length,
            damaged: alerts.filter(i => i.is_damaged).length,
            maintenance: alerts.filter(i => i.is_maintenance).length,
            missing: alerts.filter(i => i.is_missing).length,
            total_active_alerts: alerts.length
        };

        return { 
            success: true, 
            data: summary,
            items: alerts.slice(0, 10) // Return top 10 most critical for quick triage
        };
    } catch (error) {
        console.error('Unexpected error in getInventoryAlerts:', error);
        return { success: false, error: 'An unexpected system error occurred.' };
    }
}
