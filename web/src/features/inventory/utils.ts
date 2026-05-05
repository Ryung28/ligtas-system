import { InventoryItem } from "@/lib/supabase"
import { AggregatedInventoryItem } from "./types"

/**
 * 🏛️ SINGULAR AUTHORITY AGGREGATION ENGINE
 *
 * Model: One row per SKU for bulk items. The parent's packaging_json is the
 * sole source of truth. Child rows (parent_id != null) on bulk items are
 * treated as soft-deleted legacy data and are silently ignored.
 *
 * For non-bulk items, rows are grouped by SKU and summed by location.
 */
export function aggregateInventory(items: InventoryItem[]): AggregatedInventoryItem[] {
    const itemMap = new Map<string, AggregatedInventoryItem>()

    items.forEach(item => {
        const groupKey = `${item.item_name.toLowerCase().trim()}-${(item.category || '').toLowerCase().trim()}`

        let packaging = (item as any).packaging_json || (item as any).packaging
        if (typeof packaging === 'string') {
            try { packaging = JSON.parse(packaging) } catch { packaging = null }
        }

        const isBulkEnabled = packaging?.enabled === true && Array.isArray(packaging?.batches) && packaging.batches.length > 0
        const isChildRow = (item as any).parent_id != null

        // 🛡️ SINGULAR AUTHORITY: Skip child rows for bulk items.
        // The parent row carries the full manifest; children are legacy noise.
        if (isBulkEnabled && isChildRow) return

        const itemLocation = (item.storage_location || 'unknown').trim()

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
        const variantsMap = new Map<string, any>()
        group.variants.forEach(v => variantsMap.set(String(v.location_id), v))

        if (isBulkEnabled) {
            // 🏛️ BULK PATH: Derive locations and units purely from the manifest.
            // Each batch.locationId defines a separate site card.
            packaging.batches.forEach((batch: any) => {
                const locId = String(batch.locationId ?? 'unassigned')
                const locName = batch.locationName || locId

                let variant = variantsMap.get(locId)
                if (!variant) {
                    variant = {
                        id: item.id,
                        location: locName,
                        location_id: locId,
                        qty_good: 0, qty_damaged: 0, qty_maintenance: 0, qty_lost: 0,
                        stock_available: 0, stock_total: 0,
                        status: item.status,
                        ids: [item.id],
                        batches: [],
                    }
                    variantsMap.set(locId, variant)
                    group.variants.push(variant)
                }

                const units = Number(batch.units) || 0
                variant.stock_available += units
                variant.stock_total += units
                variant.qty_good += units
                variant.batches.push(batch)
            })

            // 🏛️ HOME ANCHOR: Ensure the location defined on the master record exists as a variant.
            // This prevents the UI from 'falling back' to a random satellite site for the Main Location card.
            const locationRegistryId = String((item as any).location_registry_id || '')
            const homeLocationName = (item.storage_location || 'unknown').trim()
            
            let homeVariant = variantsMap.get(locationRegistryId)
            if (!homeVariant) {
                homeVariant = {
                    id: item.id,
                    location: homeLocationName,
                    location_id: locationRegistryId,
                    qty_good: 0, qty_damaged: 0, qty_maintenance: 0, qty_lost: 0,
                    stock_available: 0, stock_total: 0,
                    status: item.status,
                    ids: [item.id],
                    batches: [],
                }
                variantsMap.set(locationRegistryId, homeVariant)
                group.variants.push(homeVariant)
            }

            // Row-level damaged/lost stock (loose stock) applies to the home variant.
            homeVariant.qty_damaged += (item.qty_damaged || 0)
            homeVariant.qty_maintenance += (item.qty_maintenance || 0)
            homeVariant.qty_lost += (item.qty_lost || 0)
            homeVariant.stock_total += (homeVariant.qty_damaged + homeVariant.qty_maintenance + homeVariant.qty_lost)
        } else {
            // 🏛️ NON-BULK PATH: Aggregate by registry ID or location name.
            const locationRegistryId = String((item as any).location_registry_id || '')
            const locId = locationRegistryId || itemLocation

            let variant = variantsMap.get(locId)
            if (!variant) {
                variant = {
                    id: item.id,
                    location: itemLocation,
                    location_id: locId,
                    qty_good: item.qty_good || 0,
                    qty_damaged: item.qty_damaged || 0,
                    qty_maintenance: item.qty_maintenance || 0,
                    qty_lost: item.qty_lost || 0,
                    stock_available: item.stock_available || 0,
                    stock_total: item.stock_total || 0,
                    status: item.status,
                    ids: [item.id],
                    batches: [],
                }
                variantsMap.set(locId, variant)
                group.variants.push(variant)
            } else {
                variant.stock_available += (item.stock_available || 0)
                variant.stock_total += (item.stock_total || 0)
                variant.qty_good += (item.qty_good || 0)
                variant.qty_damaged += (item.qty_damaged || 0)
                variant.qty_maintenance += (item.qty_maintenance || 0)
                variant.qty_lost += (item.qty_lost || 0)
                if (!variant.ids.includes(item.id)) variant.ids.push(item.id)
            }
        }
    })

    // Final rollup
    itemMap.forEach(group => {
        group.stock_total = group.variants.reduce((s, v) => s + v.stock_total, 0)
        group.stock_available = group.variants.reduce((s, v) => s + v.stock_available, 0)
        group.qty_good = group.variants.reduce((s, v) => s + v.qty_good, 0)
        group.qty_damaged = group.variants.reduce((s, v) => s + v.qty_damaged, 0)
        group.qty_maintenance = group.variants.reduce((s, v) => s + v.qty_maintenance, 0)
        group.qty_lost = group.variants.reduce((s, v) => s + v.qty_lost, 0)
        group.is_multi_location = group.variants.length > 1
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
