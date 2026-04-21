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

export interface ActiveLoan {
    id: number
    borrower_name: string
    quantity: number
    status: 'borrowed' | 'overdue'
    expected_return_date: string | null
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
export async function getActiveLoansByIds(itemIds: number[]): Promise<{ success: boolean; data?: ActiveLoan[]; error?: string }> {
    try {
        if (!itemIds || itemIds.length === 0) return { success: true, data: [] }
        
        const { data, error } = await supabase
            .from('borrow_logs')
            .select('id, borrower_name, quantity, status, expected_return_date, created_at')
            .in('inventory_id', itemIds)
            .in('status', ['borrowed', 'overdue'])
            .order('created_at', { ascending: false })

        if (error) {
            console.error('Supabase error fetching active loans:', error)
            throw error
        }

        return {
            success: true,
            data: data || [],
        }
    } catch (error: any) {
        console.error('Error in getActiveLoansByIds:', error)
        return {
            success: false,
            error: error.message || 'Failed to fetch active loans',
        }
    }
}
