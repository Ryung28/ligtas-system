'use client'

import { useEffect } from 'react'
import type { StorageLocation, CatalogPackaging, CatalogDistribution } from '../types'
import type { BulkPackagingState } from './use-bulk-packaging'
import type { SiteLogisticsState } from './use-site-logistics'

/**
 * CATALOG ITEM DIALOG V3 — Packaging Sync Hook
 *
 * ONE-WAY BRIDGE: packaging → distributions.
 * This is the ONLY place the two domains communicate.
 *
 * Rules:
 * - Reads packaging state (via syncKey + packaging).
 * - Writes to distributions (via setDistributions).
 * - NEVER reads distributions back. No feedback loop.
 * - Does NOT trigger updatePackaging. No circular dependency.
 */
export function usePackagingSync(
    packaging: CatalogPackaging,
    syncKey: string,
    setDistributions: React.Dispatch<React.SetStateAction<CatalogDistribution[]>>,
    locations: any[]
) {
    useEffect(() => {
        if (!packaging.enabled) return

        setDistributions(prev => {
            // STEP 1: Strict Reset — If bulk is enabled, the manifest is the sole authority.
            // We zero out all site counts to prevent "ghost stacking" from master rows.
            let next = prev.map(d => ({
                ...d,
                qtyGood: 0,
                _bulkManaged: true,
            }))

            // STEP 2: Aggregate manifest units by location
            const byLocation = new Map<string | null, number>()
            packaging.batches.forEach(batch => {
                const locId = batch.locationId ?? packaging.defaultLocationId ?? null
                const units = Number(batch.units) || 0
                const current = byLocation.get(locId) || 0
                byLocation.set(locId, current + units)
            })

            // STEP 3: Map manifest to distributions
            for (const [locId, units] of byLocation.entries()) {
                let existingIdx = next.findIndex(d => 
                    (locId === null && (d as any)._isMaster) || 
                    (String(d.locationId) === String(locId))
                )

                const resolvedName = locations.find(l => String(l.id) === String(locId))?.location_name
                
                // 🛡️ LOADING GUARD: If we have no registry data yet, don't fallback to ID strings.
                // This prevents "25" from leaking into the database as a name.
                const nameToUse = resolvedName || (locations.length > 0 ? String(locId || 'Unknown Site') : null)

                if (existingIdx !== -1) {
                    const existing = next[existingIdx]
                    const currentName = existing.locationName
                    const isGeneric = !currentName || currentName === 'Unknown Site' || /^\d+$/.test(currentName)

                    next[existingIdx] = {
                        ...existing,
                        qtyGood: units,
                        _bulkManaged: true,
                        ...(nameToUse && isGeneric ? { locationName: nameToUse } : {})
                    }
                } else {
                    // New location discovered — only push if we can resolve a valid name or if registry is loaded
                    if (nameToUse) {
                        next.push({
                            locationId: locId,
                            locationName: nameToUse,
                            qtyGood: units,
                            qtyDamaged: 0,
                            qtyMaintenance: 0,
                            qtyLost: 0,
                            _bulkManaged: true,
                        } as any)
                    }
                }
            }

            // ... rest of the logic ...

            // STEP 4: Safety Master — If we have locations but none is marked as master,
            // we auto-promote the first one. This is critical for new items being 
            // initialized via bulk manifests.
            if (next.length > 0 && !next.some(d => (d as any)._isMaster)) {
                (next[0] as any)._isMaster = true
            }

            // STEP 5: Ghost Pruner — remove non-master rows that were left with 0 units 
            // after the sync (e.g., a location was removed from all boxes).
            next = next.filter(d => {
                const total = (Number(d.qtyGood) || 0) + (Number(d.qtyDamaged) || 0) + 
                            (Number(d.qtyMaintenance) || 0) + (Number(d.qtyLost) || 0)
                
                // Always keep the master row (usually the Parent record)
                if ((d as any)._isMaster) return true
                
                // 🛡️ AUTO-PRUNE: If stock is 0, let it be deleted from the database
                return total > 0
            })

            // STEP 5: Equality Check (PREVENT FOCUS LOSS)
            // If the math hasn't structurally changed the array or values, don't update state.
            const hasChanged = next.length !== prev.length || next.some((d, i) => {
                const p = prev[i]
                return d.locationId !== p.locationId || 
                       d.locationName !== p.locationName || 
                       d.qtyGood !== p.qtyGood || 
                       (d as any)._bulkManaged !== (p as any)._bulkManaged
            })
            
            return hasChanged ? next : prev
        })
    }, [syncKey, packaging.enabled, setDistributions, locations])
}
