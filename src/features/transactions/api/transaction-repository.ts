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
    const returnedAt = new Date().toISOString();
    
    // 1. Update the log status with comprehensive audit trail
    const { error: updateError } = await supabase
        .from('borrow_logs')
        .update({
            status: 'returned',
            actual_return_date: returnedAt,
            received_by_name: audit.received_by_name,
            returned_by_name: audit.returned_by_name, // 🛡️ Audit: Who physically returned it
            return_condition: audit.return_condition,
            return_notes: audit.return_notes
        })
        .eq('id', logId);

    if (updateError) return handleError(updateError);

    revalidatePath('/dashboard/logs');
    revalidatePath('/dashboard/inventory');

    return { success: true, message: 'Item successfully restored to inventory.', data: { returnedAt } };
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
