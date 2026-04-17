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

export async function borrowItem(formData: FormData) {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        
        // Parse and validate form data
        const rawData = {
            borrower_name: formData.get('borrower_name'),
            contact_number: formData.get('contact_number'),
            office_department: formData.get('office_department'),
            item_id: formData.get('item_id'),
            quantity: formData.get('quantity'),
            purpose: formData.get('purpose') || '',
            approved_by: formData.get('approved_by') || '',
            released_by: formData.get('released_by') || '',
            expected_return_date: formData.get('expected_return_date') || null,
            pickup_scheduled_at: formData.get('pickup_scheduled_at') || null,
        }

        // Validate item_id is present before parsing
        if (!rawData.item_id || rawData.item_id === '') {
            return {
                success: false,
                error: 'Please select an item',
            }
        }

        const validatedData = borrowItemSchema.parse(rawData)

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

        // Step 2: Insert borrow log
        const now = new Date().toISOString();
        const { data: logData, error: logError } = await supabase
            .from('borrow_logs')
            .insert([
                {
                    inventory_id: validatedData.item_id,
                    item_name: inventoryItem.item_name,
                    quantity: validatedData.quantity,
                    borrower_name: validatedData.borrower_name,
                    borrower_contact: validatedData.contact_number,
                    borrower_organization: validatedData.office_department || 'N/A',
                    purpose: validatedData.purpose,
                    approved_by_name: validatedData.approved_by || null,
                    released_by_name: validatedData.released_by || null,
                    released_by_user_id: user?.id || null,
                    transaction_type: isConsumable ? 'dispense' : 'borrow',
                    status: isConsumable ? 'dispensed' : (isScheduled ? 'reserved' : 'borrowed'),
                    borrow_date: isScheduled ? null : now,
                    pickup_scheduled_at: validatedData.pickup_scheduled_at ? new Date(validatedData.pickup_scheduled_at).toISOString() : null,
                    actual_return_date: isConsumable ? now : null, 
                    expected_return_date: isConsumable ? null : (validatedData.expected_return_date ? new Date(validatedData.expected_return_date).toISOString() : null),
                    platform_origin: 'Web',
                    created_origin: 'Web',
                    last_updated_origin: 'Web',
                    created_at: now,
                },
            ])
            .select()

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

            if (inventoryItem.stock_available < item.quantity) {
                errors.push(`${inventoryItem.item_name}: Only ${inventoryItem.stock_available} units available`)
                continue
            }

            const isConsumable = item.item_type === 'consumable'

            borrowLogs.push({
                inventory_id: item.item_id,
                item_name: inventoryItem.item_name,
                quantity: item.quantity,
                borrower_name: validatedData.borrower_name,
                borrower_contact: validatedData.contact_number,
                borrower_organization: validatedData.office_department || 'N/A',
                purpose: validatedData.purpose || '',
                approved_by_name: validatedData.approved_by || null,
                released_by_name: validatedData.released_by || null,
                released_by_user_id: user?.id || null,
                transaction_type: isConsumable ? 'dispense' : 'borrow',
                status: isConsumable ? 'dispensed' : (isScheduled ? 'reserved' : 'borrowed'),
                borrow_date: isScheduled ? null : now,
                pickup_scheduled_at: validatedData.pickup_scheduled_at ? new Date(validatedData.pickup_scheduled_at).toISOString() : null,
                actual_return_date: isConsumable ? now : null,
                expected_return_date: isConsumable ? null : (validatedData.expected_return_date ? new Date(validatedData.expected_return_date).toISOString() : null),
                platform_origin: 'Web',
                created_origin: 'Web',
                last_updated_origin: 'Web',
                created_at: now,
            })
        }

        if (errors.length > 0) {
            return {
                success: false,
                error: errors.join('; '),
            }
        }

        if (borrowLogs.length === 0) {
            return {
                success: false,
                error: 'No valid items to borrow',
            }
        }

        // Insert all borrow logs
        const { data: logData, error: logError } = await supabase
            .from('borrow_logs')
            .insert(borrowLogs)
            .select()

        if (logError) {
            console.error('Batch borrow error:', logError)
            return {
                success: false,
                error: `Failed to create borrow records: ${logError.message}`,
            }
        }

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        return {
            success: true,
            data: logData,
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
        returnCondition: 'good' | 'fair' | 'damaged' | 'maintenance' | 'lost'
        returnNotes: string | null
    }
) {
    try {
        const supabase = await createSupabaseServer()
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
                actual_return_date: new Date().toISOString(),
                received_by_name: auditData?.receivedByName || null,
                received_by_user_id: user?.id || null,
                return_condition: auditData?.returnCondition || 'good',
                return_notes: auditData?.returnNotes || null,
                platform_origin: 'Web',
                last_updated_origin: 'Web',
            })
            .eq('id', logId)

        if (updateError) throw updateError

        // 3. Update Inventory (Increment Stock)
        const { data: item, error: itemError } = await supabase
            .from('inventory')
            .select('stock_available')
            .eq('id', log.inventory_id)
            .single()

        if (item) {
            await supabase
                .from('inventory')
                .update({
                    stock_available: item.stock_available + log.quantity,
                })
                .eq('id', log.inventory_id)
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
                platform_origin: 'Web',
                last_updated_origin: 'Web',
            })
            .eq('id', logId)

        if (updateError) throw updateError

        // Step B: Pull stock back out of Inventory
        const { data: item, error: itemError } = await supabase
            .from('inventory')
            .select('stock_available')
            .eq('id', log.inventory_id)
            .single()

        if (item) {
            const newStock = Math.max(0, item.stock_available - log.quantity)
            await supabase
                .from('inventory')
                .update({ stock_available: newStock })
                .eq('id', log.inventory_id)
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

export async function releaseReservedItem(logId: number) {
    try {
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        const userName = user?.user_metadata?.full_name || user?.email || 'Authorized Staff'
        
        const now = new Date().toISOString()
        
        const { data, error } = await supabase
            .from('borrow_logs')
            .update({
                status: 'borrowed',
                borrow_date: now,
                released_by_user_id: user?.id || null,
                released_by_name: userName,
                platform_origin: 'Web',
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
