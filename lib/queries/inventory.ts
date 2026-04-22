import { supabase } from '@/lib/supabase'
import { isLowStock } from '@/lib/inventory-utils'

/**
 * Centralized inventory queries
 * All inventory data fetching should use these functions
 */

export async function getInventory() {
    const { data, error } = await supabase
        .from('inventory')
        .select('*')
        .is('deleted_at', null)
        .order('item_name', { ascending: true })
        .limit(1000)

    if (error) throw error
    return data || []
}

// Alias for Server Components
export const getInitialInventory = getInventory

export async function getInventoryWithAvailability() {
    const [inventory, availability] = await Promise.all([
        getInventory(),
        supabase.from('inventory_availability').select('id, stock_pending')
    ])

    const pendingMap = new Map(
        (availability.data || []).map(item => [item.id, item.stock_pending])
    )

    return inventory.map(item => ({
        ...item,
        stock_pending: pendingMap.get(item.id) || 0
    }))
}

/**
 * 🛰️ TACTICAL FETCH: Hydrated Inventory with Resolved Assets
 * This is the master fetcher used by the Global Inventory Provider.
 */
export async function fetchInventory() {
    // 1. Get raw inventory with pending status
    // 2. No signing needed for public buckets—components handle URLs directly
    return await getInventoryWithAvailability()
}

export async function getInventoryStats() {
    const inventory = await getInventory()
    
    return {
        totalItems: inventory.length,
        totalStock: inventory.reduce((sum, item) => sum + (item.stock_available || 0), 0),
        lowStockCount: inventory.filter(item => isLowStock(item)).length,
        outOfStockCount: inventory.filter(item => (item.stock_available || 0) === 0).length,
        damagedCount: inventory.filter(item =>
            ['Maintenance', 'Damaged', 'Lost'].includes(item.status || '')
        ).length
    }
}
