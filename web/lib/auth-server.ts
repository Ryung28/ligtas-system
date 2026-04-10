import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { cache } from 'react'
import { resolveUserStatus } from '@/lib/auth-utils'

/**
 * 🏛️ Identity Singleton Engine (getCachedUser)
 * 🛡️ SUPER SENIOR PROTOCOL: Explicit DTO (Data Transfer Object)
 * We strictly extract only serializable primitives (strings/numbers/bools).
 * This prevents "Only plain objects can be passed to Client Components" errors
 * caused by Supabase internal class prototypes.
 */
export const getCachedUser = cache(async () => {
    const cookieStore = await cookies()

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                get(name: string) {
                    return cookieStore.get(name)?.value
                },
            },
        }
    )

    try {
        const { data: { user }, error: userError } = await supabase.auth.getUser()
        if (userError || !user) return null

        const { data: profile } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle()

        const { role, status } = await resolveUserStatus(supabase, user, profile)

        // 🛡️ DTO: Explicitly map fields to ensure plain-object serialization
        return { 
            id: user.id,
            email: user.email ?? '',
            role: role,
            status: status,
            full_name: profile?.full_name ?? user.user_metadata?.full_name ?? 'Responder',
            avatar_url: profile?.avatar_url ?? user.user_metadata?.avatar_url ?? null,
            phone: user.phone ?? '',
            last_sign_in_at: user.last_sign_in_at ?? null,
            created_at: user.created_at ?? null,
        }
    } catch (error) {
        console.error(' [Auth Cache Error]:', error)
        return null
    }
})

// Legacy Alias
export const getCurrentUserServer = getCachedUser
