'use server';

import { createSupabaseServer } from '@/lib/supabase-server';
import { PostgrestError } from '@supabase/supabase-js';
import { revalidatePath } from 'next/cache';

export interface TransactionResult<T = any> {
    success: boolean;
    data?: T;
    error?: string;
    message?: string;
}

/**
 * Executes a borrowing operation.
 * Pattern: Atomic Dispatch
 */
export async function createBorrowRecord(data: any): Promise<TransactionResult> {
    const supabase = await createSupabaseServer();
    const { data: log, error } = await supabase
        .from('borrow_logs')
        .insert([data])
        .select()
        .single();

    if (error) return handleError(error);
    
    // Clear cache to reflect new dispatch in logs
    revalidatePath('/dashboard/logs');
    revalidatePath('/dashboard/inventory');
    
    return { success: true, data: log };
}

/**
 * Executes a batch borrowing operation.
 * Pattern: Operational Fulfillment
 */
export async function createBatchBorrow(logs: any[]): Promise<TransactionResult> {
    const supabase = await createSupabaseServer();
    const { data: result, error } = await supabase
        .from('borrow_logs')
        .insert(logs)
        .select();

    if (error) return handleError(error);
    
    revalidatePath('/dashboard/logs');
    revalidatePath('/dashboard/inventory');
    
    return { success: true, data: result };
}

/**
 * Executes a return operation.
 * Pattern: Inventory Restoration
 */
export async function finalizeReturn(logId: number, audit: any, quantity: number, inventoryId: number): Promise<TransactionResult> {
    const supabase = await createSupabaseServer();
    
    // 1. Update the log status
    const { error: updateError } = await supabase
        .from('borrow_logs')
        .update({
            status: 'returned',
            actual_return_date: new Date().toISOString(),
            ...audit
        })
        .eq('id', logId);

    if (updateError) return handleError(updateError);

    // 2. Adjust Stock
    const { data: item, error: itemError } = await supabase
        .from('inventory')
        .select('stock_available')
        .eq('id', inventoryId)
        .single();

    if (itemError) return handleError(itemError);

    const { error: stockError } = await supabase
        .from('inventory')
        .update({ stock_available: (item?.stock_available || 0) + quantity })
        .eq('id', inventoryId);

    if (stockError) return handleError(stockError);

    revalidatePath('/dashboard/logs');
    revalidatePath('/dashboard/inventory');

    return { success: true, message: 'Item successfully restored to inventory.' };
}

/**
 * Standardized Error Transporter
 */
function handleError(error: PostgrestError): TransactionResult {
    console.error('Database Error:', error);
    
    if (error.message?.includes('check_stock_positive')) {
        return { success: false, error: 'Insufficient operational stock for this request.' };
    }
    
    return { success: false, error: error.message || 'An unexpected logistical error occurred.' };
}
