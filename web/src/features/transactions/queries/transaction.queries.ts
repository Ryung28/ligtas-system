'use server'

import { supabase } from '@/lib/supabase'

/**
 * TRANSACTIONS DOMAIN - Query Actions
 * 
 * Read-only operations for fetching borrow/return transaction data.
 */

export interface PendingRequest {
    id: number
    borrower_name: string
    quantity: number
    created_at: string
}

export async function getPendingRequestsByItemId(itemId: number): Promise<{ success: boolean; data?: PendingRequest[]; error?: string }> {
    try {
        const { data, error } = await supabase
            .from('borrow_logs')
            .select('id, borrower_name, quantity, created_at')
            .eq('inventory_id', itemId)
            .eq('status', 'pending')
            .order('created_at', { ascending: true })

        if (error) {
            console.error('Supabase error fetching pending requests:', error)
            throw error
        }

        return {
            success: true,
            data: data || [],
        }
    } catch (error: any) {
        console.error('Error in getPendingRequestsByItemId:', error)
        return {
            success: false,
            error: error.message || 'Failed to fetch pending requests',
        }
    }
}
