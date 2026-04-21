import { z } from 'zod'

/**
 * CATALOG DOMAIN - Validation Schemas
 * 
 * These schemas define the shape and validation rules for inventory items.
 * They are used by both server actions and can be reused in client-side forms.
 */

export const addItemSchema = z.object({
    name: z.string().min(2, 'Item name must be at least 2 characters'),
    description: z.string().optional().nullable(),
    category: z.string().min(1, 'Please select a category'),
    stock_total: z.coerce.number().min(0, 'Total stock cannot be negative'),
    stock_available: z.coerce.number().min(0, 'Current stock cannot be negative'),
    status: z.string().default('Good'),
    image_url: z.string().optional().nullable(),
    serial_number: z.string().optional().nullable(),
    equipment_type: z.string().optional().nullable(),
    item_type: z.enum(['equipment', 'consumable']).default('equipment'),
    storage_location: z.string().optional().nullable(),
    location_id: z.coerce.number().optional().nullable(),
    brand: z.string().optional().nullable(),
    model_number: z.string().optional().nullable(),
    expiry_date: z.string().optional().nullable(),
    expiry_alert_days: z.coerce.number().int().positive().optional().nullable(),
    parent_id: z.coerce.number().optional().nullable(),
    variant_label: z.string().optional().nullable(),
    target_stock: z.coerce.number().min(0).optional().default(0),
    low_stock_threshold: z.coerce.number().min(0).max(100).optional().default(20),
    // Enterprise Status Buckets
    qty_good: z.coerce.number().min(0).default(0),
    qty_damaged: z.coerce.number().min(0).default(0),
    qty_maintenance: z.coerce.number().min(0).default(0),
    qty_lost: z.coerce.number().min(0).default(0),
})

export type AddItemInput = z.infer<typeof addItemSchema>

export const siteDistributionSchema = z.object({
    id: z.coerce.number().optional().nullable(),
    locationId: z.coerce.number().optional().nullable(),
    locationName: z.string().min(1, 'Location name is required'),
    qtyGood: z.coerce.number().min(0, 'Quantity cannot be negative'),
    qtyDamaged: z.coerce.number().min(0),
    qtyMaintenance: z.coerce.number().min(0),
    qtyLost: z.coerce.number().min(0),
})

export type SiteDistributionInput = z.infer<typeof siteDistributionSchema>
