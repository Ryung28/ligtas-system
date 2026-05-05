'use client'

import { useState, useCallback, useMemo } from 'react'
import type { CatalogDistribution, CatalogTotals, StorageLocation } from '../types'

/**
 * CATALOG ITEM DIALOG V3 — Site Logistics Hook
 * Domain: multi-site distribution matrix + computed totals.
 * Reads: nothing outside this hook.
 * Writes: only its own distributions state.
 *
 * NOTE: The packaging sync (packaging → distributions) is handled
 * by use-packaging-sync.ts — NOT here.
 */
export function useSiteLogistics(item?: any) {
    const [distributions, setDistributions] = useState<CatalogDistribution[]>(() => {
        if (!item) {
            // 🏛️ INITIAL STATE: Start with one empty row to act as a placeholder.
            return [{
                locationId: null,
                locationName: '',
                qtyGood: 0,
                qtyDamaged: 0,
                qtyMaintenance: 0,
                qtyLost: 0,
                _isMaster: false,
            }]
        }

        const master: CatalogDistribution = {
            id: item?.id,
            locationId: item?.location_registry_id || item?.location_id || null,
            locationName: item?.storage_location || '',
            qtyGood: item?.qty_good ?? 0,
            qtyDamaged: item?.qty_damaged ?? 0,
            qtyMaintenance: item?.qty_maintenance ?? 0,
            qtyLost: item?.qty_lost ?? 0,
            _isMaster: true,
        }

        const variants: CatalogDistribution[] = (item?.variants || []).map((v: any) => ({
            id: v.id,
            locationId: v.location_id,
            locationName: v.location || v.location_name || '',
            qtyGood: v.qty_good ?? 0,
            qtyDamaged: v.qty_damaged ?? 0,
            qtyMaintenance: v.qty_maintenance ?? 0,
            qtyLost: v.qty_lost ?? 0,
        }))

        return [master, ...variants.filter(v => 
            String(v.locationId) !== String(master.locationId)
        )]
    })

    const totals = useMemo<CatalogTotals>(() => ({
        qtyGood: distributions.reduce((s, d) => s + (Number(d.qtyGood) || 0), 0),
        qtyDamaged: distributions.reduce((s, d) => s + (Number(d.qtyDamaged) || 0), 0),
        qtyMaintenance: distributions.reduce((s, d) => s + (Number(d.qtyMaintenance) || 0), 0),
        qtyLost: distributions.reduce((s, d) => s + (Number(d.qtyLost) || 0), 0),
        total: distributions.reduce(
            (s, d) =>
                s + (Number(d.qtyGood) || 0) + (Number(d.qtyDamaged) || 0) +
                (Number(d.qtyMaintenance) || 0) + (Number(d.qtyLost) || 0),
            0
        ),
    }), [distributions])

    const updateSiteQty = useCallback((index: number, bucket: string, val: number | string) => {
        setDistributions(prev => {
            const next = [...prev]
            if (!next[index]) return prev
            next[index] = { ...next[index], [bucket]: val === '' ? '' : Number(val) }
            return next
        })
    }, [])

    const addDistribution = useCallback((location: StorageLocation) => {
        setDistributions(prev => {
            const exists = prev.some(d => String(d.locationId) === String(location.id));
            if (exists) return prev;

            // Find if there's an empty placeholder row (initial state)
            const placeholderIndex = prev.findIndex(d => d.locationId === null);

            if (placeholderIndex !== -1) {
                // CONSUME PLACEHOLDER: The very first location becomes the silent master
                const updated = [...prev];
                updated[placeholderIndex] = {
                    ...updated[placeholderIndex],
                    locationId: location.id,
                    locationName: location.location_name,
                    _isMaster: true // Silently promote to master
                };
                return updated;
            }

            // Normal add for non-first locations
            const hasMaster = prev.some(d => d._isMaster);
            return [...prev, {
                locationId: location.id,
                locationName: location.location_name,
                qtyGood: 0, qtyDamaged: 0, qtyMaintenance: 0, qtyLost: 0,
                _isMaster: !hasMaster
            }];
        });
    }, [])

    const removeDistribution = useCallback((index: number) => {
        setDistributions(prev => {
            if (prev.length <= 1) {
                // 🏛️ RESET TO EMPTY: Instead of deleting last row, clear it to keep placeholder.
                return [{
                    locationId: null,
                    locationName: '',
                    qtyGood: 0, qtyDamaged: 0, qtyMaintenance: 0, qtyLost: 0,
                    _isMaster: false
                }]
            }
            // 🛡️ Prevent deleting the master row
            if (prev[index]?._isMaster) return prev
            return prev.filter((_, i) => i !== index)
        })
    }, [])

    const setMaster = useCallback((index: number) => {
        setDistributions(prev => {
            return prev.map((d, i) => ({
                ...d,
                _isMaster: i === index
            }))
        })
    }, [])

    return {
        distributions,
        setDistributions,
        totals,
        updateSiteQty,
        addDistribution,
        removeDistribution,
        setMaster,
    }
}

export type SiteLogisticsState = ReturnType<typeof useSiteLogistics>
