'use client'

import { useState } from 'react'

/**
 * CATALOG ITEM DIALOG V3 — Thresholds Hook
 * Domain: targetStock, lowStockThreshold, restockAlertEnabled.
 * No cross-domain dependencies.
 */
export function useItemThresholds(item?: any) {
    const [targetStock, setTargetStock] = useState<number | string>(item?.target_stock ?? 0)
    const [lowStockThreshold, setLowStockThreshold] = useState<number | string>(item?.low_stock_threshold ?? 20)
    const [restockAlertEnabled, setRestockAlertEnabled] = useState<boolean>(item?.restock_alert_enabled ?? true)

    return {
        targetStock, setTargetStock,
        lowStockThreshold, setLowStockThreshold,
        restockAlertEnabled, setRestockAlertEnabled,
    }
}

export type ItemThresholdsState = ReturnType<typeof useItemThresholds>
