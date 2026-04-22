'use server'

import { revalidatePath } from 'next/cache'
import { createSupabaseServer } from '@/lib/supabase-server'
import { z } from 'zod'
import type { ActionResult, Station, StationManifestItem } from '../types'

// ─── Zod Schemas ─────────────────────────────────────────────────────────────

const createStationSchema = z.object({
    location_name: z.string().min(1, 'Physical location is required'),
    station_name: z.string().min(1, 'Station name is required').max(100),
    station_code: z.string().optional(),
    description: z.string().max(200).optional().nullable(),
    item_ids: z.array(z.number().int().positive()).optional(),
})

const updateStationNameSchema = z.object({
    station_id: z.number().int().positive(),
    station_name: z.string().min(1, 'Name is required').max(100),
})

const syncManifestSchema = z.object({
    station_id: z.number().int().positive(),
    item_ids: z.array(z.number().int().positive()),
})

// ─── Read ─────────────────────────────────────────────────────────────────────

export async function getStationManifest(
    stationId: number
): Promise<ActionResult<StationManifestItem[]>> {
    try {
        const supabase = await createSupabaseServer()

        const { data, error } = await supabase
            .from('station_manifest')
            .select(`
                item_id,
                inventory (
                    id,
                    item_name,
                    base_name,
                    variant_label,
                    category,
                    stock_available,
                    stock_total,
                    target_stock,
                    unit,
                    item_type
                )
            `)
            .eq('station_id', stationId)

        if (error) {
            console.error('[getStationManifest]', error)
            return { data: null, error: 'Failed to load station manifest.' }
        }

        const items: StationManifestItem[] = (data ?? [])
            .filter(row => row.inventory !== null)
            .map(row => {
                const inv = row.inventory as {
                    id: number
                    item_name: string
                    base_name: string | null
                    variant_label: string | null
                    category: string
                    stock_available: number
                    stock_total: number
                    target_stock: number
                    unit: string
                    item_type: string
                }
                return {
                    item_id: row.item_id,
                    item_name: inv.item_name,
                    base_name: inv.base_name,
                    variant_label: inv.variant_label,
                    category: inv.category ?? 'GEN',
                    stock_available: inv.stock_available,
                    stock_total: inv.stock_total,
                    target_stock: inv.target_stock,
                    unit: inv.unit ?? 'pcs',
                    item_type: (inv.item_type ?? 'consumable') as 'equipment' | 'consumable',
                }
            })

        return { data: items, error: null }
    } catch (err) {
        console.error('[getStationManifest] unexpected', err)
        return { data: null, error: 'An unexpected error occurred.' }
    }
}

// ─── Mutations ────────────────────────────────────────────────────────────────

export async function createStation(
    input: z.infer<typeof createStationSchema>
): Promise<ActionResult<Station>> {
    try {
        const supabase = await createSupabaseServer()
        const parsed = createStationSchema.safeParse(input)

        if (!parsed.success) {
            return { data: null, error: parsed.error.errors[0].message }
        }

        const { data: { user } } = await supabase.auth.getUser()

        // 🎲 AUTO-GENERATE STATION CODE
        const generatedCode = parsed.data.station_code || 
            `STN-${Math.random().toString(36).substring(2, 6).toUpperCase()}`

        // Step 1: Create the station
        const { data: station, error: stationError } = await supabase
            .from('storage_locations')
            .insert({
                location_name: parsed.data.location_name,
                station_name: parsed.data.station_name,
                station_code: generatedCode,
                description: parsed.data.description ?? null,
            })
            .select('id, location_name, station_name, station_code, description, created_at')
            .single()

        if (stationError) {
            console.error('[createStation]', stationError)
            if (stationError.code === '23505') {
                return { data: null, error: 'A station with that code already exists.' }
            }
            return { data: null, error: `Station creation failed: ${stationError.message}` }
        }

        // Step 2: Atomic manifest sync if items provided
        if (parsed.data.item_ids && parsed.data.item_ids.length > 0) {
            const rows = parsed.data.item_ids.map(item_id => ({
                station_id: station.id,
                item_id,
                added_by: user?.id ?? null,
            }))

            const { error: manifestError } = await supabase
                .from('station_manifest')
                .insert(rows)

            if (manifestError) {
                console.error('[createStation:manifest]', manifestError)
                // We keep the station but notify that manifest failed
                return { data: station as Station, error: 'Station created but manifest failed to sync.' }
            }
        }

        revalidatePath('/dashboard/inventory/tactical-stations')
        return { data: station as Station, error: null }
    } catch (err) {
        console.error('[createStation] unexpected', err)
        return { data: null, error: 'An unexpected error occurred during creation.' }
    }
}

export async function updateStationName(
    input: z.infer<typeof updateStationNameSchema>
): Promise<ActionResult<null>> {
    try {
        const parsed = updateStationNameSchema.safeParse(input)
        if (!parsed.success) return { data: null, error: parsed.error.errors[0].message }

        const supabase = await createSupabaseServer()
        const { error } = await supabase
            .from('storage_locations')
            .update({ station_name: parsed.data.station_name })
            .eq('id', parsed.data.station_id)

        if (error) {
            console.error('[updateStationName]', error)
            return { data: null, error: 'Failed to update station name.' }
        }

        revalidatePath('/dashboard/inventory/tactical-stations')
        return { data: null, error: null }
    } catch (err) {
        console.error('[updateStationName] unexpected', err)
        return { data: null, error: 'An unexpected error occurred.' }
    }
}

export async function deleteStation(stationId: number): Promise<ActionResult<null>> {
    try {
        const validated = z.number().int().positive().safeParse(stationId)
        if (!validated.success) return { data: null, error: 'Invalid station ID.' }

        const supabase = await createSupabaseServer()

        const { error } = await supabase
            .from('storage_locations')
            .delete()
            .eq('id', stationId)

        if (error) {
            console.error('[deleteStation]', error)
            return { data: null, error: 'Failed to delete station.' }
        }

        revalidatePath('/dashboard/inventory/tactical-stations')
        return { data: null, error: null }
    } catch (err) {
        console.error('[deleteStation] unexpected', err)
        return { data: null, error: 'An unexpected error occurred.' }
    }
}

/**
 * Atomic replace: removes all current mappings for the station
 * and re-inserts the new selection in one shot.
 */
export async function syncStationManifest(
    stationId: number,
    itemIds: number[]
): Promise<ActionResult<null>> {
    try {
        const parsed = syncManifestSchema.safeParse({ station_id: stationId, item_ids: itemIds })
        if (!parsed.success) return { data: null, error: parsed.error.errors[0].message }

        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()

        // Step 1: wipe existing manifest for this station
        const { error: deleteError } = await supabase
            .from('station_manifest')
            .delete()
            .eq('station_id', parsed.data.station_id)

        if (deleteError) {
            console.error('[syncStationManifest] delete failed', deleteError)
            return { data: null, error: 'Failed to clear previous manifest.' }
        }

        // Step 2: re-insert selections (skip if empty — station is now empty)
        if (parsed.data.item_ids.length > 0) {
            const rows = parsed.data.item_ids.map(item_id => ({
                station_id: parsed.data.station_id,
                item_id,
                added_by: user?.id ?? null,
            }))

            const { error: insertError } = await supabase
                .from('station_manifest')
                .insert(rows)

            if (insertError) {
                console.error('[syncStationManifest] insert failed', insertError)
                return { data: null, error: 'Failed to save manifest. Try again.' }
            }
        }

        revalidatePath('/dashboard/inventory/tactical-stations')
        return { data: null, error: null }
    } catch (err) {
        console.error('[syncStationManifest] unexpected', err)
        return { data: null, error: 'An unexpected error occurred.' }
    }
}
