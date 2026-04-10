'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'

// Table to store custom storage locations
const STORAGE_LOCATIONS_TABLE = 'storage_locations'

export async function getStorageLocations() {
    try {
        const supabase = await createSupabaseServer()
        
        const { data, error } = await supabase
            .from(STORAGE_LOCATIONS_TABLE)
            .select('*')
            .order('created_at', { ascending: false })

        if (error) throw error

        return { 
            success: true, 
            data: data || [] 
        }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to fetch locations', data: [] }
    }
}

export async function addStorageLocation(locationName: string) {
    try {
        if (!locationName.trim()) {
            return { success: false, error: 'Location name cannot be empty' }
        }

        const supabase = await createSupabaseServer()

        // Check if location already exists
        const { data: existing } = await supabase
            .from(STORAGE_LOCATIONS_TABLE)
            .select('id')
            .eq('location_name', locationName.trim())
            .single()

        if (existing) {
            return { success: false, error: 'This location already exists' }
        }

        const { data, error } = await supabase
            .from(STORAGE_LOCATIONS_TABLE)
            .insert([{ location_name: locationName.trim() }])
            .select()
            .single()

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { 
            success: true, 
            message: `"${locationName}" saved to locations`,
            data: data 
        }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to save location', data: null }
    }
}

export async function deleteStorageLocation(id: number) {
    try {
        const supabase = await createSupabaseServer()
        
        // 🔒 SAFETY CHECK: Prevent deletion of sites with gear
        const { data: linked } = await supabase
            .from('inventory')
            .select('id')
            .eq('location_registry_id', id)
            .limit(1)

        if (linked && linked.length > 0) {
            return { success: false, error: '⚠️ Site has active inventory. Move gear first.' }
        }

        const { error } = await supabase
            .from(STORAGE_LOCATIONS_TABLE)
            .delete()
            .eq('id', id)

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { success: true, message: 'Site removed successfully.' }
    } catch (error: any) {
        return { success: false, error: 'Failed to delete site registry entry.' }
    }
}
