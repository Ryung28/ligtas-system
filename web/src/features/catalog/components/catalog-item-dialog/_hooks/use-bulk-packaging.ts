'use client'

import { useState, useCallback, useMemo } from 'react'
import type { CatalogPackaging, CatalogBatch, ExpiryMode } from '../types'

/** Collision-resistant ID: timestamp + 6 random chars */
const createId = () => `b_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`

function normalizeBatches(raw: any[], containerType: string, defaultLocationId: string | null): CatalogBatch[] {
    return raw.map((b: any, idx: number) => ({
        id: b?.id || createId(),
        label: b?.label || `${containerType || 'Box'} ${idx + 1}`,
        units: Number(b?.units) || 0,
        locationId: b?.locationId ?? defaultLocationId ?? null,
        expiry_date: b?.expiry_date ?? null,
    }))
}

function initPackaging(item?: any): CatalogPackaging {
    const p = item?.packaging_json
    if (!p) {
        return {
            enabled: false,
            containerType: 'Box',
            containerCount: 0,
            unitsPerContainer: 0,
            defaultLocationId: null,
            batches: [],
            expiry_mode: 'none',
            expiry_groups: [],
        }
    }

    const batches = normalizeBatches(Array.isArray(p.batches) ? p.batches : [], p.containerType, p.defaultLocationId ?? null)

    const seenGroupIds = new Set<string>()
    const groups = Array.isArray(p.expiry_groups)
        ? p.expiry_groups.map((g: any, idx: number) => {
            let gid = g?.id || createId()
            if (seenGroupIds.has(gid)) gid = createId()
            seenGroupIds.add(gid)
            return {
                id: gid,
                label: g?.label || `Group ${idx + 1}`,
                expiry_date: g?.expiry_date || '',
                batch_ids: Array.isArray(g?.batch_ids) ? g.batch_ids : [],
            }
        })
        : []

    return {
        ...p,
        defaultLocationId: p.defaultLocationId ?? null,
        batches,
        expiry_mode: (p.expiry_mode || 'none') as ExpiryMode,
        expiry_groups: groups,
    }
}

/**
 * CATALOG ITEM DIALOG V3 — Bulk Packaging Hook
 * Domain: carton manifest, batch generation, expiry groups.
 * Reads: nothing outside this hook.
 * Writes: only its own packaging state.
 *
 * NOTE: The cross-domain sync (packaging → distributions) is handled
 * by use-packaging-sync.ts to keep this hook pure.
 */
export function useBulkPackaging(item?: any) {
    const [packaging, setPackaging] = useState<CatalogPackaging>(() => initPackaging(item))

    // ─── Core Updater ───────────────────────────────────────────────────────────
    const updatePackaging = useCallback((updates: Partial<CatalogPackaging> & Record<string, any>) => {
        setPackaging(prev => {
            const next = { ...prev, ...updates }

            // Surgical updates for batches when master fields change
            if (
                updates.containerCount !== undefined ||
                updates.unitsPerContainer !== undefined ||
                updates.defaultLocationId !== undefined
            ) {
                const count = Math.max(0, Number(next.containerCount) || 0)
                const upc = Math.max(0, Number(next.unitsPerContainer) || 0)
                const defaultLoc = next.defaultLocationId ?? null
                const isBulkUnitUpdate = updates.unitsPerContainer !== undefined
                const isBulkLocUpdate = updates.defaultLocationId !== undefined

                let nextBatches = [...prev.batches]

                // 1. Handle Count Changes (Push / Slice)
                if (updates.containerCount !== undefined) {
                    if (count > nextBatches.length) {
                        const added = Array.from({ length: count - nextBatches.length }).map((_, i) => ({
                            id: createId(),
                            label: `${next.containerType} ${nextBatches.length + i + 1}`,
                            units: Number(prev.unitsPerContainer || upc),
                            locationId: prev.defaultLocationId ?? defaultLoc,
                            expiry_date: null,
                        }))
                        nextBatches = [...nextBatches, ...added]
                    } else if (count < nextBatches.length) {
                        nextBatches = nextBatches.slice(0, count)
                    }
                }

                // 2. Handle Master Unit/Location Cascades
                if (isBulkUnitUpdate || isBulkLocUpdate) {
                    nextBatches = nextBatches.map(b => ({
                        ...b,
                        units: isBulkUnitUpdate ? upc : b.units,
                        locationId: isBulkLocUpdate ? defaultLoc : b.locationId
                    }))
                }

                next.batches = nextBatches
            }

            // Keep containerCount in sync with actual batch count
            next.containerCount = next.batches.length

            // Prune stale batch IDs from expiry groups
            const batchIdSet = new Set(next.batches.map((b: CatalogBatch) => b.id))
            next.expiry_groups = (next.expiry_groups || [])
                .map(g => ({ ...g, batch_ids: g.batch_ids.filter(id => batchIdSet.has(id)) }))
                .filter(g => g.batch_ids.length > 0 || next.expiry_mode !== 'grouped')

            // Expiry mode transitions
            if (updates.expiry_mode === 'none') {
                next.expiry_groups = []
            }
            if (updates.expiry_mode === 'single') {
                const existingDate = next.expiry_groups?.[0]?.expiry_date || ''
                next.expiry_groups = [{
                    id: next.expiry_groups?.[0]?.id || createId(),
                    label: 'All Cartons',
                    expiry_date: existingDate,
                    batch_ids: next.batches.map((b: CatalogBatch) => b.id),
                }]
            }
            if (updates.expiry_mode === 'per_carton') {
                const byBatch = new Map<string, string>()
                for (const g of next.expiry_groups || []) {
                    for (const batchId of g.batch_ids) byBatch.set(batchId, g.expiry_date || '')
                }
                next.expiry_groups = next.batches.map((b: CatalogBatch, idx: number) => ({
                    id: createId(),
                    label: b.label || `Carton ${idx + 1}`,
                    expiry_date: byBatch.get(b.id) || b.expiry_date || '',
                    batch_ids: [b.id],
                }))
            }

            return next
        })
    }, [])

    // ─── Batch Handlers ─────────────────────────────────────────────────────────
    const updateBatchUnits = useCallback((index: number, val: number) => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches]
            if (nextBatches[index]) {
                nextBatches[index] = { ...nextBatches[index], units: Math.max(0, val) }
            }
            return { ...prev, batches: nextBatches }
        })
    }, [])

    const updateBatchLabel = useCallback((index: number, label: string) => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches]
            if (nextBatches[index]) {
                nextBatches[index] = { ...nextBatches[index], label }
            }
            return { ...prev, batches: nextBatches }
        })
    }, [])

    const updateBatchLocation = useCallback((index: number, locationId: string | null, locationName?: string) => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches]
            if (nextBatches[index]) {
                nextBatches[index] = { ...nextBatches[index], locationId, locationName }
            }
            return { ...prev, batches: nextBatches }
        })
    }, [])

    const updateMultipleBatchLocations = useCallback((indices: number[], locationId: string | null, locationName?: string) => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches]
            indices.forEach(idx => {
                if (nextBatches[idx]) {
                    nextBatches[idx] = { ...nextBatches[idx], locationId, locationName }
                }
            })
            return { ...prev, batches: nextBatches }
        })
    }, [])

    const addExtraBatch = useCallback(() => {
        setPackaging(prev => {
            const nextBatches = [...prev.batches, {
                id: createId(),
                label: `${prev.containerType} ${prev.batches.length + 1}`,
                units: Number(prev.unitsPerContainer) || 0,
                locationId: prev.defaultLocationId ?? null,
                expiry_date: null,
            }]
            return { ...prev, batches: nextBatches, containerCount: nextBatches.length }
        })
    }, [])

    const removeBatch = useCallback((batchId: string) => {
        setPackaging(prev => {
            const nextBatches = prev.batches.filter(b => b.id !== batchId)
            const nextGroups = (prev.expiry_groups || [])
                .map(g => ({ ...g, batch_ids: g.batch_ids.filter(id => id !== batchId) }))
                .filter(g => g.batch_ids.length > 0)

            return {
                ...prev,
                batches: nextBatches,
                containerCount: nextBatches.length,
                expiry_groups: prev.expiry_mode === 'single' && nextBatches.length > 0
                    ? [{
                        id: nextGroups[0]?.id || createId(),
                        label: 'All Cartons',
                        expiry_date: nextGroups[0]?.expiry_date || '',
                        batch_ids: nextBatches.map(b => b.id),
                    }]
                    : nextGroups,
            }
        })
    }, [])

    // ─── Expiry Group Handlers ───────────────────────────────────────────────────
    const addExpiryGroup = useCallback(() => {
        setPackaging(prev => ({
            ...prev,
            expiry_groups: [...(prev.expiry_groups || []), {
                id: createId(),
                label: `Group ${(prev.expiry_groups?.length || 0) + 1}`,
                expiry_date: '',
                batch_ids: [],
            }],
            expiry_mode: prev.expiry_mode === 'none' ? 'grouped' : prev.expiry_mode,
        }))
    }, [])

    const updateExpiryGroup = useCallback((groupId: string, updates: Partial<{ label: string; expiry_date: string; batch_ids: string[] }>) => {
        setPackaging(prev => ({
            ...prev,
            expiry_groups: prev.expiry_groups.map(g => g.id === groupId ? { ...g, ...updates } : g),
        }))
    }, [])

    const removeExpiryGroup = useCallback((groupId: string) => {
        setPackaging(prev => ({
            ...prev,
            expiry_groups: prev.expiry_groups.filter(g => g.id !== groupId),
        }))
    }, [])

    const assignBatchToGroup = useCallback((groupId: string, batchId: string, assigned: boolean) => {
        setPackaging(prev => ({
            ...prev,
            expiry_groups: prev.expiry_groups.map(g => {
                const set = new Set(g.batch_ids)
                if (g.id === groupId) {
                    if (assigned) set.add(batchId)
                    else set.delete(batchId)
                } else if (assigned) {
                    set.delete(batchId)
                }
                return { ...g, batch_ids: Array.from(set) }
            }),
        }))
    }, [])

    const splitExpiryPerCarton = useCallback(() => {
        setPackaging(prev => {
            const byBatch = new Map<string, string>()
            for (const g of prev.expiry_groups || []) {
                for (const batchId of g.batch_ids) {
                    if (g.expiry_date) byBatch.set(batchId, g.expiry_date)
                }
            }

            return {
                ...prev,
                expiry_mode: 'per_carton',
                expiry_groups: prev.batches.map((b, idx) => ({
                    id: createId(),
                    label: b.label || `Carton ${idx + 1}`,
                    expiry_date: byBatch.get(b.id) || b.expiry_date || '',
                    batch_ids: [b.id],
                })),
            }
        })
    }, [])

    // ─── Derived ─────────────────────────────────────────────────────────────────
    /** Calculate the earliest date found in the manifest to sync back to the main identity column. */
    const earliestExpiry = useMemo(() => {
        if (!packaging.enabled) return null
        
        // Collect all possible dates from both batches and groups to be safe
        const batchDates = packaging.batches.map(b => b.expiry_date).filter(Boolean) as string[]
        const groupDates = (packaging.expiry_groups || []).map(g => g.expiry_date).filter(Boolean) as string[]
        
        const allDates = [...batchDates, ...groupDates]
        if (allDates.length === 0) return null

        return allDates.reduce((earliest, current) => (current < earliest ? current : earliest))
    }, [packaging.enabled, packaging.batches, packaging.expiry_groups])

    /** Stable key — only changes when logistics-relevant fields mutate. Consumed by use-packaging-sync. */
    const syncKey = [
        packaging.enabled,
        packaging.defaultLocationId,
        ...packaging.batches.map(b => `${b.id}-${b.units}-${b.locationId}`),
    ].join('|')

    return {
        packaging,
        syncKey,
        earliestExpiry,
        updatePackaging,
        updateBatchUnits,
        updateBatchLabel,
        updateBatchLocation,
        updateMultipleBatchLocations,
        addExtraBatch,
        removeBatch,
        addExpiryGroup,
        updateExpiryGroup,
        removeExpiryGroup,
        assignBatchToGroup,
        splitExpiryPerCarton,
    }
}

export type BulkPackagingState = ReturnType<typeof useBulkPackaging>
