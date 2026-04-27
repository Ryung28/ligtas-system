'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'
import { z } from 'zod'
import { borrowItemSchema, batchBorrowSchema } from '../schemas/transaction.schema'

/**
 * TRANSACTIONS DOMAIN - Mutation Actions
 * 
 * Borrow, Return, and Batch operations for equipment transactions.
 * Includes tactical safeguards and automatic stock management via DB triggers.
 */

export async function borrowItem(input: BorrowItemInput | FormData) {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        
        let validatedData: BorrowItemInput;

        if (input instanceof FormData) {
            const rawData = {
                borrower_name: input.get('borrower_name'),
                contact_number: input.get('contact_number'),
                office_department: input.get('office_department'),
                item_id: input.get('item_id'),
                quantity: input.get('quantity'),
                inventory_variant_id: input.get('inventory_variant_id'),
                purpose: input.get('purpose') || '',
                approved_by: input.get('approved_by') || '',
                released_by: input.get('released_by') || '',
                expected_return_date: input.get('expected_return_date') || null,
                pickup_scheduled_at: input.get('pickup_scheduled_at') || null,
                source_batch: input.get('source_batch') ? JSON.parse(input.get('source_batch') as string) : null
            }
            validatedData = borrowItemSchema.parse(rawData)
        } else {
            validatedData = borrowItemSchema.parse(input)
        }

        // Step 1: Check if enough stock is available and get item type
        const { data: inventoryItem, error: checkError } = await supabase
            .from('inventory')
            .select('id, item_name, stock_available, status, item_type')
            .eq('id', validatedData.item_id)
            .single()

        if (checkError || !inventoryItem) {
            console.error('Item lookup error:', checkError)
            return {
                success: false,
                error: 'Item not found',
            }
        }

        // AUDIT SAFEGUARD: No borrowing decommissioned items
        if (inventoryItem.status === 'archived') {
            return {
                success: false,
                error: 'Error: Resource is archived and unavailable for checkout.',
            }
        }

        if (inventoryItem.stock_available < validatedData.quantity) {
            return {
                success: false,
                error: `Insufficient stock. Only ${inventoryItem.stock_available} units available.`,
            }
        }

        const isConsumable = inventoryItem.item_type === 'consumable'
        const isScheduled = !!validatedData.pickup_scheduled_at;
        const variantId = validatedData.inventory_variant_id;

        // Step 1.5: SATELLITE STOCK CHECK (Single Item Path)
        // IMPORTANT: Do not mutate stock here. DB trigger owns stock decrement
        // on successful borrow_logs insert, keeping operation atomic.
        if (variantId) {
            const { data: variantItem, error: variantError } = await supabase
                .from('inventory')
                .select('stock_available, storage_location')
                .eq('id', variantId)
                .single()

            if (variantError || !variantItem) {
                return { success: false, error: 'Location data not found' }
            }

            if (variantItem.stock_available < validatedData.quantity) {
                return { success: false, error: `${inventoryItem.item_name} at ${variantItem.storage_location}: Only ${variantItem.stock_available} units available` }
            }
        }

        // Step 2: Atomic stock+log transaction via RPC
        const now = new Date().toISOString();
        const { data: txData, error: logError } = await supabase.rpc('dispatch_borrow_atomic', {
            p_inventory_id: validatedData.item_id,
            p_inventory_variant_id: variantId || null,
            p_item_name: inventoryItem.item_name,
            p_quantity: validatedData.quantity,
            p_borrower_name: validatedData.borrower_name,
            p_borrower_contact: validatedData.contact_number,
            p_borrower_organization: validatedData.office_department || 'N/A',
            p_purpose: validatedData.purpose || '',
            p_approved_by_name: validatedData.approved_by || null,
            p_released_by_name: validatedData.released_by || null,
            p_released_by_user_id: user?.id || null,
            p_transaction_type: isConsumable ? 'dispense' : 'borrow',
            p_status: isConsumable ? 'dispensed' : (isScheduled ? 'reserved' : 'borrowed'),
            p_borrow_date: isScheduled
                ? (validatedData.pickup_scheduled_at ? new Date(validatedData.pickup_scheduled_at).toISOString() : now)
                : now,
            p_pickup_scheduled_at: validatedData.pickup_scheduled_at ? new Date(validatedData.pickup_scheduled_at).toISOString() : null,
            p_actual_return_date: isConsumable ? now : null,
            p_expected_return_date: isConsumable ? null : (validatedData.expected_return_date ? new Date(validatedData.expected_return_date).toISOString() : null),
            p_platform_origin: 'Web',
            p_created_origin: 'Web',
            p_last_updated_origin: 'Web',
            p_source_batch: validatedData.source_batch || null,
            p_now: now,
        })

        if (logError) {
            console.error('Borrow log error:', logError)
            if (logError.message.includes('check_stock_positive')) {
                return {
                    success: false,
                    error: 'Transaction failed: Not enough stock available.',
                }
            }
            return {
                success: false,
                error: `Failed to create borrow record: ${logError.message}`,
            }
        }

        const createdLogId = Number((txData as any)?.borrow_log_id || 0)
        let logData: any[] = []
        if (createdLogId > 0) {
            const { data: insertedLog } = await supabase
                .from('borrow_logs')
                .select('*')
                .eq('id', createdLogId)
                .limit(1)
            logData = (insertedLog as any[]) || []
        }

        // AGGREGATE GRANULAR BATCH DEDUCTION (If applicable)
        if (validatedData.source_batch) {
            const { data: item, error: fetchErr } = await supabase
                .from('inventory')
                .select('packaging_json')
                .eq('id', validatedData.item_id)
                .single();
            
            const oldPackaging = item?.packaging_json;

            if (fetchErr) {
                console.error('Batch sync fetch error:', fetchErr);
            } else if (item?.packaging_json?.enabled && item.packaging_json.batches) {
                const newPackaging = { ...item.packaging_json };
                const batchIndex = newPackaging.batches.findIndex((b: any) => b.id === validatedData.source_batch.batch_id);
                
                if (batchIndex !== -1) {
                    const targetBatch = newPackaging.batches[batchIndex];
                    
                    // 🛡️ TACTICAL SAFEGUARD: Initialize max_units if it doesn't exist
                    if (targetBatch.max_units === undefined) {
                        targetBatch.max_units = targetBatch.units;
                    }
                    
                    targetBatch.units = Math.max(0, targetBatch.units - validatedData.quantity);
                    
                    // 🔒 OPTIMISTIC LOCK: Only update if the JSON hasn't changed since our fetch
                    const { error: updateErr } = await supabase
                        .from('inventory')
                        .update({ packaging_json: newPackaging })
                        .eq('id', validatedData.item_id)
                        .eq('packaging_json', oldPackaging);

                    if (updateErr) {
                        console.error('Batch sync update error:', updateErr);
                    }
                }
            }
        }

        // Revalidate pages
        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        return {
            success: true,
            data: logData[0],
            message: isConsumable 
                ? `Successfully dispensed ${validatedData.quantity} unit(s) of ${inventoryItem.item_name}`
                : `Successfully borrowed ${validatedData.quantity} unit(s) of ${inventoryItem.item_name}`,
        }
    } catch (error) {
        if (error instanceof z.ZodError) {
            console.error('Validation error:', error.errors)
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

export async function batchBorrowItems(data: {
    borrower_name: string
    contact_number: string
    office_department?: string | null
    purpose?: string
    approved_by?: string
    released_by?: string
    expected_return_date?: string | null
    pickup_scheduled_at?: string | null
    items: Array<{
        item_id: number
        quantity: number
        item_type: 'equipment' | 'consumable'
        inventory_variant_id?: number | null
    }>
}) {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        const validatedData = batchBorrowSchema.parse(data)

        const now = new Date().toISOString()
        const borrowLogs = []
        const errors = []

        const isScheduled = !!validatedData.pickup_scheduled_at;

        // Process each item
        for (const item of validatedData.items) {
            // Check stock availability
            const { data: inventoryItem, error: checkError } = await supabase
                .from('inventory')
                .select('id, item_name, stock_available, status, item_type')
                .eq('id', item.item_id)
                .single()

            if (checkError || !inventoryItem) {
                errors.push(`Item ID ${item.item_id} not found`)
                continue
            }

            if (inventoryItem.status === 'archived') {
                errors.push(`${inventoryItem.item_name} is archived`)
                continue
            }

            // SATELLITE STOCK CHECK: If borrowing from a specific location (Variant)
            // IMPORTANT: Do not mutate stock here. DB trigger owns stock decrement
            // on successful borrow_logs insert, keeping operation atomic.
            if (item.inventory_variant_id) {
                const { data: variantItem, error: variantError } = await supabase
                    .from('inventory')
                    .select('id, stock_available, storage_location')
                    .eq('id', item.inventory_variant_id)
                    .single()

                if (variantError || !variantItem) {
                    errors.push(`Location data for ${inventoryItem.item_name} not found`)
                    continue
                }

                if (variantItem.stock_available < item.quantity) {
                    errors.push(`${inventoryItem.item_name} (at ${variantItem.storage_location}): Only ${variantItem.stock_available} units available`)
                    continue
                }
            } else {
                // Fallback: Check only against main inventory table (Primary Location)
                if (inventoryItem.stock_available < item.quantity) {
                    errors.push(`${inventoryItem.item_name}: Only ${inventoryItem.stock_available} units available`)
                    continue
                }
            }

            const isConsumable = inventoryItem.item_type === 'consumable'

            const { data: txRow, error: txErr } = await supabase.rpc('dispatch_borrow_atomic', {
                p_inventory_id: item.item_id,
                p_inventory_variant_id: item.inventory_variant_id || null,
                p_item_name: inventoryItem.item_name,
                p_quantity: item.quantity,
                p_borrower_name: validatedData.borrower_name,
                p_borrower_contact: validatedData.contact_number,
                p_borrower_organization: validatedData.office_department || 'N/A',
                p_purpose: validatedData.purpose || '',
                p_approved_by_name: validatedData.approved_by || null,
                p_released_by_name: validatedData.released_by || null,
                p_released_by_user_id: user?.id || null,
                p_transaction_type: isConsumable ? 'dispense' : 'borrow',
                p_status: isConsumable ? 'dispensed' : (isScheduled ? 'reserved' : 'borrowed'),
                p_borrow_date: isScheduled
                    ? (validatedData.pickup_scheduled_at ? new Date(validatedData.pickup_scheduled_at).toISOString() : now)
                    : now,
                p_pickup_scheduled_at: validatedData.pickup_scheduled_at ? new Date(validatedData.pickup_scheduled_at).toISOString() : null,
                p_actual_return_date: isConsumable ? now : null,
                p_expected_return_date: isConsumable ? null : (validatedData.expected_return_date ? new Date(validatedData.expected_return_date).toISOString() : null),
                p_platform_origin: 'Web',
                p_created_origin: 'Web',
                p_last_updated_origin: 'Web',
                p_source_batch: item.source_batch || null,
                p_now: now,
            })
            if (txErr) {
                if (txErr.message?.includes('check_stock_positive')) {
                    errors.push(`${inventoryItem.item_name}: insufficient stock`)
                } else {
                    errors.push(`${inventoryItem.item_name}: ${txErr.message}`)
                }
                continue
            }
            borrowLogs.push(txRow)

            // AGGREGATE GRANULAR BATCH DEDUCTION (Internal Batch Selection)
            if (item.source_batch) {
                const { data: fullItem, error: fetchBatchErr } = await supabase
                    .from('inventory')
                    .select('packaging_json')
                    .eq('id', item.item_id)
                    .single();

                if (fetchBatchErr) {
                    console.error('Batch sync fetch error:', fetchBatchErr);
                } else if (fullItem?.packaging_json?.enabled && fullItem.packaging_json.batches) {
                    const newPackaging = { ...fullItem.packaging_json };
                    const batchIndex = newPackaging.batches.findIndex((b: any) => b.id === item.source_batch.batch_id);
                    
                    if (batchIndex !== -1) {
                        const targetBatch = newPackaging.batches[batchIndex];
                        
                        // 🛡️ TACTICAL SAFEGUARD: Initialize max_units if it doesn't exist
                        if (targetBatch.max_units === undefined) {
                            targetBatch.max_units = targetBatch.units;
                        }

                        targetBatch.units = Math.max(0, targetBatch.units - item.quantity);
                        
                        const { error: updateErr } = await supabase
                            .from('inventory')
                            .update({ packaging_json: newPackaging })
                            .eq('id', item.item_id);

                        if (updateErr) {
                            console.error('Batch sync update error:', updateErr);
                        }
                    }
                }
            }
        }

        if (borrowLogs.length === 0) {
            return {
                success: false,
                error: errors.length > 0 ? errors.join('; ') : 'No valid items to borrow',
            }
        }

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        if (errors.length > 0) {
            return {
                success: true,
                data: borrowLogs,
                message: `Borrowed ${borrowLogs.length} item(s). Some items failed: ${errors.join('; ')}`,
            }
        }

        return {
            success: true,
            data: borrowLogs,
            message: `Successfully borrowed ${borrowLogs.length} item(s)`,
        }
    } catch (error) {
        if (error instanceof z.ZodError) {
            console.error('Validation error:', error.errors)
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



export async function returnItem(
    logId: number, 
    auditData?: {
        receivedByName: string
        returnedByName?: string
        returnCondition: 'good' | 'fair' | 'damaged' | 'maintenance' | 'lost'
        returnNotes: string | null
    }
) {
    try {
        const supabase = await createSupabaseServer()
        const now = new Date().toISOString()
        // 1. Fetch Log and current user
        const { data: log, error: logError } = await supabase
            .from('borrow_logs')
            .select('*')
            .eq('id', logId)
            .single()

        if (logError || !log) throw new Error('Transaction log not found')
        if (log.status === 'returned') return { success: false, error: 'Item already returned' }

        // Get current user ID for audit trail
        const { data: { user } } = await supabase.auth.getUser()

        // 2. Update Log Status & Audit Trail
        const { error: updateError } = await supabase
            .from('borrow_logs')
            .update({
                status: 'returned',
                actual_return_date: now,
                received_by_name: auditData?.receivedByName || null,
                returned_by_name: auditData?.returnedByName || null,
                received_by_user_id: user?.id || null,
                return_condition: auditData?.returnCondition || 'good',
                return_notes: auditData?.returnNotes || null,
                last_updated_origin: 'Web',
                updated_at: now,
            })
            .eq('id', logId)

        if (updateError) throw updateError

        // 3. Update Inventory (Increment Stock)
        // Variant-aware: restore to the exact row that was deducted on borrow.
        const targetInventoryId = log.inventory_variant_id ?? log.inventory_id
        const { data: item, error: itemError } = await supabase
            .from('inventory')
            .select('stock_available')
            .eq('id', targetInventoryId)
            .single()

        if (item) {
            await supabase
                .from('inventory')
                .update({
                    stock_available: item.stock_available + log.quantity,
                })
                .eq('id', targetInventoryId)
        }

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        const conditionText = auditData?.returnCondition ? ` (Condition: ${auditData.returnCondition})` : ''
        return { 
            success: true, 
            message: `Item returned successfully${conditionText}` 
        }

    } catch (error: any) {
        console.error('Return item error:', error)
        return { success: false, error: error.message || 'Failed to return item' }
    }
}

export async function bulkReturnItems(logIds: number[]) {
    try {
        let successCount = 0
        let failCount = 0

        for (const logId of logIds) {
            const result = await returnItem(logId)
            if (result.success) successCount++
            else failCount++
        }

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        return {
            success: true,
            message: `Successfully processed ${successCount} returns. ${failCount > 0 ? `${failCount} failed.` : ''}`,
            successCount,
            failCount
        }
    } catch (error: any) {
        return { success: false, error: 'Error: Bulk return process interrupted' }
    }
}
export async function revertReturnItem(logId: number) {
    try {
        const supabase = await createSupabaseServer()
        
        // 1. Fetch the log to verify status and get metadata
        const { data: log, error: logError } = await supabase
            .from('borrow_logs')
            .select('*')
            .eq('id', logId)
            .single()

        if (logError || !log) throw new Error('Transaction log not found')
        if (log.status !== 'returned') return { success: false, error: 'Only returned items can be reverted to borrowed state' }

        // 2. Atomically Revert Status and Correct Stock
        // Note: In a production environment, this should ideally be handled inside a DB function to ensure atomicity.
        // For this restoration, we use sequential updates with error checking.
        
        // Step A: Restore Borrowed Status
        const { error: updateError } = await supabase
            .from('borrow_logs')
            .update({
                status: 'borrowed',
                actual_return_date: null,
                received_by_name: null,
                received_by_user_id: null,
                return_condition: null,
                return_notes: null,
                last_updated_origin: 'Web',
                updated_at: new Date().toISOString(),
            })
            .eq('id', logId)

        if (updateError) throw updateError

        // Step B: Pull stock back out of Inventory
        // Variant-aware: revert from the exact row that was restored on return.
        const targetInventoryId = log.inventory_variant_id ?? log.inventory_id
        const { data: item, error: itemError } = await supabase
            .from('inventory')
            .select('stock_available')
            .eq('id', targetInventoryId)
            .single()

        if (item) {
            const newStock = Math.max(0, item.stock_available - log.quantity)
            await supabase
                .from('inventory')
                .update({ stock_available: newStock })
                .eq('id', targetInventoryId)
        }

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        return { 
            success: true, 
            message: `Reversion successful: ${log.item_name} is now marked as BORROWED again.` 
        }

    } catch (error: any) {
        console.error('Revert return error:', error)
        return { success: false, error: error.message || 'Failed to revert return' }
    }
}

export async function releaseReservedItem(logId: number, auditOptions?: { handedBy?: string, physicallyReceivedBy?: string }) {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        const authorizerName = user?.user_metadata?.full_name || user?.email || 'Authorized Staff'
        
        const now = new Date().toISOString()
        
        const { data, error } = await supabase
            .from('borrow_logs')
            .update({
                status: 'borrowed',
                borrow_date: now,
                released_by_user_id: user?.id || null,
                released_by_name: authorizerName, // Authorizing system user
                handed_by: auditOptions?.handedBy || authorizerName, // Phsyical staff at the desk
                physically_received_by: auditOptions?.physicallyReceivedBy || null, // Phsyical person receiving
                last_updated_origin: 'Web',
                updated_at: now
            })
            .eq('id', logId)
            .select()

        if (error) throw error

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        
        return { 
            success: true, 
            message: 'Item released successfully. Status updated to BORROWED.' 
        }
    } catch (error) {
        console.error('Release Reserved Error:', error)
        return { 
            success: false, 
            error: 'Failed to release reserved item' 
        }
    }
}
