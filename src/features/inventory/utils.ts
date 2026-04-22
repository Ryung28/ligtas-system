import { InventoryItem } from "@/lib/supabase"
import { AggregatedInventoryItem } from "./types"

/**
 * 🏛️ PLATINUM AGGREGATION ENGINE
 * Consolidates inventory rows by SKU across multiple sites.
 */
export function aggregateInventory(items: InventoryItem[]): AggregatedInventoryItem[] {
    const itemMap = new Map<string, AggregatedInventoryItem>()
    
    items.forEach(item => {
        const groupKey = `${item.item_name.toLowerCase().trim()}-${(item.category || '').toLowerCase().trim()}`
        const itemLocation = item.storage_location || 'unknown'
        
        if (!itemMap.has(groupKey)) {
            itemMap.set(groupKey, { 
                ...item, 
                stock_total: 0,
                stock_available: 0,
                qty_good: 0,
                qty_damaged: 0,
                qty_maintenance: 0,
                qty_lost: 0,
                variants: [], 
                is_multi_location: false,
                primary_location: itemLocation,
            } as AggregatedInventoryItem)
        }
        
        const group = itemMap.get(groupKey)!
        group.stock_total += (item.stock_total || 0)
        group.stock_available += (item.stock_available || 0)
        group.qty_good += (item.qty_good || 0)
        group.qty_damaged += (item.qty_damaged || 0)
        group.qty_maintenance += (item.qty_maintenance || 0)
        group.qty_lost += (item.qty_lost || 0)

        const existingVariant = group.variants.find(v => v.location === itemLocation)
        if (existingVariant) {
            existingVariant.stock_available += item.stock_available
            existingVariant.stock_total += item.stock_total
            existingVariant.qty_good += item.qty_good
            existingVariant.qty_damaged += item.qty_damaged
            existingVariant.qty_maintenance += item.qty_maintenance
            existingVariant.qty_lost += item.qty_lost
            existingVariant.ids.push(item.id)
        } else {
            if (group.variants.length > 0) group.is_multi_location = true
            group.variants.push({
                id: item.id,
                location: itemLocation,
                location_id: (item as any).location_registry_id,
                qty_good: item.qty_good,
                qty_damaged: item.qty_damaged,
                qty_maintenance: item.qty_maintenance,
                qty_lost: item.qty_lost,
                stock_available: item.stock_available,
                stock_total: item.stock_total,
                status: item.status,
                ids: [item.id]
            })
        }
    })
    
    return Array.from(itemMap.values())
}

/**
 * Effective low-stock threshold in units.
 */
export function getEffectiveLowStockThreshold(item: Partial<InventoryItem>): number | null {
    const anchor = Number((item.target_stock ?? 0) > 0 ? item.target_stock : (item.stock_total ?? 0))
    const percent = Number(item.low_stock_threshold ?? 20)

    if (anchor <= 0) return null
    return Math.ceil((anchor * percent) / 100)
}

/**
 * True when this row should be considered low-stock in UI.
 */
export function isLowStock(item: Partial<InventoryItem>): boolean {
    if (item.restock_alert_enabled === false) return false

    const available = item.stock_available ?? 0
    const st = (item.status || "").toLowerCase()
    if (["damaged", "lost", "deleted"].includes(st)) return false

    const eff = getEffectiveLowStockThreshold(item)
    if (eff == null) return false
    return available <= eff
}

export function getStockStatusLabel(item: Partial<InventoryItem>): 'OUT OF STOCK' | 'LOW STOCK' | 'IN STOCK' {
    const available = item.stock_available || 0

    if (available === 0) return 'OUT OF STOCK'
    if (isLowStock(item)) return 'LOW STOCK'
    return 'IN STOCK'
}
