'use server'

import { revalidatePath } from 'next/cache'
import { supabase } from '@/lib/supabase'
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
            equipment_type: formData.get('equipment_type'),
            item_type: formData.get('item_type') || 'equipment',
            storage_location: formData.get('storage_location') || 'lower_warehouse',
            brand: formData.get('brand'),
            expiry_date: formData.get('expiry_date'),
            parent_id: formData.get('parent_id'),
            variant_label: formData.get('variant_label'),
            low_stock_threshold: formData.get('low_stock_threshold') || 20,
            // Enterprise Sub-Buckets
            qty_good: Number(formData.get('qty_good')) || Number(formData.get('stock_total')) || 0,
            qty_damaged: Number(formData.get('qty_damaged')) || 0,
            qty_maintenance: Number(formData.get('qty_maintenance')) || 0,
            qty_lost: Number(formData.get('qty_lost')) || 0,
        }

        // 🛡️ RECONCILIATION: Ensure stock_total matches the sum of buckets
        const calculatedTotal = rawData.qty_good + rawData.qty_damaged + rawData.qty_maintenance + rawData.qty_lost
        const finalStockTotal = Math.max(Number(rawData.stock_total) || 0, calculatedTotal)
        const validatedData = addItemSchema.parse(rawData)

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
                        low_stock_threshold: validatedData.low_stock_threshold || 20,
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
                category: validatedData.category,
                stock_total: finalStockTotal,
                stock_available: rawData.qty_good, // Available is strictly Ready for Deployment
                qty_good: rawData.qty_good,
                qty_damaged: rawData.qty_damaged,
                qty_maintenance: rawData.qty_maintenance,
                qty_lost: rawData.qty_lost,
                status: 'Good', // Base status is Good; sub-buckets handle triage
                image_url: validatedData.image_url,
                serial_number: validatedData.serial_number,
                equipment_type: validatedData.equipment_type,
                item_type: validatedData.item_type,
                storage_location: validatedData.storage_location,
                brand: validatedData.brand,
                expiry_date: validatedData.expiry_date,
                low_stock_threshold: validatedData.low_stock_threshold,
            },
        ]).select()

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

export async function bulkAddItems(items: Array<{ name: string; category: string; stock_total: number; status: string; description?: string }>) {
    try {
        const validatedItems = z.array(addItemSchema).parse(items)

        const insertData = validatedItems.map(item => ({
            item_name: item.name,
            description: item.description,
            category: item.category,
            stock_total: item.stock_total,
            stock_available: item.stock_total,
            status: item.status,
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
    } catch (error) {
        if (error instanceof z.ZodError) {
            return { success: false, error: 'Validation failed: ' + error.errors[0].message }
        }
        return { success: false, error: 'An unexpected error occurred' }
    }
}

export async function updateItem(formData: FormData) {
    try {
        const id = formData.get('id')
        if (!id) throw new Error('Item ID is required')

        const rawData = {
            name: formData.get('name'),
            description: formData.get('description'),
            category: formData.get('category'),
            stock_total: formData.get('stock_total'),
            stock_available: formData.get('stock_available'),
            status: formData.get('status') || 'Good',
            image_url: formData.get('image_url'),
            serial_number: formData.get('serial_number'),
            equipment_type: formData.get('equipment_type'),
            storage_location: formData.get('storage_location'),
            brand: formData.get('brand'),
            expiry_date: formData.get('expiry_date'),
            low_stock_threshold: formData.get('low_stock_threshold') || 20,
            // Enterprise Sub-Buckets
            qty_good: Number(formData.get('qty_good')) || 0,
            qty_damaged: Number(formData.get('qty_damaged')) || 0,
            qty_maintenance: Number(formData.get('qty_maintenance')) || 0,
            qty_lost: Number(formData.get('qty_lost')) || 0,
        }

        const calculatedTotal = rawData.qty_good + rawData.qty_damaged + rawData.qty_maintenance + rawData.qty_lost
        const finalStockTotal = Math.max(Number(rawData.stock_total) || 0, calculatedTotal)

        const validatedData = addItemSchema.parse(rawData)

        // Validate that current stock doesn't exceed total stock
        if (validatedData.stock_available > validatedData.stock_total) {
            return {
                success: false,
                error: 'Current stock cannot exceed fixed total stock',
            }
        }

        // 🛡️ SUB-BUCKET UPDATE (THE ENTERPRISE WAY)
        // We update the single row with its partitioned quantities.
        const { data, error } = await supabase
            .from('inventory')
            .update({
                item_name: rawData.name,
                description: rawData.description,
                category: rawData.category,
                stock_total: finalStockTotal,
                stock_available: rawData.qty_good,
                qty_good: rawData.qty_good,
                qty_damaged: rawData.qty_damaged,
                qty_maintenance: rawData.qty_maintenance,
                qty_lost: rawData.qty_lost,
                image_url: rawData.image_url,
                serial_number: rawData.serial_number,
                equipment_type: rawData.equipment_type,
                storage_location: rawData.storage_location,
                brand: rawData.brand,
                expiry_date: rawData.expiry_date,
                low_stock_threshold: rawData.low_stock_threshold,
            })
            .eq('id', id)
            .select()

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')
        return { success: true, message: 'Item reconciled successfully 🟢' }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to update item' }
    }
}

export async function updateItemLocation(itemId: number, newLocation: string) {
    try {
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
