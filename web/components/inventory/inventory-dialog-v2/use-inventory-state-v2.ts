"use client"

import { useState, useMemo, useEffect } from 'react'

/**
 * ResQTrack V2 STATE HOOK (ULTIMATE PARITY)
 * Handles Identity, Variant, Health, Consumable Metadata, and Logistics.
 */
export function useInventoryStateV2(initialItem?: any) {
    const createId = () => Math.random().toString(36).slice(2, 11)
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
        batches: Array<{ id: string, label: string, units: number, expiry_date?: string | null }>;
        expiry_mode: 'none' | 'single' | 'grouped' | 'per_carton';
        expiry_groups: Array<{ id: string; label: string; expiry_date: string; batch_ids: string[] }>;
    }>(() => {
        const p = initialItem?.packaging_json;
        if (p) {
            const normalizedBatches = Array.isArray(p.batches)
                ? p.batches.map((b: any, idx: number) => ({
                    id: b?.id || createId(),
                    label: b?.label || `${p.containerType || 'Box'} ${idx + 1}`,
                    units: Number(b?.units) || 0,
                    expiry_date: b?.expiry_date ?? null,
                }))
                : []

            const normalizedGroups = Array.isArray(p.expiry_groups)
                ? p.expiry_groups.map((g: any, idx: number) => ({
                    id: g?.id || createId(),
                    label: g?.label || `Group ${idx + 1}`,
                    expiry_date: g?.expiry_date || '',
                    batch_ids: Array.isArray(g?.batch_ids) ? g.batch_ids : [],
                }))
                : []

            const mode = (p.expiry_mode || 'none') as 'none' | 'single' | 'grouped' | 'per_carton'

            return {
                ...p,
                batches: normalizedBatches,
                expiry_mode: mode,
                expiry_groups: normalizedGroups,
            }
        }
        return {
            enabled: false,
            containerType: 'Box',
            containerCount: 0,
            unitsPerContainer: 0,
            batches: [],
            expiry_mode: 'none',
            expiry_groups: [],
        };
    })

    const updatePackaging = (updates: any) => {
        setPackaging(prev => {
            const next = { ...prev, ...updates };
            
            // Auto-generate batches if count/units change
            if (updates.containerCount !== undefined || updates.unitsPerContainer !== undefined) {
                const count = Math.max(0, Number(next.containerCount) || 0);
                const upc = Math.max(0, Number(next.unitsPerContainer) || 0);
                next.batches = Array(count).fill(0).map((_, i) => {
                    const existing = prev.batches[i]
                    return {
                        id: existing?.id || createId(),
                        label: existing?.label || `${next.containerType} ${i + 1}`,
                        units: existing ? existing.units : upc,
                        expiry_date: existing?.expiry_date ?? null,
                    }
                });
            }

            // Keep groups synchronized to current batch ids.
            const batchIdSet = new Set(next.batches.map((b: any) => b.id))
            next.expiry_groups = (next.expiry_groups || [])
                .map((g: any) => ({
                    ...g,
                    batch_ids: (g.batch_ids || []).filter((id: string) => batchIdSet.has(id)),
                }))
                .filter((g: any) => g.batch_ids.length > 0 || next.expiry_mode !== 'grouped')

            if (updates.expiry_mode === 'none') {
                next.expiry_groups = []
            }
            if (updates.expiry_mode === 'single') {
                const existingDate = next.expiry_groups?.[0]?.expiry_date || ''
                next.expiry_groups = [{
                    id: next.expiry_groups?.[0]?.id || createId(),
                    label: 'All Cartons',
                    expiry_date: existingDate,
                    batch_ids: next.batches.map((b: any) => b.id),
                }]
            }
            if (updates.expiry_mode === 'per_carton') {
                const byBatch = new Map<string, string>()
                for (const g of next.expiry_groups || []) {
                    for (const batchId of g.batch_ids || []) byBatch.set(batchId, g.expiry_date || '')
                }
                next.expiry_groups = next.batches.map((b: any, idx: number) => ({
                    id: createId(),
                    label: b.label || `Carton ${idx + 1}`,
                    expiry_date: byBatch.get(b.id) || b.expiry_date || '',
                    batch_ids: [b.id],
                }))
            }
            return next;
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

    // 🔄 SYNC ENGINE: Packaging -> Distributions
    // Ensures Bulk Mode totals are atomically synced to the primary distribution
    // This solves the issue where consumable stock updates failed to persist due to stale state.
    useEffect(() => {
        if (packaging.enabled) {
            const total = packaging.batches.reduce((sum, b) => sum + (Number(b.units) || 0), 0)
            setDistributions(prev => {
                if (prev.length === 0) return prev
                if (prev[0].qtyGood === total) return prev
                const next = [...prev]
                next[0] = { ...next[0], qtyGood: total }
                return next
            })
        }
    }, [packaging.enabled, packaging.batches])

    const updateBatchUnits = (index: number, val: number) => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches];
            if (nextBatches[index]) {
                nextBatches[index] = { ...nextBatches[index], units: Math.max(0, val) };
            }
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
                id: createId(),
                label: `Extra ${prev.containerType}`,
                units: 0,
                expiry_date: null,
            }];
            return { ...prev, batches: nextBatches, containerCount: nextBatches.length };
        });
    }

    const removeBatch = (batchId: string) => {
        setPackaging(prev => {
            const nextBatches = prev.batches.filter(b => b.id !== batchId)
            const nextGroups = (prev.expiry_groups || [])
                .map(g => ({ ...g, batch_ids: (g.batch_ids || []).filter(id => id !== batchId) }))
                .filter(g => g.batch_ids.length > 0)

            const mode = prev.expiry_mode === 'single' && nextBatches.length > 0
                ? 'single'
                : prev.expiry_mode

            return {
                ...prev,
                batches: nextBatches,
                containerCount: nextBatches.length,
                expiry_groups: mode === 'single' && nextBatches.length > 0
                    ? [{
                        id: nextGroups[0]?.id || createId(),
                        label: 'All Cartons',
                        expiry_date: nextGroups[0]?.expiry_date || '',
                        batch_ids: nextBatches.map(b => b.id),
                    }]
                    : nextGroups,
            }
        })
    }

    const addExpiryGroup = () => {
        setPackaging(prev => {
            const nextGroups = [...(prev.expiry_groups || []), {
                id: createId(),
                label: `Group ${(prev.expiry_groups?.length || 0) + 1}`,
                expiry_date: '',
                batch_ids: [],
            }]
            return { ...prev, expiry_groups: nextGroups, expiry_mode: prev.expiry_mode === 'none' ? 'grouped' : prev.expiry_mode }
        })
    }

    const updateExpiryGroup = (groupId: string, updates: Partial<{ label: string; expiry_date: string; batch_ids: string[] }>) => {
        setPackaging(prev => ({
            ...prev,
            expiry_groups: (prev.expiry_groups || []).map(g => g.id === groupId ? { ...g, ...updates } : g),
        }))
    }

    const removeExpiryGroup = (groupId: string) => {
        setPackaging(prev => ({
            ...prev,
            expiry_groups: (prev.expiry_groups || []).filter(g => g.id !== groupId),
        }))
    }

    const assignBatchToGroup = (groupId: string, batchId: string, assigned: boolean) => {
        setPackaging(prev => {
            const nextGroups = (prev.expiry_groups || []).map(g => {
                const set = new Set(g.batch_ids || [])
                if (g.id === groupId) {
                    if (assigned) set.add(batchId)
                    else set.delete(batchId)
                } else if (assigned) {
                    set.delete(batchId)
                }
                return { ...g, batch_ids: Array.from(set) }
            })
            return { ...prev, expiry_groups: nextGroups }
        })
    }

    const splitExpiryPerCarton = () => {
        setPackaging(prev => ({
            ...prev,
            expiry_mode: 'per_carton',
            expiry_groups: prev.batches.map((b, idx) => ({
                id: createId(),
                label: b.label || `Carton ${idx + 1}`,
                expiry_date: b.expiry_date || '',
                batch_ids: [b.id],
            })),
        }))
    }

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
        setDistributions(prev => {
            const next = [...prev]
            if (!next[index]) return prev
            next[index] = { ...next[index], [bucket]: val === '' ? '' : Number(val) }
            return next
        })
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
        packaging, updatePackaging, updateBatchUnits, updateBatchLabel, addExtraBatch, removeBatch,
        addExpiryGroup, updateExpiryGroup, removeExpiryGroup, assignBatchToGroup, splitExpiryPerCarton,
        distributions, updateSiteQty, totals,
        addDistribution, removeDistribution
    }
}
