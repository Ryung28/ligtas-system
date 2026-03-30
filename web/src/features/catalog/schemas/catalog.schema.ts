import { z } from 'zod'

/**
 * CATALOG DOMAIN - Validation Schemas
 * 
 * These schemas define the shape and validation rules for inventory items.
 * They are used by both server actions and can be reused in client-side forms.
 */

export const addItemSchema = z.object({
    name: z.string().min(2, 'Item name must be at least 2 characters'),
    description: z.string().optional(),
    category: z.string().min(1, 'Please select a category'),
    stock_total: z.coerce.number().min(1, 'Fixed total stock must be at least 1'),
    stock_available: z.coerce.number().min(0, 'Current stock cannot be negative'),
    status: z.string().default('Good'),
    image_url: z.string().optional().nullable(),
    serial_number: z.string().optional().nullable(),
    equipment_type: z.string().optional().nullable(),
    item_type: z.enum(['equipment', 'consumable']).default('equipment'),
    storage_location: z.string().min(1, 'Storage location is required').default('lower_warehouse'),
    brand: z.string().optional().nullable(),
    expiry_date: z.string().optional().nullable(),
    parent_id: z.coerce.number().optional().nullable(),
    variant_label: z.string().optional().nullable(),
    low_stock_threshold: z.coerce.number().min(0).max(100).default(20),
})

export type AddItemInput = z.infer<typeof addItemSchema>
