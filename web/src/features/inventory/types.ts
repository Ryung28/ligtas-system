import { InventoryItem } from "@/lib/supabase"

export interface AggregatedInventoryItem extends InventoryItem {
    variants: Array<{
        id: number
        location: string
        location_id?: string
        qty_good: number
        qty_damaged: number
        qty_maintenance: number
        qty_lost: number
        stock_available: number
        stock_total: number
        status: string
        ids: number[]
    }>
    is_multi_location: boolean
    primary_location: string
}
