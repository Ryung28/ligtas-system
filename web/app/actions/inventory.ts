'use server'

import { revalidatePath } from 'next/cache'
import { supabase } from '@/lib/supabase'
import { z } from 'zod'

// ============================================
// VALIDATION SCHEMAS
// ============================================

const addItemSchema = z.object({
    name: z.string().min(2, 'Item name must be at least 2 characters'),
    description: z.string().optional(),
    category: z.string().min(1, 'Please select a category'),
    stock_total: z.coerce.number().min(1, 'Stock must be at least 1'),
    status: z.string().default('Good'),
    image_url: z.string().optional().nullable(),
    serial_number: z.string().optional().nullable(),
    equipment_type: z.string().optional().nullable(),
    item_type: z.enum(['equipment', 'consumable']).default('equipment'),
})

const borrowItemSchema = z.object({
    borrower_name: z.string().min(1, 'Borrower name is required'),
    contact_number: z
        .string()
        .regex(/^09\d{9}$/, 'Invalid Philippine mobile number (must be 09XXXXXXXXX)'),
    office_department: z.string().optional().nullable(),
    item_id: z.coerce.number().min(1, 'Please select an item'),
    quantity: z.coerce.number().min(1, 'Quantity must be at least 1'),
    purpose: z.string().optional(),
    expected_return_date: z.string().optional().nullable(),
})

const batchBorrowSchema = z.object({
    borrower_name: z.string().min(1, 'Borrower name is required'),
    contact_number: z
        .string()
        .regex(/^09\d{9}$/, 'Invalid Philippine mobile number (must be 09XXXXXXXXX)'),
    office_department: z.string().optional().nullable(),
    purpose: z.string().optional(),
    expected_return_date: z.string().optional().nullable(),
    items: z.array(z.object({
        item_id: z.number().min(1),
        quantity: z.number().min(1),
        item_type: z.enum(['equipment', 'consumable']).default('equipment'),
    })).min(1, 'At least one item is required'),
})

// ============================================
// SERVER ACTIONS
// ============================================

export async function addItem(formData: FormData) {
    try {
        // Parse and validate form data
        const rawData = {
            name: formData.get('name'),
            description: formData.get('description'),
            category: formData.get('category'),
            stock_total: formData.get('stock_total'),
            status: 'Good',
            image_url: formData.get('image_url'),
            serial_number: formData.get('serial_number'),
            equipment_type: formData.get('equipment_type'),
            item_type: formData.get('item_type') || 'equipment',
        }

        const validatedData = addItemSchema.parse(rawData)

        // Insert into Supabase
        const { data, error } = await supabase.from('inventory').insert([
            {
                item_name: validatedData.name,
                description: validatedData.description,
                category: validatedData.category,
                stock_total: validatedData.stock_total,
                stock_available: validatedData.stock_total, // Initially all stock is available
                status: validatedData.status,
                image_url: validatedData.image_url,
                serial_number: validatedData.serial_number,
                equipment_type: validatedData.equipment_type,
                item_type: validatedData.item_type,
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
            message: 'Item added successfully',
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

export async function borrowItem(formData: FormData) {
    try {
        // Parse and validate form data
        const rawData = {
            borrower_name: formData.get('borrower_name'),
            contact_number: formData.get('contact_number'),
            office_department: formData.get('office_department'),
            item_id: formData.get('item_id'),
            quantity: formData.get('quantity'),
            purpose: formData.get('purpose') || '',
            expected_return_date: formData.get('expected_return_date') || null,
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

        // TACTICAL SAFEGUARD: No borrowing decommissioned items
        if (inventoryItem.status === 'archived') {
            return {
                success: false,
                error: 'TACTICAL ERROR: Resource is archived and decommissioned from service.',
            }
        }

        if (inventoryItem.stock_available < validatedData.quantity) {
            return {
                success: false,
                error: `Insufficient stock. Only ${inventoryItem.stock_available} units available.`,
            }
        }

        const isConsumable = inventoryItem.item_type === 'consumable'

        // Step 2: Insert borrow log
        // Note: The DB Trigger 'auto_update_inventory_stock' will automatically decrement 
        // the inventory stock. If stock goes < 0, the DB Check Constraint will fail this insert.
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
                    transaction_type: isConsumable ? 'dispense' : 'borrow',
                    status: isConsumable ? 'dispensed' : 'borrowed',
                    borrow_date: now,
                    actual_return_date: isConsumable ? now : null, // Auto-complete consumables
                    expected_return_date: isConsumable ? null : (validatedData.expected_return_date ? new Date(validatedData.expected_return_date).toISOString() : null),
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

        // Previous Step 3 (Manual Update) removed to avoid double-decrement.

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
    expected_return_date?: string | null
    items: Array<{
        item_id: number
        quantity: number
        item_type: 'equipment' | 'consumable'
    }>
}) {
    try {
        const validatedData = batchBorrowSchema.parse(data)

        const now = new Date().toISOString()
        const borrowLogs = []
        const errors = []

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
                transaction_type: isConsumable ? 'dispense' : 'borrow',
                status: isConsumable ? 'dispensed' : 'borrowed',
                borrow_date: now,
                actual_return_date: isConsumable ? now : null,
                expected_return_date: isConsumable ? null : (validatedData.expected_return_date ? new Date(validatedData.expected_return_date).toISOString() : null),
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

export async function returnItem(logId: number, status: string = 'Good', notes: string = '') {
    try {
        // 1. Fetch Log
        const { data: log, error: logError } = await supabase
            .from('borrow_logs')
            .select('*')
            .eq('id', logId)
            .single()

        if (logError || !log) throw new Error('Transaction log not found')
        if (log.status === 'returned') return { success: false, error: 'Item already returned' }

        // 2. Update Log Status & Details
        const { error: updateError } = await supabase
            .from('borrow_logs')
            .update({
                status: 'returned',
                actual_return_date: new Date().toISOString(),
                return_notes: notes,
            })
            .eq('id', logId)

        if (updateError) throw updateError

        // 3. Update Inventory (Increment Stock + Update Condition)
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
                    status: status // Update item condition based on return assessment
                })
                .eq('id', log.inventory_id)
        }

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/inventory')
        revalidatePath('/dashboard')

        return { success: true, message: `Item returned successfully as ${status}` }

    } catch (error: any) {
        console.error('Return item error:', error)
        return { success: false, error: error.message || 'Failed to return item' }
    }
}

// Helper function to get available items for dropdown with pending awareness
export async function getAvailableItems() {
    try {
        const { data, error } = await supabase
            .from('inventory_availability')
            .select('id, item_name, stock_available, stock_truly_available, stock_pending, category, status, item_type')
            .neq('status', 'archived')
            .gt('stock_truly_available', 0)
            .order('item_name')

        if (error) throw error

        return {
            success: true,
            data: data || [],
        }
    } catch (error) {
        console.error('Error fetching items:', error)
        return {
            success: false,
            data: [],
            error: 'Failed to fetch available items',
        }
    }
}

// Fetch distinct categories from database
export async function getCategories() {
    try {
        const { data, error } = await supabase
            .from('inventory')
            .select('category')
            .neq('status', 'archived')
            .order('category')

        if (error) throw error

        // Predefined categories to always show
        const predefinedCategories = ['Medical', 'Tools', 'Rescue', 'PPE', 'Logistics', 'Goods']
        
        // Get unique categories from database
        const dbCategoriesSet = new Set(data?.map(item => item.category).filter(Boolean) || [])
        const dbCategories = Array.from(dbCategoriesSet)
        
        // Merge and deduplicate
        const allCategoriesSet = new Set([...predefinedCategories, ...dbCategories])
        const allCategories = Array.from(allCategoriesSet)
        
        return {
            success: true,
            data: allCategories.sort(),
        }
    } catch (error) {
        console.error('Error fetching categories:', error)
        return {
            success: false,
            data: ['Medical', 'Tools', 'Rescue', 'PPE', 'Logistics', 'Goods'],
            error: 'Failed to fetch categories',
        }
    }
}

// ============================================
// UPDATE & DELETE ACTIONS
// ============================================

export async function updateItem(formData: FormData) {
    try {
        const id = formData.get('id')
        if (!id) throw new Error('Item ID is required')

        const rawData = {
            name: formData.get('name'),
            description: formData.get('description'),
            category: formData.get('category'),
            stock_total: formData.get('stock_total'),
            // We generally don't update stock_available directly here unless logical reset, 
            // but for simple edit we might assume stock_total update affects available if we want to sync them.
            // For now, let's keep it simple: Update Name/Category. 
            // If Stock Total changes, we should ideally adjust Available too, but that's complex logic:
            // stock_available = new_total - (old_total - old_available).
            // For this MVP, let's assume we just update the basic info.
            status: formData.get('status') || 'Good',
            image_url: formData.get('image_url'),
            serial_number: formData.get('serial_number'),
            equipment_type: formData.get('equipment_type'),
        }

        const validatedData = addItemSchema.parse(rawData)

        // Fetch current item to calculate stock diff if needed, or primarily just update details
        const { data: currentItem, error: fetchError } = await supabase
            .from('inventory')
            .select('*')
            .eq('id', id)
            .single()

        if (fetchError || !currentItem) throw new Error('Item not found')

        // Calculate new available stock if total changed
        const stockDiff = validatedData.stock_total - currentItem.stock_total
        const newStockAvailable = currentItem.stock_available + stockDiff

        const { data, error } = await supabase
            .from('inventory')
            .update({
                item_name: validatedData.name,
                description: validatedData.description,
                category: validatedData.category,
                stock_total: validatedData.stock_total,
                stock_available: newStockAvailable < 0 ? 0 : newStockAvailable,
                status: validatedData.status,
                image_url: validatedData.image_url,
                serial_number: validatedData.serial_number,
                equipment_type: validatedData.equipment_type
            })
            .eq('id', id)
            .select()

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { success: true, message: 'Item updated successfully' }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to update item' }
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

        // 🛡️ STEEL CAGE: Logic Redirection
        // Instead of hard delete, we perform a soft-delete (Archive).
        // This hides the item from the active_inventory view but preserves the audit trail.
        const { error } = await supabase
            .from('inventory')
            .update({ 
                deleted_at: new Date().toISOString(),
                status: 'archived'
            })
            .eq('id', id)

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { success: true, message: 'Item archived successfully' }
    } catch (error: any) {
        console.error('Archive Error:', error)
        return { success: false, error: error.message || 'Failed to archive item' }
    }
}

// ============================================
// APPROVAL ACTIONS
// ============================================

export async function approveRequest(logId: number) {
    try {
        const { error } = await supabase
            .from('borrow_logs')
            .update({ status: 'staged' }) // Tactical: Items are reserved but not yet handed off
            .eq('id', logId)

        if (error) throw error

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard')
        return { success: true, message: 'Request approved and moved to staging' }
    } catch (error: any) {
        console.error('Approve error:', error)
        return { success: false, error: error.message || 'Failed to approve request' }
    }
}

export async function completeHandoff(logId: number) {
    try {
        const { error } = await supabase
            .from('borrow_logs')
            .update({ 
                status: 'borrowed',
                borrow_date: new Date().toISOString() // Actual time the item left the building
            })
            .eq('id', logId)

        if (error) throw error

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard')
        return { success: true, message: 'Handoff complete. Item is now in active service.' }
    } catch (error: any) {
        console.error('Handoff error:', error)
        return { success: false, error: error.message || 'Failed to complete handoff' }
    }
}

export async function rejectRequest(logId: number) {
    try {
        // 1. Fetch Log to get inventory_id and quantity for restoration
        const { data: log, error: fetchError } = await supabase
            .from('borrow_logs')
            .select('inventory_id, quantity, status')
            .eq('id', logId)
            .single()

        if (fetchError || !log) throw new Error('Request not found')
        if (log.status !== 'pending' && log.status !== 'staged') throw new Error('Only pending or staged requests can be rejected')

        // 2. Mark as Rejected
        const { error: updateError } = await supabase
            .from('borrow_logs')
            .update({ status: 'rejected' })
            .eq('id', logId)

        if (updateError) throw updateError

        // 3. Restore Stock (Increment back)
        const { data: item, error: itemError } = await supabase
            .from('inventory')
            .select('stock_available')
            .eq('id', log.inventory_id)
            .single()

        if (item) {
            await supabase
                .from('inventory')
                .update({
                    stock_available: item.stock_available + log.quantity
                })
                .eq('id', log.inventory_id)
        }

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard')
        return { success: true, message: 'Request rejected and stock restored' }
    } catch (error: any) {
        console.error('Reject error:', error)
        return { success: false, error: error.message || 'Failed to reject request' }
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
        console.error('Bulk return error:', error)
        return { success: false, error: 'Tactical Error: Bulk return protocol interrupted' }
    }
}
