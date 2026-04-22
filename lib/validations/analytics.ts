import { z } from 'zod'

/**
 * 🛰️ TRENDING ITEM SCHEMA: TACTICAL ASSET ANALYTICS
 */
export const TrendingItemSchema = z.object({
  inventoryId: z.union([z.string(), z.number()]),
  itemName: z.string(),
  category: z.string(),
  borrowCount: z.number().default(0),
  warehouseId: z.string().nullable().optional(),
  lastBorrowedAt: z.string().nullable().optional(),
})

export type TrendingItem = z.infer<typeof TrendingItemSchema>
