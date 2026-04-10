'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import { revalidatePath } from 'next/cache'

export async function rebalanceStockAction(formData: {
    sourceId: number;
    destinationId: number | string; // Can be a number (ID) or "NAME:Location Name"
    quantity: number;
    itemName: string;
    masterId?: number; // Needed if we are creating a new site presence
}) {
    const supabase = await createSupabaseServer()
    let { sourceId, destinationId, quantity, itemName } = formData

    try {
        // 1. Get User for Audit
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Session expired. Please log in again.')

        // 2. Resolve Destination ID (Handle Dynamic "Spawn" Case)
        let resolvedDestId: number

        if (typeof destinationId === 'string' && destinationId.startsWith('NAME:')) {
            const locationName = destinationId.replace('NAME:', '')
            
            // MASTER PROTOCOL: Look up the Registry ID for this name to ensure hard-binding
            const { data: registryLoc } = await supabase
                .from('storage_locations')
                .select('id')
                .eq('location_name', locationName)
                .single()

            const registryId = registryLoc?.id || null;

            // Get Master Item Info to clone properly
            const { data: sourceItem } = await supabase
                .from('inventory')
                .select('parent_id, item_name, category, image_url, item_type, brand, unit')
                .eq('id', sourceId)
                .single()

            if (!sourceItem) throw new Error('Source item not found')

            const masterId = sourceItem.parent_id || sourceId

            // Check if this Master Item ALREADY has a row for this location
            const { data: existingPresence } = await supabase
                .from('inventory')
                .select('id')
                .eq('parent_id', masterId)
                .eq('storage_location', locationName)
                .single()

            if (existingPresence) {
                resolvedDestId = existingPresence.id
            } else {
                // CREATE THE NEW PRESENCE (Spawn) with HARD-BOUND Registry ID
                const { data: newRow, error: spawnError } = await supabase
                    .from('inventory')
                    .insert({
                        parent_id: masterId,
                        item_name: sourceItem.item_name,
                        category: sourceItem.category,
                        image_url: sourceItem.image_url,
                        item_type: sourceItem.item_type,
                        brand: sourceItem.brand,
                        unit: sourceItem.unit,
                        storage_location: locationName,
                        location_registry_id: registryId,
                        stock_available: 0,
                        stock_total: 0,
                        status: 'good',
                        qty_good: 0
                    })
                    .select('id')
                    .single()

                if (spawnError) throw spawnError
                resolvedDestId = newRow.id
            }
        } else {
            resolvedDestId = Number(destinationId)
        }

        // 3. Execute Atomic Transfer via MASTER PROPORTIONAL RPC
        const { error } = await supabase.rpc('transfer_inventory_stock_master', {
            p_source_id: sourceId,
            p_dest_id: resolvedDestId,
            p_quantity: quantity,
            p_user_id: user.id
        })

        if (error) {
            console.error('RPC Error:', error)
            throw new Error(error.message || 'Database transaction failed')
        }

        revalidatePath('/dashboard/inventory')
        return { success: true, message: `Successfully moved ${quantity} units of ${itemName}` }

    } catch (error: any) {
        console.error('Transfer Action Error:', error)
        return { success: false, message: error.message || 'An unexpected error occurred' }
    }
}

/**
 * 📦 BULK ALLOCATE ACTION
 * Distributes a total stock quantity across multiple locations.
 * Ensures the master item is updated and satellites are created/synced.
 */
export async function bulkAllocateAction(data: {
    masterId: number;
    allocations: Array<{ location: string; quantity: number }>;
    itemName: string;
}) {
    const supabase = await createSupabaseServer()
    const { masterId, allocations, itemName } = data

    try {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Session expired')

        // 1. Fetch the Master Item to use as a template for satellites
        const { data: masterItem, error: masterError } = await supabase
            .from('inventory')
            .select('*')
            .eq('id', masterId)
            .single()

        if (masterError || !masterItem) throw new Error('Master resource not found')

        // 2. Process Allocations
        // The first allocation in the list will be treated as the "Master" site update.
        // The rest will be processed as satellite creations or updates.
        
        for (let i = 0; i < allocations.length; i++) {
            const { location, quantity } = allocations[i]
            
                // MASTER PROTOCOL: Resolve Registry ID for this location name
                const { data: registryLoc } = await supabase
                    .from('storage_locations')
                    .select('id')
                    .eq('location_name', location)
                    .single()

                const registryId = registryLoc?.id || null;

                if (i === 0) {
                    // Update the Master Row
                    const { error: updateError } = await supabase
                        .from('inventory')
                        .update({
                            storage_location: location,
                            location_registry_id: registryId,
                            stock_total: quantity,
                            stock_available: quantity,
                            qty_good: quantity,
                            qty_damaged: 0,
                            qty_maintenance: 0,
                            qty_lost: 0
                        })
                        .eq('id', masterId)
                    
                    if (updateError) throw updateError
                } else {
                    // Upsert Satellite Row
                    const { data: existing } = await supabase
                        .from('inventory')
                        .select('id')
                        .eq('parent_id', masterId)
                        .eq('storage_location', location)
                        .single()

                if (existing) {
                    const { error: variantUpdateError } = await supabase.from('inventory').update({
                        stock_total: quantity,
                        stock_available: quantity,
                        qty_good: quantity,
                        location_registry_id: registryId
                    }).eq('id', existing.id)
                    if (variantUpdateError) throw variantUpdateError
                } else {
                    // Create new presence with Registry ID Hard-Binding
                    const { error: variantInsertError } = await supabase.from('inventory').insert({
                        parent_id: masterId,
                        item_name: masterItem.item_name,
                        base_name: masterItem.base_name,
                        category: masterItem.category,
                        image_url: masterItem.image_url,
                        item_type: masterItem.item_type,
                        unit: masterItem.unit,
                        storage_location: location,
                        location_registry_id: registryId,
                        stock_total: quantity,
                        stock_available: quantity,
                        qty_good: quantity,
                        status: 'Good'
                    })
                    if (variantInsertError) throw variantInsertError
                }
            }
        }

        revalidatePath('/dashboard/inventory')
        return { success: true, message: `Re-allocated ${itemName} across ${allocations.length} sites.` }

    } catch (error: any) {
        console.error('Bulk Allocation Error:', error)
        return { success: false, message: error.message || 'Intake distribution failed' }
    }
}
