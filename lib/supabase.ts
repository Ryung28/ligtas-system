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
    location_registry_id?: number | null
    qty_good?: number
    qty_damaged?: number
    qty_maintenance?: number
    qty_lost?: number
}

export interface InventoryItem {
    id: number
    item_name: string
    category: string
    description?: string
    stock_total: number
    item_type?: 'equipment' | 'consumable'
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
    expiry_alert_days?: number | null
    target_stock?: number
    low_stock_threshold?: number
    restock_alert_enabled?: boolean
    created_at?: string
    updated_at?: string
}
export function getInventoryImageUrl(pathOrUrl?: string | null) {
    if (!pathOrUrl || pathOrUrl.trim() === '') return null
    
    const baseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://knarlvwnuvedyfvvaota.supabase.co'
    const BUCKET = 'item-images'

    // 🛡️ DEFENSIVE RESOLVER: Handle both raw paths and potentially expired URLs
    if (pathOrUrl.startsWith('http')) {
        // If it's our own Supabase URL, extract path to avoid expired signatures/tokens
        if (pathOrUrl.includes('/storage/v1/object/')) {
            try {
                // Parse: .../storage/v1/object/[type]/[bucket]/[path]
                const pathSuffix = pathOrUrl.split('/storage/v1/object/')[1]
                const parts = pathSuffix.split('?')[0].split('/') // Remove query params first
                
                const bucketName = parts[1]
                const filePath = parts.slice(2).join('/')
                
                if (bucketName === BUCKET) {
                    return `${baseUrl}/storage/v1/object/public/${BUCKET}/${filePath}`
                }
            } catch (e) {
                return pathOrUrl // Fallback on parse error
            }
        }
        return pathOrUrl
    }
    
    // 🏛️ DEFENSIVE CLEANING: Remove leading slashes and redundant bucket prefixes
    // This allows the system to handle 'mask.png', '/mask.png', and 'item-images/mask.png' correctly.
    let cleanPath = pathOrUrl.trim().replace(/^\/+/, '')
    
    if (cleanPath.startsWith(`${BUCKET}/`)) {
        cleanPath = cleanPath.replace(`${BUCKET}/`, '')
    }
    
    // 🚀 BULLETPROOF RESOLUTION: Manually construct the public URL
    // By doing this manually, we avoid any bugs where the Supabase SDK returns a relative
    // path if it was instantiated without NEXT_PUBLIC_SUPABASE_URL in specific Next.js Server Actions.
    return `${baseUrl}/storage/v1/object/public/${BUCKET}/${cleanPath}`
}
