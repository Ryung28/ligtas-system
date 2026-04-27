'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import type { ActionResult, Station, StationManifestItem } from '../types'

/**
 * 🛰️ TACTICAL RESOLVER
 * Fetches the manifest for a station using either its numeric ID or tactical code.
 */
export async function getStationManifest(
    stationId: string | number
): Promise<ActionResult<{ station: Station; items: StationManifestItem[] }>> {
    try {
        const supabase = await createSupabaseServer()

        // 1. Resolve the Station first (Internal ID or Tactical Code)
        const isNumeric = !isNaN(Number(stationId)) && String(stationId).trim() !== ''
        
        const { data: station, error: sError } = await supabase
            .from('storage_locations')
            .select('*')
            .or(`id.eq.${isNumeric ? Number(stationId) : -1},station_code.eq.${String(stationId)}`)
            .maybeSingle()

        if (sError || !station) {
            return { data: null, error: 'Station not found.' }
        }

        // 2. Fetch the manifest items
        const { data: manifest, error: mError } = await supabase
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
                    item_type,
                    image_url
                )
            `)
            .eq('station_id', station.id)

        if (mError) {
            console.error('[getStationManifest:items]', mError)
            return { data: null, error: 'Failed to load station manifest.' }
        }

        const items: StationManifestItem[] = (manifest ?? [])
            .filter(row => row.inventory !== null)
            .map(row => {
                const inv = row.inventory as any
                return {
                    station_id: station.id,
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
                    image_url: inv.image_url
                }
            })

        return { 
            data: { 
                station: station as Station, 
                items 
            }, 
            error: null 
        }
    } catch (err) {
        console.error('[getStationManifest] unexpected', err)
        return { data: null, error: 'An unexpected error occurred.' }
    }
}
