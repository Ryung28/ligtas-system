import { supabase } from '@/lib/supabase'

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

export async function getInventoryStats() {
    const inventory = await getInventory()
    
    return {
        totalItems: inventory.length,
        totalStock: inventory.reduce((sum, item) => sum + (item.stock_available || 0), 0),
        lowStockCount: inventory.filter(item => {
            const available = item.stock_available || 0
            const total = item.stock_total || 1
            const threshold = total * 0.5
            return available > 0 && available < threshold
        }).length,
        outOfStockCount: inventory.filter(item => (item.stock_available || 0) === 0).length,
        damagedCount: inventory.filter(item =>
            ['Maintenance', 'Damaged', 'Lost'].includes(item.status || '')
        ).length
    }
}
