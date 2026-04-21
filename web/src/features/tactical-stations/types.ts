// /src/features/tactical-stations/types.ts

export type Station = {
    id: number
    location_name: string
    station_name: string | null
    station_code: string | null
    description: string | null
    created_at: string
}

export type StationManifestItem = {
    item_id: number
    item_name: string
    category: string
    stock_available: number
    unit: string
    item_type: 'equipment' | 'consumable'
}

export type InventoryPickerItem = {
    id: number
    item_name: string
    category: string
    stock_available: number
    unit: string
    item_type: 'equipment' | 'consumable'
}

export type ActionResult<T> =
    | { data: T; error: null }
    | { data: null; error: string }
