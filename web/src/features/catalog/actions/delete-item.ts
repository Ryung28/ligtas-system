'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'
import { ActionResult } from '@/src/shared/types'

export async function deleteItem(id: number): Promise<ActionResult<void>> {
    try {
        const supabase = await createSupabaseServer()
        
        // 🛡️ STOCK GUARD: Prevent deleting items with active stock
        const { data: records } = await supabase
            .from('inventory')
            .select('stock_total, item_name')
            .or(`id.eq.${id},parent_id.eq.${id}`)
            .is('deleted_at', null)

        const totalStock = (records || []).reduce((s, r) => s + (r.stock_total || 0), 0)
        if (totalStock > 0) {
            return { data: null, error: `Cannot delete "${records?.[0]?.item_name || 'item'}". It still has ${totalStock} units in stock. Please clear inventory first.` }
        }

        const { data: activeBorrows } = await supabase.from('borrow_logs').select('id').eq('inventory_id', id).eq('status', 'borrowed')
        if (activeBorrows && activeBorrows.length > 0) return { data: null, error: 'Active checkouts exist' }
        
        const { error } = await supabase.from('inventory').update({ deleted_at: new Date().toISOString() }).eq('id', id)
        if (error) throw error
        
        revalidatePath('/dashboard/inventory')
        return { data: undefined, error: null }
    } catch (error: any) {
        return { data: null, error: error.message || 'Failed to delete item' }
    }
}

export async function bulkDeleteItem(ids: number[]): Promise<ActionResult<void>> {
    try {
        if (!ids.length) return { data: undefined, error: null }
        const supabase = await createSupabaseServer()
        
        // 🛡️ STOCK GUARD: Prevent deleting items with active stock
        const { data: records } = await supabase
            .from('inventory')
            .select('id, stock_total, item_name')
            .or(`id.in.(${ids.join(',')}),parent_id.in.(${ids.join(',')})`)
            .is('deleted_at', null)

        const itemsWithStock = records?.filter(r => (r.stock_total || 0) > 0) || []
        if (itemsWithStock.length > 0) {
            return { data: null, error: `Cannot delete ${itemsWithStock.length} items that still have active stock. Please clear inventory first.` }
        }

        const { data: activeBorrows } = await supabase
            .from('borrow_logs')
            .select('inventory_id')
            .in('inventory_id', ids)
            .eq('status', 'borrowed')
            
        if (activeBorrows && activeBorrows.length > 0) {
            return { data: null, error: 'Some items have active checkouts and cannot be deleted.' }
        }

        const { error } = await supabase.from('inventory').update({ deleted_at: new Date().toISOString() }).in('id', ids)
        if (error) throw error
        
        revalidatePath('/dashboard/inventory')
        return { data: undefined, error: null }
    } catch (error: any) {
        return { data: null, error: error.message || 'Failed to perform bulk delete' }
    }
}
