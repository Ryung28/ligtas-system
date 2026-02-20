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
    category: z.enum(['Rescue', 'Medical', 'Comms', 'Vehicles', 'Office', 'Tools', 'PPE', 'Logistics'], {
        errorMap: () => ({ message: 'Please select a valid category' }),
    }),
    stock_total: z.coerce.number().min(1, 'Stock must be at least 1'),
    status: z.string().default('Good'),
    image_url: z.string().optional().nullable(),
})

const borrowItemSchema = z.object({
    borrower_name: z.string().min(1, 'Borrower name is required'),
    contact_number: z
        .string()
        .regex(/^09\d{9}$/, 'Invalid Philippine mobile number (must be 09XXXXXXXXX)'),
    office_department: z.string().min(1, 'Office/Department is required'),
    item_id: z.coerce.number().min(1, 'Please select an item'),
    quantity: z.coerce.number().min(1, 'Quantity must be at least 1'),
    purpose: z.string().optional(),
    expected_return_date: z.string().optional().nullable(),
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

        const validatedData = borrowItemSchema.parse(rawData)

        // Step 1: Check if enough stock is available
        const { data: inventoryItem, error: checkError } = await supabase
            .from('inventory')
            .select('id, item_name, stock_available')
            .eq('id', validatedData.item_id)
            .single()

        if (checkError || !inventoryItem) {
            return {
                success: false,
                error: 'Item not found',
            }
        }

        if (inventoryItem.stock_available < validatedData.quantity) {
            return {
                success: false,
                error: `Insufficient stock. Only ${inventoryItem.stock_available} units available.`,
            }
        }

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
                    borrower_organization: validatedData.office_department,
                    purpose: validatedData.purpose,
                    transaction_type: 'borrow',
                    status: 'borrowed',
                    borrow_date: now,
                    expected_return_date: validatedData.expected_return_date ? new Date(validatedData.expected_return_date).toISOString() : null,
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
                error: 'Failed to create borrow record',
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
            message: `Successfully borrowed ${validatedData.quantity} unit(s) of ${inventoryItem.item_name}`,
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

// Helper function to get available items for dropdown
export async function getAvailableItems() {
    try {
        const { data, error } = await supabase
            .from('inventory')
            .select('id, item_name, stock_available, category')
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
                image_url: validatedData.image_url
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
        const { error } = await supabase
            .from('inventory')
            .delete()
            .eq('id', id)

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { success: true, message: 'Item deleted successfully' }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to delete item' }
    }
}

// ============================================
// APPROVAL ACTIONS
// ============================================

export async function approveRequest(logId: number) {
    try {
        const { error } = await supabase
            .from('borrow_logs')
            .update({ status: 'borrowed' })
            .eq('id', logId)

        if (error) throw error

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard')
        return { success: true, message: 'Request approved successfully' }
    } catch (error: any) {
        console.error('Approve error:', error)
        return { success: false, error: error.message || 'Failed to approve request' }
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
        if (log.status !== 'pending') throw new Error('Only pending requests can be rejected')

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
