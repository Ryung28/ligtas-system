'use server'

import { revalidatePath } from 'next/cache'
import { supabase } from '@/lib/supabase'

/**
 * APPROVALS DOMAIN - Workflow Actions
 * 
 * Approve, Handoff, and Reject operations for pending borrow requests.
 * Implements the tactical staging workflow.
 */

export async function approveRequest(logId: number, approvedBy: string) {
    try {
        const { error } = await supabase
            .from('borrow_logs')
            .update({ 
                status: 'staged',
                approved_by: approvedBy,
                approved_at: new Date().toISOString()
            })
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

export async function completeHandoff(logId: number, handedBy: string) {
    try {
        const { error } = await supabase
            .from('borrow_logs')
            .update({ 
                status: 'borrowed',
                borrow_date: new Date().toISOString(),
                handed_by: handedBy,
                handed_at: new Date().toISOString()
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
