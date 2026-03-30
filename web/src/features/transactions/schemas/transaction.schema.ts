import { z } from 'zod'

/**
 * TRANSACTIONS DOMAIN - Validation Schemas
 * 
 * These schemas define the shape and validation rules for borrow/return transactions.
 * They enforce business rules like Philippine mobile number format.
 */

export const borrowItemSchema = z.object({
    borrower_name: z.string().min(1, 'Borrower name is required'),
    contact_number: z
        .string()
        .regex(/^09\d{9}$/, 'Invalid Philippine mobile number (must be 09XXXXXXXXX)'),
    office_department: z.string().optional().nullable(),
    item_id: z.coerce.number().min(1, 'Please select an item'),
    quantity: z.coerce.number().min(1, 'Quantity must be at least 1'),
    purpose: z.string().optional(),
    expected_return_date: z.string().optional().nullable(),
})

export const batchBorrowSchema = z.object({
    borrower_name: z.string().min(1, 'Borrower name is required'),
    contact_number: z
        .string()
        .regex(/^09\d{9}$/, 'Invalid Philippine mobile number (must be 09XXXXXXXXX)'),
    office_department: z.string().optional().nullable(),
    purpose: z.string().optional(),
    expected_return_date: z.string().optional().nullable(),
    items: z.array(z.object({
        item_id: z.number().min(1),
        quantity: z.number().min(1),
        item_type: z.enum(['equipment', 'consumable']).default('equipment'),
    })).min(1, 'At least one item is required'),
})

export type BorrowItemInput = z.infer<typeof borrowItemSchema>
export type BatchBorrowInput = z.infer<typeof batchBorrowSchema>
