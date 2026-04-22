'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'

/**
 * 🛡️ LOGISTICS COMMAND ACTIONS
 * 
 * Server-side operations for resolving pending logistics triage items.
 * Updates 'logistics_actions' statuses and revalidates dashboard caches.
 */

export async function resolveLogisticsAction(id: string, decision: 'completed' | 'flagged', note?: string) {
    try {
        const supabase = await createSupabaseServer()
        
        const updateData: any = { 
            status: decision, 
            updated_at: new Date().toISOString() 
        }
        
        if (note) {
            updateData.forensic_note = note
        }
        
        const { error } = await supabase
            .from('logistics_actions')
            .update(updateData)
            .eq('id', id)

        if (error) {
            console.error('📡 DATABASE ERROR (resolveLogisticsAction):', error)
            return { success: false, error: error.message }
        }

        // Global cache purge to ensure real-time UI synchronization
        revalidatePath('/dashboard')
        revalidatePath('/dashboard/borrowers')
        revalidatePath('/dashboard/approvals')
        revalidatePath('/dashboard/logs')
        
        return { success: true, message: `Action ${decision} successfully.` }
    } catch (e: any) {
        console.error('📡 UNEXPECTED SERVER ERROR (resolveLogisticsAction):', e)
        return { success: false, error: 'Internal Server Error' }
    }
}
