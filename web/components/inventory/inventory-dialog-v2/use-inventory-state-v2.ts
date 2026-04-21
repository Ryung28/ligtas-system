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

    // 4. Planning Thresholds
    const [targetStock, setTargetStock] = useState<number | string>(initialItem?.target_stock ?? 0)
    const [lowStockThreshold, setLowStockThreshold] = useState<number | string>(initialItem?.low_stock_threshold ?? 20)
    const [restockAlertEnabled, setRestockAlertEnabled] = useState<boolean>(initialItem?.restock_alert_enabled ?? true)
    
    // 4.5. Packaging State (Enterprise Mode - Named & Mixed)
    const [packaging, setPackaging] = useState<{
        enabled: boolean;
        containerType: string;
        containerCount: number | string;
        unitsPerContainer: number | string;
        batches: Array<{ id: string, label: string, units: number }>;
    }>(() => {
        const p = initialItem?.packaging_json;
        if (p) return p;
        return {
            enabled: false,
            containerType: 'Box',
            containerCount: 0,
            unitsPerContainer: 0,
            batches: []
        };
    })

    const updatePackaging = (updates: any) => {
        setPackaging(prev => {
            const next = { ...prev, ...updates };
            
            // Auto-generate batches if count/units change and we haven't manually added extra ones
            if (updates.containerCount !== undefined || updates.unitsPerContainer !== undefined) {
                const count = Math.max(0, Number(next.containerCount) || 0);
                const upc = Math.max(0, Number(next.unitsPerContainer) || 0);
                next.batches = Array(count).fill(0).map((_, i) => ({
                    id: Math.random().toString(36).substr(2, 9),
                    label: `${next.containerType} ${i + 1}`,
                    units: upc
                }));
            }
            
            if (next.enabled) {
                const total = next.batches.reduce((sum, b) => sum + b.units, 0);
                updateSiteQty(0, 'qtyGood', total);
            }
            return next;
        });
    }

    const updateBatchUnits = (index: number, val: number) => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches];
            if (nextBatches[index]) {
                nextBatches[index] = { ...nextBatches[index], units: Math.max(0, val) };
            }
            const total = nextBatches.reduce((sum, b) => sum + b.units, 0);
            updateSiteQty(0, 'qtyGood', total);
            return { ...prev, batches: nextBatches };
        });
    }

    const updateBatchLabel = (index: number, label: string) => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches];
            if (nextBatches[index]) {
                nextBatches[index] = { ...nextBatches[index], label };
            }
            return { ...prev, batches: nextBatches };
        });
    }

    const addExtraBatch = () => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches, {
                id: Math.random().toString(36).substr(2, 9),
                label: `Extra ${prev.containerType}`,
                units: 0
            }];
            return { ...prev, batches: nextBatches, containerCount: nextBatches.length };
        });
    }

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
        if (distributions.some(d => d.locationId === location.id)) return
        setDistributions(prev => [
            ...prev,
            {
                locationId: location.id, locationName: location.location_name,
                qtyGood: 0, qtyDamaged: 0, qtyMaintenance: 0, qtyLost: 0
            }
        ])
    }

    const removeDistribution = (index: number) => {
        if (distributions.length <= 1) return
        setDistributions(prev => prev.filter((_, i) => i !== index))
    }

    return {
        name, setName, categoryId, setCategoryId, description, setDescription, itemType, setItemType,
        serialNumber, setSerialNumber, modelNumber, setModelNumber,
        brand, setBrand, expiryDate, setExpiryDate, expiryAlertDays, setExpiryAlertDays,
        targetStock, setTargetStock, lowStockThreshold, setLowStockThreshold,
        restockAlertEnabled, setRestockAlertEnabled,
        packaging, updatePackaging, updateBatchUnits, updateBatchLabel, addExtraBatch,
        distributions, updateSiteQty, totals,
        addDistribution, removeDistribution
    }
}
