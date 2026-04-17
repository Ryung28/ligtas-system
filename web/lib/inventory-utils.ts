import { InventoryItem } from "./supabase"

/**
 * Effective low-stock threshold in units.
 * Formula: ceil(target_stock * low_stock_threshold / 100).
 * If either input is missing/zero, returns null (percent rule disabled).
 */
export function getEffectiveLowStockThreshold(item: Partial<InventoryItem>): number | null {
    const target = Number(item.target_stock ?? 0)
    const percent = Number(item.low_stock_threshold ?? 0)

    if (target <= 0 || percent <= 0) return null
    return Math.ceil((target * percent) / 100)
}

/**
 * True when this row should be considered low-stock in UI.
 * SSOT parity with backend:
 * - hard critical: stock_available < 5
 * - percent rule: stock_available <= ceil(target_stock * low_stock_threshold / 100)
 * - excluded statuses: damaged/lost/deleted
 * - disabled when restock_alert_enabled = false
 */
export function isLowStock(item: Partial<InventoryItem>): boolean {
    if (item.restock_alert_enabled === false) return false

    const available = item.stock_available ?? 0
    const st = (item.status || "").toLowerCase()
    if (["damaged", "lost", "deleted"].includes(st)) return false

    const eff = getEffectiveLowStockThreshold(item)
    if (available < 5) return true
    if (eff == null) return false
    return available <= eff
}

/** @deprecated Use getEffectiveLowStockThreshold; kept for any external imports */
export function getLowStockLimit(item: Partial<InventoryItem>): number {
    return getEffectiveLowStockThreshold(item) ?? 10
}

export function getStockStatusLabel(item: Partial<InventoryItem>): 'OUT OF STOCK' | 'LOW STOCK' | 'IN STOCK' {
    const available = item.stock_available || 0

    if (available === 0) return 'OUT OF STOCK'
    if (isLowStock(item)) return 'LOW STOCK'
    return 'IN STOCK'
}
