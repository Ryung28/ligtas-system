import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Type definitions for inventory
export interface InventoryItem {
    id: number
    item_name: string
    category: string
    description?: string
    stock_total: number
    stock_available: number
    status: string // 'Good', 'Damaged', or calculated status
    image_url?: string
    created_at?: string
    updated_at?: string
}
