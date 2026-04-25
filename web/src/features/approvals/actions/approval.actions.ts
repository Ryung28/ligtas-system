'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'

/**
 * APPROVALS DOMAIN - Workflow Actions
 * 
 * Approve, Handoff, and Reject operations for pending borrow requests.
 * Implements the tactical staging workflow.
 */

export async function approveRequest(
    logId: number, 
    approvedBy: string, 
    isInstant: boolean = false,
    auditOptions?: { 
        handedBy?: string, 
        physicallyReceivedBy?: string,
        adminId?: string 
    }
) {
    try {
        const supabase = await createSupabaseServer()
        
        // 🛡️ SECURITY: Verify Admin Role
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { data: profile } = await supabase
            .from('user_profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (profile?.role?.toLowerCase() !== 'admin') {
            return { success: false, error: 'Authorization failed: Only Administrators can approve requests.' }
        }
        
        // 1. Fetch item type to handle consumables correctly
        const { data: log } = await supabase
            .from('borrow_logs')
            .select('inventory_id, inventory(item_type)')
            .eq('id', logId)
            .single()

        const isConsumable = log?.inventory?.item_type === 'consumable' || log?.inventory?.[0]?.item_type === 'consumable'

        const updateData: any = { 
            status: isInstant ? (isConsumable ? 'dispensed' : 'borrowed') : 'staged',
            approved_by: approvedBy,
            approved_by_name: approvedBy,
            approved_at: new Date().toISOString(),
            last_updated_origin: 'Web'
        }

        if (isInstant) {
            updateData.handed_by = auditOptions?.handedBy || approvedBy
            updateData.released_by_name = approvedBy
            updateData.released_by_user_id = auditOptions?.adminId || null
            updateData.physically_received_by = auditOptions?.physicallyReceivedBy || null
            updateData.handed_at = new Date().toISOString()
            updateData.borrow_date = new Date().toISOString()
        }

        const { error } = await supabase
            .from('borrow_logs')
            .update(updateData)
            .eq('id', logId)

        if (error) throw error

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard/approvals')
        revalidatePath('/dashboard')
        revalidatePath('/m')
        revalidatePath('/m/logs')
        return { 
            success: true, 
            message: isInstant 
                ? 'Request approved and equipment marked as borrowed.' 
                : 'Request approved and moved to staging' 
        }
    } catch (error: any) {
        console.error('Approve error:', error)
        return { success: false, error: error.message || 'Failed to approve request' }
    }
}

export async function completeHandoff(
    logId: number, 
    handedBy: string, 
    adminId?: string,
    physicallyReceivedBy?: string
) {
    try {
        const supabase = await createSupabaseServer()

        // 🛡️ SECURITY: Verify Admin Role
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { data: profile } = await supabase
            .from('user_profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (profile?.role?.toLowerCase() !== 'admin') {
            return { success: false, error: 'Authorization failed: Only Administrators can complete handoffs.' }
        }

        // 1. Fetch item type to handle consumables correctly
        const { data: log } = await supabase
            .from('borrow_logs')
            .select('inventory_id, inventory(item_type)')
            .eq('id', logId)
            .single()

        const isConsumable = log?.inventory?.item_type === 'consumable' || log?.inventory?.[0]?.item_type === 'consumable'

        const { error } = await supabase
            .from('borrow_logs')
            .update({ 
                status: isConsumable ? 'dispensed' : 'borrowed',
                borrow_date: new Date().toISOString(),
                handed_by: handedBy,
                released_by_name: handedBy,
                released_by_user_id: adminId || null,
                physically_received_by: physicallyReceivedBy || null,
                handed_at: new Date().toISOString(),
                last_updated_origin: 'Web'
            })
            .eq('id', logId)

        if (error) throw error

        revalidatePath('/dashboard/logs')
        revalidatePath('/dashboard')
        revalidatePath('/m')
        revalidatePath('/m/logs')
        return { success: true, message: 'Handoff complete. Item is now in active service.' }
    } catch (error: any) {
        console.error('Handoff error:', error)
        return { success: false, error: error.message || 'Failed to complete handoff' }
    }
}

export async function rejectRequest(logId: number) {
    try {
        const supabase = await createSupabaseServer()

        // 🛡️ SECURITY: Verify Admin Role
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Unauthorized')

        const { data: profile } = await supabase
            .from('user_profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (profile?.role?.toLowerCase() !== 'admin') {
            return { success: false, error: 'Authorization failed: Only Administrators can reject requests.' }
        }
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
        revalidatePath('/m')
        revalidatePath('/m/logs')
        return { success: true, message: 'Request rejected and stock restored' }
    } catch (error: any) {
        console.error('Reject error:', error)
        return { success: false, error: error.message || 'Failed to reject request' }
    }
}
