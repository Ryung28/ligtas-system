'use server'

import { z } from 'zod'
import { createSupabaseServer } from '@/lib/supabase-server'
import { revalidatePath } from 'next/cache'

// ============================================================================
// LIGTAS NOTIFICATION SERVER ACTIONS
// 🛡️ All mutations flow through here. NEVER call RPCs directly from client
//    components. Uses Zod for type-safe input validation.
// ============================================================================

// ── Input Schemas ─────────────────────────────────────────────────────────────

const RestockInputSchema = z.object({
    itemId: z.union([z.string().min(1), z.number()], { message: 'A valid inventory item identifier is required.' }),
    quantity: z.number().int().positive({ message: 'Quantity must be a positive integer.' }),
})

const ApproveUserInputSchema = z.object({
    userId: z.string().uuid({ message: 'A valid user UUID is required.' }),
    role: z.enum(['admin', 'editor', 'viewer'], {
        errorMap: () => ({ message: 'Role must be one of: admin, editor, viewer.' }),
    }),
})

// ── Return Type ───────────────────────────────────────────────────────────────

interface ActionResult {
    success: boolean
    message: string
    errors?: Record<string, string[]>
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION 1: RESTOCK INVENTORY
// 🛡️ The Vault: Calls increment_inventory RPC with validated, typed inputs.
// ─────────────────────────────────────────────────────────────────────────────

export async function restockInventoryAction(
    itemId: string | number,
    quantity: number,
): Promise<ActionResult> {
    try {
        // 1. VALIDATION GATE (The Steel Cage)
        const parsed = RestockInputSchema.safeParse({ itemId, quantity })
        if (!parsed.success) {
            return {
                success: false,
                message: 'Validation failed. Please check your inputs.',
                errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
            }
        }

        // 2. AUTH-AWARE SERVER CLIENT
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) {
            return { success: false, message: 'Unauthorized. Please log in.' }
        }

        // 3. RPC EXECUTION (Server-Only)
        const { error } = await supabase.rpc('increment_inventory', {
            item_id: parsed.data.itemId,
            count: parsed.data.quantity,
        })

        if (error) {
            console.error('[Action:restockInventory] DB Error:', error.message)
            return { success: false, message: error.message }
        }

        // 🛡️ REVALIDATION GATE: Force Next.js to purge stale UI cache
        revalidatePath('/')

        return { success: true, message: `Successfully added ${parsed.data.quantity} units.` }
    } catch (error: any) {
        console.error('[Action:restockInventory] Critical Failure:', error.message)
        return { success: false, message: 'Logistics synchronization failure.' }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION 2: APPROVE USER ACCESS
// 🛡️ The Vault: Calls approve_user RPC with validated, typed inputs.
// ─────────────────────────────────────────────────────────────────────────────

export async function approveUserAction(
    userId: string,
    role: 'admin' | 'editor' | 'viewer',
): Promise<ActionResult> {
    try {
        // 1. VALIDATION GATE (The Steel Cage)
        const parsed = ApproveUserInputSchema.safeParse({ userId, role })
        if (!parsed.success) {
            return {
                success: false,
                message: 'Validation failed. Please check your inputs.',
                errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
            }
        }

        // 2. AUTH-AWARE SERVER CLIENT
        const supabase = await createSupabaseServer()
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) {
            return { success: false, message: 'Unauthorized. Please log in.' }
        }

        // 3. RPC EXECUTION (Server-Only)
        const { error } = await supabase.rpc('approve_user', {
            target_user_id: parsed.data.userId,
            target_role: parsed.data.role,
        })

        if (error) {
            console.error('[Action:approveUser] DB Error:', error.message)
            return { success: false, message: error.message }
        }

        // 🛡️ REVALIDATION GATE: Force Next.js to purge stale UI cache
        revalidatePath('/')

        return { success: true, message: `User granted ${parsed.data.role} access.` }
    } catch (error: any) {
        console.error('[Action:approveUser] Critical Failure:', error.message)
        return { success: false, message: 'Identity synchronization failure.' }
    }
}
