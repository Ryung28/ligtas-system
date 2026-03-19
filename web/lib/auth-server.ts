import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import { resolveUserStatus } from '@/lib/auth-utils'

// ── Senior Dev: Server-Side Authentication Helper ──
// Use in Server Components (page.tsx, layout.tsx) for cookie-aware auth.

export async function getCurrentUserServer() {
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
        const { data: { user }, error } = await supabase.auth.getUser()
        if (error || !user) return null

        const { data: profile } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle()

        // 🛡️ Unified resolution — no duplicated whitelist logic here
        const { role, status } = await resolveUserStatus(supabase, user, profile)

        return { ...user, ...profile, role, status }
    } catch (error) {
        console.error('Get user server error:', error)
        return null
    }
}
