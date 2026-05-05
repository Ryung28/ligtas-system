/**
 * CATALOG ITEM DIALOG V3 — Shared Types
 * Single source of truth for all domain hook interfaces.
 */

export interface CatalogBatch {
  id: string
  label: string
  units: number
  locationId: string | null
  locationName?: string | null
  expiry_date: string | null
}

export interface CatalogExpiryGroup {
  id: string
  label: string
  expiry_date: string
  batch_ids: string[]
}

export type ExpiryMode = 'none' | 'single' | 'grouped' | 'per_carton'

export interface CatalogPackaging {
  enabled: boolean
  containerType: string
  containerCount: number | string
  unitsPerContainer: number | string
  defaultLocationId: string | null
  batches: CatalogBatch[]
  expiry_mode: ExpiryMode
  expiry_groups: CatalogExpiryGroup[]
}

export interface CatalogDistribution {
  id?: number
  locationId: string | number | null
  locationName: string
  qtyGood: number | string
  qtyDamaged: number | string
  qtyMaintenance: number | string
  qtyLost: number | string
  _isMaster?: boolean
  _bulkManaged?: boolean
}

export interface CatalogTotals {
  qtyGood: number
  qtyDamaged: number
  qtyMaintenance: number
  qtyLost: number
  total: number
}

export interface PolicyErrors {
  ready: string
  target: string
  threshold: string
}

export interface StorageLocation {
  id: string | number
  location_name: string
}
