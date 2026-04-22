import { createSupabaseServer } from '@/lib/supabase-server'
import { StationsHubClient } from './stations-hub-client'
import type { Station, InventoryPickerItem } from '@/src/features/tactical-stations/types'

export const metadata = {
    title: 'Tactical Station Builder | ResQTrack',
    description: 'Physical QR Station Builder & Inventory Mapping',
}

export const dynamic = 'force-dynamic'

async function getStations(): Promise<Station[]> {
    try {
        const supabase = await createSupabaseServer()
        const { data, error } = await supabase
            .from('storage_locations')
            .select('id, location_name, station_code, description, created_at')
            .not('station_code', 'is', null)
            .order('created_at', { ascending: true })

        if (error) {
            console.error('[getStations]', error)
            return []
        }
        return (data ?? []) as Station[]
    } catch {
        return []
    }
}

async function getInventoryItems(): Promise<InventoryPickerItem[]> {
    try {
        const supabase = await createSupabaseServer()
        const { data, error } = await supabase
            .from('inventory')
            .select('id, item_name, category, stock_available, stock_total, target_stock, unit, item_type')
            .is('deleted_at', null)
            .order('item_name', { ascending: true })

        if (error) {
            console.error('[getInventoryItems]', error)
            return []
        }
        return (data ?? []).map(row => ({
            id: row.id as number,
            item_name: row.item_name as string,
            category: (row.category ?? 'GEN') as string,
            stock_available: (row.stock_available ?? 0) as number,
            stock_total: (row.stock_total ?? 0) as number,
            unit: (row.unit ?? 'pcs') as string,
            item_type: ((row.item_type ?? 'consumable') as 'equipment' | 'consumable'),
        }))
    } catch {
        return []
    }
}

export default async function TacticalStationsPage() {
    const [stations, inventoryItems] = await Promise.all([
        getStations(),
        getInventoryItems(),
    ])

    return (
        <StationsHubClient
            stations={stations}
            inventoryItems={inventoryItems}
        />
    )
}
