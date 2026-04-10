import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Type definitions for inventory
export type StorageLocation = 'lower_warehouse' | '2nd_floor_warehouse' | 'office' | 'field'

export const STORAGE_LOCATION_LABELS: Record<StorageLocation, string> = {
    lower_warehouse: 'Lower Warehouse',
    '2nd_floor_warehouse': '2nd Floor Warehouse',
    office: 'Office',
    field: 'Field'
}

export interface InventoryVariant {
    id: number
    location: string
    stock_available: number
    stock_total: number
    status: string
}

export interface InventoryItem {
    id: number
    item_name: string
    category: string
    description?: string
    stock_total: number
    stock_available: number
    stock_borrowed?: number
    stock_pending?: number
    stock_truly_available?: number
    aggregate_total?: number
    aggregate_available?: number
    variants?: InventoryVariant[]
    status: string // 'Good', 'Damaged', or calculated status
    // Enterprise Status Buckets (Quantity Partitioning)
    qty_good: number
    qty_damaged: number
    qty_maintenance: number
    qty_lost: number
    image_url?: string
    location?: string
    serial_number?: string
    equipment_type?: string
    storage_location?: string
    primary_location?: string
    brand?: string
    expiry_date?: string
    target_stock?: number
    low_stock_threshold?: number
    created_at?: string
    updated_at?: string
}
