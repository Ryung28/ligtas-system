"use client"

import { useState, useMemo } from 'react'

/**
 * LIGTAS V2 STATE HOOK (ULTIMATE PARITY)
 * Handles Identity, Variant, Health, Consumable Metadata, and Logistics.
 */
export function useInventoryStateV2(initialItem?: any) {
    // 1. Identity & Classification
    const [name, setName] = useState(initialItem?.item_name || '')
    const [categoryId, setCategoryId] = useState(initialItem?.category || '')
    const [description, setDescription] = useState(initialItem?.description || '')
    const [itemType, setItemType] = useState(initialItem?.item_type || 'equipment')
    const [serialNumber, setSerialNumber] = useState(initialItem?.serial_number || '')
    const [modelNumber, setModelNumber] = useState(initialItem?.model_number || '')
    
    // 2. Consumable Meta
    const [brand, setBrand] = useState(initialItem?.brand || '')
    const [expiryDate, setExpiryDate] = useState(initialItem?.expiry_date ? new Date(initialItem.expiry_date).toISOString().split('T')[0] : '')
    const [expiryAlertDays, setExpiryAlertDays] = useState<number | string>(initialItem?.expiry_alert_days ?? 15)

    // Variation State has been permanently REMOVED to maintain flat-hierarchy parity with Mobile Tactical Terminal.

    // 4. Planning Thresholds
    const [targetStock, setTargetStock] = useState<number | string>(initialItem?.target_stock ?? 0)
    const [lowStockThreshold, setLowStockThreshold] = useState<number | string>(initialItem?.low_stock_threshold ?? 20)
    const [restockAlertEnabled, setRestockAlertEnabled] = useState<boolean>(initialItem?.restock_alert_enabled ?? true)

    // 5. Logistics Distribution Matrix
    const [distributions, setDistributions] = useState<any[]>(() => {
        const variants = initialItem?.variants || []
        if (variants.length > 0) {
            return variants.map((v: any) => ({
                id: v.id, locationId: v.location_id, locationName: v.location || v.location_name,
                qtyGood: v.qty_good ?? 0, qtyDamaged: v.qty_damaged ?? 0,
                qtyMaintenance: v.qty_maintenance ?? 0, qtyLost: v.qty_lost ?? 0
            }))
        }
        return [{
            id: initialItem?.id,
            locationId: initialItem?.location_registry_id || initialItem?.location_id || (initialItem ? null : 10),
            locationName: initialItem?.storage_location || 'lower_warehouse',
            qtyGood: initialItem?.qty_good || 0, qtyDamaged: initialItem?.qty_damaged || 0,
            qtyMaintenance: initialItem?.qty_maintenance || 0, qtyLost: initialItem?.qty_lost || 0
        }]
    })

    // 6. Computed Balancer
    const totals = useMemo(() => ({
        qtyGood: distributions.reduce((s, d) => s + (Number(d.qtyGood) || 0), 0),
        qtyDamaged: distributions.reduce((s, d) => s + (Number(d.qtyDamaged) || 0), 0),
        qtyMaintenance: distributions.reduce((s, d) => s + (Number(d.qtyMaintenance) || 0), 0),
        qtyLost: distributions.reduce((s, d) => s + (Number(d.qtyLost) || 0), 0),
        total: distributions.reduce((s, d) => 
            s + (Number(d.qtyGood) || 0) + (Number(d.qtyDamaged) || 0) + 
            (Number(d.qtyMaintenance) || 0) + (Number(d.qtyLost) || 0), 0)
    }), [distributions])

    // Handlers
    const updateSiteQty = (index: number, bucket: string, val: number | string) => {
        const next = [...distributions]
        next[index] = { ...next[index], [bucket]: val === '' ? '' : Number(val) }
        setDistributions(next)
    }

    const addDistribution = (location: any) => {
        // Prevent duplicate locations
        if (distributions.some(d => d.locationId === location.id)) return
        setDistributions(prev => [
            ...prev,
            {
                locationId: location.id,
                locationName: location.location_name,
                qtyGood: 0,
                qtyDamaged: 0,
                qtyMaintenance: 0,
                qtyLost: 0
            }
        ])
    }

    const removeDistribution = (index: number) => {
        if (distributions.length <= 1) return // Keep at least one
        setDistributions(prev => prev.filter((_, i) => i !== index))
    }

    return {
        name, setName, categoryId, setCategoryId, description, setDescription, itemType, setItemType,
        serialNumber, setSerialNumber, modelNumber, setModelNumber,
        brand, setBrand, expiryDate, setExpiryDate, expiryAlertDays, setExpiryAlertDays,
        targetStock, setTargetStock, lowStockThreshold, setLowStockThreshold,
        restockAlertEnabled, setRestockAlertEnabled,
        distributions, updateSiteQty, totals,
        addDistribution, removeDistribution
    }
}
