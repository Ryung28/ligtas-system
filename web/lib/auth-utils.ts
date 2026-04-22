import type { User } from '@supabase/supabase-js'
import type { SupabaseClient } from '@supabase/supabase-js'

// ============================================================================
// ResQTrack AUTH UTILS
// 🛡️ Unified Identity Resolution — Single source of truth for the
//    "authorized_emails whitelist fallback" logic, shared by both
//    auth.ts (client) and auth-server.ts (server).
// ============================================================================

export interface ResolvedUserStatus {
    role: string
    status: string
}

/**
 * resolveUserStatus
 *
 * Accepts a raw Supabase `User` object and the fetched `user_profiles` row.
 * If the profile is already active, returns as-is.
 * If not, performs a whitelist check against `authorized_emails` and promotes
 * the user to active if a match is found.
 *
 * 🛡️ DRY: This is the SINGLE AUTHORITATIVE implementation. Auth.ts and
 * auth-server.ts both delegate to this function.
 */
export async function resolveUserStatus(
    supabase: SupabaseClient,
    user: User,
    profile: Record<string, unknown> | null,
): Promise<ResolvedUserStatus> {
    let role: string = (profile?.role as string) ?? 'viewer'
    let status: string = (profile?.status as string) ?? 'pending'

    // Fast-path: Active privileged users skip the whitelist check
    if (status === 'active' && (role === 'admin' || role === 'editor')) {
        return { role, status }
    }

    // Whitelist Fallback: Check authorized_emails for runtime promotion
    if (status !== 'active') {
        const { data: whitelist } = await supabase
            .from('authorized_emails')
            .select('role')
            .eq('email', user.email?.toLowerCase() ?? '')
            .maybeSingle()

        if (whitelist) {
            role = whitelist.role as string
            status = 'active'
            console.log(`[Auth-Utils] Runtime promotion for ${user.email} → ${role}`)
        }
    }

    return { role, status }
}
