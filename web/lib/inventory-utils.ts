import { InventoryItem } from "./supabase"

/**
 * Effective low-stock threshold in units — matches `system_intel` (NULLIF 0 → default 10).
 */
export function getEffectiveLowStockThreshold(item: Partial<InventoryItem>): number {
    const raw = item.low_stock_threshold
    return raw != null && raw > 0 ? raw : 10
}

/**
 * True when this row would appear in `system_intel` as an INVENTORY / stock_low alert.
 * SSOT: stock_available < 5 OR stock_available <= effective threshold; excludes bad statuses.
 */
export function isLowStock(item: Partial<InventoryItem>): boolean {
    if (item.restock_alert_enabled === false) return false

    const available = item.stock_available ?? 0
    const st = (item.status || "").toLowerCase()
    if (["damaged", "lost", "deleted"].includes(st)) return false

    const eff = getEffectiveLowStockThreshold(item)
    return available < 5 || available <= eff
}

/** @deprecated Use getEffectiveLowStockThreshold; kept for any external imports */
export function getLowStockLimit(item: Partial<InventoryItem>): number {
    return getEffectiveLowStockThreshold(item)
}

export function getStockStatusLabel(item: Partial<InventoryItem>): 'OUT OF STOCK' | 'LOW STOCK' | 'IN STOCK' {
    const available = item.stock_available || 0

    if (available === 0) return 'OUT OF STOCK'
    if (isLowStock(item)) return 'LOW STOCK'
    return 'IN STOCK'
}
