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
            data: data?.map(loc => loc.location_name) || [] 
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

        const { error } = await supabase
            .from(STORAGE_LOCATIONS_TABLE)
            .insert([{ location_name: locationName.trim() }])

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { success: true, message: `"${locationName}" saved to locations` }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to save location' }
    }
}

export async function deleteStorageLocation(locationName: string) {
    try {
        const supabase = await createSupabaseServer()
        
        const { error } = await supabase
            .from(STORAGE_LOCATIONS_TABLE)
            .delete()
            .eq('location_name', locationName)

        if (error) throw error

        revalidatePath('/dashboard/inventory')
        return { success: true }
    } catch (error: any) {
        return { success: false, error: error.message || 'Failed to delete location' }
    }
}
