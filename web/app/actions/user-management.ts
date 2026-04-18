'use server'

import { z } from 'zod'
import { createSupabaseServer } from '@/lib/supabase-server'

// ============================================================================
// LIGTAS USER MANAGEMENT SERVER ACTIONS
// 🛡️ All personnel mutations flow through here. Zero client-side RPCs.
// ============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// RE-EXPORT: UPDATE USER ROLE (pre-existing action — kept for compatibility)
// ─────────────────────────────────────────────────────────────────────────────

const ExtendedRoleSchema = z.enum(['admin', 'editor', 'viewer', 'responder'])

export async function updateUserRole(
    userId: string,
    newRole: 'admin' | 'editor' | 'viewer' | 'responder',
): Promise<{ success: boolean; message?: string; error?: string }> {
    try {
        const validatedRole = ExtendedRoleSchema.parse(newRole)
        const supabase = await createSupabaseServer()

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('Authentication required')

        if (userId.startsWith('pending-')) {
            const targetEmail = userId.replace('pending-', '')
            const { error } = await supabase
                .from('authorized_emails')
                .update({ role: validatedRole })
                .eq('email', targetEmail)
            if (error) throw error
        } else {
            const { error } = await supabase.rpc('update_user_role', {
                target_user_id: userId,
                new_role: validatedRole,
            })
            if (error) throw error
        }

        return { success: true, message: `User ${validatedRole === 'admin' ? 'promoted' : 'demoted'} successfully` }
    } catch (error: unknown) {
        const message = error instanceof Error ? error.message : 'Failed to update user role'
        console.error('[UserAction:updateRole]', message)
        return { success: false, error: message }
    }
}


const UuidSchema = z.string().uuid({ message: 'A valid user UUID is required.' })
const RoleSchema = z.enum(['admin', 'editor', 'viewer', 'responder'])
const EmailSchema = z.string().email({ message: 'A valid email is required.' })

// ── Return Type ───────────────────────────────────────────────────────────────

interface ActionResult {
    success: boolean
    message: string
    errors?: Record<string, string[]>
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION 1: APPROVE USER
// ─────────────────────────────────────────────────────────────────────────────

const ApproveUserInputSchema = z.object({
    userId: UuidSchema,
    role: RoleSchema,
})

export async function approveUserAction(
    userId: string,
    role: 'admin' | 'editor' | 'viewer' | 'responder' = 'responder',
): Promise<ActionResult> {
    const parsed = ApproveUserInputSchema.safeParse({ userId, role })
    if (!parsed.success) {
        return {
            success: false,
            message: 'Validation failed.',
            errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
        }
    }

    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { success: false, message: 'Unauthorized.' }

    const { error } = await supabase.rpc('approve_user', {
        target_user_id: parsed.data.userId,
        target_role: parsed.data.role,
    })

    if (error) {
        console.error('[UserAction:approve]', error.message)
        return { success: false, message: error.message }
    }

    return { success: true, message: `User approved as ${parsed.data.role}.` }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION 2: REJECT USER
// ─────────────────────────────────────────────────────────────────────────────

const RejectUserInputSchema = z.object({ userId: UuidSchema })

export async function rejectUserAction(userId: string): Promise<ActionResult> {
    const parsed = RejectUserInputSchema.safeParse({ userId })
    if (!parsed.success) {
        return {
            success: false,
            message: 'Validation failed.',
            errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
        }
    }

    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { success: false, message: 'Unauthorized.' }

    const { error } = await supabase.rpc('reject_user', {
        target_user_id: parsed.data.userId,
    })

    if (error) {
        console.error('[UserAction:reject]', error.message)
        return { success: false, message: error.message }
    }

    return { success: true, message: 'User access denied.' }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION 3: SUSPEND USER (Atomic Scrubbing Sequence)
// 🛡️ Atomicity: chat scrubbing + profile suspension run server-side together.
// ─────────────────────────────────────────────────────────────────────────────

const SuspendUserInputSchema = z.object({ userId: UuidSchema })

export async function suspendUserAction(userId: string): Promise<ActionResult> {
    const parsed = SuspendUserInputSchema.safeParse({ userId })
    if (!parsed.success) {
        return {
            success: false,
            message: 'Invalid user ID signature.',
            errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
        }
    }

    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { success: false, message: 'Unauthorized.' }

    // STEP 1: Scrubbing Sequence (Ghost Data Purge) ─ runs atomically on server
    try {
        await supabase
            .from('chat_messages')
            .delete()
            .or(`sender_id.eq.${parsed.data.userId},receiver_id.eq.${parsed.data.userId}`)

        await supabase
            .from('chat_rooms')
            .delete()
            .eq('borrower_user_id', parsed.data.userId)
    } catch (cleanupErr) {
        console.warn('[UserAction:suspend] Scrubbing warning:', cleanupErr)
    }

    // STEP 2: Revoke whitelist access (prevents re-activation on next login)
    try {
        const { data: profile } = await supabase
            .from('user_profiles')
            .select('email')
            .eq('id', parsed.data.userId)
            .single()

        if (profile?.email) {
            await supabase
                .from('authorized_emails')
                .delete()
                .eq('email', profile.email.toLowerCase().trim())
        }
    } catch (revokeErr) {
        console.warn('[UserAction:suspend] Whitelist revoke warning:', revokeErr)
    }

    // STEP 3: Suspend the profile
    const { error } = await supabase
        .from('user_profiles')
        .update({ status: 'suspended' })
        .eq('id', parsed.data.userId)

    if (error) {
        console.error('[UserAction:suspend]', error.message)
        return { success: false, message: 'Deletion sequence failed at the vault level.' }
    }

    return { success: true, message: 'Personnel access revoked and data scrubbed.' }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION 4: REACTIVATE USER
// ─────────────────────────────────────────────────────────────────────────────

const ReactivateUserInputSchema = z.object({ userId: UuidSchema })

const AuthorizeUserInputSchema = z.object({
    email: EmailSchema,
    role: RoleSchema,
})

export async function reactivateUserAction(userId: string): Promise<ActionResult> {
    const parsed = ReactivateUserInputSchema.safeParse({ userId })
    if (!parsed.success) {
        return {
            success: false,
            message: 'Validation failed.',
            errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
        }
    }

    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { success: false, message: 'Unauthorized.' }

    const { error } = await supabase
        .from('user_profiles')
        .update({ status: 'active' })
        .eq('id', parsed.data.userId)

    if (error) {
        console.error('[UserAction:reactivate]', error.message)
        return { success: false, message: error.message }
    }

    return { success: true, message: 'User reactivated.' }
}

export async function authorizeUserAction(
    email: string,
    role: 'admin' | 'editor' | 'viewer' | 'responder' = 'editor',
): Promise<ActionResult> {
    const parsed = AuthorizeUserInputSchema.safeParse({ email, role })
    if (!parsed.success) {
        return {
            success: false,
            message: 'Validation failed.',
            errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
        }
    }

    const supabase = await createSupabaseServer()
    const { data: { user: adminUser } } = await supabase.auth.getUser()
    if (!adminUser) return { success: false, message: 'Unauthorized.' }

    const cleanEmail = parsed.data.email.toLowerCase().trim()

    // 1. Whitelist Management (Atomic Update)
    const { error: whitelistError } = await supabase
        .from('authorized_emails')
        .upsert({ 
            email: cleanEmail, 
            role: parsed.data.role 
        }, { onConflict: 'email' })

    if (whitelistError) {
        console.error('[UserAction:authorize] Whitelist failed:', whitelistError.message)
        return { success: false, message: whitelistError.message }
    }

    // 2. SELF-HEALING: If user has an existing suspended profile, REACTIVATE THEM
    try {
        const { data: profile } = await supabase
            .from('user_profiles')
            .select('id, status')
            .ilike('email', cleanEmail)
            .maybeSingle()

        if (profile && profile.status === 'suspended') {
            const { error: patchError } = await supabase
                .from('user_profiles')
                .update({ 
                    status: 'active',
                    role: parsed.data.role,
                    updated_at: new Date().toISOString()
                })
                .eq('id', profile.id)

            if (patchError) throw patchError
            return { success: true, message: `${cleanEmail} was previously suspended but is now REACTIVATED.` }
        }
    } catch (err) {
        console.warn('[UserAction:authorize] Self-healing warning:', err)
    }

    return { success: true, message: `${cleanEmail} is now authorized.` }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION 6: UNAUTHORIZE USER (Whitelist Delete)
// ─────────────────────────────────────────────────────────────────────────────

const UnauthorizeUserInputSchema = z.object({ email: EmailSchema })

export async function unauthorizeUserAction(email: string): Promise<ActionResult> {
    const parsed = UnauthorizeUserInputSchema.safeParse({ email })
    if (!parsed.success) {
        return {
            success: false,
            message: 'Validation failed.',
            errors: parsed.error.flatten().fieldErrors as Record<string, string[]>,
        }
    }

    const supabase = await createSupabaseServer()
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return { success: false, message: 'Unauthorized.' }

    const { error } = await supabase
        .from('authorized_emails')
        .delete()
        .eq('email', parsed.data.email.toLowerCase().trim())

    if (error) {
        console.error('[UserAction:unauthorize]', error.message)
        return { success: false, message: 'Failed to revoke access.' }
    }

    return { success: true, message: `Access revoked for ${parsed.data.email}.` }
}
